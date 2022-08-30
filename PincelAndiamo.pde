// Todo lo que corresponde especificamente al pincel de Andiamo 1 esta aca

float RIBBON_WIDTH = 0.8; // Average ribbon width
float SMOOTH_COEFF = 0.7; // Smoothing coefficient used to ease the jumps in the tracking data.
int RIBBON_DETAIL = 5;
float MIN_POS_CHANGE = 2;
float NORM_FACTOR = 5; // This factor allows to normalize ribbon width with respect to the speed of the 
                       // drawing, so that all ribbons have approximately same width.
float MIN_CTRL_CHANGE = 5;
float TEXCOORDU_INC = 0.1;

boolean USE_TEXTURES = false;

String[] TEXTURE_FILES = {
  "line00/01.png",
  "line00/02.png",
  "line01/01.png",
  "line01/02.png",    
  "line02/01.png",
  "line02/02.png",
  "line03/01.png",
  "line03/02.png",
  "line04/01.png",
  "line04/02.png"
};

float INVISIBLE_ALPHA = 1;    // Alpha at which a stroke is considered invisible

class PincelAndiamo extends Pincel  {
  int ribbonDetail;
  int nVertPerStretch;
  int nControl = 0;
  BSpline lspline;
  BSpline rspline;

  float oldX, oldY, oldZ;
  float newX, newY, newZ;
  float oldVel;
  float newVel;
  float twist;
  float ribbonsWidth;

  float pX0, pY0;
  float pX, pY;
  
  ArrayList<StrokeQuad> quads;
  ArrayList<Integer> quadCount;
  
  PincelAndiamo(int indice, String nombre, char[] teclas) {
    super(indice, nombre, teclas);
    initRibbons();
    quads = new ArrayList<StrokeQuad>();
    quadCount = new ArrayList<Integer>();
  }
  
  Pincel nuevoPincel() {    
    return new PincelAndiamo(indice, nombre, teclas);
  }  

  void initRibbons() {
    ribbonDetail = RIBBON_DETAIL;
    nVertPerStretch = 0;
    for (int ui = 1; ui <= 10; ui ++) {
      if (ui % ribbonDetail == 0) {
        nVertPerStretch += 4;
      }
    }    
    lspline = new BSpline(true);
    rspline = new BSpline(true);
    ribbonsWidth = random(0.7 * RIBBON_WIDTH, 1.3 * RIBBON_WIDTH);  
  }
    
  void addPointToRibbon(float x, float y, color tinta, float escala, boolean starting) {
    pX = x;
    pY = y;
  
    if (starting) {
      // (x, y) is the first position, so initializing the previous position to this one.
      pX0 = pX;
      pY0 = pY;
      nControl = 0;
      return;
    } 
  
    // Discarding steps that are too small.
    if (abs(pX - pX0) < MIN_POS_CHANGE && abs(pY - pY0) < MIN_POS_CHANGE) return;
    pX0 = pX;
    pY0 = pY;
  
    if (nControl == 4) {
      lspline.shiftBSplineCPoints();
      rspline.shiftBSplineCPoints();
    } 
    else {
      // Initializing the first 4 control points
      PVector p1 = new PVector(pX, pY, 0);
      PVector p0 = new PVector(pX0, pY0, 0);
      PVector p10 = PVector.sub(p0, p1);
      PVector p_1 = PVector.add(p0, p10); 
      PVector p_2 = PVector.add(p_1, p10);
  
      lspline.setCPoint(0, p_2);
      lspline.setCPoint(1, p_1);
      lspline.setCPoint(2, p0);
      lspline.setCPoint(3, p1);
  
      rspline.setCPoint(0, p_2);
      rspline.setCPoint(1, p_1);
      rspline.setCPoint(2, p0);
      rspline.setCPoint(3, p1);
  
      newX = pX;
      newY = pY;
      newZ = 0;
  
      nControl = 4;
    }
  
  //  twist[i] = TWO_PI * cos(TWO_PI * millis() / (1000.0 * twistPeriod[i]) + twistPhase[i]); 
    oldX = newX;
    oldY = newY;
    oldZ = newZ;
    newX = SMOOTH_COEFF * oldX + (1 - SMOOTH_COEFF) * pX;
    newY = SMOOTH_COEFF * oldY + (1 - SMOOTH_COEFF) * pY;
    newZ = 0;
  
    float dX = newX - oldX;
    float dY = newY - oldY;
    float dZ = newZ - oldZ;
  
    float nX = +dY;
    float nY = -dX;
    float nZ = 0;    
  
    PVector dir = new PVector(dX, dY, dZ);
    PVector nor = new PVector(nX, nY, nZ);
    oldVel = newVel;
    float l = dir.mag();  
    newVel = escala * ribbonsWidth / map(l, 0, 100, 1, NORM_FACTOR + 0.1);
    
  //  println(tablet.getPressure());
  //  newVel = 1 + tablet.getPressure() * NORM_FACTOR;
  
  //  dir.normalize();
  //    PMatrix3D rmat = new PMatrix3D();
  //    rmat.rotate(twist[i], dir.x, dir.y, dir.z);
  //    PVector rnor = rmat.mult(nor, null);
  
    addControlPoint(lspline, newX, newY, newZ, nor, +newVel);
    addControlPoint(rspline, newX, newY, newZ, nor, -newVel);
  
    float r = red(tinta);
    float g = green(tinta);
    float b = blue(tinta);
    float a = alpha(tinta);
    addRibbonStretch(lspline, rspline, r, g, b, a);
  }
   
