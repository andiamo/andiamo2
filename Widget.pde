class Widget {
    Interface intf;
    float relX;
    float relY;
    float absX;
    float absY;
    float width;
    float height;
    float mouseX;
    float mouseY;
    float pmouseX;
    float pmouseY;
    boolean isFocused;
    Widget parent;
    ArrayList<Widget> children;
    boolean isActive;
    boolean isVisible;
    String name;
    String callback;
    
  Widget() { }  
  
  Widget(Interface intf) {
    this(intf, 0, 0, 0, 0, "", "");
  }

  Widget(Interface intf, float x, float y, float w, float h) {
    this(intf, x, y, w, h, "", "");
  }

  Widget(Interface intf, float x, float y, float w, float h, String name) {
    this(intf, x, y, w, h, name, "");
  }  
  
  Widget(Interface intf, float x, float y, float w, float h, String name, String callback) {
    this.intf = intf;

    relX = intf.scaleFactor * x;
    relY = intf.scaleFactor * y;

    absX = intf.scaleFactor * x;
    absY = intf.scaleFactor * y;

    width = intf.scaleFactor * w;
    height = intf.scaleFactor * h;

    mouseX = 0;
    mouseY = 0;
    pmouseX = 0;
    pmouseY = 0;

    isFocused = false;
    parent = null;
    children = new ArrayList<Widget>();

    isActive = true;
    isVisible = true;

    name = name;
    this.callback = callback;    
  }

  void runCallback() {
    intf.sketch.method(callback);
  }

  void setParent(Widget p) {
    parent = p;
    absX = p.absX + relX;
    absY = p.absY + relY;
  }

  void setCallback(String callback) {
    this.callback = callback;
  }

  void addChildren(Widget c) {
    children.add(c);
    c.setParent(this);
  }

  void updateChildren() {
    for (Widget child: children) {
      child.setRelMousePos();
      child.setFocusedState();
      child.updateChildren();
    }
  }

  void drawChildren() {
    PApplet p = intf.sketch;
    for (Widget child: children) {
      if (!child.isVisible) continue;

      p.pushMatrix();
      child.setOrigin();

      p.pushStyle();
      child.draw();
      p.popStyle();

      intf.addDrawn(child);

      child.drawChildren();
      p.popMatrix();
    }
  }

  void setOrigin() {
    intf.sketch.translate(relX, relY);
  }

  void setRelMousePos() {
    PApplet p = intf.sketch;
    mouseX = p.mouseX - absX;
    mouseY = p.mouseY - absY;
    pmouseX = p.pmouseX - absX;
    pmouseY = p.pmouseY - absY;
  }

  void setFocusedState() {
    isFocused = this == intf.focused;
  }

  boolean hasFocus(int mx, int my) {
    return absX <= mx && mx <= absX + width && absY <= my && my <= absY + height;
  }

  void show() {
    isVisible = true;
    setVisible();
  }

  void hide() {
    isVisible = false;
    setInvisible();
  }

  void activate() {
    isActive = true;
    setActive();
  }

  void deactivate() {
    isActive = false;
    setInactive();
  }

  void setup() {
  }

  void draw() {
  }

  void press() {
  }

  void hover() {
  }

  void drag() {
  }

  void release() {
  }

  void lostFocus() {
  }

  void setActive() {
  }

  void setInactive() {
  }

  void setVisible() {
  }

  void setInvisible() {
  }
}
