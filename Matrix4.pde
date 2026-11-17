/**
 * Transformation affine en coordonnées homogènes, stockée sous forme de matrice 3x4
 * (la dernière ligne [0 0 0 1] est omise) par lignes dans m[12] :
 *     | m[0] m[1]  m[2]  m[3]  |      | R  t |
 *     | m[4] m[5]  m[6]  m[7]  |  =   | 0  1 |
 *     | m[8] m[9]  m[10] m[11] |
 * où R est la partie linéaire (rotation, échelle...) et t la translation.
 *
 * Les méthodes qui retournent une Matrix4 créent un nouvel objet,
 * sauf celles dont le nom commence par "set".
 */
class Matrix4 {
  float[] m = new float[12];

  // ---------- Constructeurs ----------
  Matrix4() {  // identité
    setIdentite();
  }

  Matrix4(Matrix4 o) {
    arrayCopy(o.m, m);
  }

  // ---------- Initialisation ----------
  Matrix4 setIdentite() {
    for (int i = 0; i < 12; i++) m[i] = 0;
    m[0] = 1; m[5] = 1; m[10] = 1;
    return this;
  }

  Matrix4 copie() {
    return new Matrix4(this);
  }

  /** Transformation corps rigide : rotation q suivie de la translation pos (objet -> monde). */
  Matrix4 setOrientationEtPosition(Quaternion q, PVector pos) {
    setMatrix3(q.toMatrix3());
    return setTranslation(pos);
  }

  Matrix4 setMatrix3(Matrix3 R) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) m[4 * i + j] = R.m[3 * i + j];
    }
    return this;
  }

  Matrix4 setTranslation(PVector t) {
    m[3] = t.x; m[7] = t.y; m[11] = t.z;
    return this;
  }

  Matrix4 setEchelle(PVector s) {
    setIdentite();
    m[0] = s.x; m[5] = s.y; m[10] = s.z;
    return this;
  }

  // ---------- Accès ----------
  Matrix3 getMatrix3() {
    return new Matrix3(m[0], m[1], m[2],
                       m[4], m[5], m[6],
                       m[8], m[9], m[10]);
  }

  PVector getTranslation() {
    return new PVector(m[3], m[7], m[11]);
  }

  /** i-ème colonne de la partie linéaire (0, 1, 2 : axes de l'objet dans le repère monde). */
  PVector getAxe(int i) {
    return new PVector(m[i], m[4 + i], m[8 + i]);
  }

  // ---------- Opérations ----------
  /** Composition this * o : applique d'abord o, puis this. */
  Matrix4 mult(Matrix4 o) {
    Matrix4 r = new Matrix4();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        r.m[4 * i + j] = m[4 * i] * o.m[j] + m[4 * i + 1] * o.m[4 + j] + m[4 * i + 2] * o.m[8 + j];
      }
      // Translation : R1 * t2 + t1
      r.m[4 * i + 3] = m[4 * i] * o.m[3] + m[4 * i + 1] * o.m[7] + m[4 * i + 2] * o.m[11] + m[4 * i + 3];
    }
    return r;
  }

  /** Transforme un POINT (position) : R p + t. */
  PVector mult(PVector p) {
    return new PVector(
      m[0] * p.x + m[1] * p.y + m[2] * p.z + m[3],
      m[4] * p.x + m[5] * p.y + m[6] * p.z + m[7],
      m[8] * p.x + m[9] * p.y + m[10] * p.z + m[11]
    );
  }

  /** Transforme une DIRECTION : R d (la translation est ignorée, i.e. composante homogène w = 0). */
  PVector multDirection(PVector d) {
    return new PVector(
      m[0] * d.x + m[1] * d.y + m[2] * d.z,
      m[4] * d.x + m[5] * d.y + m[6] * d.z,
      m[8] * d.x + m[9] * d.y + m[10] * d.z
    );
  }

  float determinant() {
    return getMatrix3().determinant();
  }

  /** Inverse d'une transformation affine : [R t]^-1 = [R^-1  -R^-1 t]. */
  Matrix4 inverse() {
    Matrix3 Rinv = getMatrix3().inverse();     // lance une exception si singulière
    Matrix4 r = new Matrix4();
    r.setMatrix3(Rinv);
    PVector t = Rinv.mult(getTranslation());
    return r.setTranslation(t.mult(-1));
  }

  /**
   * Raccourci pour un corps rigide (partie linéaire orthonormée) : applique l'inverse
   * de la transformation à un point (monde -> objet) sans calculer l'inverse complet : R^T (p - t).
   */
  PVector multInversePoint(PVector p) {
    PVector d = PVector.sub(p, getTranslation());
    return getMatrix3().transposee().mult(d);
  }

  PVector multInverseDirection(PVector d) {
    return getMatrix3().transposee().mult(d);
  }

  boolean egale(Matrix4 o, float eps) {
    for (int i = 0; i < 12; i++) if (abs(m[i] - o.m[i]) > eps) return false;
    return true;
  }

  // ---------- Intégration avec Processing ----------
  /** Multiplie la matrice courante de Processing par celle-ci (à utiliser entre pushMatrix()/popMatrix()). */
  void appliquer() {
    applyMatrix(m[0], m[1], m[2], m[3],
                m[4], m[5], m[6], m[7],
                m[8], m[9], m[10], m[11],
                0, 0, 0, 1);
  }

  String toString() {
    String s = "";
    for (int i = 0; i < 3; i++) {
      s += "| " + nf(m[4 * i], 0, 4) + "  " + nf(m[4 * i + 1], 0, 4) + "  "
         + nf(m[4 * i + 2], 0, 4) + "  " + nf(m[4 * i + 3], 0, 4) + " |\n";
    }
    return s + "| 0.0000  0.0000  0.0000  1.0000 |\n";
  }
}
