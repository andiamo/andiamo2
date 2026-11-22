# Arquitectura del código — Andiamo 2

Este documento describe la arquitectura interna de **Andiamo 2** (Processing 4.x / `P2D`), cómo se resuelven la mecánica de bucles y secuencias sincronizadas, cómo funciona el sistema extensible de pinceles y UI, y qué consideraciones tener en cuenta al agregar pinceles o portar el motor a **p5.js / Trazos.club**.

---

## 1. Evolución desde Andiamo 1

En la primera versión de [Andiamo](../../andiamo/andiamo.pde), cada `Stroke` almacenaba directamente los vértices (`StrokeQuad`) generados por el algoritmo de cinta B-spline (`Ribbons.pde`). Esa arquitectura tenía dos limitaciones estructurales:

1. **Acoplamiento entre tiempo y geometría:** el pincel spline estaba incrustado dentro de la clase `Stroke`, lo que impedía crear otros estilos visuales que compartieran el mismo sistema de grabación y bucle temporal.
2. **Trazos independientes:** cada pincelada tenía su propia lógica de desvanecimiento basada en `fadeOutFact` por cuadro (`frameRate`), lo cual dificultaba agrupar trazos sucesivos preservando con precisión las pausas temporales entre ellos.

**Andiamo 2** resuelve ambos problemas separando las responsabilidades en capas limpias:

* **`Toque` y `Trazo` (`Trazos.pde`):** registran la entrada cruda del usuario con marcas de tiempo absolutas en milisegundos (`millis()`) y gestionan la línea temporal de reproducción/desvanecimiento.
* **`Pincel` (`Pinceles.pde`):** es una interfaz/clase abstracta pura de renderizado que recibe un arreglo `Toque[]` (el prefijo activo en el instante actual) junto con un color (con alfa ya modulado) y un factor de escala.
* **Secuencias unidas (`unirTrazos`):** permite que múltiples pinceladas sigan acumulándose dentro del mismo `Trazo` (marcando los límites de sub-trazo con `Toque.primero` y `Toque.ultimo`), conservando los tiempos muertos reales entre gestos en un único reloj maestro.

---

## 2. Mapa de archivos

| Archivo | Responsabilidad principal |
| :--- | :--- |
| [`andiamo2.pde`](../andiamo2.pde) | Punto de entrada de Processing (`settings`, `setup`, `draw`) y despacho de eventos de mouse/teclado entre `Interface` y `Estado`. |
| [`Parametros.pde`](../Parametros.pde) | Constantes globales de ventana (`PANTALLA_COMPLETA`, `PANTALLA_ANCHO`, `PANTALLA_ALTO`, `PANTALLA_INDICE`) y límites de memoria (`MAX_TRAZOS`, `MAX_TOQUES`). |
| [`Estado.pde`](../Estado.pde) | Estado global de la aplicación, máquina de grabación de trazos, atajos de teclado y sincronización entre lógica y widgets de UI. |
| [`Trazos.pde`](../Trazos.pde) | Clases `Trazo` y `Toque`; algoritmo de bucle temporal, búsqueda binaria de cuadros y ciclo de vida de borrado. |
| [`Capas.pde`](../Capas.pde) | `CapaDibujo` (9 capas con opacidad animada y lista de trazos) y `LienzoFondo` (fondo con transición interpolada). |
| [`Colores.pde`](../Colores.pde) | Clase `Tinta` y carga de paletas predefinidas (`tintasFondo` y `tintasPincel`). |
| [`Interpolacion.pde`](../Interpolacion.pde) | `NumeroInterpolado`: filtro resorte-amortiguador para transiciones suaves en parámetros y opacidades de capa. |
| [`Pinceles.pde`](../Pinceles.pde) | Clase abstracta `Pincel`, registro de pinceles (`cargarPinceles`), integración con la UI y 7 pinceles incluidos. |
| [`PincelAndiamo.pde`](../PincelAndiamo.pde) | Implementación de `PincelAndiamo` (cinta B-spline clásica con `BSpline` y `StrokeQuad`). |
| [`PincelYellowTail.pde`](../PincelYellowTail.pde) | Implementación de `PincelYellowTail` (algoritmo cinético de Golan Levin adaptado a `Toque[]`). |
| [`Interface.pde`](../Interface.pde) | Gestor del árbol de widgets (`Interface`), captura de arrastre (`activeWidget`), foco por hover y tooltips. |
| [`Widget.pde`](../Widget.pde) | Clase base `Widget` con jerarquía padre-hijo, coordenadas relativas/absolutas y callbacks por reflexión Java. |
| [`UI.pde`](../UI.pde) | Construcción de la barra de herramientas, widgets concretos (`ColorSelector`, `ValueSlider`, `UIToggleHotspot`, `HelpOverlay`, etc.) y callbacks globales. |

