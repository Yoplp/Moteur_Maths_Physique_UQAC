
class TestMatrices {
  final float EPSILON = 0.0001f;
  boolean tousLesTestsReussis = true;

  boolean runTests() {
    tousLesTestsReussis = true;
    println("---- DEBUT TESTS UNITAIRES Matrix3 / Matrix4 / Quaternion ----");
    testMatrix3Identite();
    testMatrix3Produit();
    testMatrix3ProduitVecteur();
    testMatrix3Transposee();
    testMatrix3Determinant();
    testMatrix3Inverse();
    testMatrix3InverseSinguliere();
    testMatrix3Antisymetrique();
    testMatrix3TenseurBoite();
    testMatrix3AxeParallele();

    testMatrix4Point();
    testMatrix4Direction();
    testMatrix4Composition();
    testMatrix4Inverse();

    testQuaternionHamilton();
    testQuaternionNormaliser();
    testQuaternionAxeAngle();
    testQuaternionPivoter();
    testQuaternionConjugue();
    testQuaternionVersMatrice();
    testMatriceVersQuaternion();
    testQuaternionIntegrationCours();
    testQuaternionSlerp();
    println("---- FIN TESTS UNITAIRES Matrix3 / Matrix4 / Quaternion ----");
    return tousLesTestsReussis;
  }

  //  Matrix3 
  void testMatrix3Identite() {
    Vecteur3D v = new Vecteur3D(1, -2, 3);
    verifierVecteur("testMatrix3Identite", v, new Matrix3().mult(v));    // I v = v
  }

  void testMatrix3Produit() {
    Matrix3 a = new Matrix3(1, 2, 0,
                            0, 1, 0,
                            2, 0, 1);
    Matrix3 b = new Matrix3(1, 0, 1,
                            0, 2, 0,
                            1, 1, 0);
    // ligne 3 de A . colonnes de B : (2+0+1, 0+0+1, 2+0+0) = (3, 1, 2)
    Matrix3 attendu = new Matrix3(1, 4, 1,
                                  0, 2, 0,
                                  3, 1, 2);
    verifierMatrix3("testMatrix3Produit", attendu, a.mult(b));
  }

  void testMatrix3ProduitVecteur() {
    Matrix3 a = new Matrix3(1, 2, 0,
                            0, 1, 0,
                            2, 0, 1);
    Vecteur3D attendu = new Vecteur3D(5, 2, 5);     // (1+4+0, 0+2+0, 2+0+3)
    verifierVecteur("testMatrix3ProduitVecteur", attendu, a.mult(new Vecteur3D(1, 2, 3)));
  }

  void testMatrix3Transposee() {
    Matrix3 a = new Matrix3(1, 2, 0,
                            0, 1, 0,
                            2, 0, 1);
    Matrix3 attendu = new Matrix3(1, 0, 2,
                                  2, 1, 0,
                                  0, 0, 1);
    verifierMatrix3("testMatrix3Transposee", attendu, a.transposee());
  }

  void testMatrix3Determinant() {
    Matrix3 m = new Matrix3(2, 0, 1,
                            1, 3, 2,
                            1, 1, 2);
    // 2 (3*2 - 2*1) - 0 + 1 (1*1 - 3*1) = 8 - 2 = 6
    verifierFloat("testMatrix3Determinant", 6, m.determinant());
  }

  void testMatrix3Inverse() {
    Matrix3 m = new Matrix3(2, 0, 1,
                            1, 3, 2,
                            1, 1, 2);
    Matrix3 inv = m.inverse();
    verifierMatrix3("testMatrix3Inverse (M M^-1 = I)", new Matrix3(), m.mult(inv));
    verifierMatrix3("testMatrix3Inverse (M^-1 M = I)", new Matrix3(), inv.mult(m));
  }

  void testMatrix3InverseSinguliere() {
    Matrix3 s = new Matrix3(1, 2, 3,
                            2, 4, 6,       // ligne 2 = 2 x ligne 1 : déterminant nul
                            1, 1, 1);
    boolean exceptionLancee = false;
    try {
      s.inverse();
    } catch (ArithmeticException e) {
      exceptionLancee = true;
    }
    verifier("testMatrix3InverseSinguliere", exceptionLancee, "aucune exception pour une matrice singulière");
  }

  void testMatrix3Antisymetrique() {
    Vecteur3D v = new Vecteur3D(1, 2, 3);
    Vecteur3D u = new Vecteur3D(4, -5, 6);
    Vecteur3D attendu = new Vecteur3D(27, 6, -13);   // v x u
    verifierVecteur("testMatrix3Antisymetrique ([v]x u = v x u)", attendu, new Matrix3().setAntisymetrique(v).mult(u));
  }

  void testMatrix3TenseurBoite() {
    // M = 3, demi-dimensions (1, 2, 3) : Ixx = 1 (4 + 9), Iyy = 1 (1 + 9), Izz = 1 (1 + 4)
    Matrix3 attendu = new Matrix3(13, 0, 0,
                                  0, 10, 0,
                                  0, 0, 5);
    verifierMatrix3("testMatrix3TenseurBoite", attendu, new Matrix3().setTenseurBoite(3, new Vecteur3D(1, 2, 3)));
  }

