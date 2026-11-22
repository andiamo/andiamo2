# Guía de uso — Andiamo 2

Andiamo 2 es una herramienta de dibujo animado en tiempo real pensada para dibujo en vivo, improvisación visual y trabajo por capas. Cada pincelada que hacés no es solo una imagen estática: el programa graba **qué dibujaste** y **el ritmo exacto con el que lo dibujaste**, para luego reproducirlo en bucle.

---

## 1. Primeros pasos y cómo mostrar/ocultar la interfaz

Al abrir Andiamo 2, la pantalla aparece completamente limpia para maximizar el espacio de dibujo:

* **Dibujar:** hacé clic y arrastrá con el mouse o tableta gráfica en cualquier parte del lienzo.
* **Mostrar / ocultar la barra de controles:**
  * Presioná **`Enter`**, **o**
  * Hacé clic en la **esquina superior izquierda** (un área de `30×30 px` completamente invisible cuando la interfaz está oculta; cuando la barra está abierta muestra un botón `×` para volver a ocultarla).
* **Ayuda en pantalla:** con la interfaz abierta, hacé clic en **`? Ayuda`** (o presioná **`H`**) para abrir el resumen interactivo de mecánica y atajos.
* **Tooltips descriptivos:** pasá el cursor por encima de cualquier botón, muestra de color o deslizador para ver su explicación y atajo de teclado debajo de la barra.

---

## 2. Mecánica del bucle (*loop*) y modos de trazo

Entender cómo funciona el ciclo temporal de un trazo es la clave para dominar Andiamo 2.

### ¿Qué pasa cuando dibujás un trazo?

1. **Al presionar el botón del mouse:** comienza la grabación de un `Trazo` en el instante `t₀`.
2. **Mientras arrastrás:** cada movimiento registra un punto (`Toque`) con su posición `(x, y)`, su velocidad (`p`) y el tiempo exacto en milisegundos (`t`).
3. **Al soltar el botón:** el trazo se cierra (salvo que **Unir** esté activo) y se agrega al final una pausa virtual equivalente al tiempo configurado en el deslizador **`Borrado`** (por defecto `2.0 s`).

Según qué botones estén activos en la sección **MODO DE TRAZO**, el trazo se comporta de una de tres maneras:

| Modo | Estado de botones | Comportamiento |
| :--- | :--- | :--- |
| **Repetir** *(por defecto)* | `Repetir` activo (`Espacio`) | El trazo se dibuja siguiendo su ritmo original desde `t₀` hasta el final; luego se desvanece suavemente durante el tiempo de **`Borrado`** y vuelve a empezar desde el principio en un bucle infinito. |
| **1 vez** (auto-borrado) | `1 vez` activo (`N`) | El trazo se reproduce una sola vez, se desvanece al llegar al final durante el tiempo de **`Borrado`** y se elimina automáticamente de la capa. Ideal para gestos efímeros. |
| **Fijo** (estático) | Ambos desactivados | El trazo queda dibujado de forma permanente y estática sobre la capa, sin animarse ni borrarse (hasta que lo borres manualmente). |

> **Nota sobre `Repetir` y `1 vez`:** son mutuamente excluyentes. Activar uno desactiva automáticamente el otro.

### ¿Para qué sirve el deslizador `Borrado`?

* Controla cuántos segundos tarda el trazo en desvanecerse **al final de cada ciclo** antes de reiniciar el bucle (en modo **Repetir**) o antes de desaparecer definitivamente (en modo **1 vez**).
* Si lo llevás a `0.0 s`, el trazo termina y reinicia (o desaparece) de golpe, sin fundido.
* Si lo subís hasta `15.0 s`, el trazo permanece visible desvaneciéndose lentamente antes de volver a empezar.
* **Importante:** este parámetro se captura **en el momento en que cerrás el trazo**. Cambiar `Borrado` afecta a los trazos nuevos, manteniendo intacto el ritmo de los ya dibujados.

---

## 3. Unir trazos consecutivos (`Unir` / `Tab`)

