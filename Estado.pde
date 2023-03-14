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
  Tinta tintaPincelSeleccionada;
  Tinta tintaFondoSeleccionada;
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
    tintaPincelSeleccionada = tintasPincel.get(0);  
    tintaFondoSeleccionada = tintasFondo.get(0);
    todasCapasSeleccionadas = false;
    registrandoTrazo = false;
    mostrarTextoDeEstado = false;
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
                             tintaPincelSeleccionada, 
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
        invertirRepetirTrazos();
      } else if (key == TAB) {
        invertirUnirTrazos();
      } else if (listaContieneTecla(teclasSeleccionUnaCapa)) {        
        seleccionarCapa(indiceDeTecla(teclasSeleccionUnaCapa));
      } else if (listaContieneTecla(teclasSeleccionTodasLasCapas)) {
        for (CapaDibujo capa: capas) capa.mostrar();
        todasCapasSeleccionadas = true;        
      } else if (listaContieneTecla(teclasOcultarUnaCapa)) {
        ocultarCapa(indiceDeTecla(teclasOcultarUnaCapa));
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
            seleccionarPincel(p.indice);
          }
        }
        for (Tinta t: tintasPincel) {
          if (listaContieneTecla(t.teclas)) {
            tintaPincelSeleccionada = tintasPincel.get(t.indice);
          }
        }
        for (Tinta t: tintasFondo) {
          if (listaContieneTecla(t.teclas)) {
            tintaFondoSeleccionada = tintasFondo.get(t.indice);
            lienzo.cambiarColor(t);
          }
        }
      }
      resetearModificador();
    }
  }
  
  void seleccionarCapa(int capa) {
    capaSeleccionada = capa;
    mostrarCapa(capaSeleccionada);
    todasCapasSeleccionadas = false;
  }
  
  void ocultarCapa(int capa) {
    capas.get(capa).ocultar();
  }
  
  void mostrarCapa(int capa) {
    capas.get(capa).mostrar();
  }
  
  boolean capaEstaOculta(int capa) {
    return capas.get(capa).oculta();
  }
  
  void seleccionarPincel(int pincel) {
    pincelSeleccionado = pincel;    
  }
  
  void invertirRepetirTrazos() {
    repetirTrazos = !repetirTrazos;
  }
  
  void invertirUnirTrazos() {
    unirTrazos = !unirTrazos;
    if (!unirTrazos) {
      cerrarTrazo(capas.get(capaSeleccionada), modificador == SHIFT);
    }
  }
  
  void crearTintaPincelSeleccionada(color c) {
    tintaPincelSeleccionada = new Tinta(-1, "user-gen", new char[]{}, c); 
  }
  
  void crearTintaFondoSeleccionada(color c) {
    tintaFondoSeleccionada = new Tinta(-1, "user-gen", new char[]{}, c);
    lienzo.cambiarColor(tintaFondoSeleccionada);    
  }
  
}

void toggleUI(String name) {
  Widget container = intf.getWidget("container");
  if (container.isVisible) container.hide();
  else container.show();
}

void selectLayer(String name) {
  if (name.equals("selectL1")) {
    selectLayer(0);
  } else if (name.equals("selectL2")) {
    selectLayer(1);
  } else if (name.equals("selectL3")) {
    selectLayer(2);
  } else if (name.equals("selectL4")) {
    selectLayer(3);
  } else if (name.equals("selectL5")) {
    selectLayer(4);
  } else if (name.equals("selectL6")) {
    selectLayer(5);
  } else if (name.equals("selectL7")) {
    selectLayer(6);
  } else if (name.equals("selectL8")) {
    selectLayer(7);
  } else if (name.equals("selectL9")) {
    selectLayer(8);
  }
}

void selectLayer(int layer) {
  estado.seleccionarCapa(layer);  
  for (int i = 1; i <= 9; i++) {
    SelectButton w = (SelectButton)intf.getWidget("selectL" + i);
    if (i - 1 != layer) {
      w.selected = false;
    }    
  }
}

void toggleLayer(String name) {
  if (name.equals("showL1")) {
    toggleLayer(0);
  } else if (name.equals("showL2")) {
    toggleLayer(1);
  } else if (name.equals("showL3")) {
    toggleLayer(2);
  } else if (name.equals("showL4")) {
    toggleLayer(3);
  } else if (name.equals("showL5")) {
    toggleLayer(4);
  } else if (name.equals("showL6")) {
    toggleLayer(5);
  } else if (name.equals("showL7")) {
    toggleLayer(6);
  } else if (name.equals("showL8")) {
    toggleLayer(7);
  } else if (name.equals("showL9")) {
    toggleLayer(8);
  }
}

void toggleLayer(int layer) {
  if (estado.capaEstaOculta(layer)) {
    estado.mostrarCapa(layer);
  } else {
    estado.ocultarCapa(layer);
  }
}

void selectBrush(String name) {
  if (name.equals("selectB1")) {
    selectBrush(0);
  } else if (name.equals("selectB2")) {
    selectBrush(1);
  } else if (name.equals("selectB3")) {
    selectBrush(2);
  } else if (name.equals("selectB4")) {
    selectBrush(3);
  } else if (name.equals("selectB5")) {
    selectBrush(4);
  } else if (name.equals("selectB6")) {
    selectBrush(5);
  } else if (name.equals("selectB7")) {
    selectBrush(6);
  } else if (name.equals("selectB8")) {
    selectBrush(7);
  }  
}

void selectBrush(int brush) {
  estado.seleccionarPincel(brush);
  for (int i = 1; i <= 8; i++) {
    SelectButton w = (SelectButton)intf.getWidget("selectB" + i);
    if (i - 1 != brush) {
      w.selected = false;
    }    
  }
}

void toggleLoop(String name) {
  estado.invertirRepetirTrazos();  
}

void toggleJoin(String name) {
  estado.invertirUnirTrazos();
}

void setColor(String name) {
  if (name.equals("brushColor")) {
    ColorSelector csel = (ColorSelector)intf.getWidget("brushColor");
    estado.crearTintaPincelSeleccionada(csel.getColor());
  } else if (name.equals("backColor")) {
    ColorSelector csel = (ColorSelector)intf.getWidget("backColor");
    estado.crearTintaFondoSeleccionada(csel.getColor());
  }
}