  boolean addControlPoint(BSpline spline, float newX, float newY, float newZ, PVector nor, float vel) {
    boolean addCP = true;
    PVector cp1 = new PVector(newX - vel * nor.x, newY - vel * nor.y, newZ - vel * nor.z);
    if (1 < nControl) {
      PVector cp0 = new PVector();
      spline.getCPoint(nControl - 2, cp0);
      addCP = MIN_CTRL_CHANGE < cp1.dist(cp0);
    }
    if (addCP) {
      spline.setCPoint(nControl - 1, cp1);
      return true;
    }
    return false;
  }  
  
  float uTexCoord = 0;
  PVector Sid1Point0 = new PVector();
  PVector Sid1Point1 = new PVector();
  PVector Sid2Point0 = new PVector();
  PVector Sid2Point1 = new PVector();
  void addRibbonStretch(BSpline spline1, BSpline spline2, float r, float g, float b, float a) {  
    int ti;
    float t;
  
    // The initial geometry is generated.
    spline1.feval(0, Sid1Point1);
    spline2.feval(0, Sid2Point1);
  
    for (ti = 1; ti <= 10; ti++) {    
      if (ti % ribbonDetail == 0) {
        t = 0.1 * ti;
  
        // The geometry of the previous iteration is saved.
        Sid1Point0.set(Sid1Point1);
        Sid2Point0.set(Sid2Point1);
  
        // The new geometry is generated.
        spline1.feval(t, Sid1Point1);
        spline2.feval(t, Sid2Point1);
        
        StrokeQuad quad = new StrokeQuad(millis());
        quad.setVertex(0, Sid1Point0.x, Sid1Point0.y, Sid1Point0.z, 0, uTexCoord, r, g, b, a);
        quad.setVertex(1, Sid2Point0.x, Sid2Point0.y, Sid2Point0.z, 1, uTexCoord, r, g, b, a);
        updateTexCoordU();
        quad.setVertex(2, Sid2Point1.x, Sid2Point1.y, Sid2Point1.z, 1, uTexCoord, r, g, b, a);
        quad.setVertex(3, Sid1Point1.x, Sid1Point1.y, Sid1Point1.z, 0, uTexCoord, r, g, b, a);      
        updateTexCoordU();
        addQuad(quad);
      }    
    }
  }  
  
  void updateTexCoordU() { 
    uTexCoord += TEXCOORDU_INC;
    if (1 < uTexCoord) {
      uTexCoord = 0;
    } 
  }
  
  void addQuad(StrokeQuad quad) {
    quads.add(quad);
  }   
    
  void pintar(Toque[] toques, color tinta, float escala) {    
    if (quadCount.size() < toques.length) {
      for (int i = quadCount.size(); i < toques.length; i++) {
        addPointToRibbon(toques[i].x, toques[i].y, tinta, escala, toques[i].primero);
        quadCount.add(quads.size());
      }
    }
    
    if (0 < quadCount.size()) {
      float alphaScale = alpha(tinta) / 255;
      beginShape(QUADS);
      noStroke();
      fill(tinta);
      for (int i = 0; i < quadCount.get(toques.length - 1); i++) {
        StrokeQuad quad = quads.get(i);
        quad.display(alphaScale);
      }
      endShape(); 
    }
  }
}

