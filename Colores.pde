void cargarColores() {
  tintasFondo = new ArrayList<Tinta>();
  tintasPincel = new ArrayList<Tinta>();
  
  tintasFondo.add(new Tinta(0, new char[]{'Z', 'z'}, #FFFFFF));
  tintasFondo.add(new Tinta(1, new char[]{'X', 'x'}, #000000));  
    
  tintasPincel.add(new Tinta(0, new char[]{'A', 'a'}, #171717));
  tintasPincel.add(new Tinta(1, new char[]{'S', 's'}, #F7F7F7));
  tintasPincel.add(new Tinta(2, new char[]{'D', 'd'}, #EA8879));
  tintasPincel.add(new Tinta(3, new char[]{'F', 'f'}, #A6EA6B));
  tintasPincel.add(new Tinta(4, new char[]{'G', 'g'}, #4EC7EA));
}

class Tinta {
  int indice;
  char[] teclas;
  float rojo;
  float verde;
  float azul;
  
  Tinta(color c) {
    this.indice = -1;
    this.teclas = new char[]{};
    
    rojo = red(c);
    verde = green(c);
    azul = blue(c);    
  }
  
  Tinta(int indice, char[] teclas, color c) {
    this.indice = indice;
    this.teclas = teclas;
    
    rojo = red(c);
    verde = green(c);
    azul = blue(c);
  }
  
  color generarColor() {
    return generarColor(255);      
  }

  color generarColor(float opacidad) {
    return color(rojo, verde, azul, opacidad);      
  }  

  color generarColorComplementario() {
    return generarColorComplementario(255);      
  }
  
  color generarColorComplementario(float opacidad) {
    return color(255 - rojo, 255 - verde, 255 - azul, opacidad);      
  }
  
  color interpolarHacia(Tinta destino, float factor) {
    return lerpColor(generarColor(), destino.generarColor(), factor);
  }
}