  void testMatrix3AxeParallele() {
    // Masse ponctuelle (Jcm = 0) de 2 kg à 3 m sur l'axe z : Ixx = Iyy = m r² = 18, Izz = 0
    Matrix3 nul = new Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0);
    Matrix3 attendu = new Matrix3(18, 0, 0,
                                  0, 18, 0,
                                  0, 0, 0);
    verifierMatrix3("testMatrix3AxeParallele", attendu, nul.axeParallele(2, new Vecteur3D(0, 0, 3)));
  }

  //  Matrix4 

  // Rotation de 90° autour de z suivie d'une translation de (10, 0, 0)
  Matrix4 rotation90zTranslation() {
    return new Quaternion().setAxeAngle(new Vecteur3D(0, 0, 1), HALF_PI).toMatrix4(new Vecteur3D(10, 0, 0));
  }

  void testMatrix4Point() {
    // (1, 0, 0) -> rotation -> (0, 1, 0) -> translation -> (10, 1, 0)
    verifierVecteur("testMatrix4Point", new Vecteur3D(10, 1, 0), rotation90zTranslation().mult(new Vecteur3D(1, 0, 0)));
  }

  void testMatrix4Direction() {
    // Une direction n'est pas translatée : (1, 0, 0) -> (0, 1, 0)
    verifierVecteur("testMatrix4Direction", new Vecteur3D(0, 1, 0), rotation90zTranslation().multDirection(new Vecteur3D(1, 0, 0)));
  }

  void testMatrix4Composition() {
    Matrix4 a = rotation90zTranslation();
    Matrix4 b = new Quaternion().setAxeAngle(new Vecteur3D(1, 0, 0), 0.7).toMatrix4(new Vecteur3D(1, 2, 3));
    Vecteur3D p = new Vecteur3D(1, -2, 0.5);
    // (A B) p = A (B p)
    verifierVecteur("testMatrix4Composition", a.mult(b.mult(p)), a.mult(b).mult(p));
  }

  void testMatrix4Inverse() {
    Matrix4 m = rotation90zTranslation();
    Vecteur3D p = new Vecteur3D(3, -1, 2);
    verifierMatrix4("testMatrix4Inverse (M M^-1 = I)", new Matrix4(), m.mult(m.inverse()));
    verifierVecteur("testMatrix4Inverse (M^-1 M p = p)", p, m.inverse().mult(m.mult(p)));
    verifierVecteur("testMatrix4MultInversePoint", p, m.multInversePoint(m.mult(p)));

    // Avec une mise à l'échelle (partie linéaire non orthonormée)
    Matrix4 echelle = new Matrix4().setEchelle(new Vecteur3D(2, 4, 0.5)).setTranslation(new Vecteur3D(1, 1, 1));
    verifierMatrix4("testMatrix4Inverse (échelle)", new Matrix4(), echelle.inverse().mult(echelle));
  }

  //  Quaternion
  void testQuaternionHamilton() {
    Quaternion i = new Quaternion(0, 1, 0, 0);
    Quaternion j = new Quaternion(0, 0, 1, 0);
    verifierQuaternion("testQuaternionHamilton (i j = k)", new Quaternion(0, 0, 0, 1), i.mult(j));
    verifierQuaternion("testQuaternionHamilton (j i = -k)", new Quaternion(0, 0, 0, -1), j.mult(i));
    verifierQuaternion("testQuaternionHamilton (i i = -1)", new Quaternion(-1, 0, 0, 0), i.mult(i));
  }

  void testQuaternionNormaliser() {
    Quaternion q = new Quaternion(1, 1, 1, 1).normaliser();
    verifierQuaternion("testQuaternionNormaliser", new Quaternion(0.5, 0.5, 0.5, 0.5), q);
    verifierFloat("testQuaternionNormaliser (norme)", 1, q.norme());
  }

  void testQuaternionAxeAngle() {
    // 180° autour de z, avec un axe non unitaire : [cos 90°, sin 90° (0, 0, 1)] = [0, (0, 0, 1)]
    Quaternion q = new Quaternion().setAxeAngle(new Vecteur3D(0, 0, 2), PI);
    verifierQuaternion("testQuaternionAxeAngle", new Quaternion(0, 0, 0, 1), q);
    verifierFloat("testQuaternionAxeAngle (angle)", PI, q.angle());
    verifierVecteur("testQuaternionAxeAngle (axe)", new Vecteur3D(0, 0, 1), q.axe());
  }

  void testQuaternionPivoter() {
    Quaternion q = new Quaternion().setAxeAngle(new Vecteur3D(0, 0, 1), HALF_PI);
    verifierVecteur("testQuaternionPivoter", new Vecteur3D(0, 1, 0), q.pivoter(new Vecteur3D(1, 0, 0)));
    verifierVecteur("testQuaternionPivoter (sur l'axe)", new Vecteur3D(0, 0, 5), q.pivoter(new Vecteur3D(0, 0, 5)));
  }

  void testQuaternionConjugue() {
    Quaternion q = new Quaternion().setAxeAngle(new Vecteur3D(1, 2, 3), 1.1);
    verifierQuaternion("testQuaternionConjugue (q q* = 1)", new Quaternion(), q.mult(q.conjugue()));
    verifierQuaternion("testQuaternionConjugue (q* = q^-1)", q.inverse(), q.conjugue());
  }

  void testQuaternionVersMatrice() {
    Quaternion q = new Quaternion().setAxeAngle(new Vecteur3D(1, 2, 3), 1.1);
    Matrix3 r = q.toMatrix3();
    Vecteur3D v = new Vecteur3D(0.3, -1, 2);
    // La matrice et le quaternion doivent faire la même rotation : R v = q v q*
    verifierVecteur("testQuaternionVersMatrice (R v = q v q*)", q.pivoter(v), r.mult(v));
    verifier("testQuaternionVersMatrice (orthonormale)", r.estOrthonormale(EPSILON), "R R^T != I");
    verifierFloat("testQuaternionVersMatrice (det = 1)", 1, r.determinant());
  }

  void testMatriceVersQuaternion() {
    // Grands angles autour de x, y, z : la trace est négative, on passe par les 3 autres cas de setMatrix3
    Vecteur3D[] axes = { new Vecteur3D(1, 0, 0), new Vecteur3D(0, 1, 0), new Vecteur3D(0, 0, 1), new Vecteur3D(1, 2, 3) };
    float[] angles = { 3.0, 3.0, 3.0, 1.1 };
    for (int k = 0; k < axes.length; k++) {
      Quaternion q = new Quaternion().setAxeAngle(axes[k], angles[k]);
      Quaternion retour = new Quaternion().setMatrix3(q.toMatrix3());
      // q et -q représentent la même orientation
      boolean ok = retour.egale(q, EPSILON) || retour.egale(q.negation(), EPSILON);
      verifier("testMatriceVersQuaternion #" + (k + 1), ok, "attendu " + q + ", obtenu " + retour);
    }
  }

  void testQuaternionIntegrationCours() {
    // Exemple du cours (ch. 8) : q = 1, w = (1, 1, 1) pendant 2 s
    //   q' = q + 1/2 [0, w] q dt = [1, (1, 1, 1)]  ->  normalisé : [1/2, (1/2, 1/2, 1/2)]
    //   soit une rotation de 120° autour de (1, 1, 1)
    Quaternion q = new Quaternion();
    q.integrer(new Vecteur3D(1, 1, 1), 2);
    verifierQuaternion("testQuaternionIntegrationCours", new Quaternion(0.5, 0.5, 0.5, 0.5), q);
    verifierFloat("testQuaternionIntegrationCours (120°)", TWO_PI / 3, q.angle());
    float u = 1 / sqrt(3);
    verifierVecteur("testQuaternionIntegrationCours (axe)", new Vecteur3D(u, u, u), q.axe());
  }

  void testQuaternionSlerp() {
    Quaternion q0 = new Quaternion();
    Quaternion q1 = new Quaternion().setAxeAngle(new Vecteur3D(0, 0, 1), HALF_PI);
    Quaternion attendu = new Quaternion().setAxeAngle(new Vecteur3D(0, 0, 1), QUARTER_PI);   // à mi-chemin : 45°
    verifierQuaternion("testQuaternionSlerp", attendu, q0.slerp(q1, 0.5));
  }

  //  Vérifications-
  void verifier(String nomTest, boolean condition, String detailEchec) {
    if (condition) {
      println("[SUCCÈS] " + nomTest);
    } else {
      println("[ÉCHEC] " + nomTest + " | " + detailEchec);
      tousLesTestsReussis = false;
    }
  }

  void verifierFloat(String nomTest, float attendu, float actuel) {
    verifier(nomTest, abs(attendu - actuel) < EPSILON, "Attendu: " + attendu + ", Obtenu: " + actuel);
  }

  void verifierVecteur(String nomTest, Vecteur3D attendu, Vecteur3D actuel) {
    boolean ok = abs(attendu.x - actuel.x) < EPSILON
              && abs(attendu.y - actuel.y) < EPSILON
              && abs(attendu.z - actuel.z) < EPSILON;
    verifier(nomTest, ok, "Attendu: " + attendu + ", Obtenu: " + actuel);
  }

  void verifierMatrix3(String nomTest, Matrix3 attendu, Matrix3 actuel) {
    verifier(nomTest, attendu.egale(actuel, EPSILON), "Attendu:\n" + attendu + "Obtenu:\n" + actuel);
  }

  void verifierMatrix4(String nomTest, Matrix4 attendu, Matrix4 actuel) {
    verifier(nomTest, attendu.egale(actuel, EPSILON), "Attendu:\n" + attendu + "Obtenu:\n" + actuel);
  }

  void verifierQuaternion(String nomTest, Quaternion attendu, Quaternion actuel) {
    verifier(nomTest, attendu.egale(actuel, EPSILON), "Attendu: " + attendu + ", Obtenu: " + actuel);
  }
}