class StrokeQuad {  
  float[] x, y, z;
  float[] u, v;  
  float[] r, g, b, a;
  float[] a0;
  boolean visible;

  int t;

  StrokeQuad(int t) {
    this.t = t;  
    x = new float[4];
    y = new float[4];
    z = new float[4];
    u = new float[4];
    v = new float[4];    
    r = new float[4];
    g = new float[4];
    b = new float[4];
    a = new float[4];
    a0 = new float[4];
    visible = true;
  }
  
  StrokeQuad(XML xml) {
    t = parseInt(xml.getChild("t").getContent());
    x = new float[4];
    y = new float[4];
    z = new float[4];
    u = new float[4];
    v = new float[4];    
    r = new float[4];
    g = new float[4];
    b = new float[4];
    a = new float[4];
    a0 = new float[4];
    for (int i = 0; i < 4; i++) {
      String vert = xml.getChild("v" + i).getContent();
      String[] parts = split(vert, ",");
      x[i] = parseFloat(parts[0]);
      y[i] = parseFloat(parts[1]);
      z[i] = parseFloat(parts[2]);
      
      u[i] = parseFloat(parts[3]);
      v[i] = parseFloat(parts[4]);
   
      r[i] = parseFloat(parts[5]);
      g[i] = parseFloat(parts[6]);

      b[i] = parseFloat(parts[7]);
      a[i] = parseFloat(parts[8]);
      a0[i] = parseFloat(parts[9]);
    }
  }

  void setVertex(int i, float x, float y, float z, float u, float v, float r, float g, float b, float a) {
    this.x[i] = x;
    this.y[i] = y;
    this.z[i] = z;

    this.u[i] = u;
    this.v[i] = v;

    this.r[i] = r;
    this.g[i] = g;
    this.b[i] = b;
    this.a[i] = a;

    a0[i] = a;
  }

  void restoreAlpha() {
    for (int i = 0; i < 4; i++) {
      a[i] = a0[i];
    }
  }

  void update(float ff) {
    visible = false;
    for (int i = 0; i < 4; i++) {
      a[i] *= ff;
      if (INVISIBLE_ALPHA < a[i]) {        
        visible = true;
      } else {
        a[i] = 0;
      }
    }     
  }

  //void draw(PGraphics pg, float ascale) {
  void display(float alphaScale) {  
    if (visible) {      
      for (int i = 0; i < 4; i++) {        
        if (USE_TEXTURES) {
          tint(r[i], g[i], b[i], a[i] * alphaScale);
          vertex(x[i], y[i], u[i], v[i]);
        } else {
          fill(r[i], g[i], b[i], a[i] * alphaScale);
          vertex(x[i], y[i]);          
        } 
      }      
    }
  }
}

final int MAX_BEZIER_ORDER = 10; // Maximum curve order.

final float[][] BSplineMatrix = {
  {-1.0/6.0,  1.0/2.0, -1.0/2.0, 1.0/6.0},
  { 1.0/2.0,     -1.0,  1.0/2.0,     0.0},
  {-1.0/2.0,      0.0,  1.0/2.0,     0.0},
  { 1.0/6.0,  2.0/3.0,  1.0/6.0,     0.0}
};

// The element(i, n) of this array contains the binomial coefficient
// C(i, n) = n!/(i!(n-i)!)
final int[][] BinomialCoefTable = {
  {1, 1, 1, 1,  1,  1,  1,  1,   1,   1},
  {1, 2, 3, 4,  5,  6,  7,  8,   9,  10},
  {0, 1, 3, 6, 10, 15, 21, 28,  36,  45},
  {0, 0, 1, 4, 10, 20, 35, 56,  84, 120},
  {0, 0, 0, 1,  5, 15, 35, 70, 126, 210},
  {0, 0, 0, 0,  1,  6, 21, 56, 126, 252},
  {0, 0, 0, 0,  0,  1,  7, 28,  84, 210},
  {0, 0, 0, 0,  0,  0,  1,  8,  36, 120},
  {0, 0, 0, 0,  0,  0,  0,  1,   9,  45},
  {0, 0, 0, 0,  0,  0,  0,  0,   1,  10},
  {0, 0, 0, 0,  0,  0,  0,  0,   0,   1}
};

