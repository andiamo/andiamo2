void createUI() {
  intf = new Interface(this);
  intf.addFont("Arial", 14);  
  
  Widget w;
  
  w = new ToggleButton(intf, 0, 0, 30, 30, "toggleUI", "toggleUI", "I");
  intf.addWidget(w);
  
  w = new Container(intf, 30, 0, width - 30, 30, "container");
  intf.addWidget(w);
  w.hide();
  
  float left = 5;
  
  w = new ToggleButton(intf, left, 0, 20, 30, "toggleLoop", "toggleLoop", "R");
  intf.addWidget(w, intf.getWidget("container"));
  ((ToggleButton)w).toggled = true;

  left += 20 + 5;  
  
  w = new ToggleButton(intf, left, 0, 20, 30, "toggleAuto", "toggleAuto", "1");
  intf.addWidget(w, intf.getWidget("container"));

  left += 20 + 5;
  
  w = new ToggleButton(intf, left, 0, 20, 30, "toggleJoin", "toggleJoin", "U");
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 20 + 5;
  
  w = new ToggleButton(intf, left, 0, 20, 30, "delAll", "delAll", "B");
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 20 + 5;
  
  for (int i = 1; i <= 9; i++) {
    w = new SelectButton(intf, left + (i-1) * 25, 10, 20, 20, "selectL" + i, "selectLayer", "C" + i);
    intf.addWidget(w, intf.getWidget("container"));
    ((SelectButton)w).selected = i == 1;
  }
  
  for (int i = 1; i <= 9; i++) {
    w = new ToggleButton(intf, left + (i-1) * 25, 0, 20, 10, "showL" + i, "showLayer", "-");
    intf.addWidget(w, intf.getWidget("container"));
    ((ToggleButton)w).toggled = true;
  }
  
  left += 9 * 25;
  
  w = new ToggleButton(intf, left, 0, 20, 10, "showAll", "showAll", "-");
  intf.addWidget(w, intf.getWidget("container"));
  ((ToggleButton)w).toggled = true;
  
  w = new ToggleButton(intf, left, 10, 20, 20, "selectAll", "selectAll", "T");  
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 45;

  intf.addWidget(new Label(intf, left - 20, 5, 20, 20, "cp"), intf.getWidget("container"));    
  w = new ColorSelector(intf, left, 5, 100, 20, "brushColor", "setColor");
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 130;
  
  intf.addWidget(new Label(intf, left - 20, 5, 20, 20, "cf"), intf.getWidget("container"));
  w = new ColorSelector(intf, left, 5, 100, 20, "backColor", "setColor");
  ((ColorSelector)w).setColor(255, 255, 255);
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 130;
  
  intf.addWidget(new Label(intf, left - 15, 5, 15, 20, "o"), intf.getWidget("container"));
  w = new ValueSlider(intf, left, 10, 60, 10, "brushOpacity", "setOpacity");
  ((ValueSlider)w).setValue(1);
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 80;
  
  intf.addWidget(new Label(intf, left - 15, 5, 15, 20, "e"), intf.getWidget("container"));
  w = new ValueSlider(intf, left, 10, 60, 10, "brushScale", "setScale");
  ((ValueSlider)w).setValue(0.5);
  intf.addWidget(w, intf.getWidget("container"));

  left += 80;
  
  intf.addWidget(new Label(intf, left - 15, 5, 15, 20, "b"), intf.getWidget("container"));
  w = new ValueSlider(intf, left, 10, 60, 10, "eraseSpeed", "setEraseSpeed");
  ((ValueSlider)w).setValue(0.5);
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 80;
  
  intf.addWidget(new Label(intf, left - 15, 5, 15, 20, "f"), intf.getWidget("container"));
  w = new ValueSlider(intf, left, 10, 60, 10, "backChangeSpeed", "setBackChangeSpeed");
  ((ValueSlider)w).setValue(0.5);
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 80;
  
  agregarPincelesAlInterface(left);
}

void toggleUI(String name) {
  estado.invertirMostrarUI();  
}

