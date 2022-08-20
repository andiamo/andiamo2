ArrayList<Pincel> pinceles;
ArrayList<Tinta> tintasFondo;
ArrayList<Tinta> tintasPincel;
ArrayList<CapaDibujo> capas;
LienzoFondo lienzo;
Estado estado;

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
  lienzo = new LienzoFondo();
  estado = new Estado();
}

void draw() {
  estado.actualizar();
  lienzo.pintar();
  pintarCapas();  
  estado.mostrar();
}

void mousePressed() {  
  estado.iniciarTrazo();
}

void mouseDragged() {
  estado.actualizarTrazo();
}

void mouseReleased() {
  estado.terminarTrazo();
}

void keyPressed() {
  estado.procesarTeclado();
}
