void createUI() {
  intf = new Interface(this);
  intf.addFont("Arial", 10);
  intf.addFont("Arial", 11);
  intf.addFont("Arial", 12);
  intf.addFont("Arial", 14);
  intf.addFont("Arial", 16);

  Widget w;

  // Hotspot en la esquina superior izquierda (30x30): completamente invisible cuando UI está oculta.
  UIToggleHotspot cornerBtn = new UIToggleHotspot(intf, 0, 0, 30, 30, "toggleUI", "toggleUI");
  cornerBtn.setTooltip("Mostrar/ocultar interfaz (Enter)");
  intf.addWidget(cornerBtn);

  float containerW = max(width - 42, 1118);
  Container container = new Container(intf, 34, 4, containerW, 90, "container");
  intf.addWidget(container);
  container.hide();

  // --- FILA 1: Modo de trazo + Pinceles + Borrado / Ayuda ---
  intf.addWidget(new SectionLabel(intf, 8, 3, 175, 11, "MODO DE TRAZO"), container);
  intf.addWidget(new SectionLabel(intf, 198, 3, 640, 11, "PINCELES"), container);
  intf.addWidget(new SectionLabel(intf, 856, 3, 250, 11, "ACCIONES Y AYUDA"), container);

  ToggleButton loopBtn = new ToggleButton(intf, 8, 16, 58, 24, "toggleLoop", "toggleLoop", "Repetir");
  loopBtn.toggled = estado.repetirTrazos;
  loopBtn.activeColor = color(232, 93, 74);
  loopBtn.setTooltip("Repetir en bucle (Espacio): Los nuevos trazos se animan cíclicamente");
  intf.addWidget(loopBtn, container);

  ToggleButton autoBtn = new ToggleButton(intf, 70, 16, 50, 24, "toggleAuto", "toggleAuto", "1 vez");
  autoBtn.toggled = estado.borrarTrazosAuto;
  autoBtn.activeColor = color(217, 130, 43);
  autoBtn.setTooltip("Un solo ciclo (N): El trazo se reproduce una vez y se borra automáticamente");
  intf.addWidget(autoBtn, container);

  ToggleButton joinBtn = new ToggleButton(intf, 124, 16, 52, 24, "toggleJoin", "toggleJoin", "Unir");
  joinBtn.toggled = estado.unirTrazos;
  joinBtn.activeColor = color(43, 158, 179);
  joinBtn.setTooltip("Unir trazos (Tab / ~): Agrupa trazos sucesivos conservando pausas reales");
  intf.addWidget(joinBtn, container);

  intf.addWidget(new Divider(intf, 186, 6, 1, 34), container);

  agregarPincelesAlInterface(198, 16);

  intf.addWidget(new Divider(intf, 846, 6, 1, 34), container);

  ActionButton delBtn = new ActionButton(intf, 856, 16, 66, 24, "eraseAction", "eraseNow", "Borrar");
  delBtn.setTooltip("Borrar ahora (Supr): Borra último trazo o toda la capa si 'Modo: Todo' está activo");
  intf.addWidget(delBtn, container);

  ToggleButton delAllBtn = new ToggleButton(intf, 926, 16, 86, 24, "delAll", "delAll", "Modo: Todo");
  delAllBtn.toggled = estado.borrarTodosLosTrazos;
  delAllBtn.activeColor = color(201, 59, 59);
  delAllBtn.setTooltip("Modo de borrado (M): Activo = Supr borra toda la capa; Inactivo = solo el último trazo");
  intf.addWidget(delAllBtn, container);

  ToggleButton helpBtn = new ToggleButton(intf, 1018, 16, 76, 24, "toggleHelp", "toggleHelp", "? Ayuda");
  helpBtn.toggled = estado.mostrarAyuda;
  helpBtn.activeColor = color(78, 110, 242);
  helpBtn.setTooltip("Guía de uso y atajos de teclado (H)");
  intf.addWidget(helpBtn, container);

  // --- FILA 2: Capas + Colores + Parámetros ---
  intf.addWidget(new SectionLabel(intf, 8, 46, 360, 11, "CAPAS (1-9) / VISIBILIDAD"), container);
  intf.addWidget(new SectionLabel(intf, 382, 46, 166, 11, "COLOR TRAZO (A-G)"), container);
  intf.addWidget(new SectionLabel(intf, 562, 46, 140, 11, "FONDO (Z-X)"), container);
  intf.addWidget(new SectionLabel(intf, 716, 46, 434, 11, "PARÁMETROS DE TRAZO Y TIEMPOS"), container);

  float layerLeft = 8;
  for (int i = 1; i <= 9; i++) {
    float lx = layerLeft + (i - 1) * 26;
    VisibilityButton visBtn = new VisibilityButton(intf, lx, 59, 23, 7, "showL" + i, "showLayer");
    visBtn.toggled = true;
    visBtn.setTooltip("Mostrar/ocultar capa " + i + " (Shift+" + i + ")");
    intf.addWidget(visBtn, container);

    SelectButton layBtn = new SelectButton(intf, lx, 68, 23, 18, "selectL" + i, "selectLayer", str(i));
    layBtn.selected = (i == 1);
    layBtn.setTooltip("Seleccionar capa " + i + " (Tecla " + i + ")");
    intf.addWidget(layBtn, container);
  }

  float allLeft = layerLeft + 9 * 26;
  VisibilityButton showAllBtn = new VisibilityButton(intf, allLeft, 59, 44, 7, "showAll", "showAll");
  showAllBtn.toggled = true;
  showAllBtn.setTooltip("Mostrar/ocultar todas las capas (Shift+0)");
  intf.addWidget(showAllBtn, container);

  ToggleButton selAllBtn = new ToggleButton(intf, allLeft, 68, 44, 18, "selectAll", "selectAll", "Todas");
  selAllBtn.activeColor = color(58, 134, 255);
  selAllBtn.setTooltip("Seleccionar todas las capas para opacidad o borrado (Tecla 0)");
  intf.addWidget(selAllBtn, container);

  ValueSlider layerOpac = new ValueSlider(intf, allLeft + 50, 59, 78, 27, "layerOpacity", "setLayerOpacity", "Capa", SLIDER_PERCENT);
  layerOpac.setValue(1);
  layerOpac.setTooltip("Opacidad de capa activa (Shift+↑/↓ o [ / ])");
  intf.addWidget(layerOpac, container);

  intf.addWidget(new Divider(intf, 376, 48, 1, 38), container);

  ColorSelector brushCol = new ColorSelector(intf, 382, 59, 166, 27, "brushColor", "setColor", tintasPincel, true);
  brushCol.setColor(estado.tintaPincelSeleccionada.generarColor());
  brushCol.setTooltip("Color del trazo: clic en muestra (A-G) o arrastrá R / G / B");
  intf.addWidget(brushCol, container);

  intf.addWidget(new Divider(intf, 554, 48, 1, 38), container);

  ColorSelector backCol = new ColorSelector(intf, 562, 59, 140, 27, "backColor", "setColor", tintasFondo, false);
  backCol.setColor(estado.tintaFondoSeleccionada.generarColor());
  backCol.setTooltip("Color de fondo: clic en muestra (Z-X) o arrastrá R / G / B");
  intf.addWidget(backCol, container);

  intf.addWidget(new Divider(intf, 708, 48, 1, 38), container);

  ValueSlider brushOpac = new ValueSlider(intf, 716, 59, 104, 27, "brushOpacity", "setOpacity", "Opac.", SLIDER_PERCENT);
  brushOpac.setValue(1);
  brushOpac.setTooltip("Opacidad de nuevos trazos (Flechas ← / →)");
  intf.addWidget(brushOpac, container);

  ValueSlider brushScale = new ValueSlider(intf, 826, 59, 104, 27, "brushScale", "setScale", "Escala", SLIDER_SCALE);
  brushScale.setValue(0.5);
  brushScale.setTooltip("Escala/grosor de nuevos trazos (Flechas ↑ / ↓)");
  intf.addWidget(brushScale, container);

  ValueSlider eraseSpd = new ValueSlider(intf, 936, 59, 104, 27, "eraseSpeed", "setEraseSpeed", "Borrado", SLIDER_SECONDS);
  eraseSpd.setValue(0.5);
  eraseSpd.setTooltip("Tiempo de desvanecimiento al cerrar el bucle (- / +)");
  intf.addWidget(eraseSpd, container);

  ValueSlider backSpd = new ValueSlider(intf, 1046, 59, 104, 27, "backChangeSpeed", "setBackChangeSpeed", "Fondo t", SLIDER_SECONDS);
  backSpd.setValue(0.5);
  backSpd.setTooltip("Duración de transición del color de fondo (< / >)");
  intf.addWidget(backSpd, container);

  // Panel flotante de ayuda
  float helpW = min(width - 40, 780);
  float helpH = min(height - 130, 440);
  HelpOverlay helpOverlay = new HelpOverlay(intf, (width - helpW) * 0.5, 112, helpW, helpH, "helpOverlay");
  intf.addWidget(helpOverlay);
  helpOverlay.hide();
}

