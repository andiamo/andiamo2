// Nuevos pinceles se pueden probar en el editor online de p5.js usando este bosquejo de ejemplo:
// https://editor.p5js.org/codeanticode/sketches/EEURt9RtI

void cargarPinceles() {
  pinceles = new ArrayList<Pincel>();
  
  pinceles.add(new PincelAndiamo1(0, "Andiamo", new char[]{'Q', 'q'}));
  pinceles.add(new PincelLinea(1, "Linea", new char[]{'W', 'w'}));
  pinceles.add(new PincelCinta(2, "Cinta", new char[]{'E', 'e'}));
  pinceles.add(new PincelChispa(3, "Chispa", new char[]{'R', 'r'}));
  pinceles.add(new PincelCirculo(4, "Circulo", new char[]{'T', 't'}));
  pinceles.add(new PincelCajas(5, "Cajas", new char[]{'T', 't'}));
  pinceles.add(new PincelYellowTail(6, "YellowTail", new char[]{'Y', 'y'}));
}

boolean distintos(Toque ptoque, Toque toque) {
  if (ptoque == null) return false;
  return ptoque.x != toque.x || ptoque.y != toque.y;  
}

abstract class Pincel {
  String nombre;
  char[] teclas;
  int indice;
  
  Pincel(int indice, String nombre, char[] teclas) {
    this.indice = indice;
    this.nombre = nombre;
    this.teclas = teclas;    
  }
  
  abstract Pincel nuevoPincel();
  
  abstract void pintar(Toque[] toques, color tinta, float escala);
}
  
class PincelLinea extends Pincel  {
  PincelLinea(int indice, String nombre, char[] teclas) {
    super(indice, nombre, teclas);
  }
  
  Pincel nuevoPincel() {
    return new PincelLinea(indice, nombre, teclas);
  }
  
  void pintar(Toque[] toques, color tinta, float escala) {
    stroke(tinta);
    strokeWeight(escala);
    Toque ptoque = null;
    for (Toque toque: toques) {      
      if (distintos(ptoque, toque) && !toque.primero) {        
        line(ptoque.x, ptoque.y, toque.x, toque.y);      
      }
      ptoque = toque;
    }      
  }
}

class PincelCinta extends Pincel  {
  PincelCinta(int indice, String nombre, char[] teclas) {
    super(indice, nombre, teclas);
  }
  
  Pincel nuevoPincel() {
    return new PincelCinta(indice, nombre, teclas);
  }  
  
  void pintar(Toque[] toques, color tinta, float escala) {
    noStroke();
    fill(tinta);
    float w = 0;
    Toque ptoque = null;
    for (Toque toque: toques) {
      if (toque.primero) {
        if (ptoque != null) endShape();        
        beginShape(QUAD_STRIP);
        w = 0;
      } else if (distintos(ptoque, toque)) {                
        float dx = toque.x - ptoque.x;
        float dy = toque.y - ptoque.y;
        float d2 = sqrt(sq(dx) + sq(dy));
        float nx = 0;
        float ny = 0;        
        if (!toque.ultimo) {
          nx = dy / d2;
          ny = -dx / d2;          
        }
        w = 0.9 * w + 0.1 * toque.p;
        vertex(toque.x + nx * w * escala, toque.y + ny * w * escala);
        vertex(toque.x - nx * w * escala, toque.y - ny * w * escala);
      }      
      ptoque = toque;
    }
    endShape();
  }
}

class PincelChispa extends Pincel  {
  PincelChispa(int indice, String nombre, char[] teclas) {
    super(indice, nombre, teclas);
  }
  
  Pincel nuevoPincel() {
    return new PincelChispa(indice, nombre, teclas);
  }    
  
  void pintar(Toque[] toques, color tinta, float escala) {
    if (1 < toques.length) {
      strokeCap(ROUND);
      Toque toque = toques[toques.length - 1];
      Toque ptoque = toques[toques.length - 2];
      float r = 2 * toque.p * escala;
      stroke(tinta);
      noFill();      
      strokeWeight(r);
      line(ptoque.x, ptoque.y, toque.x, toque.y);
    } else if (toques.length == 1) {
      noStroke();
      fill(tinta);      
      Toque toque = toques[toques.length - 1];
      float r = 5 * escala;
      ellipse(toque.x, toque.y, r, r);
   }
  }
}

class PincelCirculo extends Pincel  {
  float offset;
  
  PincelCirculo(int indice, String nombre, char[] teclas) {
    super(indice, nombre, teclas);
    offset = random(10);
  }
  
  Pincel nuevoPincel() {
    return new PincelCirculo(indice, nombre, teclas);
  }    
  
  void pintar(Toque[] toques, color tinta, float escala) {
    if (0 < toques.length) {
      noStroke();
      fill(tinta);      
      Toque toque = toques[toques.length - 1];
      float r = 20 * escala * noise(offset + millis() / 2500.0);
      ellipse(toque.x, toque.y, r, r);
   }
  }
}

class PincelCajas extends Pincel  {
  float offset;
  
  PincelCajas(int indice, String nombre, char[] teclas) {
    super(indice, nombre, teclas);
    offset = random(10);
  }
  
  Pincel nuevoPincel() {
    return new PincelCajas(indice, nombre, teclas);
  }    
  
  void pintar(Toque[] toques, color tinta, float escala) {
    if (0 < toques.length) {      
      rectMode(CENTER);
      noStroke();
      fill(tinta);      
      Toque toque = toques[toques.length - 1];
      float r = 20 * escala * noise(offset + millis() / 2500.0);      
      rect(toque.x, toque.y, r, r);
   }
  }
}
