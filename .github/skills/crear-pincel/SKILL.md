---
name: crear-pincel
description: Guía paso a paso para diseñar, implementar, registrar y verificar un nuevo pincel (subclase de Pincel) en Andiamo 2, pensada para artistas, educadores y colaboradores con o sin experiencia en programación. Úsala cuando el usuario quiera crear, prototipar o agregar un nuevo pincel en andiamo2.
---

# Crear un nuevo pincel en Andiamo 2

Esta skill guía la creación completa de un pincel en **Andiamo 2** (Processing 4.x / `P2D`), desde una idea artística en lenguaje cotidiano hasta un archivo `.pde` compilado y probado contra todos los modos de bucle.

---

## Paso 1: Entender qué quiere el usuario (entrevista breve y accesible)

Si el usuario todavía no especificó el comportamiento exacto (por ejemplo: *"quiero un pincel tipo burbujas"* o *"un pincel expresivo como tiza"*), hacele **pocas preguntas claras y sin jerga técnica** antes de escribir código (usando `ask_user` si está disponible, o en un mensaje conciso):

1. **Nombre corto y tecla:** ¿Cómo querés que se llame el botón (máx. 8–10 letras, ej. `"Tiza"`, `"Burbujas"`)? Sugerir una tecla libre (`B`, `C`, `J`, `K`, `L`, `P`, `V`), o dejarlo sin tecla si ya no quedan letras cómodas (la barra pagina automáticamente a partir de 10 pinceles).
2. **Comportamiento del trazo:**
   * ¿Se dibuja **toda la estela** que recorriste o **solo la punta** en movimiento?
   * ¿El grosor o tamaño reacciona a la **velocidad** de tu mano?
   * ¿Querés variación orgánica (temblor, partículas, tamaño cambiante) o líneas geométricas limpias?
3. **Al soltar / en bucle:** ¿Sigue el ritmo exacto y se desvanece normalmente (`animarOpacidad = true`), o tiene vida propia continua tras soltar (como `YellowTail`)?

Si el usuario ya dio suficiente detalle, proponé valores sensatos por defecto y avanzá directamente al diseño.

---

## Paso 2: Elegir el arquetipo adecuado

Revisá los ejemplos existentes en `Pinceles.pde`, `PincelAndiamo.pde` y `PincelYellowTail.pde` para elegir la arquitectura más simple que logre el efecto:

| Arquetipo | Referencia en el repo | Cuándo usarlo |
| :--- | :--- | :--- |
| **Estela completa sin estado extra** | `PincelLinea`, `PincelCinta`, `PincelAbanico` | Cintas, líneas caligráficas, polígonos o conexiones entre `toques` que se dibujan rápido recorriendo el arreglo. |
| **Punta móvil / Cometa** | `PincelChispa`, `PincelCirculo`, `PincelCuadrados` | Formas u objetos que siguen el extremo actual `toques[toques.length - 1]` (o los últimos N toques). |
| **Geometría cacheada incremental** | `PincelAndiamo` | Curvas o mallas costosas (B-splines, triangulaciones) que conviene calcular una sola vez conforme crece `toques.length`. |
| **Simulación / Partículas con estado** | `PincelYellowTail` | Trazos cuya geometría sigue evolucionando después de `toque.ultimo`, o sistemas de partículas deterministas/por toque. |

---

## Paso 3: Reglas técnicas obligatorias (invariantes de `Trazo` y `Toque`)

Verificá cada una de estas reglas al escribir la clase:

1. **Archivo propio:** creá `Pincel<NombrePascalCase>.pde` en la raíz de `andiamo2/` (por ejemplo `PincelBurbujas.pde`). No metas pinceles nuevos dentro de `Pinceles.pde`.
2. **Metadatos y prototipo:**
   * En el constructor `Pincel<Nombre>(int indice, char[] teclas)`, llamá a `super(indice, teclas);` y definí `nombre` (corto, para el botón) y `descripcion` (en español, para el tooltip).
   * Implementá `Pincel nuevoPincel()` devolviendo `new Pincel<Nombre>(indice, teclas)`. **Nunca** devuelvas `this`. Todo estado por trazo (`offset`, listas, caches) debe inicializarse nuevo en cada instancia.
3. **Renderizado cuadro a cuadro sin parpadeo:**
   * `pintar(Toque[] toques, color tinta, float escala)` se ejecuta en cada `draw()` luego de que `LienzoFondo.pintar()` borra toda la pantalla.
   * **Nunca** llames `random()` sin semilla fija dentro de `pintar()`, porque cambiará 60 veces por segundo causando parpadeo. Si necesitás aleatoriedad por toque:
     * calculá una función hash determinista a partir del índice/coordenadas del toque, **o**
     * guardá los atributos aleatorios por toque en una `ArrayList` interna que solo agrega elementos cuando `miCache.size() < toques.length`.