void drawStatusAndTooltip() {
  float y = 100;
  float x = 34;

  if (estado.unirTrazos && estado.registrandoTrazo) {
    String msg = "● Grabando secuencia unida — dibujá más trazos o presioná Tab / 'Unir' para reproducir";
    intf.setFont("Arial", 11);
    float tw = textWidth(msg) + 20;
    pushStyle();
    noStroke();
    fill(20, 46, 56, 235);
    rect(x, y, tw, 22, 6);
    stroke(62, 198, 224, 180);
    noFill();
    rect(x, y, tw, 22, 6);
    fill(170, 240, 255);
    textAlign(LEFT, CENTER);
    text(msg, x + 10, y + 10);
    popStyle();
    y += 26;
  }

  if (intf.currentTooltip != null && !intf.currentTooltip.equals("")) {
    String tip = intf.currentTooltip;
    intf.setFont("Arial", 11);
    float tw = textWidth(tip) + 20;
    pushStyle();
    noStroke();
    fill(18, 20, 26, 235);
    rect(x, y, tw, 22, 6);
    stroke(255, 255, 255, 55);
    noFill();
    rect(x, y, tw, 22, 6);
    fill(235, 238, 245);
    textAlign(LEFT, CENTER);
    text(tip, x + 10, y + 10);
    popStyle();
  }
}

