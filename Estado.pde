char[] teclasDisminuirTiempoBorrado = {'-', '_'};
char[] teclasAumentarTiempoBorrado  = {'+', '='};

char[] teclasDisminuirTiempoTransicionFondo = {'<', ','};
char[] teclasAumentarTiempoTransicionFondo  = {'>', '.'};

char[] teclasSeleccionUnaCapa = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
char[] teclasSeleccionTodasLasCapas = {'0'};

char[] teclasOcultarUnaCapa = {'!', '@', '#', '$', '%', '^', '&', '*', '('};
char[] teclasOcultarTodasLasCapas = {')'};

int modificador = -1;

boolean listaContieneTecla(char[] teclas) {
  for (char tcl: teclas) {
    if (tcl == key) return true;
  }
  return false;
}

int indiceDeTecla(char[] teclas) {
  for (int i = 0; i < teclas.length; i++) {
    char tcl = teclas[i];
    if (tcl == key) return i;
  }
  return -1;
}

void resetearModificador() {
  modificador = -1;
}

int actualizarModificador() {
  if (keyPressed) {
    if (key == CODED) {
      if (keyCode == SHIFT) {
        modificador = SHIFT;
      }
    }
  }
  return modificador;
}

class Estado {
  Trazo nuevoTrazo;
  boolean registrandoTrazo;
  int pincelSeleccionado;
  int tintaPincelSeleccionada;
  int tintaFondoSeleccionada;
  int capaSeleccionada;
  boolean todasCapasSeleccionadas;
  boolean unirTrazos;
  boolean repetirTrazos;
  int tiempoTransicionFondoSeleccionado;

  boolean mostrarTextoDeEstado;
  int tiempoBorradoSeleccionado;
  NumeroInterpolado tiempoBorradoTrazos;  
  int nivelOpacidadSeleccionado;
  NumeroInterpolado factorOpacidadTrazos;
  int nivelEscalaSeleccionado;
  NumeroInterpolado factorEscalaTrazos;
  
  Estado() {
    nuevoTrazo = null;
    
    capaSeleccionada = 0;
    pincelSeleccionado = 0;
    tintaPincelSeleccionada = 0;  
    tintaFondoSeleccionada = 0;
    todasCapasSeleccionadas = false;
    registrandoTrazo = false;
    mostrarTextoDeEstado = true;
    unirTrazos = false;
    repetirTrazos = true;
    
    tiempoBorradoSeleccionado = 2;
    nivelOpacidadSeleccionado = 9;
    nivelEscalaSeleccionado = 4;
    tiempoTransicionFondoSeleccionado = 4;
    
    tiempoBorradoTrazos = new NumeroInterpolado(tiemposBorradoTrazo[tiempoBorradoSeleccionado]);   
    factorOpacidadTrazos = new NumeroInterpolado(nivelesOpacidadTrazos[nivelOpacidadSeleccionado]);
    factorEscalaTrazos = new NumeroInterpolado(nivelesEscalaTrazos[nivelEscalaSeleccionado]);
    
    textFont(createFont("Helvetica", 18));
  }
  
  void actualizar() {
    tiempoBorradoTrazos.actualizar();
    factorOpacidadTrazos.actualizar();
    factorEscalaTrazos.actualizar();
  }
  
  void iniciarTrazo() {
    if (!registrandoTrazo) {    
      registrandoTrazo = true;
      nuevoTrazo = new Trazo(capas.get(capaSeleccionada), 
                             pinceles.get(pincelSeleccionado).nuevoPincel(), 
                             tintasPincel.get(tintaPincelSeleccionada), 
                             factorOpacidadTrazos.valor,
                             factorEscalaTrazos.valor,
                             repetirTrazos, millis());
    }
    nuevoTrazo.agregarUnToque(crearToque(true));    
  }
  
  void actualizarTrazo() {
    if (registrandoTrazo) {
      nuevoTrazo.agregarUnToque(crearToque(false));
    } 
  }

  void terminarTrazo() {
    if (registrandoTrazo) {
      if (unirTrazos) {
        nuevoTrazo.toquePrevioEsUltimo();
      } else {
        cerrarTrazo(capas.get(capaSeleccionada), modificador == SHIFT);
      }
    }
  }     
  
  void mostrar() {
    if (mostrarTextoDeEstado) {
      String texto = "";
      texto = "capa:" + (todasCapasSeleccionadas ? "todas" : (capaSeleccionada + 1));
      texto += " pincel:" + (pincelSeleccionado + 1);        
      texto += " loopear:" + (repetirTrazos ? "si" : "no");
      texto += " unir:" + (unirTrazos ? "si" : "no");
      fill(lienzo.tintaActual.generarColorComplementario());  
      text(texto, 0, 0, width, 20);      
    }
  }
  