---

## 3. Ciclo de ejecución y flujo de eventos

```
setup()
 ├── cargarPinceles()      -> instancia prototipos de los 9 pinceles en `pinceles`
 ├── cargarColores()       -> llena `tintasFondo` y `tintasPincel`
 ├── crearCapas()          -> crea 9 instancias de `CapaDibujo` (índice 1..9)
 ├── lienzo = new LienzoFondo()
 ├── estado = new Estado()
 └── createUI()            -> arma `intf` (oculta inicialmente)

draw()  (cada cuadro)
 ├── estado.actualizar()   -> avanza interpolaciones de parámetros globales
 ├── lienzo.pintar()       -> dibuja fondo (con `lerpColor` si está cambiando)
 ├── pintarCapas()         -> recorre capas de atrás (8) hacia adelante (0):
 │     ├── capa.pintar()   -> actualiza opacidad, dibuja trazos y limpia removidos
 │     └── si es capa seleccionada y `registrandoTrazo`, dibuja `estado.nuevoTrazo`
 └── intf.update()         -> actualiza y dibuja la UI encima del lienzo
```

### Despacho de eventos de mouse

`andiamo2.pde` delega primero en `intf`:

* **`mouseMoved()`:** llama a `intf.mouseMoved()` para actualizar el widget bajo el cursor (`focused`) y mostrar su tooltip.
* **`mousePressed()`:** si un widget visible tiene el foco (`intf.mousePressed()` devuelve `true`), `Interface` guarda ese widget en `activeWidget` y no inicia un trazo en el lienzo. Caso contrario, llama a `estado.iniciarTrazo()`.
* **`mouseDragged()`:** si `activeWidget != null`, envía `drag()` al widget capturado incluso si el puntero salió de su caja; si no, llama a `estado.actualizarTrazo()`.
* **`mouseReleased()`:** si `activeWidget != null`, envía `release()` al widget y libera la captura; si no, llama a `estado.terminarTrazo()`.

---

## 4. Modelo temporal: `Toque` y `Trazo`

### Estructura de `Toque`

Cada muestra de entrada capturada durante un trazo almacena:

* `x`, `y`: posición del puntero en píxeles.
* `p`: pseudo-presión derivada de la distancia euclidiana respecto al cuadro anterior (`sqrt((x - px)² + (y - py)²)`).
* `t`: marca de tiempo absoluta (`millis()`).
* `primero`: `true` en el primer toque de cada pincelada (clave cuando se unen múltiples trazos).
* `ultimo`: `true` en el último toque de una pincelada cerrada.

### Ciclo de vida de un `Trazo`

1. **Creación (`Estado.iniciarTrazo()`):**
   * Si `!registrandoTrazo`, crea un nuevo `Trazo` clonando el prototipo del pincel activo mediante `pinceles.get(pincelSeleccionado).nuevoPincel()`, y fija en el trazo una copia de los valores actuales de `tinta`, `factorOpacidad`, `factorEscala`, `repetir` y `tiempoComienzo = millis()`.
   * Agrega el primer `Toque` con `primero = true`.
2. **Grabación (`Estado.actualizarTrazo()`):**
   * Agrega toques sucesivos hasta `MAX_TOQUES` (1000).
   * Actualiza `tiempoFinal = toque.t`.
3. **Cierre (`Trazo.cerrate(boolean unico)`):**
   * Se ejecuta al soltar el mouse (si `unirTrazos == false`) o al desactivar `unirTrazos` (o cambiar de capa/pincel).
   * Fija `duracionBorrado = int(estado.tiempoBorradoTrazos.valor)`.
   * Marca el último toque real con `ultimo = true` y fija `tiempoBorrado = ultimoToque.t`.
   * Agrega un **`fakeToque`** sintético en `t = ultimoToque.t + duracionBorrado` para extender la línea temporal del trazo durante la fase de desvanecimiento.
   * Si `unico == true` (modo *1 vez*), marca `removiendo = true` con `tiempoInicioRemocion = -1` (auto-borrado al completar el ciclo).

