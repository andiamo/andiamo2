class Interface {
  PApplet sketch;
  float scaleFactor;
  Widget focused;
  ArrayList<Widget> drawn;
  HashMap<String, PFont> fonts;
  HashMap<String, Widget> widgets;
  Widget root;
    
  Interface(PApplet sketch) {
    this(sketch, 1);
  }
  
  Interface(PApplet sketch, float scale) {
    this.sketch = sketch;
    
    scaleFactor = scale;
    focused = null;
    drawn = new ArrayList<Widget>(); 
    fonts = new HashMap<String, PFont>();
    widgets = new HashMap<String, Widget>();
    root = new Widget(this);
  }

  void addWidget(Widget w) {
    addWidget(w, null, "");
  }

  void addWidget(Widget w, Widget parent) {
    addWidget(w, parent, "");
  }

  void addWidget(Widget w, String parentName) {
    addWidget(w, null, parentName);
  }

  void addWidget(Widget w, Widget parent, String parentName) {
    if (parent != null) {
      parent.addChildren(w);
    } else {
      if (parentName != null && !parentName.equals("")) {
        Widget namedParent = getWidget(parentName);
        if (namedParent != null) {
          namedParent.addChildren(w);
        }
      } else {
        root.addChildren(w);
      }
    }
    if (w.name != null && !w.name.equals("")) {
      widgets.put(w.name, w);
    }

    w.setup();
  }

  Widget getWidget(String name) {
    if (widgets.containsKey(name)) {
      return widgets.get(name);
    } else {
      return null;
    }
  }

  void addFont(String name, int size) {
    PFont font = sketch.createFont(name, scaleFactor * size);
    fonts.put(name + str(size), font);
  }

  void setFont(String name, int size) {
    String key = name + str(size);
    if (fonts.containsKey(key)) {
      PFont font = fonts.get(key);
      sketch.textFont(font, size);
    }
  }

  void update() {
    root.updateChildren();
    drawn.clear();
    root.drawChildren();
  }

  void addDrawn(Widget w) {
    drawn.add(w);
  }

  boolean mousePressed() {
    setFocused(sketch.mouseX, sketch.mouseY);
    if (focused != null) {
      focused.setRelMousePos();
      focused.press();
      return true;
    }
    return false;
  }

  boolean mouseMoved() {
    setFocused(sketch.mouseX, sketch.mouseY);
    if (focused != null) {
      focused.setRelMousePos();
      focused.hover();
      return true;
    }
    return false;
  }

  boolean mouseDragged() {
    setFocused(sketch.mouseX, sketch.mouseY);
    if (focused != null) {
      focused.setRelMousePos();
      focused.drag();
      return true;
    }
    return false;
  }

  boolean mouseReleased() {
    setFocused(sketch.mouseX, sketch.mouseY);
    if (focused != null) {
      focused.setRelMousePos();
      focused.release();
      return true;
    }
    return false;
  }

  void setFocused(int mx, int my) {
    Widget pfocused = this.focused;
    focused = null;
    for (int i = drawn.size() - 1; i >= 0; i--) {
      Widget child = drawn.get(i);
      if (child.isVisible && child.isActive && child.hasFocus(mx, my)) {
        if (pfocused != null && pfocused != child) {
          pfocused.lostFocus();
        }
        focused = child;
        return;
      }
    }
    if (pfocused != null) {
      pfocused.lostFocus();
    }
  }
}
