# Tutorial paso a paso: Cómo crear pinceles nuevos con IA (`crear-pincel`)

Esta guía está pensada para artistas, docentes y colaboradores de **Andiamo / Trazos** —aunque no tengas experiencia previa programando— para que puedas diseñar e incorporar nuevos pinceles a **Andiamo 2** trabajando junto a un asistente de IA.

---

## ¿Qué incluye este repositorio para ayudar a la IA?

Para que el asistente de IA no cometa los errores típicos de Processing ni rompa la mecánica de bucles, el repositorio ya trae configuradas dos piezas:

1. **[`.github/copilot-instructions.md`](../.github/copilot-instructions.md):** reglas permanentes del proyecto que el asistente lee automáticamente (estructura de archivos, cómo compilar y restricciones de teclado/interfaz).
2. **[`.github/skills/crear-pincel/SKILL.md`](../.github/skills/crear-pincel/SKILL.md):** una *skill* especializada con el paso a paso para entrevistarte, elegir la mejor arquitectura de pincel, generar el código respetando todas las reglas de `Trazo` y `Toque`, y compilar el proyecto para verificar que no haya errores.

---

## Paso 1: Preparar tu espacio de trabajo

1. Abrí la carpeta `andiamo2/` en **VS Code** (o iniciá tu asistente/Copilot CLI dentro de `andiamo2/`).
2. Tené **Processing 4.x** a mano para abrir [`andiamo2.pde`](../andiamo2.pde) y probar los resultados visualmente en vivo.

---

## Paso 2: Pensar tu pincel (sin escribir código)

Antes de pedirle nada al asistente, imaginá tu pincel respondiendo estas 4 preguntas simples:

1. **¿Qué deja en la pantalla?**
   * *¿Toda la estela del movimiento* (como una cinta, tiza o hilo)?
   * *¿O solo algo en la punta* (como una estrella, gota, luz o círculo que viaja)?
2. **¿Cómo reacciona a tu mano?**
   * Si movés rápido el mouse o lápiz, ¿se hace más fino, más grueso, más suelto o lanza más partículas?
3. **¿Cómo se comporta el bucle?**
   * ¿Se dibuja y se desvanece suavemente siguiendo tu ritmo original, o sigue moviéndose/flotando por su cuenta después de soltar?
4. **Nombre y tecla:**
   * Pensá un nombre corto (máx. 8–10 letras, por ejemplo `Tiza`, `Burbujas`, `Pasto`, `Órbita`).
   * Podés elegir una tecla libre (`B`, `C`, `J`, `K`, `L`, `P`, `V`) o dejarlo solo como botón en la barra. Si superás los 9 pinceles, la barra agrega automáticamente flechas `< 1/2 >` para navegar entre páginas de pinceles sin superponerse con otros botones.

---

## Paso 3: Pedirle el pincel al asistente usando la skill

Podés iniciar la conversación invocando la skill directamente o describiendo tu idea en lenguaje natural.

### Ejemplo 1: Pedido abierto (la IA te hace preguntas para definirlo)

> *"Usá la skill `crear-pincel` para ayudarme a crear un pincel nuevo. Quiero algo parecido a dibujar con tiza suave sobre un pizarrón, que tenga un poco de textura granulada."*

### Ejemplo 2: Pedido más específico

> *"Usá la skill `crear-pincel` para crear un pincel llamado `Burbujas` con la tecla `K`. Al mover el mouse quiero que deje círculos semitransparentes de distintos tamaños que tiemblen suavemente sin parpadear, y que cuando vaya más rápido las burbujas sean más grandes."*

### ¿Qué va a hacer el asistente?

1. Si falta algún detalle (por ejemplo, si reemplazar o sumar un botón, o cómo reacciona a la velocidad), te hará 2 o 3 preguntas cortas.
2. Creará un archivo nuevo exclusivo para tu pincel, por ejemplo `PincelBurbujas.pde`.
3. Lo registrará en [`cargarPinceles()`](../Pinceles.pde) dentro de [`Pinceles.pde`](../Pinceles.pde).
4. Compilará el bosquejo automáticamente con Processing CLI para asegurarse de que no haya ningún error antes de avisarte que está listo.

