class Cible {
  Vecteur3D pos;
  float largeur = 20;
  float hauteur = 50;
  color couleurAttendue;

  Cible() {
    // Position aléatoire 
    float x = random(width / 2, width - largeur);
    float y = random(height / 2, height - 50 - hauteur); // Reste au-dessus du sol
    pos = new Vecteur3D(x, y, 0);

    //  couleur aléatoire parmis celle des balles
    int choix = int(random(4));

    if (choix == 0) couleurAttendue = color(255, 255, 0); // Balle
    else if (choix == 1) couleurAttendue = color(150, 150, 150); // Boulet
    else if (choix == 2) couleurAttendue = color(255, 0, 0); // Laser
    else couleurAttendue = color(255, 100, 0); // Boule de feu
  }

  void dessiner() {
    fill(couleurAttendue);
    noStroke();
    rect(pos.x, pos.y, largeur, hauteur);
  }

  // Vérifie la collision Cercle (Projectile) / Rectangle (Cible) ET la couleur
  boolean estTouchee(Particule p) {
    Vecteur3D pPos = p.pos;
    float pRayon = p.rayon;

    // point du rectangle le plus proche du centre de la particule
    float pointProcheX = constrain(pPos.x, pos.x, pos.x + largeur);
    float pointProcheY = constrain(pPos.y, pos.y, pos.y + hauteur);

    // distance entre ce point et le centre de la particule
    float distance = dist(pPos.x, pPos.y, pointProcheX, pointProcheY);

    // si distance est plus petite que le rayon, il y a collision
    boolean collisionPhysique = distance < pRayon;
    
    return (collisionPhysique && p.couleur == couleurAttendue);
  }
}
