
// Boîte pleine (pavé) : corps rigide avec le tenseur d'inertie d'une boîte autour de son centre de masse
class Boite extends CorpsRigide {
  Vecteur3D demiDimensions;

  Boite(float masse, Vecteur3D demiDimensions, Vecteur3D position) {
    super(masse, new Matrix3().setTenseurBoite(masse, demiDimensions), position);
    this.demiDimensions = demiDimensions;
  }

  // Dessine la boîte avec notre propre Matrix4 
  void afficher(int opacite) {
    float a = demiDimensions.x, b = demiDimensions.y, c = demiDimensions.z;
    pushMatrix();
    transformation.appliquer();
    stroke(20);
    strokeWeight(2);
    beginShape(QUADS);
    fill(230, 70, 70, opacite);       
    vertex(-a, -b, c); vertex(a, -b, c); vertex(a, b, c); vertex(-a, b, c);
    fill(70, 200, 90, opacite);       
    vertex(a, -b, -c); vertex(-a, -b, -c); vertex(-a, b, -c); vertex(a, b, -c);
    fill(70, 120, 230, opacite);      
    vertex(a, -b, c); vertex(a, -b, -c); vertex(a, b, -c); vertex(a, b, c);
    fill(240, 200, 60, opacite);      
    vertex(-a, -b, -c); vertex(-a, -b, c); vertex(-a, b, c); vertex(-a, b, -c);
    fill(200, 90, 220, opacite);      
    vertex(-a, b, c); vertex(a, b, c); vertex(a, b, -c); vertex(-a, b, -c);
    fill(80, 210, 220, opacite);      
    vertex(-a, -b, -c); vertex(a, -b, -c); vertex(a, -b, c); vertex(-a, -b, c);
    endShape();
    popMatrix();
  }
}
