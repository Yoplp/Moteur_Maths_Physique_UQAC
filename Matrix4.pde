class Matrix4 {
  float[] m = new float[12];

  // ---------- Constructeurs ----------
  Matrix4() {  // identité
    setIdentite();
  }


  // ---------- Initialisation ----------
  Matrix4 setIdentite() {
    for (int i = 0; i < 12; i++) m[i] = 0;
    m[0] = 1; m[5] = 1; m[10] = 1;
    return this;
  }

  /** Transformation corps rigide : rotation q suivie de la translation pos (objet -> monde). */
  Matrix4 setOrientationEtPosition(Quaternion q, Vecteur3D pos) {
    setMatrix3(q.toMatrix3());
    return setTranslation(pos);
  }

  Matrix4 setMatrix3(Matrix3 R) {
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) m[4 * i + j] = R.m[3 * i + j];
    }
    return this;
  }

  Matrix4 setTranslation(Vecteur3D t) {
    m[3] = t.x; m[7] = t.y; m[11] = t.z;
    return this;
  }

  Matrix4 setEchelle(Vecteur3D s) {
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

  Vecteur3D getTranslation() {
    return new Vecteur3D(m[3], m[7], m[11]);
  }

  /** i-ème colonne de la partie linéaire (0, 1, 2 : axes de l'objet dans le repère monde). */
  Vecteur3D getAxe(int i) {
    return new Vecteur3D(m[i], m[4 + i], m[8 + i]);
  }


  // matrice * matrice
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

  // Transforme un POINT (position) : R p + t. 
  Vecteur3D mult(Vecteur3D p) {
    return new Vecteur3D(
      m[0] * p.x + m[1] * p.y + m[2] * p.z + m[3],
      m[4] * p.x + m[5] * p.y + m[6] * p.z + m[7],
      m[8] * p.x + m[9] * p.y + m[10] * p.z + m[11]
    );
  }

  // Transforme une DIRECTION : R d (la translation est ignorée, i.e. composante homogène w = 0). 
  Vecteur3D multDirection(Vecteur3D d) {
    return new Vecteur3D(
      m[0] * d.x + m[1] * d.y + m[2] * d.z,
      m[4] * d.x + m[5] * d.y + m[6] * d.z,
      m[8] * d.x + m[9] * d.y + m[10] * d.z
    );
  }

  float determinant() {
    return getMatrix3().determinant();
  }

  // Inversion 
  Matrix4 inverse() {
    Matrix3 Rinv = getMatrix3().inverse();     
    Matrix4 r = new Matrix4();
    r.setMatrix3(Rinv);
    Vecteur3D t = Rinv.mult(getTranslation());
    return r.setTranslation(t.multiplier(-1));
  }

  /**
   * Raccourci pour un corps rigide (partie linéaire orthonormée) : applique l'inverse
   * de la transformation à un point (monde -> objet) sans calculer l'inverse complet : R^T (p - t).
   */
  Vecteur3D multInversePoint(Vecteur3D p) {
    Vecteur3D d = p.soustraire(getTranslation());
    return getMatrix3().transposee().mult(d);
  }

  Vecteur3D multInverseDirection(Vecteur3D d) {
    return getMatrix3().transposee().mult(d);
  }

  // ---------- Intégration avec Processing ----------
  /** Multiplie la matrice courante de Processing par celle-ci (à utiliser entre pushMatrix()/popMatrix()). */
  void appliquer() {
    applyMatrix(m[0], m[1], m[2], m[3],
                m[4], m[5], m[6], m[7],
                m[8], m[9], m[10], m[11],
                0, 0, 0, 1);
  }

  // ---------- Comparaison / affichage (utilisés par les tests) ----------
  boolean egale(Matrix4 o, float eps) {
    for (int i = 0; i < 12; i++) if (abs(m[i] - o.m[i]) > eps) return false;
    return true;
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
