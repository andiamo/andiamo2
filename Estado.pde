class Estado {
  Trazo nuevoTrazo;
  boolean registrandoTrazo;
  int pincelSeleccionado;
  Tinta tintaPincelSeleccionada;
  Tinta tintaFondoSeleccionada;
  int capaSeleccionada;
  
  boolean borrarTodosLosTrazos;
  boolean todasCapasSeleccionadas;
  boolean unirTrazos;
  boolean repetirTrazos;
  
  boolean mostrarTextoDeEstado;
  boolean mostrarUI;
  
  //int tiempoBorradoSeleccionado;
  NumeroInterpolado tiempoBorradoTrazos;
  
  //int tiempoTransicionFondoSeleccionado;
  NumeroInterpolado tiempoTransicionFondo;  
  
  //int nivelOpacidadSeleccionado;
  NumeroInterpolado factorOpacidadTrazos;
  
  //int nivelEscalaSeleccionado;
  NumeroInterpolado factorEscalaTrazos;
  
  Estado() {
    nuevoTrazo = null;
    
    capaSeleccionada = 0;
    pincelSeleccionado = 0;
    tintaPincelSeleccionada = tintasPincel.get(0);  
    tintaFondoSeleccionada = tintasFondo.get(0);
    
    borrarTodosLosTrazos = false;
    todasCapasSeleccionadas = false;
    registrandoTrazo = false;
    
    mostrarTextoDeEstado = false;
    mostrarUI = false;
    
    unirTrazos = false;
    repetirTrazos = true;
    
    //tiempoBorradoSeleccionado = 2;
    //nivelOpacidadSeleccionado = 9;
    //nivelEscalaSeleccionado = 4;
    //tiempoTransicionFondoSeleccionado = 4;
    
    tiempoBorradoTrazos = new NumeroInterpolado(2000);   
    tiempoTransicionFondo = new NumeroInterpolado(2000);
    
    factorOpacidadTrazos = new NumeroInterpolado(1);
    factorEscalaTrazos = new NumeroInterpolado(1);
    
    //textFont(createFont("Helvetica", 18));
  }
  
  void actualizar() {
    tiempoBorradoTrazos.actualizar();
    tiempoTransicionFondo.actualizar();
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
        cerrarTrazo(capas.get(capaSeleccionada));
      }
    }
  }     
  
  //void mostrar() {
  //  if (mostrarTextoDeEstado) {
  //    String texto = "";
  //    texto = "capa:" + (todasCapasSeleccionadas ? "todas" : (capaSeleccionada + 1));
  //    texto += " pincel:" + (pincelSeleccionado + 1);        
  //    texto += " loopear:" + (repetirTrazos ? "si" : "no");
  //    texto += " unir:" + (unirTrazos ? "si" : "no");
  //    fill(lienzo.tintaActual.generarColorComplementario());  
  //    text(texto, 0, 0, width, 20);      
  //  }
  //}
  
  void procesarTeclado() {
    //actualizarModificador();
    
    if (key == CODED) {
      if (keyCode == SHIFT) {
        invertirBorrarTodos();
        ToggleButton button = (ToggleButton)intf.getWidget("delAll");
        button.toggled = borrarTodosLosTrazos;
      }
      //if (keyCode == LEFT) {
      //  nivelOpacidadSeleccionado = constrain(nivelOpacidadSeleccionado - 1, 0, 9);
      //  factorOpacidadTrazos.establecerObjetivo(nivelesOpacidadTrazos[nivelOpacidadSeleccionado]);
      //} else if (keyCode == RIGHT) {
      //  nivelOpacidadSeleccionado = constrain(nivelOpacidadSeleccionado + 1, 0, 9);
      //  factorOpacidadTrazos.establecerObjetivo(nivelesOpacidadTrazos[nivelOpacidadSeleccionado]);
      //} else if (keyCode == DOWN) {
      //  nivelEscalaSeleccionado = constrain(nivelEscalaSeleccionado - 1, 0, 9);
      //  factorEscalaTrazos.establecerObjetivo(nivelesEscalaTrazos[nivelEscalaSeleccionado]);
      //} else if (keyCode == UP) {
      //  nivelEscalaSeleccionado = constrain(nivelEscalaSeleccionado + 1, 0, 9);
      //  factorEscalaTrazos.establecerObjetivo(nivelesEscalaTrazos[nivelEscalaSeleccionado]);
      //}
    } else {
      if (key == DELETE || key == BACKSPACE) {
        if (!registrandoTrazo) {
          if (borrarTodosLosTrazos) {           
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
        //mostrarTextoDeEstado = !mostrarTextoDeEstado;
        invertirMostrarUI();
        ToggleButton button = (ToggleButton)intf.getWidget("toggleUI");
        button.toggled = mostrarUI;
      } else if (key == ' ') {
        invertirRepetirTrazos();        
        ToggleButton button = (ToggleButton)intf.getWidget("toggleLoop");
        button.toggled = repetirTrazos;   
      } else if (key == TAB) {
        invertirUnirTrazos();
        ToggleButton button = (ToggleButton)intf.getWidget("toggleJoin");
        button.toggled = unirTrazos;
      } 
      
      //else if (listaContieneTecla(teclasSeleccionUnaCapa)) {        
      //  seleccionarCapa(indiceDeTecla(teclasSeleccionUnaCapa));
      //} else if (listaContieneTecla(teclasSeleccionTodasLasCapas)) {
      //  for (CapaDibujo capa: capas) capa.mostrar();
      //  todasCapasSeleccionadas = true;        
      //} else if (listaContieneTecla(teclasOcultarUnaCapa)) {
      //  ocultarCapa(indiceDeTecla(teclasOcultarUnaCapa));
      //} else if (listaContieneTecla(teclasOcultarTodasLasCapas)) {
      //  for (CapaDibujo capa: capas) capa.ocultar();         
      
      //} else if (listaContieneTecla(teclasDisminuirTiempoTransicionFondo)) {
      //  tiempoTransicionFondoSeleccionado = constrain(tiempoTransicionFondoSeleccionado - 1, 0, 9);
      //} else if (listaContieneTecla(teclasAumentarTiempoTransicionFondo)) {
      //  tiempoTransicionFondoSeleccionado = constrain(tiempoTransicionFondoSeleccionado + 1, 0, 9);  
      
    //} else if (listaContieneTecla(teclasDisminuirTiempoBorrado)) {       
    //  tiempoBorradoSeleccionado = constrain(tiempoBorradoSeleccionado - 1, 0, 9);
    //  tiempoBorradoTrazos.establecerObjetivo(tiemposBorradoTrazo[tiempoBorradoSeleccionado]);
    //} else if (listaContieneTecla(teclasAumentarTiempoBorrado)) {        
    //  tiempoBorradoSeleccionado = constrain(tiempoBorradoSeleccionado + 1, 0, 9);
    //  tiempoBorradoTrazos.establecerObjetivo(tiemposBorradoTrazo[tiempoBorradoSeleccionado]);
      
    } 
    
    //else {
      
    //    for (Pincel p: pinceles) {
    //      if (listaContieneTecla(p.teclas)) {
    //        seleccionarPincel(p.indice);
    //      }
    //    }
    //    for (Tinta t: tintasPincel) {
    //      if (listaContieneTecla(t.teclas)) {
    //        tintaPincelSeleccionada = tintasPincel.get(t.indice);
    //      }
    //    }
    //    for (Tinta t: tintasFondo) {
    //      if (listaContieneTecla(t.teclas)) {
    //        tintaFondoSeleccionada = tintasFondo.get(t.indice);
    //        lienzo.cambiarColor(t);
    //      }
    //    }
    //  }
    //  resetearModificador();
    //}
    
    //resetearModificador();
  }
  
  void seleccionarCapa(int capa) {
    capaSeleccionada = capa;
    mostrarCapa(capaSeleccionada);
    todasCapasSeleccionadas = false;
    ToggleButton button = (ToggleButton)intf.getWidget("toggleAll");
    button.toggled = false;
    
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
  
  void invertirSeleccionarTodas() {
    todasCapasSeleccionadas = !todasCapasSeleccionadas;
  }
  
  void invertirBorrarTodos() {
    borrarTodosLosTrazos = !borrarTodosLosTrazos;
  }
  
  void invertirMostrarUI() {
    mostrarUI = !mostrarUI;
    
    Widget container = intf.getWidget("container");
    if (container.isVisible) container.hide();
    else container.show();    
  }
  
  void invertirUnirTrazos() {
    unirTrazos = !unirTrazos;
    if (!unirTrazos) {
      cerrarTrazo(capas.get(capaSeleccionada));
    }
  }
  
  void crearTintaPincelSeleccionada(color c) {
    tintaPincelSeleccionada = new Tinta(-1, "user-gen", new char[]{}, c); 
  }
  
  void crearTintaFondoSeleccionada(color c) {
    tintaFondoSeleccionada = new Tinta(-1, "user-gen", new char[]{}, c);
    lienzo.cambiarColor(tintaFondoSeleccionada);    
  }
  
  void establecerFactorOpacidad(float f) {
    factorOpacidadTrazos.establecerObjetivo(f);
  }

  void establecerFactorEscala(float f) {
    if (0.5 < f) f = map(f, 0.5, 1, 1, 10);
    factorEscalaTrazos.establecerObjetivo(f);
  }
  
  void establecerTiempoBorradoTrazos(float f) {
    if (0.5 < f) f = map(f, 0.5, 1, 2000, 15000);
    if (f < 0.5) f = map(f, 0, 0.5, 0, 2000);    
    tiempoBorradoTrazos.establecerObjetivo(f);
  }
  
  void establecerTiempoTransicionFondo(float f) {
    if (0.5 < f) f = map(f, 0.5, 1, 2000, 15000);
    if (f < 0.5) f = map(f, 0, 0.5, 0, 2000);
    tiempoTransicionFondo.establecerObjetivo(f);    
  }
}

//char[] teclasDisminuirTiempoBorrado = {'-', '_'};
//char[] teclasAumentarTiempoBorrado  = {'+', '='};

//char[] teclasDisminuirTiempoTransicionFondo = {'<', ','};
//char[] teclasAumentarTiempoTransicionFondo  = {'>', '.'};

//char[] teclasSeleccionUnaCapa = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
//char[] teclasSeleccionTodasLasCapas = {'0'};

//char[] teclasOcultarUnaCapa = {'!', '@', '#', '$', '%', '^', '&', '*', '('};
//char[] teclasOcultarTodasLasCapas = {')'};

//int modificador = -1;

//int[] tiemposTransicionFondo = {0, 500, 1000, 1500, 2000, 3000, 5000, 7000, 10000, 15000};
//int[] tiemposBorradoTrazo = {0, 500, 1000, 1500, 2000, 3000, 5000, 7000, 10000, 15000};
//float[] nivelesOpacidadTrazos = {0, 0.11, 0.22, 0.33, 0.44, 0.55, 0.66, 0.77, 0.88, 1};
//float[] nivelesEscalaTrazos = {0, 0.25, 0.5, 0.75, 1, 2.8, 4.6, 6.4, 8.2, 10.0};


//boolean listaContieneTecla(char[] teclas) {
//  for (char tcl: teclas) {
//    if (tcl == key) return true;
//  }
//  return false;
//}

//int indiceDeTecla(char[] teclas) {
//  for (int i = 0; i < teclas.length; i++) {
//    char tcl = teclas[i];
//    if (tcl == key) return i;
//  }
//  return -1;
//}

//void resetearModificador() {
//  modificador = -1;
//}

//int actualizarModificador() {
//  if (keyPressed) {
//    if (key == CODED) {
//      if (keyCode == SHIFT) {        
//        modificador = SHIFT;
//      }
//    }
//  }
//  return modificador;
//}
