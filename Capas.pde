void crearCapas() {
  capas = new ArrayList<CapaDibujo>();
  for (int i = 0; i < 9; i++) {
    capas.add(new CapaDibujo(i + 1));
  }
}

void pintarCapas() {
  for (int i = capas.size() - 1; i >= 0; i--) {
    CapaDibujo capa = capas.get(i);
    capa.pintar();
    if (i == estado.capaSeleccionada && estado.registrandoTrazo) {
      estado.nuevoTrazo.dibujate(capa.opacidad.valor);
    }
  }
}

class LienzoFondo {
  Tinta tintaActual;
  Tinta tintaPrevia;
  int tiempoCambio;
  boolean cambiando;
  int duracionCambio;
  
  LienzoFondo() {    
    tintaActual = tintasFondo.get(0);
  }
  
  void pintar() {
    color colorFondo;
    if (cambiando) {
      int t = millis();
      if (t - tiempoCambio < duracionCambio) {
        float f = float(t - tiempoCambio) / duracionCambio;      
        colorFondo = tintaPrevia.interpolarHacia(tintaActual, f);        
      } else {
        colorFondo = tintaActual.generarColor();
      }      
    } else {
      colorFondo = tintaActual.generarColor();  
    }
    background(colorFondo);    
  }
  
  void cambiarColor(Tinta tinta) {
    tintaPrevia = tintaActual;
    tintaActual = tinta;
    tiempoCambio = millis();
    cambiando = true;
    duracionCambio = (int)estado.tiempoTransicionFondo.valor;
  }
}

class CapaDibujo {
  int indice;
  ArrayList<Trazo> trazos;
  NumeroInterpolado opacidad;
  
  CapaDibujo(int indice) {
    this.indice = indice;    
    trazos = new ArrayList<Trazo>();
    opacidad = new NumeroInterpolado(1);
  }
  
  void pintar() {
    opacidad.actualizar();
    if (!visible()) return;
    ArrayList<Trazo> paraRemover = new ArrayList<Trazo>();
    for (Trazo trazo: trazos) {
      trazo.dibujate(opacidad.valor);      
      if (trazo.removido) paraRemover.add(trazo);
    }
    trazos.removeAll(paraRemover);
  }
  
  void mostrar() {
    opacidad.establecerObjetivo(1);
  }

  void ocultar() {
    opacidad.establecerObjetivo(0);
  }  
  
  void incrementarOpacidad(float d) {
    opacidad.establecerObjetivo(constrain(opacidad.objetivo + d, 0, 1));
  }

  void disminuirOpacidad(float d) {
    opacidad.establecerObjetivo(constrain(opacidad.objetivo - d, 0, 1));
  }
  
  void establecerOpacidad(float v) {
    opacidad.establecerObjetivo(constrain(v, 0, 1));
  }
  
  void borrarTrazos() {
    for (Trazo trazo: trazos) {
      trazo.remover();
    }
  }
  
  void borrarUltimoTrazo() {
    for (int i = trazos.size() - 1; i >= 0; i--) {
      Trazo tr = trazos.get(i);
      if (!tr.removiendo) {
        tr.remover();
        break;
      }
    }
  }
  
  boolean visible() {
    return 0.01 <= opacidad.valor;
  }
  
  boolean oculta() {
    return opacidad.objetivo < 0.01 && (opacidad.interpolando || opacidad.valor < 0.01);
  }
}
