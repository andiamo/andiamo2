# Registro de cambios y mejoras — Andiamo 2

Este documento detalla todos los cambios realizados sobre la base original de **Andiamo 2**, agrupados por área y archivo, explicando qué problema o limitación resolvía cada cambio y cómo quedó implementado.

---

## Resumen general

1. **Rediseño completo de la interfaz (`UI.pde`, `Interface.pde`, `Widget.pde`):** barra flotante oscura de dos filas con secciones rotuladas, 9 botones de pincel con nombre, selector de color con muestras predefinidas y mezcla RGB directa, deslizadores con valores formateados, tooltips descriptivos al pasar el cursor, indicador de grabación unida y panel integrado de ayuda (`? Ayuda`).
2. **Ocultamiento total de la interfaz (`UIToggleHotspot`):** al ocultarse (estado inicial o presionando `Enter`), no dibuja ningún elemento en pantalla, manteniendo activa la zona invisible de `30×30 px` en la esquina superior izquierda.
3. **Corrección de errores en motor, entrada y pinceles (`andiamo2.pde`, `Trazos.pde`, `Estado.pde`, `Capas.pde`, `Pinceles.pde`, `PincelYellowTail.pde`):** captura de arrastre en UI, bug de canal verde en `ColorSelector`, discontinuidad de escala en `0.5`, conflicto de tecla `SHIFT`, borrado manual inmediato de trazos fijos/en bucle, inclusión del 9.º pincel (`PincelRectangulos`), soporte de escala en `PincelYellowTail` y cierre automático de secuencias unidas al cambiar contexto.
4. **Documentación (`README.md`, `docs/GUIA_DE_USO.md`, `docs/ARQUITECTURA.md`, `docs/REGISTRO_DE_CAMBIOS.md`).**

---

## Detalle archivo por archivo

### 1. [`andiamo2.pde`](../andiamo2.pde)

* **Corrección en `settings()` para pantalla completa:**
  * *Antes:* `fullScreen(P2D, PANTALLA_ALTO)` pasaba la altura (`800`) como índice de monitor.
  * *Ahora:* usa `PANTALLA_INDICE` si `0 < PANTALLA_INDICE`, o `fullScreen(P2D)` por defecto.
* **Despacho de movimiento del cursor (`mouseMoved()`):**
  * Se agregó `void mouseMoved() { intf.mouseMoved(); }` para habilitar estados de *hover* y tooltips en la interfaz.

---

### 2. [`Trazos.pde`](../Trazos.pde)

* **Borrado manual inmediato (`Trazo.remover()` y `tiempoInicioRemocion`):**
  * *Problema anterior:* `remover()` solo marcaba `removiendo = true`, haciendo que el borrado dependiera del reloj cíclico `(millis() - tiempoComienzo) % duracionCiclo`. En trazos largos o en trazos fijos (`repetir == false`), presionar borrar podía tardar varios segundos o quedar atascado hasta alcanzar la ventana final del módulo.
  * *Cambio:* se agregó `int tiempoInicioRemocion = -1` en `Trazo`. Al llamar a `remover()`, se registra `tiempoInicioRemocion = millis()`. En `dibujate()`, cuando `0 <= tiempoInicioRemocion`, el trazo inicia inmediatamente un desvanecimiento suave de duración `max(1, min(duracionBorrado, 800))` ms y se marca `removido = true` al finalizar.
* **Separación entre modo `Repetir`, modo `1 vez` y borrado manual en `dibujate()`:**
  * Se protegió `duracionCiclo = max(1, tiempoFinal - tiempoComienzo + 1)` contra divisores `<= 0`.
  * En modo `1 vez` (`tiempoInicioRemocion < 0`), si `duracionBorrado <= 0` y se alcanza `tiempoBorrado - tiempoComienzo <= t`, el trazo se marca como `removido` sin esperar al siguiente cuadro.
* **Cierre seguro en `cerrarTrazo()`:**
  * Se verifica `0 < estado.nuevoTrazo.toques.size()` antes de invocar `cerrate()` y se limpia `estado.nuevoTrazo = null` al terminar.

---

### 3. [`Capas.pde`](../Capas.pde)