void toggleUI(String name) {
  estado.invertirMostrarUI();
}

void toggleHelp(String name) {
  estado.invertirMostrarAyuda();
}

void closeHelp(String name) {
  if (estado.mostrarAyuda) {
    estado.invertirMostrarAyuda();
    estado.syncToggle("toggleHelp", false);
  }
}

void eraseNow(String name) {
  estado.borrarTrazos();
}

void selectLayer(String name) {
  for (int i = 1; i <= 9; i++) {
    if (name.equals("selectL" + i)) {
      int sel = i - 1;
      estado.seleccionarCapa(sel);
      for (int j = 1; j <= 9; j++) {
        SelectButton w = (SelectButton)intf.getWidget("selectL" + j);
        if (w != null) w.selected = (j - 1 == sel);
      }
      return;
    }
  }
}

void showLayer(String name) {
  for (int i = 1; i <= 9; i++) {
    if (name.equals("showL" + i)) {
      int sel = i - 1;
      if (estado.capaEstaOcultando(sel)) {
        estado.mostrarCapa(sel);
      } else {
        estado.ocultarCapa(sel);
      }
      return;
    }
  }
}

void toggleLoop(String name) {
  estado.invertirRepetirTrazos();
}

void toggleAuto(String name) {
  estado.invertirBorrarTrazosAuto();
}

