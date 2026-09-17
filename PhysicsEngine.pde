void setup() {
  size(640, 640);
  
  Vector3D a = new Vector3D(1, 2, 3);
  Vector3D b = new Vector3D(4, 5, 6);

  println("Norme de a : " + a.magnitude());
  println("Norme carrée de a : " + a.magnitudeSquared());
  println("Normalisation : " + a.normalized());
  println("Multiplication : " + a.multiply(2));
  println("Addition : " + a.add(b));
  println("Soustraction : " + a.subtract(b));
  println("Produit par composantes : " + a.componentMultiply(b));
  println("Produit scalaire : " + a.dot(b));
  println("Produit vectoriel : " + a.cross(b));
  
  
  TestVector3D tests = new TestVector3D();
  tests.runTests();
}

void draw() {

}