### Reproducción y búsqueda binaria (`Trazo.dibujate()`)

En cada cuadro:

```
|<---------- dibujo original ---------->|<---- desvanecimiento ---->|
t = 0                              (tiempoBorrado - t0)      (tiempoFinal - t0)
     factorBorrado = 1.0                 1.0 ───────────────> 0.0
```

* **Tiempo relativo en bucle:**
  ```java
  int duracionCiclo = max(1, tiempoFinal - tiempoComienzo + 1);
  int t = (millis() - tiempoComienzo) % duracionCiclo;
  ```
* **`buscarIndice(t)`:** realiza una búsqueda binaria (`O(log n)`) sobre `toques` para encontrar el último `Toque` cuyo tiempo relativo `toque.t - tiempoComienzo <= t`.
* **Corte de lista:** toma el subarreglo `toques[0 .. indice]` y lo pasa a `pincel.pintar(atoques, colorConAlfa, factorEscala)`.
* **Desvanecimiento:**
  * En **bucle / auto-borrado (`1 vez`)**: cuando `t >= tiempoBorrado - tiempoComienzo`, `factorBorrado` decrece linealmente de `1` a `0` sobre `duracionBorrado` (salvo que `pincel.animarOpacidad == false` en modo repetir, como ocurre con `PincelYellowTail`).
  * En **borrado manual (`Trazo.remover()`)**: se registra `tiempoInicioRemocion = millis()` en el momento de presionar borrar, haciendo que el trazo se desvanezca de inmediato en `min(duracionBorrado, 800)` ms sin esperar a que termine el ciclo actual, tanto en trazos en bucle como en trazos fijos.

---

## 5. Capas, colores e interpolación

### `CapaDibujo` y `LienzoFondo` (`Capas.pde`)

* `pintarCapas()` recorre `capas` del índice `8` al `0`, de modo que la **Capa 1 (`indice 0`)** queda dibujada por encima de todas las demás.
* El trazo en grabación (`estado.nuevoTrazo`) se dibuja inmediatamente después de los trazos cerrados de `capaSeleccionada`, heredando la opacidad de esa capa.
* Si una capa tiene `opacidad.valor < 0.01`, `pintar()` retorna sin dibujar ni actualizar trazos (oculta la capa conservando su contenido).
* `LienzoFondo` interpola entre `tintaPrevia` y `tintaActual` mediante `lerpColor` durante `estado.tiempoTransicionFondo.valor` ms, y apaga `cambiando = false` al finalizar.

### `NumeroInterpolado` (`Interpolacion.pde`)

Todos los parámetros continuos (`tiempoBorradoTrazos`, `tiempoTransicionFondo`, `factorOpacidadTrazos`, `factorEscalaTrazos` y la opacidad de cada `CapaDibujo`) usan `NumeroInterpolado`:

* Sistema masa-resorte discreto con `atraccion = 0.1`, `atenuacion = 0.5` y `umbral = 0.01`.
* Permite que cambios abruptos por teclado, sliders o mostrar/ocultar capas se sientan orgánicos y suaves.

---

## 6. Arquitectura de pinceles (`Pincel`)

### Contrato base

```java
abstract class Pincel {
  String nombre = "";
  String descripcion = "";
  char[] teclas;
  int indice;
  boolean animarOpacidad;

  abstract Pincel nuevoPincel();
  abstract void pintar(Toque[] toques, color tinta, float escala);
}
```

* **Patrón prototipo (`nuevoPincel()`):** cada pincel en la lista global `pinceles` actúa como plantilla; cuando el usuario inicia un trazo, `nuevoPincel()` crea una instancia fresca para ese `Trazo` particular, permitiendo que el pincel guarde estado interno propio por trazo (por ejemplo, `offset` aleatorio en `PincelCirculo`, o las geometrías cacheadas en `PincelAndiamo` y `PincelYellowTail`).
* **Aislamiento de estilo:** `Trazo.dibujate()` envuelve la llamada a `pintar(...)` entre `pushStyle()` y `popStyle()`, por lo que un pincel puede modificar `fill`, `stroke`, `strokeWeight`, `rectMode`, `strokeCap`, etc. sin afectar a otros trazos ni a la UI.
* **Compatibilidad con `Unir`:** al recibir un arreglo `Toque[]`, cualquier pincel que respete `toque.primero` y `toque.ultimo` (como `PincelLinea`, `PincelCinta`, `PincelAbanico`, `PincelRectangulos` o `PincelAndiamo`) soporta automáticamente secuencias unidas con saltos entre sub-trazos sin conectar líneas fantasma entre el final de un trazo y el inicio del siguiente.