* **Finalización limpia en `LienzoFondo.pintar()`:**
  * Se valida `0 < duracionCambio` antes de dividir para evitar división por cero cuando `Fondo t` está en `0.0 s`.
  * Al cumplirse `t - tiempoCambio >= duracionCambio`, se restablece `cambiando = false` para evitar recalcular transiciones indefinidamente.

---

### 4. [`Estado.pde`](../Estado.pde)

* **Continuidad en la escala de trazo (`establecerFactorEscala()`):**
  * *Problema anterior:* cuando el deslizador estaba en `[0, 0.5]` usaba el valor directo (`0.5`), pero al superar `0.5` mapeaba `[0.5, 1.0] -> [1.0, 10.0]`, produciendo un salto brusco de `0.5` a `1.0+`.
  * *Cambio:* `[0.0, 0.5]` ahora mapea suavemente a `[0.0, 1.0]` y `[0.5, 1.0]` mapea a `[1.0, 10.0]`, de modo que la posición central (`0.5`) equivale exactamente a `1.0x`.
* **Cierre de secuencias unidas al cambiar de contexto (`cerrarTrazoEnCurso()`):**
  * Al cambiar de capa (`seleccionarCapa`), cambiar de pincel (`seleccionarPincel`) o borrar (`borrarTrazos` / `borrarCapaCompleta`) mientras `unirTrazos && registrandoTrazo`, la secuencia pendiente se cierra automáticamente en su capa original antes de aplicar la nueva acción.
* **Resolución de conflictos e implementación completa de atajos de teclado (`procesarTeclado()`):**
  * Se eliminó el uso de `SHIFT` suelto para alternar `borrarTodosLosTrazos` (lo cual provocaba activaciones accidentales al presionar `Shift` para teclas en mayúscula como `A`–`G`, `Q`–`O` o `Z`/`X`). En su lugar, se asignó la tecla **`M`** y se agregó **`Shift + Supr`** para borrado completo directo (`borrarCapaCompleta()`).
  * Se implementaron los atajos que estaban documentados o faltaban, sincronizados con los widgets de la UI:
    * `←` / `→`: opacidad de nuevos trazos (`ajustarSliderOpacidad`).
    * `↑` / `↓`: escala de nuevos trazos (`ajustarSliderEscala`).
    * `Shift + ↑` / `↓` y `[` / `]`: opacidad de capa(s) activa(s).
    * `-` / `+` (`_` / `=`): tiempo de borrado (`ajustarSliderBorrado`).
    * `,` / `.` (`<` / `>`): duración de transición de fondo (`ajustarSliderFondo`).
    * `N`: alternar modo **1 vez** (`borrarTrazosAuto`).
    * `Tab`, `` ` `` o `~`: alternar **Unir** trazos.
    * `Shift + 1`–`9` (tanto por `keyEvent.isShiftDown()` + `keyCode` como por símbolos `!@#$%^&*(`) y `Shift + 0` / `)`: mostrar u ocultar capas individuales o todas.
    * `H` o `?`: mostrar/ocultar el panel de ayuda (`invertirMostrarAyuda()`).
  * Se agregaron las funciones inversas (`obtenerValorSliderEscala`, `obtenerValorSliderBorrado`, `obtenerValorSliderFondo`) y `syncToggle()` para mantener los controles visuales sincronizados cuando se operan desde el teclado.

---

### 5. [`Pinceles.pde`](../Pinceles.pde), [`PincelAndiamo.pde`](../PincelAndiamo.pde) y [`PincelYellowTail.pde`](../PincelYellowTail.pde)

* **Nombres y descripciones en `Pincel`:**
  * Se agregaron los campos `nombre` y `descripcion` en la clase base `Pincel` y se inicializaron en los 9 pinceles (`Andiamo`, `Línea`, `Cinta`, `Chispa`, `Círculo`, `YellowTail`, `Cuadros`, `Abanico`, `Rects`).
* **Soporte dinámico y paginación automática para 10+ pinceles:**
  * *Problema anterior:* `agregarPincelesAlInterface`, `actualizarInterfacePinceles` y `seleccionarPincel` tenían el límite fijo `1..8`, dejando fuera al 9.º pincel (`PincelRectangulos`, tecla `O`), y sumar un 10.º pincel habría desbordado la barra sobre el botón `Borrar`.
  * *Cambio:* ahora iteran sobre `pinceles.size()`. Cuando hay hasta 9 pinceles (`MAX_PINCELES_SIN_PAGINACION = 9`), se muestran todos en una fila; a partir de 10 pinceles, la barra activa automáticamente paginación de 8 pinceles por página (`PINCELES_POR_PAGINA = 8`) con botones `<` / `>` e indicador `1/2`, saltando automáticamente a la página del pincel elegido al usar atajos de teclado.
