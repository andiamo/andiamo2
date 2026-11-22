# Andiamo 2

Herramienta de **dibujo animado en vivo** para **Processing 4.x** (renderizador `P2D`).

Andiamo 2 es una reescritura de [Andiamo](../andiamo) diseñada con dos objetivos principales:

1. **Pinceles extensibles:** separar la lógica temporal de los trazos de la geometría visual de cada pincel, facilitando la creación de nuevos pinceles con animaciones propias (cinta B-spline clásica, línea, cinta dinámica, chispa, círculo, YellowTail, cuadrados, abanico, rectángulos).
2. **Secuencias sincronizadas:** permitir unir múltiples pinceladas consecutivas dentro de una misma línea temporal para conservar las pausas y el ritmo original entre trazos.

## Inicio rápido

1. Abrí `andiamo2.pde` en **Processing 4.x**.
2. Ejecutá el bosquejo (**Run**).
3. Al iniciar, la interfaz está oculta para aprovechar toda la pantalla:
   * Dibujá directamente haciendo clic y arrastrando sobre el lienzo.
   * Presioná **`Enter`** o hacé clic en la **esquina superior izquierda (30×30 px)** para mostrar u ocultar la barra de controles.
   * Con la interfaz abierta, hacé clic en **`? Ayuda`** (o presioná **`H`**) para ver una guía rápida dentro de la aplicación, o pasá el cursor sobre cualquier botón para leer su descripción y atajo.

## Documentación detallada

* **[Guía de uso](./docs/GUIA_DE_USO.md):** cómo usar la interfaz, mecánica de los bucles (*loops*), unión de secuencias, capas, pinceles, colores y tabla completa de atajos de teclado.
* **[Arquitectura del código](./docs/ARQUITECTURA.md):** estructura de archivos, ciclo de vida, modelo temporal (`Trazo` / `Toque`), sistema de pinceles (`Pincel`), física de interpolación (`NumeroInterpolado`), sistema de UI (`Interface` / `Widget`) y guía para crear nuevos pinceles o portar a p5.js / Trazos.club.
* **[Tutorial: Crear pinceles con IA](./docs/TUTORIAL_CREAR_PINCEL.md):** guía paso a paso para artistas y colaboradores sobre cómo diseñar y probar nuevos pinceles usando la skill [`crear-pincel`](./.github/skills/crear-pincel/SKILL.md).
* **[Registro de cambios](./docs/REGISTRO_DE_CAMBIOS.md):** detalle archivo por archivo de las mejoras de interfaz, correcciones de errores y refactorizaciones realizadas.

## Resumen de controles de teclado

| Tecla | Acción |
| :--- | :--- |
| `Enter` | Mostrar / ocultar interfaz (también clic en esquina sup. izq. `30×30`) |
| `H` o `?` | Mostrar / ocultar panel de ayuda rápida |
| `Espacio` | Activar / desactivar **Repetir** (bucle continuo en nuevos trazos) |
| `N` | Activar / desactivar **1 vez** (reproduce una vez y se borra) |
| `Tab` o `` ` `` / `~` | Activar / desactivar **Unir** trazos consecutivos |
| `Supr` / `Backspace` | Borrar último trazo (o toda la capa si `Modo: Todo` está activo) |
| `Shift + Supr` | Borrar todos los trazos de la capa seleccionada (o todas) |
| `M` | Alternar modo de borrado (**Último trazo** / **Todo**) |
| `1` – `9` | Seleccionar capa 1 a 9 |
| `0` | Seleccionar todas las capas |
| `Shift + 1`–`9` | Mostrar / ocultar capa 1 a 9 |
| `Shift + 0` o `)` | Mostrar / ocultar todas las capas simultáneamente |
| `←` / `→` | Disminuir / aumentar opacidad de nuevos trazos |
| `↑` / `↓` | Disminuir / aumentar escala de nuevos trazos |
| `Shift + ↑` / `↓` o `[` / `]` | Disminuir / aumentar opacidad de capa(s) activa(s) |
| `-` / `+` (`_` / `=`) | Disminuir / aumentar tiempo de borrado / desvanecimiento |
| `,` / `.` (`<` / `>`) | Disminuir / aumentar tiempo de transición del color de fondo |
| `Q W E R T Y U I O` | Seleccionar pincel 1 al 9 |
| `A S D F G` | Seleccionar color predefinido de pincel |
| `Z` / `X` | Seleccionar fondo blanco / negro |
