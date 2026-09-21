class TestVecteur3D {
  // Tolérance pour la comparaison de nombres à virgule flottante
  final float EPSILON = 0.0001f;
  boolean tousLesTestsReussis = true;
  
  boolean runTests() {
    tousLesTestsReussis = true;
    println("---- DEBUT TESTS UNITAIRES Vecteur3D ----");
    testNormeCarre();
    testNormeEuclidienne();
    testMultiplier();
    testNormaliser();
    testAjouter();
    testSoustraire();
    testProduitParComposante();
    testScalaire();
    testProduitVectoriel();
    println("---- FIN TESTS UNITAIRES Vecteur3D ----");
    
    return tousLesTestsReussis;
  }

  void testNormeCarre() {
    Vecteur3D v = new Vecteur3D(1, 2, 3);
    float attendu = 14; // 1² + 2² + 3² = 1 + 4 + 9
    verifierFloat("testNormeCarre", attendu, v.normeCarre());
  }

  void testNormeEuclidienne() {
    Vecteur3D v = new Vecteur3D(0, 3, 4);
    float attendu = 5; // sqrt(0 + 9 + 16)
    verifierFloat("testNormeEuclidienne", attendu, v.normeEuclidienne());
  }

  void testMultiplier() {
    Vecteur3D v = new Vecteur3D(1, -2, 3);
    Vecteur3D attendu = new Vecteur3D(2, -4, 6); // (1*2 + -2*2 + 3*2)
    verifierVector("testMultiplier", attendu, v.multiplier(2));
  }

  void testNormaliser() {
    Vecteur3D v = new Vecteur3D(3, 0, 0);
    Vecteur3D attendu = new Vecteur3D(1, 0, 0); // sqrt(3*3 + 0 + 0) ----> (3, 0, 0) / (3, 3, 3)
    verifierVector("testNormaliser", attendu, v.normaliser());
  }

  void testAjouter() {
    Vecteur3D v1 = new Vecteur3D(1, 2, 3);
    Vecteur3D v2 = new Vecteur3D(-1, -3, 5);
    Vecteur3D attendu = new Vecteur3D(0, -1, 8); // ( 1-1, 2-3, 3+5)
    verifierVector("testAjouter", attendu, v1.ajouter(v2));
  }

  void testSoustraire() {
    Vecteur3D v1 = new Vecteur3D(5, 5, 5);
    Vecteur3D v2 = new Vecteur3D(2, 3, 4);
    Vecteur3D attendu = new Vecteur3D(3, 2, 1); // (5-2, 5-3 5-4)
    verifierVector("testSoustraire", attendu, v1.soustraire(v2));
  }

  void testProduitParComposante() {
    Vecteur3D v1 = new Vecteur3D(2, 3, 4);
    Vecteur3D v2 = new Vecteur3D(2, 1, 0.5f);
    Vecteur3D attendu = new Vecteur3D(4, 3, 2); // (2*2, 3*1, 4*0.5)
    verifierVector("testProduitParComposante", attendu, v1.produitParComposante(v2));
  }

  void testScalaire() {
    Vecteur3D v1 = new Vecteur3D(1, 2, 3);
    Vecteur3D v2 = new Vecteur3D(4, -5, 6);
    float attendu = 12; // (1*4) + (2*-5) + (3*6) = 4 - 10 + 18
    verifierFloat("testScalaire", attendu, v1.scalaire(v2));
  }

  void testProduitVectoriel() {
    Vecteur3D v1 = new Vecteur3D(2, 3, 4);
    Vecteur3D v2 = new Vecteur3D(5, -1, 2);
    // composante X : (y1 * z2) - (z1 * y2) = (3 * 2) - (4 * -1) = 6 - (-4) = 10
    // composante Y : (z1 * x2) - (x1 * z2) = (4 * 5) - (2 * 2) = 20 - 4 = 16
    // composante Z : (x1 * y2) - (y1 * x2) = (2 * -1) - (3 * 5) = -2 - 15 = -17
    Vecteur3D attendu = new Vecteur3D(10, 16, -17);
    verifierVector("testProduitVectoriel", attendu, v1.produitVectoriel(v2));
  }

  // Méthodes utilitaires de vérification utilisation de EPSILON pour éviter des mini erreurs de mémoire
  void verifierFloat(String nomTest, float attendu, float actuel) {
    if (abs(attendu - actuel) < EPSILON) {
      println("[SUCCÈS] " + nomTest);
    } else {
      println("[ÉCHEC] " + nomTest + " | Attendu: " + attendu + ", Obtenu: " + actuel);
      tousLesTestsReussis = false;
    }
  }

  void verifierVector(String nomTest, Vecteur3D attendu, Vecteur3D actuel) {
    if (abs(attendu.x - actuel.x) < EPSILON && 
        abs(attendu.y - actuel.y) < EPSILON && 
        abs(attendu.z - actuel.z) < EPSILON) {
      println("[SUCCÈS] " + nomTest);
    } else {
      println("[ÉCHEC] " + nomTest + " | Attendu: " + attendu + ", Obtenu: " + actuel);
      tousLesTestsReussis = false;
    }
  }
}
