void setup() {
  size(1280, 640);

  TestVecteur3D tests = new TestVecteur3D();
  boolean reussiteTests = true;
  reussiteTests = !(reussiteTests && !tests.runTests());

  if (!reussiteTests) {
    println("ERREUR : Un ou plusieurs tests ont échoué. Arrêt du moteur.");
    exit();
    return;
  }
}

void draw() {
  background(0);
}

void keyPressed() {
}

void mousePressed() {
}