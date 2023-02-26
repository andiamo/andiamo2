class Button extends Widget {
  Button() { }
  
  void draw() {
    PApplet p = intf.sketch;
    p.fill(255, 0 ,0);
    p.rect(0, 0, width, height, 5);
  }
}
