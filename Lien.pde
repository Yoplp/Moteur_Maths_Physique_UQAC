
// Lien élastique entre deux particules du blob.
//  - En dessous de la limite d'élasticité, il se comporte comme un RESSORT classique (loi de Hooke).
//  - Au-delà de longueurRepos * limiteElasticite, il se comporte comme un CÂBLE : il ne peut plus
//    s'allonger (contact généré par DetectionCable et résolu par impulsion).
class Lien {
  int ia, ib;                     // indices des particules dans le blob
  Particule a, b;
  float longueurRepos;
  float limiteElasticite;         // ex. 1.5 = le lien peut s'étirer de 50 % avant de devenir un câble

  // Un RessortParticules n'agit que sur UNE particule : il en faut un de chaque côté
  RessortParticules ressortSurA;
  RessortParticules ressortSurB;
  DetectionCable cable;

  Lien(int ia, int ib, Particule a, Particule b, float longueurRepos, float k, float limiteElasticite) {
    this.ia = ia;
    this.ib = ib;
    this.a = a;
    this.b = b;
    this.longueurRepos = longueurRepos;
    this.limiteElasticite = limiteElasticite;

    ressortSurA = new RessortParticules(b, k, longueurRepos);
    ressortSurB = new RessortParticules(a, k, longueurRepos);
    cable = new DetectionCable(a, b, longueurRepos * limiteElasticite, 0.0f);
  }

  void enregistrer(RegistreForces registre) {
    registre.ajouter(a, ressortSurA);
    registre.ajouter(b, ressortSurB);
  }

  void retirer(RegistreForces registre) {
    registre.retirer(a, ressortSurA);
    registre.retirer(b, ressortSurB);
  }

  // Longueur actuelle / longueur au repos (1 = au repos)
  float etirement() {
    return b.pos.soustraire(a.pos).normeEuclidienne() / longueurRepos;
  }

  // Couleur selon la tension : vert au repos -> rouge quand le lien devient un câble
  void dessiner() {
    float t = constrain((etirement() - 1.0f) / (limiteElasticite - 1.0f), 0, 1);
    stroke(lerpColor(color(90, 180, 90), color(220, 40, 40), t));
    strokeWeight(1.5);
    line(a.pos.x, a.pos.y, b.pos.x, b.pos.y);
  }
}