4. **Respetar `tinta` (incluyendo su canal alfa):**
   * `tinta` ya trae multiplicada la opacidad de la capa, del trazo y el fundido de `Borrado`.
   * Usá `fill(tinta)` / `stroke(tinta)`. Si necesitás crear un color derivado, usá `color(red(tinta), green(tinta), blue(tinta), alpha(tinta) * factor)`. Nunca pongas alfa fijo `255` salvo que `animarOpacidad = false` sea intencional.
5. **Respetar `escala`:**
   * Multiplicá tamaños, radios y grosores por `escala`. Contemplá que `escala` puede valer `0.0` (en ese caso `Trazo.dibujate()` ya retorna temprano, pero igual evitá divisiones por `escala`).
6. **Compatibilidad con `Unir` (`toque.primero` y `toque.ultimo`):**
   * Con `Unir` activo, `toques` puede contener varios trazos separados en el tiempo.
   * Siempre verificá `if (toque.primero)` para **cortar** líneas/formas (`endShape()`, reiniciar `ptoque`) y **nunca** dibujar una línea recta conectando el final de un sub-trazo con el comienzo del siguiente.
7. **Proteger casos borde (`toques.length == 1` y `fakeToque`):**
   * Al cerrar un trazo, `Trazo.cerrate()` agrega un `fakeToque` al final con el mismo `(x, y)` que el último toque real.
   * Antes de calcular normales o ángulos (`dx`, `dy`, `d2 = sqrt(sq(dx) + sq(dy))`), verificá `distintos(ptoque, toque)` y `0.001 < d2` para evitar `NaN`.
   * Si el usuario hace un solo clic sin arrastrar (`toques.length == 1`), dibujá un punto/marca o salí limpiamente sin `IndexOutOfBoundsException`.
8. **Balancear matrices y formas:**
   * Si usás `pushMatrix()` / `popMatrix()` o `beginShape()` / `endShape()`, garantizá que cada apertura tenga su cierre correspondiente en todos los caminos de ejecución.

---

## Paso 4: Registrar el pincel en `Pinceles.pde` y cuidar la UI

1. En `cargarPinceles()` dentro de `Pinceles.pde`, agregá el pincel con su índice consecutivo y arreglo de teclas (`{'X', 'x'}`):
   ```java
   pinceles.add(new PincelMiPincel(indice, new char[]{'K', 'k'}));
   ```
2. **Chequeo de colisión de teclas:** confirmá que la tecla elegida no esté usada en `Pinceles.pde`, `Colores.pde` (`A S D F G`, `Z X`) ni `Estado.pde` (`H`, `M`, `N`). Teclas recomendadas libres: `B`, `C`, `J`, `K`, `L`, `P`, `V`.
3. **Comportamiento en la barra de herramientas (10+ pinceles):**
   * En `Pinceles.pde`, `agregarPincelesAlInterface()` muestra los 9 pinceles en una sola fila cuando `pinceles.size() <= 9`, y activa automáticamente paginación de 8 pinceles por página con controles `< 1/2 >` cuando hay 10 o más pinceles (cambiando de página automáticamente al usar un atajo de teclado). No hace falta modificar `UI.pde` al sumar nuevos pinceles.

---

## Paso 5: Compilar y verificar antes de entregar

1. Ejecutá la compilación con Processing CLI (si está disponible en la máquina):
   ```bash
   /Applications/Processing.app/Contents/MacOS/Processing cli \
     --sketch=/Users/andres/code/trazos/andiamo2 \
     --output=/tmp/andiamo2-build \
     --force --build && rm -rf /tmp/andiamo2-build
   ```
   Si falla, corregí los errores y volvé a compilar hasta obtener `Finished.` con código de salida `0`.
2. Hacé una revisión mental rápida de los 5 escenarios de prueba:
   * Clic de un solo punto (`toques.length == 1`).
   * Trazo normal en modo `Repetir` (¿se desvanece bien con `Borrado`?).
   * Dos pinceladas seguidas con `Unir` (`Tab`) (¿salta limpio sin línea conectora?).
   * Cambio de `Escala`, `Opac.` y opacidad de capa.
   * Dos trazos simultáneos con el mismo pincel (¿independientes?).
3. Entregale al usuario un resumen claro en español con:
   * Archivo creado y tecla asignada.
   * Qué probar visualmente en Processing (incluyendo el checklist de `Repetir`, `Unir`, `Escala` y `Opac.`).
   * Sugerencias de cómo pedir ajustes si quiere refinar el resultado.