// The element of this(i, j) of this table contains(i/10)^(3-j).
final float[][] TVectorTable = {  
//   t^3,  t^2, t^1, t^0
  {    0,    0,   0,   1}, // t = 0.0
  {0.001, 0.01, 0.1,   1}, // t = 0.1
  {0.008, 0.04, 0.2,   1}, // t = 0.2
  {0.027, 0.09, 0.3,   1}, // t = 0.3
  {0.064, 0.16, 0.4,   1}, // t = 0.4
  {0.125, 0.25, 0.5,   1}, // t = 0.5
  {0.216, 0.36, 0.6,   1}, // t = 0.6
  {0.343, 0.49, 0.7,   1}, // t = 0.7
  {0.512, 0.64, 0.8,   1}, // u = 0.8
  {0.729, 0.81, 0.9,   1}, // t = 0.9
  {    1,    1,   1,   1}  // t = 1.0
};

// The element of this(i, j) of this table contains(3-j)*(i/10)^(2-j) if
// j < 3, 0 otherwise.
final float[][] DTVectorTable = { 
// 3t^2,  2t^1, t^0
  {   0,     0,   1, 0}, // t = 0.0
  {0.03,   0.2,   1, 0}, // t = 0.1
  {0.12,   0.4,   1, 0}, // t = 0.2
  {0.27,   0.6,   1, 0}, // t = 0.3
  {0.48,   0.8,   1, 0}, // t = 0.4
  {0.75,   1.0,   1, 0}, // t = 0.5
  {1.08,   1.2,   1, 0}, // t = 0.6
  {1.47,   1.4,   1, 0}, // t = 0.7
  {1.92,   1.6,   1, 0}, // t = 0.8
  {2.43,   1.8,   1, 0}, // t = 0.9
  {   3,     2,   1, 0}  // t = 1.0
};

abstract class Curve3D {
  abstract void feval(float t, PVector p);
  abstract void deval(float t, PVector d);

  abstract float fevalX(float t);
  abstract float fevalY(float t);
  abstract float fevalZ(float t);

  abstract float devalX(float t);
  abstract float devalY(float t);
  abstract float devalZ(float t);
}

abstract class Spline extends Curve3D {
  // The factorial of n.
  int factorial(int n) { 
    return n <= 0 ? 1 : n * factorial(n - 1); 
  }
  // Gives n!/(i!(n-i)!).
  int binomialCoef(int i, int n) {
    if ((i <= MAX_BEZIER_ORDER) &&(n <= MAX_BEZIER_ORDER)) return BinomialCoefTable[i][n - 1];
    else return int(factorial(n) /(factorial(i) * factorial(n - i)));
  }
  // Evaluates the Berstein polinomial(i, n) at u.
  float bersteinPol(int i, int n, float u) {
    return binomialCoef(i, n) * pow(u, i) * pow(1 - u, n - i);
  }
  // The derivative of the Berstein polinomial.
  float dbersteinPol(int i, int n, float u) {
    float s1, s2; 
    if (i == 0) s1 = 0; 
    else s1 = i * pow(u, i-1) * pow(1 - u, n - i);
    if (n == i) s2 = 0; 
    else s2 = -(n - i) * pow(u, i) * pow(1 - u, n - i - 1);
    return binomialCoef(i, n) *(s1 + s2);
  }
}

class BSpline extends Spline {
  BSpline() { 
    initParameters(true); 
  }
  BSpline(boolean t) { 
    initParameters(t); 
  }

  // Sets lookup table use.
  void initParameters(boolean t) { 
    bsplineCPoints = new float[4][3];
    TVector = new float[4];
    DTVector = new float[4]; 
    M3 = new float[4][3];
    pt = new float[3];
    tg = new float[3];        
    lookup = t;
  }
  // Sets n-th control point.
  void setCPoint(int n, PVector P) {
    bsplineCPoints[n][0] = P.x;
    bsplineCPoints[n][1] = P.y;
    bsplineCPoints[n][2] = P.z;        
    updateMatrix3();
  }

  // Gets n-th control point.
  void getCPoint(int n, PVector P) {
    P.set(bsplineCPoints[n]);
  }