* **Robustez geométrica y escala:**
  * `PincelCinta` y `PincelRectangulos`: protección contra división por cero cuando `d2 <= 0.001` (evita vértices `NaN` al hacer clic sin arrastrar).
  * `PincelYellowTail`: `thickness = INIT_TH * escala;` en `pintar()` para que responda al deslizador/atajo de `Escala`.

---

### 6. [`Interface.pde`](../Interface.pde) y [`Widget.pde`](../Widget.pde)

* **Captura de arrastre (`activeWidget`):**
  * *Problema anterior:* `mouseDragged()` volvía a llamar a `setFocused(mouseX, mouseY)` en cada cuadro. Al arrastrar deslizadores angostos (de `10 px`), apenas el cursor salía 1 píxel fuera de la caja, el widget perdía el foco, se cortaba el arrastre y al soltar se disparaba `estado.terminarTrazo()` sobre el lienzo.
  * *Cambio:* `mousePressed()` fija `activeWidget = focused` y tanto `mouseDragged()` como `mouseReleased()` envían eventos directamente a `activeWidget` hasta soltar el botón.
* **Soporte de tooltips e indicadores:**
  * Se agregaron `tooltip`, `keyHint`, `setTooltip()` y `setKeyHint()` en `Widget`.
  * `Interface.mouseMoved()` limpia y actualiza `currentTooltip` según el widget enfocado, y `Interface.update()` invoca `drawOverlayIndicators()` para dibujar tooltips y estado de grabación unida.

---

### 7. [`UI.pde`](../UI.pde)

* **Botón/zona de esquina superior izquierda (`UIToggleHotspot`):**
  * Ocupa `(0, 0, 30, 30)`. Cuando `estado.mostrarUI == false`, `draw()` retorna inmediatamente sin pintar nada (totalmente invisible); cuando la interfaz está abierta, dibuja un botón discreto con `×`.
* **Panel principal (`Container`):**
  * Barra flotante de 2 filas (`h = 90`, `y = 4`) con fondo oscuro translúcido `(24, 26, 34, 232)` y borde sutil, legible sobre fondos blancos, negros o de color.
  * Encabezados de sección (`SectionLabel`) y separadores (`Divider`) para identificar `MODO DE TRAZO`, `PINCELES`, `ACCIONES Y AYUDA`, `CAPAS (1-9) / VISIBILIDAD`, `COLOR TRAZO (A-G)`, `FONDO (Z-X)` y `PARÁMETROS DE TRAZO Y TIEMPOS`.
* **Controles mejorados:**
  * `VisibilityButton` + `SelectButton`: barras verdes/grises de visibilidad encima de los botones de capa `1..9` y `Todas`.
  * `ActionButton`: botón explícito **`Borrar`** para ejecutar el borrado con el mouse junto al interruptor **`Modo: Todo`**.
  * `ColorSelector`:
    * Corregido el bug `this.g = red(c) / 255.0` → `green(c) / 255.0`.
    * Agregadas muestras rápidas clicables (`presets` de `tintasPincel` y `tintasFondo`) con anillo indicador de color activo.
    * Barras `R`, `G`, `B` con seguimiento por `activeChannel` (restringido a `[0, 1]`) y aplicación automática sin necesidad de hacer un segundo clic en la muestra de vista previa (en vivo para el trazo; al soltar para el fondo para no reiniciar la transición en cada píxel del arrastre).
  * `ValueSlider`: barra rellena con marcador vertical, etiqueta de nombre y valor formateado en vivo (`%`, `x` o `s`), con respuesta inmediata en `press()`, `drag()` y `release()`.
  * `HelpOverlay`: ventana flotante activable con **`? Ayuda`** o **`H`** que resume la mecánica de bucles y todos los atajos de teclado.
  * `drawStatusAndTooltip()`: muestra el aviso **`● Grabando secuencia unida`** cuando `unirTrazos && registrandoTrazo` y el tooltip del control bajo el cursor.
