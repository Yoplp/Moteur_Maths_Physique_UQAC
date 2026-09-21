class Vecteur3D {
  final float x;
  final float y;
  final float z;

  Vecteur3D(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  // Norme au carré : x² + y² + z²
  float normeCarre() {
    return x * x + y * y + z * z;
  }

  // Norme euclidienne : racine(x² + y² + z²)
  float normeEuclidienne() {
    return sqrt(normeCarre());
  }

  // Multiplication par un scalaire
  Vecteur3D multiplier(float scalar) {
    return new Vecteur3D(
      x * scalar,
      y * scalar,
      z * scalar
    );
  }

  // Renvoie un nouveau vecteur de norme 1
  Vecteur3D normaliser() {
    float normeEuclidienne = normeEuclidienne();

    if (normeEuclidienne == 0.0f) {
      throw new IllegalStateException("Impossible de normaliser un vecteur avec une norme euclidienne a 0.");
    }

    return multiplier(1.0f / normeEuclidienne);
  }

  // Addition de deux vecteurs
  Vecteur3D ajouter(Vecteur3D vecteur) {
    return new Vecteur3D(
      x + vecteur.x,
      y + vecteur.y,
      z + vecteur.z
    );
  }

  // Soustraction de deux vecteurs
  Vecteur3D soustraire(Vecteur3D vecteur) {
    return new Vecteur3D(
      x - vecteur.x,
      y - vecteur.y,
      z - vecteur.z
    );
  }

  // Produit par composante
  Vecteur3D produitParComposante(Vecteur3D vecteur) {
    return new Vecteur3D(
      x * vecteur.x,
      y * vecteur.y,
      z * vecteur.z
    );
  }

  // Produit scalaire
  float scalaire(Vecteur3D vecteur) {
    return x * vecteur.x
         + y * vecteur.y
         + z * vecteur.z;
  }

  // Produit vectoriel
  Vecteur3D produitVectoriel(Vecteur3D vecteur) {
    return new Vecteur3D(
      y * vecteur.z - z * vecteur.y,
      z * vecteur.x - x * vecteur.z,
      x * vecteur.y - y * vecteur.x
    );
  }

  // Affichage console
  @Override
  String toString() {
    return "Vecteur3D(" + x + ", " + y + ", " + z + ")";
  }
}
