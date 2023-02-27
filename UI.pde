class Button extends Widget {
  Button() { }
  
  Button(Interface intf, float x, float y, float w, float h) {
    super(intf, x, y, w, h, "", "");
  }
  
  Button(Interface intf, float x, float y, float w, float h, String name, String callback) {
    super(intf, x, y, w, h, name, callback);
  }
  
  void draw() {
    PApplet p = intf.sketch;
    p.fill(255, 0 ,0);
    p.rect(0, 0, width, height, 5);
    intf.setFont("Arial", 14);
    p.fill(0);
    p.textAlign(CENTER, CENTER);
    p.text("test", 0, 0, width, height);
  }
  
  void press() {
    runCallback();
  }
}