void toggleJoin(String name) {
  estado.invertirUnirTrazos();
}

void showAll(String name) {
  ToggleButton button = (ToggleButton)intf.getWidget("showAll");
  if (button.toggled) {
    estado.mostrarTodasLasCapas();
  } else {
    estado.ocultarTodasLasCapas();
  }
}

void selectAll(String name) {
  estado.invertirSeleccionarTodasLasCapas();
}

void delAll(String name) {
  estado.invertirBorrarTodos();
}

void setColor(String name) {
  if (name.equals("brushColor")) {
    ColorSelector csel = (ColorSelector)intf.getWidget("brushColor");
    estado.crearTintaPincelSeleccionada(csel.getColor());
  } else if (name.equals("backColor")) {
    ColorSelector csel = (ColorSelector)intf.getWidget("backColor");
    estado.crearTintaFondoSeleccionada(csel.getColor());
  }
}

void setLayerOpacity(String name) {
  ValueSlider vsli = (ValueSlider)intf.getWidget("layerOpacity");
  estado.establecerOpacidadDeCapa(vsli.getValue());
}

void setOpacity(String name) {
  ValueSlider vsli = (ValueSlider)intf.getWidget("brushOpacity");
  estado.establecerFactorOpacidad(vsli.getValue());
}

void setScale(String name) {
  ValueSlider vsli = (ValueSlider)intf.getWidget("brushScale");
  estado.establecerFactorEscala(vsli.getValue());
}

void setEraseSpeed(String name) {
  ValueSlider vsli = (ValueSlider)intf.getWidget("eraseSpeed");
  estado.establecerTiempoBorradoTrazos(vsli.getValue());
}

void setBackChangeSpeed(String name) {
  ValueSlider vsli = (ValueSlider)intf.getWidget("backChangeSpeed");
  estado.establecerTiempoTransicionFondo(vsli.getValue());
}

final int SLIDER_PERCENT = 0;
final int SLIDER_SCALE = 1;
final int SLIDER_SECONDS = 2;

class UIToggleHotspot extends ToggleButton {
  UIToggleHotspot(Interface intf, float x, float y, float w, float h, String name, String callback) {
    super(intf, x, y, w, h, name, callback, "");
  }

  void draw() {
    // Completamente invisible cuando la interfaz está oculta.
    if (!estado.mostrarUI) return;

    PApplet p = intf.sketch;
    boolean hovered = (intf.focused == this);
    p.noStroke();
    p.fill(hovered ? color(52, 56, 70, 240) : color(26, 28, 36, 232));
    p.rect(4, 4, 24, 24, 6);
    p.stroke(255, 255, 255, hovered ? 140 : 60);
    p.noFill();
    p.rect(4, 4, 24, 24, 6);

    p.stroke(230);
    p.strokeWeight(1.5);
    p.line(11, 11, 21, 21);
    p.line(21, 11, 11, 21);
  }
}

class SectionLabel extends Widget {
  String text = "";

  SectionLabel(Interface intf, float x, float y, float w, float h, String txt) {
    super(intf, x, y, w, h, "", "");
    isActive = false;
    text = txt;
  }

  void draw() {
    PApplet p = intf.sketch;
    intf.setFont("Arial", 10);
    p.fill(158, 166, 184);
    p.textAlign(LEFT, CENTER);
    p.text(text, 0, 0, width, height);
  }
}

class Divider extends Widget {
  Divider(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h, "", "");
    isActive = false;
  }

  void draw() {
    PApplet p = intf.sketch;
    p.noStroke();
    p.fill(255, 255, 255, 32);
    p.rect(0, 0, width, height);
  }
}

class Label extends Widget {
  String text = "";

  Label() { }

