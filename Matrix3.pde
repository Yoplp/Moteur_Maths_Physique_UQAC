class Matrix3 {
  float[] m = new float[9];

  // ---------- Constructeurs ----------
  Matrix3() {  // identité
    setIdentite();
  }

  Matrix3(float m00, float m01, float m02,
          float m10, float m11, float m12,
          float m20, float m21, float m22) {
    set(m00, m01, m02, m10, m11, m12, m20, m21, m22);
  }

  // ---------- Initialisation ----------
  Matrix3 set(float m00, float m01, float m02,
              float m10, float m11, float m12,
              float m20, float m21, float m22) {
    m[0] = m00; m[1] = m01; m[2] = m02;
    m[3] = m10; m[4] = m11; m[5] = m12;
    m[6] = m20; m[7] = m21; m[8] = m22;
    return this;
  }

  Matrix3 setIdentite() {
    return set(1, 0, 0, 0, 1, 0, 0, 0, 1);
  }

  // Matrice dont les colonnes sont les vecteurs b1 b2 b3 */
  Matrix3 setColonnes(PVector b1, PVector b2, PVector b3) {
    return set(b1.x, b2.x, b3.x,
               b1.y, b2.y, b3.y,
               b1.z, b2.z, b3.z);
  }

  float get(int i, int j) {
    return m[3 * i + j];
  }

  Matrix3 set(int i, int j, float v) {
    m[3 * i + j] = v;
    return this;
  }


  // Matrice de rotation qui correspond à un quaternion. */
  Matrix3 setOrientation(Quaternion q) {
    float w = q.w, x = q.x, y = q.y, z = q.z;
    return set(
      1 - 2 * (y * y + z * z), 2 * (x * y - z * w),     2 * (x * z + y * w),
      2 * (x * y + z * w),     1 - 2 * (x * x + z * z), 2 * (y * z - x * w),
      2 * (x * z - y * w),     2 * (y * z + x * w),     1 - 2 * (x * x + y * y)
    );
  }

  // Matrice antisymétrique [v]x telle que [v]x * u = v x u. */
  Matrix3 setAntisymetrique(PVector v) {
    return set(0, -v.z, v.y,
               v.z, 0, -v.x,
               -v.y, v.x, 0);
  }

  // ---------- Tenseurs d'inertie (autour du centre de masse) ----------
  /** Boîte pleine de masse M, de demi-dimensions (a, b, c) : Ixx = M/3 (b² + c²), etc. */
  Matrix3 setTenseurBoite(float masse, PVector demiDim) {
    float a2 = demiDim.x * demiDim.x, b2 = demiDim.y * demiDim.y, c2 = demiDim.z * demiDim.z;
    return set(masse / 3 * (b2 + c2), 0, 0,
               0, masse / 3 * (a2 + c2), 0,
               0, 0, masse / 3 * (a2 + b2));
  }

  /** Sphère pleine : I = 2/5 M r². */
  Matrix3 setTenseurSphere(float masse, float rayon) {
    float i = 0.4f * masse * rayon * rayon;
    return set(i, 0, 0, 0, i, 0, 0, 0, i);
  }

  /**
   * Théorème de l'axe parallèle : tenseur d'inertie autour d'un point situé à d du centre de masse.
   *     J' = Jcm + M ( (d.d) I - d d^T )
   * this = Jcm (non modifié).
   */
  Matrix3 axeParallele(float masse, PVector d) {
    float x2 = d.x * d.x, y2 = d.y * d.y, z2 = d.z * d.z;
    Matrix3 delta = new Matrix3(
      y2 + z2, -d.x * d.y, -d.x * d.z,
      -d.x * d.y, x2 + z2, -d.y * d.z,
      -d.x * d.z, -d.y * d.z, x2 + y2
    );
    return add(delta.mult(masse));
  }

  /**
   * Tenseur exprimé dans le repère monde à partir du tenseur local (this) :
   *     J_monde = R J R^T       (idem pour l'inverse : J^-1_monde = R J^-1 R^T)
   */
  Matrix3 versRepereMonde(Matrix3 R) {
    return R.mult(this).mult(R.transposee());
  }

  // Matrice + matrice
  Matrix3 add(Matrix3 o) {
    Matrix3 r = new Matrix3();
    for (int i = 0; i < 9; i++) r.m[i] = m[i] + o.m[i];
    return r;
  }

  //Matrice * float
  Matrix3 mult(float s) {
    Matrix3 r = new Matrix3();
    for (int i = 0; i < 9; i++) r.m[i] = m[i] * s;
    return r;
  }

  // Produit matriciel
  Matrix3 mult(Matrix3 o) {
    Matrix3 r = new Matrix3();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        float somme = 0;
        for (int k = 0; k < 3; k++) somme += m[3 * i + k] * o.m[3 * k + j];
        r.m[3 * i + j] = somme;
      }
    }
    return r;
  }

  // matrice * vecteur
  PVector mult(PVector v) {
    return new PVector(
      m[0] * v.x + m[1] * v.y + m[2] * v.z,
      m[3] * v.x + m[4] * v.y + m[5] * v.z,
      m[6] * v.x + m[7] * v.y + m[8] * v.z
    );
  }

  //Calcul de la transposée
  Matrix3 transposee() {
    return new Matrix3(m[0], m[3], m[6],
                       m[1], m[4], m[7],
                       m[2], m[5], m[8]);
  }

  // Calcul du déterminant
  float determinant() {
    return m[0] * (m[4] * m[8] - m[5] * m[7])
         - m[1] * (m[3] * m[8] - m[5] * m[6])
         + m[2] * (m[3] * m[7] - m[4] * m[6]);
  }

  // Calcul de l'inverse de la matrice
  Matrix3 inverse() {
    float det = determinant();
    if (abs(det) < 1e-12f) throw new ArithmeticException("Matrice singulière : inverse impossible");
    float inv = 1 / det;
    return new Matrix3(
      (m[4] * m[8] - m[5] * m[7]) * inv, (m[2] * m[7] - m[1] * m[8]) * inv, (m[1] * m[5] - m[2] * m[4]) * inv,
      (m[5] * m[6] - m[3] * m[8]) * inv, (m[0] * m[8] - m[2] * m[6]) * inv, (m[2] * m[3] - m[0] * m[5]) * inv,
      (m[3] * m[7] - m[4] * m[6]) * inv, (m[1] * m[6] - m[0] * m[7]) * inv, (m[0] * m[4] - m[1] * m[3]) * inv
    );
  }

}