En el Andiamo original, cada pincelada tenía su propio reloj independiente: si dibujabas tres letras o tres puntos seguidos, con el tiempo se desfasaban o no conservaban la pausa entre ellos.

En Andiamo 2, el botón **`Unir`** (atajo `Tab`, `` ` `` o `~`) resuelve esto:

1. Activá **`Unir`**.
2. Dibujá el primer trazo y soltá el mouse. Esperá el tiempo que quieras (por ejemplo, 1 segundo).
3. Dibujá un segundo trazo, un tercero, etc. Mientras **`Unir`** esté encendido, verás el aviso **`● Grabando secuencia unida`** debajo de la barra: todos los trazos se están guardando en un **mismo reloj compartido**, incluyendo las pausas reales entre cada pincelada.
4. Cuando termines la secuencia, desactivá **`Unir`** (haciendo clic en el botón o presionando `Tab`). Recién en ese momento la secuencia completa se cierra y comienza a repetirse en bucle exactamente con las pausas con las que la dibujaste.

> Si cambiás de capa, cambiás de pincel o presionás borrar mientras estás grabando una secuencia unida, la secuencia en curso se cierra automáticamente para que puedas seguir en la nueva capa o con el nuevo pincel sin perder lo anterior.

---

## 4. Pinceles (`Q W E R T Y U I O`)

Podés elegir cualquiera de los **9 pinceles** haciendo clic en su botón o usando las teclas de la fila superior (`Q` a `O`):

| Tecla | Pincel | Descripción |
| :---: | :--- | :--- |
| `Q` | **Andiamo** | El pincel clásico de Andiamo 1: cinta suave construida con curvas B-spline cuya anchura varía inversamente con la velocidad. |
| `W` | **Línea** | Trazo continuo de línea simple con grosor uniforme dado por `Escala`. |
| `E` | **Cinta** | Cinta poligonal continua con ancho dinámico suavizado según la velocidad del trazo. |
| `R` | **Chispa** | Dibuja únicamente el segmento de la punta en movimiento, generando un efecto de chispa o cometa que recorre el trazo. |
| `T` | **Círculo** | Círculo que recorre la trayectoria variando su tamaño de forma orgánica mediante ruido Perlin (`noise`). |
| `Y` | **YellowTail** | Pincel cinético inspirado en *Yellowtail* de Golan Levin: al soltar, la cinta sigue desplazándose indefinidamente a lo largo de su propia forma (envuelve en los bordes de la pantalla; no aplica fundido de opacidad). |
| `U` | **Cuadros** | Cuadrado móvil que recorre la trayectoria con tamaño orgánico animado (`noise`). |
| `I` | **Abanico** | Conecta el punto inicial del trazo con cada punto sucesivo formando líneas radiales en abanico. |
| `O` | **Rects** | Dibuja un rectángulo extendido desde el punto inicial hasta el punto final de cada segmento cerrado. |

---

## 5. Capas y borrado (`1`–`9`, `0`, `Supr`)

Andiamo 2 cuenta con **9 capas independientes** (la capa `1` se dibuja por delante y la capa `9` al fondo).

### Selección y visibilidad

* **Seleccionar una capa:** hacé clic en los botones **`1`–`9`** (o presioná las teclas `1`–`9`). Si la capa estaba oculta, se vuelve visible automáticamente al seleccionarla.
* **Mostrar / ocultar una capa:** hacé clic en la **barra verde/gris sobre el número de cada capa** (o presioná `Shift + 1`–`9`). Las capas ocultas se desvanecen suavemente (`opacidad = 0`) sin perder sus trazos; al volver a activarlas reaparecen.
* **Todas las capas (`Todas` / `0`):**
  * **`Todas`** (`0`): selecciona todas las capas juntas para modificar su opacidad o borrarlas simultáneamente.
  * **Barra sobre `Todas`** (`Shift + 0` o `)`): muestra u oculta todas las capas al mismo tiempo.
* **Deslizador `Capa`:** ajusta suavemente la opacidad (`0%`–`100%`) de la capa seleccionada (o de todas si `Todas` está activo). También con `Shift + ↑ / ↓` o `[` / `]`.

### Borrado de trazos

* **Botón `Borrar` (tecla `Supr` / `Backspace`):**
  * Con **`Modo: Todo` desactivado:** borra únicamente el **último trazo** de la capa seleccionada (ideal como "deshacer" animado).
  * Con **`Modo: Todo` activado** (o presionando **`Shift + Supr`** en cualquier momento): borra **todos los trazos** de la capa seleccionada (o de todas las capas si `Todas` está activo).
* Los trazos borrados se desvanecen suavemente antes de eliminarse de la memoria.

---

## 6. Colores y parámetros de trazo

### Color de trazo (`A S D F G`) y Color de fondo (`Z X`)

* **Muestras rápidas:** hacé clic en cualquiera de los cuadraditos de colores predefinidos:
  * **Trazo:** Negro (`A`), Blanco (`S`), Coral (`D`), Verde lima (`F`), Celeste (`G`).
  * **Fondo:** Blanco (`Z`), Negro (`X`).
* **Selector RGB:** arrastrá las barras roja (`R`), verde (`G`) y azul (`B`) para mezclar cualquier color personalizado.
  * El color del **trazo** se actualiza en vivo al instante.
  * El color de **fondo** aplica una transición suave al soltar el selector (con una duración definida por **`Fondo t`**).

### Parámetros de los próximos trazos

Estos valores se aplican a cada **nuevo trazo** que dibujes (no alteran retrospectivamente los trazos ya cerrados):

* **`Opac.` (`←` / `→`):** opacidad del trazo de `0%` a `100%`.
* **`Escala` (`↑` / `↓`):** escala/grosor del trazo de `0.0x` a `10.0x` (el punto medio `0.5` equivale a `1.0x`).
* **`Borrado` (`-` / `+`):** duración del desvanecimiento final del trazo (`0.0 s` a `15.0 s`).
* **`Fondo t` (`<` / `>`):** duración de la transición suave al cambiar el color de fondo (`0.0 s` a `15.0 s`).

---

## 7. Referencia completa de teclado

| Categoría | Tecla | Acción |
| :--- | :--- | :--- |
| **Interfaz** | `Enter` | Mostrar / ocultar barra de interfaz |
| | `H` o `?` | Mostrar / ocultar panel de ayuda rápida |
| **Modos** | `Espacio` | Activar / desactivar **Repetir** (bucle) |
| | `N` | Activar / desactivar **1 vez** (auto-borrado) |
| | `Tab` o `` ` `` / `~` | Activar / desactivar **Unir** trazos consecutivos |
| **Borrado** | `Supr` / `Backspace` | Borrar último trazo (o capa si `Modo: Todo` activo) |
| | `Shift + Supr` | Borrar todos los trazos de la capa(s) activa(s) |
| | `M` | Alternar `Modo: Todo` (último trazo vs capa completa) |
| **Capas** | `1` – `9` | Seleccionar capa 1 a 9 |
| | `0` | Activar / desactivar selección de todas las capas |
| | `Shift + 1`–`9` | Mostrar / ocultar capa 1 a 9 |
| | `Shift + 0` o `)` | Mostrar / ocultar todas las capas |
| | `Shift + ↑` / `↓` o `[` / `]` | Ajustar opacidad de capa(s) activa(s) |
| **Parámetros** | `←` / `→` | Ajustar opacidad de nuevos trazos |
| | `↑` / `↓` | Ajustar escala de nuevos trazos |
| | `-` / `+` (`_` / `=`) | Ajustar tiempo de borrado de trazos |
| | `,` / `.` (`<` / `>`) | Ajustar tiempo de transición de fondo |
| **Pinceles** | `Q W E R T Y U I O` | Seleccionar pincel (`Andiamo` .. `Rects`) |
| **Colores** | `A S D F G` | Seleccionar color predefinido de trazo |
| | `Z` / `X` | Seleccionar fondo blanco / negro |