  Label(Interface intf, float x, float y, float w, float h, String txt) {
    super(intf, x, y, w, h, "", "");
    isActive = false;
    text = txt;
  }

  Label(Interface intf, float x, float y, float w, float h, String name, String txt) {
    super(intf, x, y, w, h, name, "");
    isActive = false;
    text = txt;
  }

  void draw() {
    PApplet p = intf.sketch;
    intf.setFont("Arial", 12);
    p.fill(230);
    p.textAlign(CENTER, CENTER);
    p.text(text, 0, 0, width, height);
  }
}

class ActionButton extends Widget {
  String label = "";
  boolean pressing = false;

  ActionButton(Interface intf, float x, float y, float w, float h, String name, String callback, String label) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
  }

  void draw() {
    PApplet p = intf.sketch;
    boolean hovered = (intf.focused == this);

    p.noStroke();
    if (pressing) p.fill(92, 98, 120);
    else if (hovered) p.fill(64, 69, 86);
    else p.fill(44, 48, 60);
    p.rect(0, 0, width, height, 5);

    p.stroke(255, 255, 255, hovered ? 110 : 40);
    p.noFill();
    p.rect(0, 0, width, height, 5);

    intf.setFont("Arial", 11);
    p.fill(240);
    p.textAlign(CENTER, CENTER);
    p.text(label, 0, -1, width, height);
  }

  void press() {
    pressing = true;
  }

  void release() {
    pressing = false;
    runCallback();
  }

  void lostFocus() {
    pressing = false;
  }
}

class SelectButton extends Widget {
  String label = "";
  boolean selected = false;
  color activeColor = color(58, 134, 255);

  SelectButton() { }

  SelectButton(Interface intf, float x, float y, float w, float h, String name, String callback, String label) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
  }

  void draw() {
    PApplet p = intf.sketch;
    boolean hovered = (intf.focused == this);

    p.noStroke();
    if (selected) p.fill(activeColor);
    else if (hovered) p.fill(62, 67, 84);
    else p.fill(42, 46, 58);
    p.rect(0, 0, width, height, 5);

    p.stroke(255, 255, 255, selected ? 180 : (hovered ? 95 : 35));
    p.noFill();
    p.rect(0, 0, width, height, 5);

    intf.setFont("Arial", 11);
    p.fill(selected ? 255 : 220);
    p.textAlign(CENTER, CENTER);
    p.text(label, 0, -1, width, height);
  }

  void release() {
    selected = true;
    runCallback();
  }
}

class ToggleButton extends Widget {
  String label = "";
  boolean toggled = false;
  color activeColor = color(232, 93, 74);

  ToggleButton() { }

  ToggleButton(Interface intf, float x, float y, float w, float h, String name, String callback, String label) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
  }

  void draw() {
    PApplet p = intf.sketch;
    boolean hovered = (intf.focused == this);

    p.noStroke();
    if (toggled) p.fill(activeColor);
    else if (hovered) p.fill(62, 67, 84);
    else p.fill(42, 46, 58);
    p.rect(0, 0, width, height, 5);

    p.stroke(255, 255, 255, toggled ? 170 : (hovered ? 95 : 35));
    p.noFill();
    p.rect(0, 0, width, height, 5);

    intf.setFont("Arial", 11);
    p.fill(toggled ? 255 : 215);
    p.textAlign(CENTER, CENTER);
    p.text(label, 0, -1, width, height);
  }

  void release() {
    toggled = !toggled;
    runCallback();
  }
}

class VisibilityButton extends ToggleButton {
  VisibilityButton(Interface intf, float x, float y, float w, float h, String name, String callback) {
    super(intf, x, y, w, h, name, callback, "");
  }

  void draw() {
    PApplet p = intf.sketch;
    boolean hovered = (intf.focused == this);
    p.noStroke();
    if (toggled) {
      p.fill(hovered ? color(82, 224, 148) : color(52, 199, 123));
    } else {
      p.fill(hovered ? color(110, 72, 78) : color(66, 68, 78));
    }
    p.rect(0, 0, width, height, 3);
  }
}

