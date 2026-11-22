# Instrucciones para asistentes de IA — Andiamo 2

Este proyecto es **Andiamo 2**, una herramienta de dibujo animado en vivo escrita para **Processing 4.x** (renderizador `P2D`). Los nombres de clases, funciones, variables y textos de interfaz están en **español**.

## Estructura clave del código

* `andiamo2.pde`: ciclo principal (`settings`, `setup`, `draw`) y eventos de mouse/teclado.
* `Trazos.pde`: clases `Trazo` y `Toque`; grabación con `millis()`, bucle temporal y búsqueda binaria.
* `Pinceles.pde`: clase abstracta `Pincel`, registro en `cargarPinceles()` y pinceles base.
* `PincelAndiamo.pde`, `PincelYellowTail.pde`: ejemplos de pinceles complejos en archivos propios.
* `Capas.pde`: `CapaDibujo` (9 capas) y `LienzoFondo` (fondo con transición suave).
* `Estado.pde`: estado global, atajos de teclado y sincronización con la UI.
* `UI.pde`, `Interface.pde`, `Widget.pde`: sistema de widgets, barra superior ocultable (`Enter` o esquina `0..30×0..30`) y tooltips.

## Reglas e invariantes críticos al modificar o crear pinceles

1. **Un archivo por pincel nuevo:** creá `Pincel<Nombre>.pde` en la raíz del sketch (junto a `andiamo2.pde`) y registralo en `cargarPinceles()` dentro de `Pinceles.pde`.
2. **Contrato de `Pincel`:**
   * Asigná `nombre` (corto, <= 10 caracteres) y `descripcion` (en español, para el tooltip) en el constructor.
   * Implementá `nuevoPincel()` devolviendo una **instancia nueva** (`new Pincel<Nombre>(indice, teclas)`), nunca `this`, para que cada trazo tenga estado independiente.
   * `pintar(Toque[] toques, color tinta, float escala)` se ejecuta **en cada cuadro** después de limpiar el fondo (`background()`). No asumas persistencia de píxeles entre cuadros ni uses `random()` sin semilla fija dentro de `pintar()`.
3. **Color, alfa y escala:**
   * Usá `tinta` directamente (`stroke(tinta)` / `fill(tinta)`), o multiplicá por `alpha(tinta) / 255.0` si componés colores, ya que `tinta` incluye la opacidad de la capa, del trazo y el fundido de borrado.
   * Usá `escala` para dimensionar grosores o tamaños (`escala` puede valer `0.0` hasta `10.0`; `1.0` es el valor inicial).
4. **Secuencias unidas (`Unir`) y `fakeToque`:**
   * Un arreglo `toques` puede contener múltiples sub-trazos separados por pausas: siempre cortá segmentos cuando `toque.primero == true` para no dibujar líneas rectas entre pinceladas distintas.
   * `Trazo.cerrate()` agrega un `fakeToque` al final con las mismas coordenadas `(x, y)` del último toque real. Protegé siempre las divisiones por distancia (`distintos(ptoque, toque)` y `0.001 < d2`) y contemplá `toques.length == 1`.
5. **Teclas reservadas y límite actual de la barra:**
   * Teclas ocupadas por pinceles: `Q W E R T Y U I O`.
   * Teclas ocupadas por tintas y acciones: `A S D F G`, `Z X`, `1–9`, `0`, `H`, `M`, `N`, `Espacio`, `Tab`, `~`, `` ` ``, `Enter`, `Supr/Backspace`, flechas, `-/+`, `,/.`, `[/]`.
   * Teclas de letra libres para nuevos pinceles: `B`, `C`, `J`, `K`, `L`, `P`, `V`.
   * La barra horizontal en `agregarPincelesAlInterface()` tiene espacio directo para 9 botones (`x = 198..842`) antes del separador en `x = 846`. Si agregás un 10.º pincel sin reemplazar otro, ajustá también el diseño/paginación de la barra en `Pinceles.pde` y `UI.pde`.

## Verificación de compilación (macOS)

Después de editar archivos `.pde`, verificá que el sketch compile sin errores con Processing CLI (y eliminá la carpeta temporal al terminar):

```bash
/Applications/Processing.app/Contents/MacOS/Processing cli \
  --sketch=/Users/andres/code/trazos/andiamo2 \
  --output=/tmp/andiamo2-build \
  --force --build && rm -rf /tmp/andiamo2-build
```

## Skill disponible

Para crear o diseñar pinceles nuevos paso a paso (especialmente con usuarios no programadores), usá la skill `crear-pincel` ubicada en `.github/skills/crear-pincel/SKILL.md`.