  void procesarTeclado() {
    actualizarModificador();
    
    if (key == CODED) {
      if (keyCode == LEFT) {
        nivelOpacidadSeleccionado = constrain(nivelOpacidadSeleccionado - 1, 0, 9);
        factorOpacidadTrazos.establecerObjetivo(nivelesOpacidadTrazos[nivelOpacidadSeleccionado]);
      } else if (keyCode == RIGHT) {
        nivelOpacidadSeleccionado = constrain(nivelOpacidadSeleccionado + 1, 0, 9);
        factorOpacidadTrazos.establecerObjetivo(nivelesOpacidadTrazos[nivelOpacidadSeleccionado]);
      } else if (keyCode == DOWN) {
        nivelEscalaSeleccionado = constrain(nivelEscalaSeleccionado - 1, 0, 9);
        factorEscalaTrazos.establecerObjetivo(nivelesEscalaTrazos[nivelEscalaSeleccionado]);
      } else if (keyCode == UP) {
        nivelEscalaSeleccionado = constrain(nivelEscalaSeleccionado + 1, 0, 9);
        factorEscalaTrazos.establecerObjetivo(nivelesEscalaTrazos[nivelEscalaSeleccionado]);
      }
    } else {
      if (key == DELETE || key == BACKSPACE) {
        if (!registrandoTrazo) {
          if (modificador == SHIFT) {
            if (todasCapasSeleccionadas) {
               for (CapaDibujo capa: capas) capa.borrarTrazos();
            } else {
              capas.get(capaSeleccionada).borrarTrazos();
            }
          } else {
            capas.get(capaSeleccionada).borrarUltimoTrazo();
          }          
        }
      } else if (keyCode == ENTER || keyCode == RETURN) {
        mostrarTextoDeEstado = !mostrarTextoDeEstado;
      } else if (key == ' ') {
        repetirTrazos = !repetirTrazos;
      } else if (key == TAB) {
        unirTrazos = !unirTrazos;
        if (!unirTrazos) {
          cerrarTrazo(capas.get(capaSeleccionada), modificador == SHIFT);
        }
      } else if (listaContieneTecla(teclasSeleccionUnaCapa)) {
        capaSeleccionada = indiceDeTecla(teclasSeleccionUnaCapa);
        capas.get(capaSeleccionada).mostrar();
        todasCapasSeleccionadas = false;
      } else if (listaContieneTecla(teclasSeleccionTodasLasCapas)) {
        for (CapaDibujo capa: capas) capa.mostrar();
        todasCapasSeleccionadas = true;        
      } else if (listaContieneTecla(teclasOcultarUnaCapa)) {
        int i = indiceDeTecla(teclasOcultarUnaCapa);
        capas.get(i).ocultar();
      } else if (listaContieneTecla(teclasOcultarTodasLasCapas)) {
        for (CapaDibujo capa: capas) capa.ocultar();         
      } else if (listaContieneTecla(teclasDisminuirTiempoTransicionFondo)) {
        tiempoTransicionFondoSeleccionado = constrain(tiempoTransicionFondoSeleccionado - 1, 0, 9);
      } else if (listaContieneTecla(teclasAumentarTiempoTransicionFondo)) {
        tiempoTransicionFondoSeleccionado = constrain(tiempoTransicionFondoSeleccionado + 1, 0, 9);  
      } else if (listaContieneTecla(teclasDisminuirTiempoBorrado)) {       
        tiempoBorradoSeleccionado = constrain(tiempoBorradoSeleccionado - 1, 0, 9);
        tiempoBorradoTrazos.establecerObjetivo(tiemposBorradoTrazo[tiempoBorradoSeleccionado]);
      } else if (listaContieneTecla(teclasAumentarTiempoBorrado)) {        
        tiempoBorradoSeleccionado = constrain(tiempoBorradoSeleccionado + 1, 0, 9);
        tiempoBorradoTrazos.establecerObjetivo(tiemposBorradoTrazo[tiempoBorradoSeleccionado]);
      } else {    
        for (Pincel p: pinceles) {
          if (listaContieneTecla(p.teclas)) {
            pincelSeleccionado = p.indice;
          }
        }
        for (Tinta t: tintasPincel) {
          if (listaContieneTecla(t.teclas)) {
            tintaPincelSeleccionada = t.indice;
          }
        }
        for (Tinta t: tintasFondo) {
          if (listaContieneTecla(t.teclas)) {
            tintaFondoSeleccionada = t.indice;
            lienzo.cambiarColor(t);
          }
        }
      }
      resetearModificador();
    }
  }
}