class Container extends Widget {
  Container() { }

  Container(Interface intf, float x, float y, float w, float h, String name) {
    super(intf, x, y, w, h, name, "");
  }

  void draw() {
    PApplet p = intf.sketch;
    p.noStroke();
    p.fill(24, 26, 34, 232);
    p.rect(0, 0, width, height, 8);
    p.stroke(255, 255, 255, 48);
    p.noFill();
    p.rect(0, 0, width, height, 8);
  }
}

class ColorSelector extends Widget {
  float r = 0;
  float g = 0;
  float b = 0;
  ArrayList<Tinta> presets;
  boolean applyOnDrag = true;
  int activeChannel = -1;

  ColorSelector() { }

  ColorSelector(Interface intf, float x, float y, float w, float h, String name, String callback, ArrayList<Tinta> presets, boolean applyOnDrag) {
    super(intf, x, y, w, h, name, callback);
    this.presets = presets;
    this.applyOnDrag = applyOnDrag;
  }

  void setColor(int r, int g, int b) {
    this.r = constrain(r / 255.0, 0, 1);
    this.g = constrain(g / 255.0, 0, 1);
    this.b = constrain(b / 255.0, 0, 1);
  }

  void setColor(color c) {
    this.r = red(c) / 255.0;
    this.g = green(c) / 255.0;
    this.b = blue(c) / 255.0;
  }

  color getColor() {
    return color(255 * r, 255 * g, 255 * b);
  }

  void draw() {
    PApplet p = intf.sketch;
    float previewW = 24;
    float topH = 12;
    float barY = 15;
    float barH = height - barY;
    float cmpW = (width - 4) / 3.0;

    // Muestra actual
    p.stroke(255, 255, 255, 160);
    p.fill(255 * r, 255 * g, 255 * b);
    p.rect(0, 0, previewW, topH, 3);

    // Muestras predefinidas (A-G / Z-X)
    if (presets != null) {
      float sx = previewW + 6;
      for (int i = 0; i < presets.size(); i++) {
        Tinta t = presets.get(i);
        color tc = t.generarColor();
        boolean isCurrent = abs(red(tc) - 255 * r) < 2 && abs(green(tc) - 255 * g) < 2 && abs(blue(tc) - 255 * b) < 2;
        p.fill(tc);
        p.stroke(isCurrent ? color(255, 220, 80) : color(255, 255, 255, 90));
        p.strokeWeight(isCurrent ? 1.5 : 1);
        p.rect(sx + i * 16, 0, 12, topH, 3);
      }
      p.strokeWeight(1);
    }

    // Barras R, G, B
    float xR = 0;
    float xG = cmpW + 2;
    float xB = 2 * (cmpW + 2);

    p.noStroke();
    p.fill(35, 15, 18);
    p.rect(xR, barY, cmpW, barH, 3);
    p.fill(220, 55, 55);
    p.rect(xR, barY, max(2, r * cmpW), barH, 3);

    p.fill(15, 35, 20);
    p.rect(xG, barY, cmpW, barH, 3);
    p.fill(60, 205, 95);
    p.rect(xG, barY, max(2, g * cmpW), barH, 3);

    p.fill(15, 22, 42);
    p.rect(xB, barY, cmpW, barH, 3);
    p.fill(65, 145, 245);
    p.rect(xB, barY, max(2, b * cmpW), barH, 3);

    p.stroke(255);
    p.line(xR + r * cmpW, barY, xR + r * cmpW, barY + barH);
    p.line(xG + g * cmpW, barY, xG + g * cmpW, barY + barH);
    p.line(xB + b * cmpW, barY, xB + b * cmpW, barY + barH);
  }