  // Replaces the current B-spline control points(0, 1, 2) with(1, 2, 3). This
  // is used when a new spline is to be joined to the recently drawn.
  void shiftBSplineCPoints() {
    for (int i = 0; i < 3; i++) {
      bsplineCPoints[0][i] = bsplineCPoints[1][i];
      bsplineCPoints[1][i] = bsplineCPoints[2][i];
      bsplineCPoints[2][i] = bsplineCPoints[3][i];
    }
    updateMatrix3();
  }

  void copyCPoints(int n_source, int n_dest) {
    for (int i = 0; i < 3; i++) {
      bsplineCPoints[n_dest][i] = bsplineCPoints[n_source][i];
    }
  }


  // Updates the temporal matrix used in order 3 calculations.
  void updateMatrix3() {
    float s; 
    int i, j, k;
    for(i = 0; i < 4; i++) {
      for(j = 0; j < 3; j++) {
        s = 0;
        for(k = 0; k < 4; k++) s += BSplineMatrix[i][k] * bsplineCPoints[k][j];
        M3[i][j] = s;
      }
    }
  }    

  void feval(float t, PVector p) { 
    evalPoint(t); 
    p.set(pt); 
  }
  void deval(float t, PVector d) { 
    evalTangent(t); 
    d.set(tg); 
  }

  float fevalX(float t) { 
    evalPoint(t); 
    return pt[0]; 
  }
  float fevalY(float t) { 
    evalPoint(t); 
    return pt[1]; 
  }
  float fevalZ(float t) { 
    evalPoint(t); 
    return pt[2]; 
  }

  float devalX(float t) { 
    evalTangent(t); 
    return tg[0]; 
  }
  float devalY(float t) { 
    evalTangent(t); 
    return tg[1]; 
  }
  float devalZ(float t) { 
    evalTangent(t); 
    return tg[2]; 
  }

  // Point evaluation.
  void evalPoint(float t) {
    if (lookup) {
      bsplinePointI(int(10 * t));
    } else {
      bsplinePoint(t);
    }
  }    

  // Tangent evaluation.
  void evalTangent(float t) {
    if (lookup) {
      bsplineTangentI(int(10 * t));
    } else {
      bsplineTangent(t);
    }
  }    

  // Calculates the point on the cubic spline corresponding to the parameter value t in [0, 1].
  void bsplinePoint(float t) {
    // Q(u) = UVector * BSplineMatrix * BSplineCPoints

    float s;
    int i, j, k;

    for(i = 0; i < 4; i++) {
      TVector[i] = pow(t, 3 - i);
    }

    for(j = 0; j < 3; j++) {
      s = 0;
      for(k = 0; k < 4; k++) {
        s += TVector[k] * M3[k][j];
      }
      pt[j] = s;
    }
  }

  // Calculates the tangent vector of the spline at t.
  void bsplineTangent(float t) {
    // Q(u) = DTVector * BSplineMatrix * BSplineCPoints

    float s;
    int i, j, k;

    for(i = 0; i < 4; i++) {
      if (i < 3) {
        DTVector[i] = (3 - i) * pow(t, 2 - i);
      } else {
        DTVector[i] = 0;
      }
    }

    for(j = 0; j < 3; j++) {
      s = 0;
      for(k = 0; k < 4; k++) {
        s += DTVector[k] * M3[k][j];
      }
      tg[j] = s;
    }
  }

  // Gives the point on the cubic spline corresponding to t/10(using the lookup table).
  void bsplinePointI(int t)
  {
    // Q(u) = TVectorTable[u] * BSplineMatrix * BSplineCPoints

    float s;
    int j, k;

    for(j = 0; j < 3; j++) {
      s = 0;
      for(k = 0; k < 4; k++) {
        s += TVectorTable[t][k] * M3[k][j];
      }
      pt[j] = s;
    }
  }

  // Calulates the tangent vector of the spline at t/10.
  void bsplineTangentI(int t) {
    // Q(u) = DTVectorTable[u] * BSplineMatrix * BSplineCPoints

    float s;
    int j, k;

    for(j = 0; j < 3; j++) {
      s = 0;
      for(k = 0; k < 4; k++) {
        s += DTVectorTable[t][k] * M3[k][j];
      }
      tg[j] = s;
    }
  }    

  // Control points.
  float[][] bsplineCPoints;

  // Parameters.
  boolean lookup;

  // Auxiliary arrays used in the calculations.
  float[][] M3;
  float[] TVector, DTVector;

  // Point and tangent vectors.
  float[] pt, tg;
}
