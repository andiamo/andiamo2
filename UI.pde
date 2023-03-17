void createUI() {
  intf = new Interface(this);
  intf.addFont("Arial", 14);  
  
  Widget w;
  
  w = new ToggleButton(intf, 0, 0, 30, 30, "toggleUI", "toggleUI", "UI");
  intf.addWidget(w);
  
  w = new Container(intf, 30, 0, width - 30, 30, "container");
  intf.addWidget(w);
  w.hide();
  
  float left = 5;
  
  w = new ToggleButton(intf, left, 0, 30, 30, "toggleLoop", "toggleLoop", "L");
  intf.addWidget(w, intf.getWidget("container"));
  ((ToggleButton)w).toggled = true;

  left += 30 + 5;
  
  w = new ToggleButton(intf, left, 0, 30, 30, "toggleJoin", "toggleJoin", "J");
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 30 + 5;
  
  for (int i = 1; i <= 9; i++) {
    w = new SelectButton(intf, left + (i-1) * 25, 10, 20, 20, "selectL" + i, "selectLayer", "L" + i);
    intf.addWidget(w, intf.getWidget("container"));
    ((SelectButton)w).selected = i == 1;
  }
  
  for (int i = 1; i <= 9; i++) {
    w = new ToggleButton(intf, left + (i-1) * 25, 0, 20, 10, "showL" + i, "toggleLayer", "-");
    intf.addWidget(w, intf.getWidget("container"));
    ((ToggleButton)w).toggled = true;
  }
  
  left += 9 * 25;
  
  w = new ToggleButton(intf, left, 0, 20, 10, "delAll", "delAll", "-");
  intf.addWidget(w, intf.getWidget("container"));
  w = new ToggleButton(intf, left, 10, 20, 20, "toggleAll", "toggleAll", "A");  
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 45;

  intf.addWidget(new Label(intf, left - 20, 5, 20, 20, "c1"), intf.getWidget("container"));    
  w = new ColorSelector(intf, left, 5, 100, 20, "brushColor", "setColor");
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 130;
  
  intf.addWidget(new Label(intf, left - 20, 5, 20, 20, "c0"), intf.getWidget("container"));
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
  
  agregarPincelesAlUI(left);
}

void toggleUI(String name) {
  estado.invertirMostrarUI();  
}

void selectLayer(String name) {
  if (name.equals("selectL1")) {
    selectLayer(0);
  } else if (name.equals("selectL2")) {
    selectLayer(1);
  } else if (name.equals("selectL3")) {
    selectLayer(2);
  } else if (name.equals("selectL4")) {
    selectLayer(3);
  } else if (name.equals("selectL5")) {
    selectLayer(4);
  } else if (name.equals("selectL6")) {
    selectLayer(5);
  } else if (name.equals("selectL7")) {
    selectLayer(6);
  } else if (name.equals("selectL8")) {
    selectLayer(7);
  } else if (name.equals("selectL9")) {
    selectLayer(8);
  }
}

void selectLayer(int layer) {
  estado.seleccionarCapa(layer);  
  for (int i = 1; i <= 9; i++) {
    SelectButton w = (SelectButton)intf.getWidget("selectL" + i);
    if (i - 1 != layer) {
      w.selected = false;
    }    
  }
}

void toggleLayer(String name) {
  if (name.equals("showL1")) {
    toggleLayer(0);
  } else if (name.equals("showL2")) {
    toggleLayer(1);
  } else if (name.equals("showL3")) {
    toggleLayer(2);
  } else if (name.equals("showL4")) {
    toggleLayer(3);
  } else if (name.equals("showL5")) {
    toggleLayer(4);
  } else if (name.equals("showL6")) {
    toggleLayer(5);
  } else if (name.equals("showL7")) {
    toggleLayer(6);
  } else if (name.equals("showL8")) {
    toggleLayer(7);
  } else if (name.equals("showL9")) {
    toggleLayer(8);
  }
}

void toggleLayer(int layer) {
  if (estado.capaEstaOculta(layer)) {
    estado.mostrarCapa(layer);
  } else {
    estado.ocultarCapa(layer);
  }
}

void toggleLoop(String name) {
  estado.invertirRepetirTrazos();  
}

void toggleJoin(String name) {
  estado.invertirUnirTrazos();
}

void toggleAll(String name) {
  estado.invertirSeleccionarTodas();  
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