  void press() {
    float previewW = 24;
    float topH = 12;
    float barY = 15;
    float cmpW = (width - 4) / 3.0;
    activeChannel = -1;

    if (mouseY <= topH + 1 && presets != null) {
      float sx = previewW + 6;
      for (int i = 0; i < presets.size(); i++) {
        float px = sx + i * 16;
        if (px - 2 <= mouseX && mouseX <= px + 14) {
          setColor(presets.get(i).generarColor());
          runCallback();
          return;
        }
      }
    }

    if (barY - 2 <= mouseY) {
      float xG = cmpW + 2;
      float xB = 2 * (cmpW + 2);
      if (mouseX < xG) activeChannel = 0;
      else if (mouseX < xB) activeChannel = 1;
      else activeChannel = 2;
      updateChannelFromMouse();
      if (applyOnDrag) runCallback();
    }
  }

  void drag() {
    if (0 <= activeChannel) {
      updateChannelFromMouse();
      if (applyOnDrag) runCallback();
    }
  }

  void release() {
    if (0 <= activeChannel) {
      updateChannelFromMouse();
      runCallback();
      activeChannel = -1;
    }
  }

  void updateChannelFromMouse() {
    float cmpW = (width - 4) / 3.0;
    float xR = 0;
    float xG = cmpW + 2;
    float xB = 2 * (cmpW + 2);
    if (activeChannel == 0) {
      r = constrain((mouseX - xR) / cmpW, 0, 1);
    } else if (activeChannel == 1) {
      g = constrain((mouseX - xG) / cmpW, 0, 1);
    } else if (activeChannel == 2) {
      b = constrain((mouseX - xB) / cmpW, 0, 1);
    }
  }
}

class ValueSlider extends Widget {
  float value = 0;
  String label = "";
  int formatMode = SLIDER_PERCENT;

  ValueSlider() { }

  ValueSlider(Interface intf, float x, float y, float w, float h, String name, String callback, String label, int formatMode) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
    this.formatMode = formatMode;
  }

  void setValue(float v) {
    this.value = constrain(v, 0, 1);
  }

  float getValue() {
    return value;
  }

  String formattedValue() {
    if (formatMode == SLIDER_PERCENT) {
      return int(round(value * 100)) + "%";
    } else if (formatMode == SLIDER_SCALE) {
      float esc = value <= 0.5 ? map(value, 0, 0.5, 0, 1) : map(value, 0.5, 1, 1, 10);
      return nf(esc, 1, 1) + "x";
    } else if (formatMode == SLIDER_SECONDS) {
      float ms = value <= 0.5 ? map(value, 0, 0.5, 0, 2000) : map(value, 0.5, 1, 2000, 15000);
      return nf(ms / 1000.0, 1, 1) + "s";
    }
    return nf(value, 1, 2);
  }

  void draw() {
    PApplet p = intf.sketch;
    boolean hovered = (intf.focused == this || intf.activeWidget == this);

    p.noStroke();
    p.fill(38, 42, 54);
    p.rect(0, 0, width, height, 5);

    // Relleno de progreso
    float fillW = max(0, value * width);
    p.fill(hovered ? color(74, 148, 255, 175) : color(58, 134, 255, 135));
    p.rect(0, 0, fillW, height, 5);

    // Línea marcadora
    p.stroke(255, 255, 255, 220);
    p.line(constrain(fillW, 1, width - 1), 2, constrain(fillW, 1, width - 1), height - 2);

    p.stroke(255, 255, 255, hovered ? 110 : 40);
    p.noFill();
    p.rect(0, 0, width, height, 5);

    intf.setFont("Arial", 10);
    p.fill(245);
    p.textAlign(LEFT, CENTER);
    p.text(label, 6, -1, width - 12, height);
    p.textAlign(RIGHT, CENTER);
    p.text(formattedValue(), 6, -1, width - 12, height);
  }

  void press() {
    value = constrain((float)(mouseX) / width, 0, 1);
    runCallback();
  }

  void drag() {
    value = constrain((float)(mouseX) / width, 0, 1);
    runCallback();
  }

  void release() {
    value = constrain((float)(mouseX) / width, 0, 1);
    runCallback();
  }
}

