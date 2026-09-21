class Cible {
  Vecteur3D pos;
  float largeur = 20;
  float hauteur = 50;
  TypeProjectile projectileAttendu;

  Cible() {
    // Position aléatoire 
    float x = random(width / 2, width - largeur);
    float y = random(height / 2, height - 50 - hauteur); // Reste au-dessus du sol
    this.pos = new Vecteur3D(x, y, 0);

    //  couleur aléatoire parmis celle des balles
    int choix = int(random(4));

    switch(choix) {
    case 1: // Boulet
      this.projectileAttendu = TypeProjectile.BOULET;
      break;
    case 2: // Laser
      this.projectileAttendu = TypeProjectile.LASER;
      break;
    case 3: // BDF
      this.projectileAttendu = TypeProjectile.BOULE_DE_FEU;
      break;
    default: // Balle (0) ou inconnu (défaute sur balle)
      this.projectileAttendu = TypeProjectile.BALLE;
      break;
    }
  }

  void dessiner() {
    fill(color(projectileAttendu.rouge, projectileAttendu.vert, projectileAttendu.bleu));
    noStroke();
    rect(pos.x, pos.y, largeur, hauteur);
  }

  // Vérifie la collision Cercle (Projectile) / Rectangle (Cible)
  boolean estTouchee(Projectile p) {
    Vecteur3D pPos = p.pos;
    float pRayon = p.rayon;

    // point du rectangle le plus proche du centre de la particule
    float pointProcheX = constrain(pPos.x, pos.x, pos.x + largeur);
    float pointProcheY = constrain(pPos.y, pos.y, pos.y + hauteur);

    // distance entre ce point et le centre de la particule
    float distance = dist(pPos.x, pPos.y, pointProcheX, pointProcheY);

    // si distance est plus petite que le rayon, il y a collision
    boolean collisionPhysique = distance < pRayon;
    
    return (collisionPhysique && p.type == projectileAttendu);
  }
}
