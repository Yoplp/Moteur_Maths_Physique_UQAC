class Projectile extends Particule {
  final TypeProjectile type;
  float rayon;
  color couleur;
  ArrayList<Vecteur3D> historique;

  Projectile(TypeProjectile type, Vecteur3D positionDeDepart, Vecteur3D direction, float vitesseInitial) {
    super(new Vecteur3D(0, 200, 0), direction.normaliser().multiplier(vitesseInitial), positionDeDepart, type.frottements, type.masse);
    this.type = type;
    this.rayon = type.rayon;
    this.couleur = color(type.rouge, type.vert, type.bleu);
    this.historique = new ArrayList<Vecteur3D>();
  }
  
  void enregistrerPosition() {
    historique.add(new Vecteur3D(pos.x, pos.y, pos.z));
  }
  
  void dessinerTrajectoire() {
    noFill();
    stroke(couleur, 160);
    strokeWeight(2);
    
    beginShape();
      for (Vecteur3D pt : historique) {
        vertex(pt.x, pt.y);
      }
      vertex(pos.x, pos.y);
    endShape();
  }
  
  void dessiner() {
    fill(couleur);
    noStroke();
    ellipse(pos.x, pos.y, rayon * 2, rayon * 2);
  }
  
}
  