---

## Paso 4: Probar el pincel en Processing (lista de verificación)

Abrí [`andiamo2.pde`](../andiamo2.pde) en **Processing** y presioná **Run** (`▶`). Luego presioná **`Enter`** (o hacé clic en la esquina superior izquierda) para abrir la barra y seleccioná tu nuevo pincel.

Hacé estas **5 pruebas rápidas** (toman 1 minuto y detectan el 99% de los detalles a pulir):

1. **Un solo clic sin arrastrar:** hacé clic breve en un punto y soltá.
   * *Qué esperar:* no debe tirar error ni congelarse.
2. **Trazo normal en modo `Repetir` (`Espacio`):** dibujá una curva fluida y esperá.
   * *Qué esperar:* se repite con tu ritmo y se desvanece suavemente durante el tiempo de `Borrado` (sin parpadeos raros ni quedar clavado).
3. **Modo `Unir` (`Tab`):** activá `Unir`, dibujá 2 trazos separados dejando 1 segundo de pausa entre ambos, y volvé a presionar `Tab`.
   * *Qué esperar:* ambos trazos se repiten con su pausa real y **no** aparece una línea recta cruzando entre el final del primero y el inicio del segundo.
4. **Deslizadores `Escala`, `Opac.` y `Capa`:** movelos y dibujá otro trazo, o bajá la opacidad de la capa actual.
   * *Qué esperar:* el tamaño y la transparencia del pincel obedecen a los controles.
5. **Dos trazos distintos al mismo tiempo:** dibujá dos trazos seguidos con el mismo pincel.
   * *Qué esperar:* el segundo trazo no debe deformar ni borrar al primero.

---

## Paso 5: Ajustar e iterar hablando en lenguaje cotidiano

Casi siempre la primera versión ya funciona, y la magia está en afinarla conversando. Podés pedirle cambios concretos así:

* *"Me gustó `Burbujas`, pero hacé que el tamaño máximo sea la mitad y que estén más juntas."*
* *"Con `Unir` quedó una rayita recta conectando dos trazos separados, corregilo."*
* *"Los puntos titilan muy rápido cada cuadro; quiero que cada burbuja mantenga su tamaño fijo mientras dura el bucle."*
* *"Cuando subo `Escala`, el borde sigue finito; hacé que `Escala` afecte también el grosor del contorno."*

---

## Problemas frecuentes y cómo pedirle a la IA que los resuelva

| Lo que ves en pantalla | Por qué suele pasar | Qué decirle al asistente |
| :--- | :--- | :--- |
| **El pincel titila o cambia como loco en cada cuadro** | El código llama a `random()` directamente dentro de `pintar()`. | *"El pincel parpadea en cada cuadro; guardá los valores aleatorios por toque o usá `noise()` con semilla fija por trazo."* |
| **Aparece una línea recta cruzando la pantalla al usar `Unir`** | No se verificó `toque.primero` para cortar el trazo entre pinceladas. | *"Cuando uso `Unir` se conectan dos trazos separados; cortá el dibujo cada vez que `toque.primero` sea verdadero."* |
| **El trazo no se desvanece al terminar el bucle o al borrar** | El pincel usó un color fijo (`fill(255)`) en vez de `tinta` / `alpha(tinta)`. | *"El pincel no respeta la opacidad ni el desvanecimiento; asegurate de usar `tinta` y su canal alfa."* |
| **El botón del nuevo pincel pisa al botón `Borrar`** | Ya había 9 pinceles en la barra y se agregó un 10.º sin ajustar el ancho/paginación. | *"El botón del nuevo pincel se superpone con `Borrar` en la barra superior; ajustá `agregarPincelesAlInterface` para que entren todos los pinceles."* |
| **No pasa nada o da error al hacer clic en un solo punto** | El algoritmo asumió al menos 2 puntos o dividió por distancia `0`. | *"Revisá que `pintar()` funcione con `toques.length == 1` y protejá divisiones cuando dos toques tienen las mismas coordenadas."* |
