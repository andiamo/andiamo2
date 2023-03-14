ArrayList<Pincel> pinceles;
ArrayList<Tinta> tintasFondo;
ArrayList<Tinta> tintasPincel;
ArrayList<CapaDibujo> capas;
LienzoFondo lienzo;
Estado estado;
Interface intf;

void settings() {
  if (PANTALLA_COMPLETA) {
    fullScreen(P2D, PANTALLA_ALTO);
  } else {
    size(PANTALLA_ANCHO, PANTALLA_ALTO, P2D);
  }
}

void setup() {  
  cargarPinceles();
  cargarColores();
  crearCapas();
  cursor(CROSS);
  lienzo = new LienzoFondo();
  estado = new Estado();
  createUI();
}

void draw() {
  estado.actualizar();
  lienzo.pintar();
  pintarCapas();  
  //estado.mostrar();
  intf.update();
}

void mousePressed() {  
  estado.iniciarTrazo();
  intf.mousePressed();
}

void mouseDragged() {
  estado.actualizarTrazo();
  intf.mouseDragged();
}

void mouseReleased() {
  estado.terminarTrazo();
  intf.mouseReleased();
}

void keyPressed() {
  estado.procesarTeclado();
}
