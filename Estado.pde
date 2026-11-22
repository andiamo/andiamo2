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
  boolean mostrarAyuda;
  
  NumeroInterpolado tiempoBorradoTrazos;
  NumeroInterpolado tiempoTransicionFondo;  
  NumeroInterpolado factorOpacidadTrazos;
  NumeroInterpolado factorEscalaTrazos;
  
  char[] teclasSeleccionUnaCapa = {'1', '2', '3', '4', '5', '6', '7', '8', '9'};
  char[] teclasOcultarUnaCapa = {'!', '@', '#', '$', '%', '^', '&', '*', '('};
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
    mostrarAyuda = false;
    
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

  void cerrarTrazoEnCurso() {
    if (registrandoTrazo && nuevoTrazo != null) {
      cerrarTrazo(nuevoTrazo.capa, borrarTrazosAuto);
    }
  }
  
  void procesarTeclado() {
    boolean shiftDown = keyEvent != null && keyEvent.isShiftDown();
    if (key == CODED) {
      if (keyCode == UP) {
        if (shiftDown) {
          incrementarOpacidad();
        } else {
          ajustarSliderEscala(0.05);
        }
      } else if (keyCode == DOWN) {
        if (shiftDown) {
          disminuirOpacidad();
        } else {
          ajustarSliderEscala(-0.05);
        }
      } else if (keyCode == LEFT) {
        ajustarSliderOpacidad(-0.1);
      } else if (keyCode == RIGHT) {
        ajustarSliderOpacidad(0.1);
      }
    } else {
      if (key == DELETE || key == BACKSPACE) {
        if (shiftDown) {
          borrarCapaCompleta();
        } else {
          borrarTrazos();
        }
      } else if (key == ENTER || key == RETURN || keyCode == ENTER || keyCode == RETURN) {
        invertirMostrarUI();
        syncToggle("toggleUI", mostrarUI);
      } else if (key == ' ') {
        invertirRepetirTrazos();
        syncToggle("toggleLoop", repetirTrazos);
      } else if (key == TAB || key == '`' || key == '~') {
        invertirUnirTrazos();
        syncToggle("toggleJoin", unirTrazos);
      } else if (key == 'n' || key == 'N') {
        invertirBorrarTrazosAuto();
        syncToggle("toggleAuto", borrarTrazosAuto);
      } else if (key == 'm' || key == 'M') {
        invertirBorrarTodos();
        syncToggle("delAll", borrarTodosLosTrazos);
      } else if (key == 'h' || key == 'H' || key == '?') {
        invertirMostrarAyuda();
        syncToggle("toggleHelp", mostrarAyuda);
      } else if (key == '[') {
        disminuirOpacidad();
      } else if (key == ']') {
        incrementarOpacidad();
      } else if (key == '-' || key == '_') {
        ajustarSliderBorrado(-0.05);
      } else if (key == '+' || key == '=') {
        ajustarSliderBorrado(0.05);
      } else if (key == ',' || key == '<') {
        ajustarSliderFondo(-0.05);
      } else if (key == '.' || key == '>') {
        ajustarSliderFondo(0.05);
      } else if (shiftDown && '1' <= keyCode && keyCode <= '9') {
        int sel = keyCode - '1';
        alternarVisibilidadCapa(sel);
      } else if (listaContieneTecla(teclasOcultarUnaCapa)) {
        int sel = indiceDeTecla(teclasOcultarUnaCapa);
        alternarVisibilidadCapa(sel);
      } else if ((shiftDown && keyCode == '0') || key == ')') {
        if (numeroCapasOcultas() == 0) {
          ocultarTodasLasCapas();
        } else {
          mostrarTodasLasCapas();
        }
        syncToggle("showAll", numeroCapasOcultas() == 0);
      } else if (listaContieneTecla(teclasSeleccionUnaCapa)) {
        int sel = indiceDeTecla(teclasSeleccionUnaCapa);
        seleccionarCapa(sel);
        for (int i = 1; i <= 9; i++) {
          SelectButton w = (SelectButton)intf.getWidget("selectL" + i);
          if (w != null) w.selected = (i - 1 == sel);
        }
      } else if (listaContieneTecla(teclasSeleccionTodasLasCapas)) {
        invertirSeleccionarTodasLasCapas();
        syncToggle("selectAll", todasCapasSeleccionadas);
      } else {
        for (Pincel p: pinceles) {
          if (listaContieneTecla(p.teclas)) {
            seleccionarPincel(p.indice);
          }
        }
        for (Tinta t: tintasPincel) {
          if (listaContieneTecla(t.teclas)) {
            tintaPincelSeleccionada = tintasPincel.get(t.indice);
            ColorSelector csel = (ColorSelector)intf.getWidget("brushColor");
            if (csel != null) csel.setColor(tintaPincelSeleccionada.generarColor());
          }
        }
        for (Tinta t: tintasFondo) {
          if (listaContieneTecla(t.teclas)) {
            tintaFondoSeleccionada = tintasFondo.get(t.indice);
            lienzo.cambiarColor(t);
            ColorSelector csel = (ColorSelector)intf.getWidget("backColor");
            if (csel != null) csel.setColor(tintaFondoSeleccionada.generarColor());
          }
        }
      }
    }
  }

  void syncToggle(String widgetName, boolean state) {
    Widget w = intf.getWidget(widgetName);
    if (w instanceof ToggleButton) {
      ((ToggleButton)w).toggled = state;
    }
  }

  void alternarVisibilidadCapa(int sel) {
    if (capaEstaOcultando(sel)) {
      mostrarCapa(sel);
      syncToggle("showL" + (sel + 1), true);
    } else {
      ocultarCapa(sel);
      syncToggle("showL" + (sel + 1), false);
    }
  }

  void ajustarSliderOpacidad(float delta) {
    float v = constrain(factorOpacidadTrazos.objetivo + delta, 0, 1);
    establecerFactorOpacidad(v);
    ValueSlider vsli = (ValueSlider)intf.getWidget("brushOpacity");
    if (vsli != null) vsli.setValue(v);
  }

  void ajustarSliderEscala(float delta) {
    float v = constrain(obtenerValorSliderEscala() + delta, 0.02, 1);
    establecerFactorEscala(v);
    ValueSlider vsli = (ValueSlider)intf.getWidget("brushScale");
    if (vsli != null) vsli.setValue(v);
  }

  void ajustarSliderBorrado(float delta) {
    float v = constrain(obtenerValorSliderBorrado() + delta, 0, 1);
    establecerTiempoBorradoTrazos(v);
    ValueSlider vsli = (ValueSlider)intf.getWidget("eraseSpeed");
    if (vsli != null) vsli.setValue(v);
  }

  void ajustarSliderFondo(float delta) {
    float v = constrain(obtenerValorSliderFondo() + delta, 0, 1);
    establecerTiempoTransicionFondo(v);
    ValueSlider vsli = (ValueSlider)intf.getWidget("backChangeSpeed");
    if (vsli != null) vsli.setValue(v);
  }

  float obtenerValorSliderEscala() {
    float esc = factorEscalaTrazos.objetivo;
    if (esc <= 1) return map(esc, 0, 1, 0, 0.5);
    return map(esc, 1, 10, 0.5, 1);
  }

  float obtenerValorSliderBorrado() {
    float ms = tiempoBorradoTrazos.objetivo;
    if (ms <= 2000) return map(ms, 0, 2000, 0, 0.5);
    return map(ms, 2000, 15000, 0.5, 1);
  }

  float obtenerValorSliderFondo() {
    float ms = tiempoTransicionFondo.objetivo;
    if (ms <= 2000) return map(ms, 0, 2000, 0, 0.5);
    return map(ms, 2000, 15000, 0.5, 1);
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
    if (unirTrazos && registrandoTrazo && capa != capaSeleccionada) {
      cerrarTrazoEnCurso();
    }
    capaSeleccionada = capa;
    todasCapasSeleccionadas = false;

    syncToggle("selectAll", false);
    if (capas.get(capa).oculta()) {
      mostrarCapa(capa);
      syncToggle("showL" + (capa + 1), true);
    }
    
    ValueSlider vsli = (ValueSlider)intf.getWidget("layerOpacity");
    if (vsli != null) vsli.setValue(capas.get(capaSeleccionada).opacidad.objetivo);
  }
  
  void ocultarCapa(int capa) {
    capas.get(capa).ocultar();
    syncToggle("showAll", false);      
  }
  
  void mostrarCapa(int capa) {
    capas.get(capa).mostrar();
    syncToggle("showAll", numeroCapasOcultas() == 0);
  }
  
  boolean capaEstaOcultando(int capa) {
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
  
  void incrementarOpacidad() {
    if (todasCapasSeleccionadas) {
      for (int i = 0; i < capas.size(); i++) incrementarOpacidad(i);  
    } else {
      incrementarOpacidad(capaSeleccionada);     
    }
    syncToggle("showAll", numeroCapasOcultas() == 0);
  }
  
  void incrementarOpacidad(int i) {
    CapaDibujo capa = capas.get(i);
    capa.incrementarOpacidad(0.1);
    if (!capa.oculta()) {
      syncToggle("showL" + (i + 1), true);        
    }
    
    if (i == capaSeleccionada) {
      ValueSlider vsli = (ValueSlider)intf.getWidget("layerOpacity");
      if (vsli != null) vsli.setValue(capa.opacidad.objetivo);
    }
  }
  
  void disminuirOpacidad() {
    if (todasCapasSeleccionadas) {
      for (int i = 0; i < capas.size(); i++) disminuirOpacidad(i);
    } else {
      disminuirOpacidad(capaSeleccionada);
    }    
    syncToggle("showAll", numeroCapasOcultas() == 0);
  }
  
  void disminuirOpacidad(int i) {
    CapaDibujo capa = capas.get(i);
    capa.disminuirOpacidad(0.1);
    if (capa.oculta()) {
      syncToggle("showL" + (i + 1), false);
    }
    
    if (i == capaSeleccionada) {
      ValueSlider vsli = (ValueSlider)intf.getWidget("layerOpacity");
      if (vsli != null) vsli.setValue(capa.opacidad.objetivo);
    }
  }
  
  void establecerOpacidadDeCapa(float f) {
    if (todasCapasSeleccionadas) {
      for (int i = 0; i < capas.size(); i++) establecerOpacidadDeCapa(i, f);
    } else {
      establecerOpacidadDeCapa(capaSeleccionada, f);
    }
    
    syncToggle("showAll", numeroCapasOcultas() == 0);
  }
  
  void establecerOpacidadDeCapa(int i, float f) {
    CapaDibujo capa = capas.get(i);
    capa.establecerOpacidad(f);   
    syncToggle("showL" + (i + 1), !capa.oculta());
  }
  
  void borrarTrazos() {
    cerrarTrazoEnCurso();
    if (borrarTodosLosTrazos) {
      borrarCapaCompleta();
    } else if (todasCapasSeleccionadas) {
      for (CapaDibujo capa: capas) capa.borrarUltimoTrazo();
    } else {
      capas.get(capaSeleccionada).borrarUltimoTrazo();
    }
  }

  void borrarCapaCompleta() {
    cerrarTrazoEnCurso();
    if (todasCapasSeleccionadas) {
      for (CapaDibujo capa: capas) capa.borrarTrazos();
    } else {
      capas.get(capaSeleccionada).borrarTrazos();
    }
  }
  
  void seleccionarPincel(int pincel) {
    if (unirTrazos && registrandoTrazo && pincel != pincelSeleccionado) {
      cerrarTrazoEnCurso();
    }
    pincelSeleccionado = pincel;
    actualizarInterfacePinceles(pincel);
  }
  
  void invertirRepetirTrazos() {
    repetirTrazos = !repetirTrazos;
    if (repetirTrazos) {
      borrarTrazosAuto = false;
      syncToggle("toggleAuto", false);
    }
  }
  
  void invertirBorrarTrazosAuto() {
    borrarTrazosAuto = !borrarTrazosAuto;
    if (borrarTrazosAuto) {
      repetirTrazos = false;
      syncToggle("toggleLoop", false);
    }
  }
  
  void invertirUnirTrazos() {
    unirTrazos = !unirTrazos;
    if (!unirTrazos) {
      cerrarTrazoEnCurso();
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
      syncToggle("showL" + i, true);
    }  
  }
  
  void ocultarTodasLasCapas() {
    for (CapaDibujo capa: capas) capa.ocultar();    
    for (int i = 1; i <= 9; i++) {
      syncToggle("showL" + i, false);
    }
  }
  
  void invertirMostrarUI() {
    mostrarUI = !mostrarUI;
    
    Widget container = intf.getWidget("container");
    if (mostrarUI) {
      container.show();
    } else {
      container.hide();
      mostrarAyuda = false;
      syncToggle("toggleHelp", false);
      Widget help = intf.getWidget("helpOverlay");
      if (help != null) help.hide();
    }
  }

  void invertirMostrarAyuda() {
    mostrarAyuda = !mostrarAyuda;
    if (mostrarAyuda && !mostrarUI) {
      invertirMostrarUI();
      syncToggle("toggleUI", true);
    }
    Widget help = intf.getWidget("helpOverlay");
    if (help != null) {
      if (mostrarAyuda) help.show();
      else help.hide();
    }
  }
  
  void crearTintaPincelSeleccionada(color c) {
    tintaPincelSeleccionada = new Tinta(c); 
  }
  
  void crearTintaFondoSeleccionada(color c) {
    tintaFondoSeleccionada = new Tinta(c);
    lienzo.cambiarColor(tintaFondoSeleccionada);    
  }
  
  void establecerFactorOpacidad(float f) {
    factorOpacidadTrazos.establecerObjetivo(constrain(f, 0, 1));
  }

  void establecerFactorEscala(float f) {
    f = constrain(f, 0, 1);
    if (f <= 0.5) f = map(f, 0, 0.5, 0, 1);
    else f = map(f, 0.5, 1, 1, 10);
    factorEscalaTrazos.establecerObjetivo(f);
  }
  
  void establecerTiempoBorradoTrazos(float f) {
    f = constrain(f, 0, 1);
    if (0.5 < f) f = map(f, 0.5, 1, 2000, 15000);
    else f = map(f, 0, 0.5, 0, 2000);    
    tiempoBorradoTrazos.establecerObjetivo(f);
  }
  
  void establecerTiempoTransicionFondo(float f) {
    f = constrain(f, 0, 1);
    if (0.5 < f) f = map(f, 0.5, 1, 2000, 15000);
    else f = map(f, 0, 0.5, 0, 2000);
    tiempoTransicionFondo.establecerObjetivo(f);    
  }
}
