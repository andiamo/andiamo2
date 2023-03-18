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
  boolean borrarTrazosAuto;
  
  boolean mostrarTextoDeEstado;
  boolean mostrarUI;
  
  NumeroInterpolado tiempoBorradoTrazos;
  NumeroInterpolado tiempoTransicionFondo;  
  NumeroInterpolado factorOpacidadTrazos;
  NumeroInterpolado factorEscalaTrazos;
  
  char[] teclasSeleccionUnaCapa = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
  char[] teclasSeleccionTodasLasCapas = {'0'};
  
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
    borrarTrazosAuto = false; 
    
    tiempoBorradoTrazos = new NumeroInterpolado(2000);   
    tiempoTransicionFondo = new NumeroInterpolado(2000);
    
    factorOpacidadTrazos = new NumeroInterpolado(1);
    factorEscalaTrazos = new NumeroInterpolado(1);
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
        cerrarTrazo(capas.get(capaSeleccionada), borrarTrazosAuto);
      }
    }
  }
  
  void procesarTeclado() {
    if (key == CODED) {
      if (keyCode == SHIFT) {
        invertirBorrarTodos();
        ToggleButton button = (ToggleButton)intf.getWidget("delAll");
        button.toggled = borrarTodosLosTrazos;
      }
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
    }
  }
  
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
  
  void seleccionarCapa(int capa) {
    capaSeleccionada = capa;
    mostrarCapa(capaSeleccionada);
    todasCapasSeleccionadas = false;
    ToggleButton button = (ToggleButton)intf.getWidget("toggleAll");
    button.toggled = false;
    
  }
  
  void ocultarCapa(int capa) {
    capas.get(capa).ocultar();
    ToggleButton button = (ToggleButton)intf.getWidget("showAll");
    button.toggled = false;
      
  }
  
  void mostrarCapa(int capa) {
    capas.get(capa).mostrar();
    if (numeroCapasOcultas() == 0) {
      ToggleButton button = (ToggleButton)intf.getWidget("showAll");
      button.toggled = true;
    }    
  }
  
  boolean capaEstaOculta(int capa) {
    return capas.get(capa).oculta();
  }
  
  int numeroCapasOcultas() {
    int num = 0;
    for (CapaDibujo capa: capas) {
      if (capa.oculta()) {
        num += 1;
      }
    }
    return num;
  }
  
  void seleccionarPincel(int pincel) {
    pincelSeleccionado = pincel;    
  }
  
  void invertirRepetirTrazos() {
    repetirTrazos = !repetirTrazos;
    if (repetirTrazos) {
      borrarTrazosAuto = false;
      ToggleButton button = (ToggleButton)intf.getWidget("toggleAuto");
      button.toggled = false;
    }
  }
  
  void invertirBorrarTrazosAuto() {
    borrarTrazosAuto = !borrarTrazosAuto;
    if (borrarTrazosAuto) {
      repetirTrazos = false;
      ToggleButton button = (ToggleButton)intf.getWidget("toggleLoop");
      button.toggled = false;
    }
  }
  
  void invertirUnirTrazos() {
    unirTrazos = !unirTrazos;
    if (!unirTrazos) {
      cerrarTrazo(capas.get(capaSeleccionada), borrarTrazosAuto);
    }
  }  

  void invertirBorrarTodos() {
    borrarTodosLosTrazos = !borrarTodosLosTrazos;
  }
  
  void invertirSeleccionarTodasLasCapas() {
    todasCapasSeleccionadas = !todasCapasSeleccionadas;
  }
  
  void mostrarTodasLasCapas() {
    for (CapaDibujo capa: capas) capa.mostrar();    
    for (int i = 1; i <= 9; i++) {
      ToggleButton button = (ToggleButton)intf.getWidget("showL" + i);
      button.toggled = true;
    }  
  }
  
  void invertirMostrarUI() {
    mostrarUI = !mostrarUI;
    
    Widget container = intf.getWidget("container");
    if (container.isVisible) container.hide();
    else container.show();    
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
    //}
    
    
 //else if (listaContieneTecla(teclasSeleccionUnaCapa)) {        
 //       seleccionarCapa(indiceDeTecla(teclasSeleccionUnaCapa));
 //     } else if (listaContieneTecla(teclasSeleccionTodasLasCapas)) {
 //       for (CapaDibujo capa: capas) capa.mostrar();
 //       todasCapasSeleccionadas = true;
 //     }    
