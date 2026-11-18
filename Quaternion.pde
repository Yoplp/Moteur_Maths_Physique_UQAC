class Quaternion {
  float w = 1, x = 0, y = 0, z = 0;

  // ---------- Constructeurs ----------
  Quaternion() { }  // identité

  Quaternion(float w, float x, float y, float z) {
    this.w = w; this.x = x; this.y = y; this.z = z;
  }

  Quaternion(Quaternion q) {
    this(q.w, q.x, q.y, q.z);
  }

  // ---------- Initialisation ----------
  Quaternion set(float w, float x, float y, float z) {
    this.w = w; this.x = x; this.y = y; this.z = z;
    return this;
  }

  Quaternion setIdentite() {
    return set(1, 0, 0, 0);
  }

  // Rotation d'un angle (radians) autour d'un axe (pas nécessairement unitaire). 
  Quaternion setAxeAngle(Vecteur3D axe, float angle) {
    float longueur = axe.normeEuclidienne();
    if (longueur < 1e-8f) return setIdentite();
    float demi = angle / 2;
    float s = sin(demi) / longueur;
    return set(cos(demi), axe.x * s, axe.y * s, axe.z * s);
  }

  // Reconstruit le quaternion à partir d'une matrice de rotation 3x3.
  Quaternion setMatrix3(Matrix3 R) {
    float[] m = R.m;
    float trace = m[0] + m[4] + m[8];
    if (trace > 0) {
      float s = sqrt(trace + 1) * 2;
      set(s / 4, (m[7] - m[5]) / s, (m[2] - m[6]) / s, (m[3] - m[1]) / s);
    } else if (m[0] > m[4] && m[0] > m[8]) {
      float s = sqrt(1 + m[0] - m[4] - m[8]) * 2;
      set((m[7] - m[5]) / s, s / 4, (m[1] + m[3]) / s, (m[2] + m[6]) / s);
    } else if (m[4] > m[8]) {
      float s = sqrt(1 + m[4] - m[0] - m[8]) * 2;
      set((m[2] - m[6]) / s, (m[1] + m[3]) / s, s / 4, (m[5] + m[7]) / s);
    } else {
      float s = sqrt(1 + m[8] - m[0] - m[4]) * 2;
      set((m[3] - m[1]) / s, (m[2] + m[6]) / s, (m[5] + m[7]) / s, s / 4);
    }
    return normaliser();
  }

  Vecteur3D vecteur() {
    return new Vecteur3D(x, y, z);
  }

  float normeCarree() {
    return w * w + x * x + y * y + z * z;
  }

  float norme() {
    return sqrt(normeCarree());
  }

  // Normalise en place (nécessaire pour qu'il représente une rotation)
  Quaternion normaliser() {
    float n = norme();
    if (n < 1e-12f) return setIdentite();
    float inv = 1 / n;
    w *= inv; x *= inv; y *= inv; z *= inv;
    return this;
  }

  /** Angle de rotation en radians, dans [0, 2*PI]. */
  float angle() {
    return 2 * acos(constrain(w, -1, 1));
  }

  // Axe de rotation unitaire (arbitraire si la rotation est nulle)
  Vecteur3D axe() {
    float s = sqrt(max(0, 1 - w * w));
    if (s < 1e-6f) return new Vecteur3D(1, 0, 0);
    return new Vecteur3D(x / s, y / s, z / s);
  }

  // ---------- Opérations ----------
  /** -q : représente le même déplacement angulaire que q. */
  Quaternion negation() {
    return new Quaternion(-w, -x, -y, -z);
  }

  /** Conjugué q* : même rotation, sens opposé (= inverse si q est unitaire). */
  Quaternion conjugue() {
    return new Quaternion(w, -x, -y, -z);
  }

  Quaternion inverse() {
    float n2 = normeCarree();
    if (n2 < 1e-12f) throw new ArithmeticException("Quaternion nul : inverse impossible");
    float inv = 1 / n2;
    return new Quaternion(w * inv, -x * inv, -y * inv, -z * inv);
  }

  /**
   * Produit de Hamilton this * q :
   * [w1 w2 - v1.v2 ; w1 v2 + w2 v1 + v1 x v2]
   * Non commutatif. Pour les rotations : applique d'abord q, puis this.
   */
  Quaternion mult(Quaternion q) {
    return new Quaternion(
      w * q.w - x * q.x - y * q.y - z * q.z,
      w * q.x + x * q.w + y * q.z - z * q.y,
      w * q.y - x * q.z + y * q.w + z * q.x,
      w * q.z + x * q.y - y * q.x + z * q.w
    );
  }

  Quaternion mult(float s) {
    return new Quaternion(w * s, x * s, y * s, z * s);
  }

  Quaternion add(Quaternion q) {
    return new Quaternion(w + q.w, x + q.x, y + q.y, z + q.z);
  }

  float produitScalaire(Quaternion q) {
    return w * q.w + x * q.x + y * q.y + z * q.z;
  }

  // Fait pivoter un vecteur : p' = q p q* (this doit être unitaire)
  Vecteur3D pivoter(Vecteur3D p) {
    Vecteur3D v = vecteur();
    Vecteur3D t = v.produitVectoriel(p).multiplier(2);   // t = 2 (v x p)
    return p.ajouter(t.multiplier(w))                    // p + w t
            .ajouter(v.produitVectoriel(t));             //   + v x t
  }

  // Déplacement angulaire d tel que this * d = q2, soit d = this^-1 * q2
  Quaternion difference(Quaternion q2) {
    return inverse().mult(q2);
  }

  // Exponentiation q^t : fraction t du déplacement angulaire (q unitaire)
  Quaternion pow(float t) {
    float c = constrain(w, -1, 1);
    if (abs(c) > 0.9999f) return new Quaternion();   // rotation (quasi) nulle
    float demi = acos(c);                            // demi-angle
    float nouveauDemi = demi * t;
    float s = sin(nouveauDemi) / sin(demi);
    return new Quaternion(cos(nouveauDemi), x * s, y * s, z * s);
  }

  /**
   * SLERP : interpolation sphérique de this (t = 0) vers q1 (t = 1).
   * slerp = (q1 * q0^-1)^t * q0, en prenant le chemin le plus court.
   */
  Quaternion slerp(Quaternion q1, float t) {
    Quaternion cible = (produitScalaire(q1) < 0) ? q1.negation() : q1;
    Quaternion d = cible.mult(this.conjugue());
    return d.pow(t).mult(this);
  }

  /**
   * Mise à jour de l'orientation avec une vélocité angulaire constante omega (rad/s) pendant dt :
   *     q(t+dt) = q(t) + 1/2 * [0, omega] * q(t) * dt     puis normalisation.
   * Modifie this.
   */
  Quaternion integrer(Vecteur3D omega, float dt) {
    Quaternion w_q = new Quaternion(0, omega.x, omega.y, omega.z);
    Quaternion dq = w_q.mult(this).mult(0.5f * dt);
    w += dq.w; x += dq.x; y += dq.y; z += dq.z;
    return normaliser();
  }

  // ---------- Conversions ----------
  Matrix3 toMatrix3() {
    Matrix3 R = new Matrix3();
    return R.setOrientation(this);
  }

  Matrix4 toMatrix4(Vecteur3D position) {
    Matrix4 M = new Matrix4();
    return M.setOrientationEtPosition(this, position);
  }

  boolean egale(Quaternion q, float eps) {
    return abs(w - q.w) < eps && abs(x - q.x) < eps && abs(y - q.y) < eps && abs(z - q.z) < eps;
  }

  String toString() {
    return "[" + nf(w, 0, 4) + " | " + nf(x, 0, 4) + ", " + nf(y, 0, 4) + ", " + nf(z, 0, 4) + "]";
  }
}
