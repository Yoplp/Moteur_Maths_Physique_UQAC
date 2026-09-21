class Projectile extends Particule {
  final TypeProjectile type;
  float rayon;
  color couleur;

  Projectile(TypeProjectile type, Vecteur3D positionDeDepart, Vecteur3D direction) {
    super(new Vecteur3D(0, 200, 0), direction.normaliser().multiplier(type.vitesse), positionDeDepart, type.frottements, type.masse);
    this.type = type;
    this.rayon = type.rayon;
    this.couleur = color(type.rouge, type.vert, type.bleu);
  }
}