void selectLayer(String name) {
  for (int i = 1; i <= 9; i++) {
    if (name.equals("selectL" + i)) {
      int sel = i - 1;      
      estado.seleccionarCapa(sel);
      for (int j = 1; j <= 9; j++) {
        SelectButton w = (SelectButton)intf.getWidget("selectL" + j);
        if (j - 1 != sel) {
          w.selected = false;
        }
      }
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

class Label extends Widget {
  String text = "";
  
  Label() { }
    
  Label(Interface intf, float x, float y, float w, float h, String txt) {
    super(intf, x, y, w, h, "", "");
    text = txt;
  }
  
  Label(Interface intf, float x, float y, float w, float h, String name, String txt) {
    super(intf, x, y, w, h, name, "");
    text = txt;
  }
  
  void draw() {
    PApplet p = intf.sketch;
    intf.setFont("Arial", 14);
    p.fill(0);    
    p.textAlign(CENTER, CENTER);
    p.text(text, 0, 0, width, height);
  }  
}

class SelectButton extends Widget {
  String label = "";
  boolean selected = false;
  
  SelectButton() { }
  
  SelectButton(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h, "", "");
  }

  SelectButton(Interface intf, float x, float y, float w, float h, String callback, String label) {
    super(intf, x, y, w, h, "", callback);
    this.label = label;
  }
  
  SelectButton(Interface intf, float x, float y, float w, float h, String name, String callback, String label) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
  }
  
  void draw() {
    PApplet p = intf.sketch;
    
    p.noStroke();
    if (selected) p.fill(255, 0 ,0);
    else p.fill(255);
    p.rect(0, 0, width, height, 5);
    intf.setFont("Arial", 14);
    if (selected) p.fill(255);
    else p.fill(0);
    
    p.textAlign(CENTER, CENTER);
    p.text(label, 0, 0, width, height);
  }
  
  void release() {
    selected = true;
    runCallback();
  }
}

class ToggleButton extends Widget {
  String label = "";
  boolean toggled = false;
  
  ToggleButton() { }
  
  ToggleButton(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h, "", "");
  }

    ToggleButton(Interface intf, float x, float y, float w, float h, String callback, String label) {
    super(intf, x, y, w, h, "", callback);
    this.label = label;
  }
  
  ToggleButton(Interface intf, float x, float y, float w, float h, String name, String callback, String label) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
  }
  
  void draw() {
    PApplet p = intf.sketch;
    
    p.noStroke();
    if (toggled) p.fill(255, 0 ,0);
    else p.fill(255);
    p.rect(0, 0, width, height, 5);
    intf.setFont("Arial", 14);
    if (toggled) p.fill(255);
    else p.fill(0);
    
    p.textAlign(CENTER, CENTER);
    p.text(label, 0, 0, width, height);
  }
  
  void release() {
    toggled = !toggled;
    runCallback();
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
    p.fill(255);
    p.rect(0, 0, width, height, 5);
  }
}

class ColorSelector extends Widget {
  float r = 0; 
  float g = 0; 
  float b = 0;
  boolean outdated = false;
  
  ColorSelector() { }
  
  ColorSelector(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h);
  }

  ColorSelector(Interface intf, float x, float y, float w, float h, String callback) {
    super(intf, x, y, w, h, "", callback);
  }

  ColorSelector(Interface intf, float x, float y, float w, float h, String name, String callback) {
    super(intf, x, y, w, h, name, callback);
  }
  
  void setColor(int r, int g, int b) {
    this.r = r / 255.0;
    this.g = g / 255.0;
    this.b = b / 255.0;
  }
  
  void setColor(color c) {
    this.r = red(c) / 255.0;
    this.g = red(c) / 255.0;
    this.b = blue(c) / 255.0;
  }  
  
  color getColor() {
    return color(255 * r, 255 * g, 255 * b);
  }
  
  void draw() {
    PApplet p = intf.sketch;
    float mixw = width * 0.2;
    float cmpw = width * 0.27;
    float x;
    
    if (outdated) p.noStroke(); 
    else p.stroke(0);
    p.fill(255 * r, 255 * g, 255 * b);
    rect(0, 0, mixw, height, 5);
    
    p.noStroke();
    
    p.fill(255 * r, 0, 0);    
    rect(mixw, 0, cmpw, height, 5);
    
    p.fill(0, 255 * g, 0);
    rect(mixw + cmpw, 0, cmpw, height, 5);
    
    p.fill(0, 0, 255 * b);
    rect(mixw + 2 * cmpw, 0, cmpw, height, 5);
    
    p.stroke(255);
    
    x = mixw + r * cmpw;
    p.line(x, 0, x, height);
    
    x = mixw + cmpw + g * cmpw;
    p.line(x, 0, x, height);
    
    x = mixw + 2 * cmpw + b * cmpw;
    p.line(x, 0, x, height);    
  }
  
  void drag() {
    float mixw = width * 0.2;
    float cmpw = width * 0.27;
    
    if (mixw <= mouseX && mouseX <= mixw + cmpw) {
      r = map(mouseX, mixw, mixw + cmpw, 0, 1);
      outdated = true;
    }
    
    if (mixw + cmpw <= mouseX && mouseX <= mixw + 2 * cmpw) {
      g = map(mouseX, mixw + cmpw, mixw + 2 * cmpw, 0, 1);
      outdated = true;
    }
    
    if (mixw + 2 * cmpw <= mouseX && mouseX <= mixw + 3 * cmpw) {
      b = map(mouseX, mixw + 2 * cmpw, mixw + 3 * cmpw, 0, 1);
      outdated = true;
    }    
  }
  
  void release() {
    float mixw = width * 0.2;
    if (0 <= mouseX && mouseX <= mixw) {
      runCallback();
      outdated = false;
    }
  }
}

class ValueSlider extends Widget {
  float value = 0;
  
  ValueSlider() { }
  
  ValueSlider(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h);
  }

  ValueSlider(Interface intf, float x, float y, float w, float h, String callback) {
    super(intf, x, y, w, h, "", callback);
  }

  ValueSlider(Interface intf, float x, float y, float w, float h, String name, String callback) {
    super(intf, x, y, w, h, name, callback);
  }
  
  void setValue(float v) {
    this.value = v;
  }

  float getValue() {
    return value;
  }
  
  void draw() {
    PApplet p = intf.sketch;
    
    p.stroke(0);
    p.noFill();
    p.rect(0, 0, width, height, 5);
    
    float x = value * width;
    p.line(x, 0, x, height);     
  }
  
  void drag() {
    value = (float)(mouseX) / width;
  }
  
  void release() {
    value = (float)(mouseX) / width;
    runCallback();
  }
}
