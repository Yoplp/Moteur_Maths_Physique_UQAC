class Vector3D {
  final float x;
  final float y;
  final float z;

  Vector3D(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  // Norme au carré : x² + y² + z²
  float magnitudeSquared() {
    return x * x + y * y + z * z;
  }

  // Norme euclidienne : racine(x² + y² + z²)
  float magnitude() {
    return sqrt(magnitudeSquared());
  }

  // Multiplication par un scalaire
  Vector3D multiply(float scalar) {
    return new Vector3D(
      x * scalar,
      y * scalar,
      z * scalar
    );
  }

  // Renvoie un nouveau vecteur de norme 1
  Vector3D normalized() {
    float magnitude = magnitude();

    if (magnitude == 0.0f) {
      throw new IllegalStateException("Cannot normalize a zero vector.");
    }

    return multiply(1.0f / magnitude);
  }

  // Addition de deux vecteurs
  Vector3D add(Vector3D vector) {
    return new Vector3D(
      x + vector.x,
      y + vector.y,
      z + vector.z
    );
  }

  // Soustraction de deux vecteurs
  Vector3D subtract(Vector3D vector) {
    return new Vector3D(
      x - vector.x,
      y - vector.y,
      z - vector.z
    );
  }

  // Produit par composante
  Vector3D componentMultiply(Vector3D vector) {
    return new Vector3D(
      x * vector.x,
      y * vector.y,
      z * vector.z
    );
  }

  // Produit scalaire
  float dot(Vector3D vector) {
    return x * vector.x
         + y * vector.y
         + z * vector.z;
  }

  // Produit vectoriel
  Vector3D cross(Vector3D vector) {
    return new Vector3D(
      y * vector.z - z * vector.y,
      z * vector.x - x * vector.z,
      x * vector.y - y * vector.x
    );
  }

  // Affichage console
  @Override
  String toString() {
    return "Vector3D(" + x + ", " + y + ", " + z + ")";
  }
}
