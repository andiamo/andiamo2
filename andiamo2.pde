ArrayList<Pincel> pinceles;
ArrayList<Tinta> tintasFondo;
ArrayList<Tinta> tintasPincel;
ArrayList<CapaDibujo> capas;
LienzoFondo lienzo;
Estado estado;
Interface intf;

void settings() {
  if (PANTALLA_COMPLETA) {
    if (0 < PANTALLA_INDICE) {
      fullScreen(P2D, PANTALLA_INDICE);
    } else {
      fullScreen(P2D);
    }
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
  intf.update();
}

void mouseMoved() {
  intf.mouseMoved();
}

void mousePressed() {
  if (!intf.mousePressed()) {
    estado.iniciarTrazo();  
  }  
}

void mouseDragged() {
  if (!intf.mouseDragged()) {
    estado.actualizarTrazo();  
  }  
}

void mouseReleased() {
  if (!intf.mouseReleased()) {
    estado.terminarTrazo();
  }
}

void keyPressed() {
  estado.procesarTeclado();
}
