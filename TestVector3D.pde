class TestVector3D {
  // Tolérance pour la comparaison de nombres à virgule flottante
  final float EPSILON = 0.0001f;

  void runTests() {
    println("START OF Vector3D UNIT TESTS");
    testMagnitudeSquared();
    testMagnitude();
    testMultiply();
    testNormalized();
    testAdd();
    testSubtract();
    testComponentMultiply();
    testDot();
    testCross();
    println("END OF Vector3D UNIT TESTS");
  }

  void testMagnitudeSquared() {
    Vector3D v = new Vector3D(1, 2, 3);
    float expected = 14; // 1² + 2² + 3² = 1 + 4 + 9
    checkFloat("testMagnitudeSquared (Norme carrée)", expected, v.magnitudeSquared());
  }

  void testMagnitude() {
    Vector3D v = new Vector3D(0, 3, 4);
    float expected = 5; // sqrt(0 + 9 + 16)
    checkFloat("testMagnitude (Norme)", expected, v.magnitude());
  }

  void testMultiply() {
    Vector3D v = new Vector3D(1, -2, 3);
    Vector3D expected = new Vector3D(2, -4, 6); // (1*2 + -2*2 + 3*2)
    checkVector("testMultiply (Multiplication par un scalaire)", expected, v.multiply(2));
  }

  void testNormalized() {
    Vector3D v = new Vector3D(3, 0, 0);
    Vector3D expected = new Vector3D(1, 0, 0); // sqrt(3*3 + 0 + 0) ----> (3, 0, 0) / (3, 3, 3)
    checkVector("testNormalized (Normalisation)", expected, v.normalized());
  }

  void testAdd() {
    Vector3D v1 = new Vector3D(1, 2, 3);
    Vector3D v2 = new Vector3D(-1, -3, 5);
    Vector3D expected = new Vector3D(0, -1, 8); // ( 1-1, 2-3, 3+5)
    checkVector("testAdd (Addition)", expected, v1.add(v2));
  }

  void testSubtract() {
    Vector3D v1 = new Vector3D(5, 5, 5);
    Vector3D v2 = new Vector3D(2, 3, 4);
    Vector3D expected = new Vector3D(3, 2, 1); // (5-2, 5-3 5-4)
    checkVector("testSubtract (Soustraction)", expected, v1.subtract(v2));
  }

  void testComponentMultiply() {
    Vector3D v1 = new Vector3D(2, 3, 4);
    Vector3D v2 = new Vector3D(2, 1, 0.5f);
    Vector3D expected = new Vector3D(4, 3, 2); // (2*2, 3*1, 4*0.5)
    checkVector("testComponentMultiply (Produit par composantes)", expected, v1.componentMultiply(v2));
  }

  void testDot() {
    Vector3D v1 = new Vector3D(1, 2, 3);
    Vector3D v2 = new Vector3D(4, -5, 6);
    float expected = 12; // (1*4) + (2*-5) + (3*6) = 4 - 10 + 18
    checkFloat("testDot (Produit scalaire)", expected, v1.dot(v2));
  }

  void testCross() {
    Vector3D v1 = new Vector3D(2, 3, 4);
    Vector3D v2 = new Vector3D(5, -1, 2);
    // composante X : (y1 * z2) - (z1 * y2) = (3 * 2) - (4 * -1) = 6 - (-4) = 10
    // composante Y : (z1 * x2) - (x1 * z2) = (4 * 5) - (2 * 2) = 20 - 4 = 16
    // composante Z : (x1 * y2) - (y1 * x2) = (2 * -1) - (3 * 5) = -2 - 15 = -17
    Vector3D expected = new Vector3D(10, 16, -17);
    
    checkVector("testCross (Produit vectoriel)", expected, v1.cross(v2));
  }

  // Méthodes utilitaires de vérification utilisation de EPSILON pour éviter des mini erreurs de mémoire
  
  void checkFloat(String testName, float expected, float actual) {
    if (abs(expected - actual) < EPSILON) {
      println("[SUCCÈS] " + testName);
    } else {
      println("[ÉCHEC] " + testName + " | Attendu: " + expected + ", Obtenu: " + actual);
    }
  }

  void checkVector(String testName, Vector3D expected, Vector3D actual) {
    if (abs(expected.x - actual.x) < EPSILON && 
        abs(expected.y - actual.y) < EPSILON && 
        abs(expected.z - actual.z) < EPSILON) {
      println("[SUCCÈS] " + testName);
    } else {
      println("[ÉCHEC] " + testName + " | Attendu: " + expected + ", Obtenu: " + actual);
    }
  }
}
