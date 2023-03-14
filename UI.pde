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
  
  left += 30 + 30;
  
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
  
  left += 9 * 25 + 30;
  
  for (int i = 1; i <= 8; i++) {
    w = new SelectButton(intf, left + (i-1) * 25, 5, 20, 20, "selectB" + i, "selectBrush", "B" + i);
    intf.addWidget(w, intf.getWidget("container"));
    ((SelectButton)w).selected = i == 1;
  }
  
  left += 8 * 25 + 30;
  
  w = new ColorSelector(intf, left, 5, 100, 20, "brushColor", "setColor");
  intf.addWidget(w, intf.getWidget("container"));
  
  left += 120;  
  
  w = new ColorSelector(intf, left, 5, 100, 20, "backColor", "setColor");
  ((ColorSelector)w).setColor(255, 255, 255);
  intf.addWidget(w, intf.getWidget("container"));  
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
  
  void press() {
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
  
  void press() {
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
  float r, g, b;
  boolean outdated;
  
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
  
  void press() {
    float mixw = width * 0.2;
    if (0 <= mouseX && mouseX <= mixw) {
      runCallback();
      outdated = false;
    }
  }
}

class ValueSlider extends Widget {
  String label;
  float value;
  
  ValueSlider() { }
  
  ValueSlider(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h);
  }

  ValueSlider(Interface intf, float x, float y, float w, float h, String callback, String label) {
    super(intf, x, y, w, h, "", callback);
    this.label = label;
  }

  ValueSlider(Interface intf, float x, float y, float w, float h, String name, String callback, String label) {
    super(intf, x, y, w, h, name, callback);
    this.label = label;
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
    runCallback();
  }
  
}