class HelpOverlay extends Widget {
  HelpOverlay(Interface intf, float x, float y, float w, float h, String name) {
    super(intf, x, y, w, h, name, "");
  }

  void setup() {
    ActionButton closeBtn = new ActionButton(intf, width - 78, 12, 64, 24, "closeHelpBtn", "closeHelp", "Cerrar");
    closeBtn.setTooltip("Cerrar ayuda (H)");
    intf.addWidget(closeBtn, this);
  }

  void draw() {
    PApplet p = intf.sketch;
    p.noStroke();
    p.fill(20, 22, 30, 244);
    p.rect(0, 0, width, height, 10);
    p.stroke(255, 255, 255, 70);
    p.noFill();
    p.rect(0, 0, width, height, 10);

    intf.setFont("Arial", 16);
    p.fill(255);
    p.textAlign(LEFT, TOP);
    p.text("Andiamo 2 — Guía rápida y atajos", 20, 16);

    float col1X = 20;
    float col1W = width * 0.45;
    float col2X = col1X + col1W + 24;
    float col2W = width - col2X - 20;

    intf.setFont("Arial", 12);
    p.fill(110, 200, 255);
    p.text("Mecánica de dibujo en vivo (bucles)", col1X, 52);

    intf.setFont("Arial", 11);
    p.fill(225);
    String mechanics =
      "• Cada trazo graba tus movimientos con su tiempo exacto.\n\n" +
      "• Repetir (Espacio): al soltar, el trazo vuelve a dibujarse en bucle " +
      "con el mismo ritmo y se desvanece según el tiempo de 'Borrado'.\n\n" +
      "• 1 vez (N): reproduce el trazo una sola vez y se elimina.\n\n" +
      "• Fijo: si 'Repetir' y '1 vez' están apagados, el trazo queda quieto.\n\n" +
      "• Unir (Tab / ~): mantené trazos separados en un mismo bucle " +
      "conservando las pausas reales entre cada pincelada.\n\n" +
      "• Ocultar UI: presioná Enter o hacé clic en la esquina superior izquierda (30×30 px, invisible al ocultar).";
    p.text(mechanics, col1X, 74, col1W, height - 90);

    intf.setFont("Arial", 12);
    p.fill(110, 200, 255);
    p.text("Atajos de teclado", col2X, 52);

    intf.setFont("Arial", 11);
    p.fill(225);
    String shortcuts =
      "Enter: Mostrar / ocultar interfaz\n" +
      "H o ?: Mostrar / ocultar esta ayuda\n" +
      "Espacio: Activar / desactivar Repetir\n" +
      "N: Activar / desactivar modo 1 vez\n" +
      "Tab / ~: Activar / desactivar Unir trazos\n" +
      "Supr / Backspace: Borrar último trazo (o capa en Modo Todo)\n" +
      "Shift + Supr: Borrar toda la capa seleccionada\n" +
      "M: Alternar Modo Todo / Último trazo\n" +
      "1–9: Seleccionar capa 1 a 9   |   0: Todas las capas\n" +
      "Shift + 1–9 / Shift + 0: Mostrar u ocultar capa(s)\n" +
      "← / →: Opacidad del nuevo trazo\n" +
      "↑ / ↓: Escala / grosor del nuevo trazo\n" +
      "Shift + ↑ / ↓ (o [ / ]): Opacidad de capa\n" +
      "- / +: Tiempo de borrado   |   < / >: Transición de fondo\n" +
      "Q W E R T Y U I O: Seleccionar pincel 1 al 9\n" +
      "A S D F G: Colores de pincel   |   Z / X: Fondo blanco / negro";
    p.text(shortcuts, col2X, 74, col2W, height - 90);
  }
}
