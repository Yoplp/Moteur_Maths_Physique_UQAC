enum TypeProjectile {
  BALLE(
    6,           // Rayon
    255, 255, 0, // Couleur RGB
    400,         // Vitesse
    0.999f,      // Frottements
    0.1f         // Masse
  ),
  BOULET(
    16,
    150, 150, 150,
    250,
    0.999f,
    5.0f
  ),
  BOULE_DE_FEU(
    12,
    255, 100, 0,
    150,
    0.999f,
    2.0f
  ),
  LASER(
    4,
    255, 0, 0,
    800,
    1.0f,
    0.01f
  );

  final float rayon;
  final int rouge;
  final int vert;
  final int bleu;
  final float vitesse;
  final float frottements;
  final float masse;

  TypeProjectile(float rayon, int rouge, int vert, int bleu, float vitesse, float frottements, float masse) {
    this.rayon = rayon;
    this.rouge = rouge;
    this.vert = vert;
    this.bleu = bleu;
    this.vitesse = vitesse;
    this.frottements = frottements;
    this.masse = masse;
  }
}