### Pinceles con estado incremental

* **`PincelAndiamo` (`PincelAndiamo.pde`):**
  * Mantiene dos splines cúbicas (`lspline`, `rspline`) y genera cuadriláteros (`StrokeQuad`) incrementalmente a medida que crece `toques.length`, guardando en `quadCount` cuántos quads corresponden a cada índice de `Toque`.
  * En cada cuadro, simplemente dibuja los primeros `quadCount.get(toques.length - 1)` quads modulando su alfa por `alpha(tinta) / 255`. Esto evita recalcular B-splines en cada cuadro del bucle.
  * *Nota:* por esa caché incremental, `escala` y el color base quedan horneados en el `StrokeQuad` al momento de procesarse el toque.
* **`PincelYellowTail` (`PincelYellowTail.pde`):**
  * Adapta el clásico *Yellowtail* de Golan Levin: procesa puntos en `path[]` hasta que aparece `toque.ultimo` (`closed = true`), momento en el cual `advanceGesture()` desplaza los puntos cíclicamente en cada cuadro y recompila los polígonos (`polygons[]`), con envolvimiento toroidal en los bordes de la pantalla (`crosses[]`).
  * Fija `animarOpacidad = false` para no atenuar el alfa durante la repetición continua.

### Cómo agregar un nuevo pincel

1. Creá una subclase de `Pincel` (en `Pinceles.pde` o en un nuevo archivo `.pde`):
   * Asigná `nombre` y `descripcion` en el constructor.
   * Implementá `nuevoPincel()` devolviendo una nueva instancia con los mismos `indice` y `teclas`.
   * Implementá `pintar(Toque[] toques, color tinta, float escala)` respetando `toque.primero` / `toque.ultimo` si el pincel conecta puntos consecutivos.
2. Registralo en `cargarPinceles()` dentro de `Pinceles.pde` con el siguiente índice entero y un arreglo de teclas libres.
3. La barra de interfaz (`agregarPincelesAlInterface`) genera los botones dinámicamente a partir de `pinceles.size()`, por lo que aparecerá automáticamente en la UI (verificá el ancho disponible si superás los 9 pinceles).

---

## 7. Sistema de UI (`Interface`, `Widget`, `UI.pde`)

* **`Interface`:** administra el árbol de widgets a partir de `root` y mantiene la lista `drawn` en orden de pintado.
  * El hit-testing (`setFocused`) recorre `drawn` en orden inverso (de adelante hacia atrás).
  * `activeWidget` implementa **captura de arrastre**: mientras el botón del mouse esté presionado sobre un slider o selector de color, todos los eventos `drag()` y `release()` siguen llegando a ese widget aunque el puntero salga de su rectángulo.
* **Callbacks por reflexión:** `Widget.runCallback()` invoca métodos públicos del sketch (`PApplet`) por nombre (`String callback`) pasando el `name` del widget (`Method.invoke(p, name)`).
* **Ocultamiento total:** `UIToggleHotspot` (`0, 0, 30, 30`) no dibuja nada cuando `estado.mostrarUI == false`, pero sigue activo en el árbol de widgets para detectar clics en la esquina superior izquierda.

---

## 8. Notas para portar Andiamo 2 a p5.js / Trazos.club

Al migrar este motor a JavaScript (`trazos-svelte`), los puntos clave de diseño a conservar son:

1. **Serialización ligera en red:** a diferencia de Andiamo 1 (que enviaba geometría/quads o dependía de un único algoritmo), aquí la fuente de verdad de un trazo es únicamente su lista de toques `{ x, y, p, t, primero, ultimo }`, su `pincelId`, `tinta`, `opacidad`, `escala`, `duracionBorrado` y modo (`repetir` / `unico`). Todos los clientes pueden reproducir exactamente el mismo pincel y sincronización a partir de esos datos.
2. **Reloj relativo:** en entornos colaborativos en red conviene expresar `Toque.t` como **tiempo relativo desde `tiempoComienzo`** (`dt = performance.now() - t0`) para evitar desfasajes entre relojes de distintos clientes.
3. **Pinceles puros:** mantener `pintar(toques, tinta, escala)` como función determinista sobre el prefijo `toques[0..idx]` permite portar o generar nuevos pinceles en p5.js de forma modular y segura.
