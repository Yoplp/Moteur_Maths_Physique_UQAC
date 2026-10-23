import java.util.HashSet;

// Rectangle fixe du décor
class Plateforme {
  float x, y, largeur, hauteur;   

  Plateforme(float x, float y, float largeur, float hauteur) {
    this.x = x;
    this.y = y;
    this.largeur = largeur;
    this.hauteur = hauteur;
  }

  void dessiner() {
    noStroke();
    fill(0);
    rect(x, y, largeur, hauteur);
  }
}


// Détection des contacts entre les particules et le décor.
// Pour chaque couple (particule, plateforme), on cherche le point du rectangle le plus proche
// du centre du cercle : s'il est à une distance inférieure au rayon, il y a interpénétration.
class DetectionDecor implements DetecteurContact {
  ArrayList<Particule> particules;
  ArrayList<Plateforme> plateformes;
  float restitution;      // rebond sur le décor
  float gravite;          // norme de g, utilisée pour reconnaître un contact au repos

  // Particules posées sur une surface (normale vers le bas) : sert au jeu pour autoriser le saut
  HashSet<Particule> particulesAuSol = new HashSet<Particule>();

  DetectionDecor(ArrayList<Particule> particules, ArrayList<Plateforme> plateformes, float restitution, float gravite) {
    this.particules = particules;
    this.plateformes = plateformes;
    this.restitution = restitution;
    this.gravite = gravite;
  }

  @Override
    void ajouterContacts(ArrayList<Contact> contacts, float temps) {
    particulesAuSol.clear();

    for (Particule p : particules) {
      for (Plateforme pl : plateformes) {
        // Point du rectangle le plus proche du centre de la particule
        float qx = constrain(p.pos.x, pl.x, pl.x + pl.largeur);
        float qy = constrain(p.pos.y, pl.y, pl.y + pl.hauteur);
        Vecteur3D versPlateforme = new Vecteur3D(qx - p.pos.x, qy - p.pos.y, 0);
        float distance = versPlateforme.normeEuclidienne();

        Vecteur3D normale;
        float penetration;

        if (distance > 0.0f) {
          if (distance >= p.rayon) {
            continue;                          // pas de contact
          }
          // Cas normal : le centre est dehors, le cercle mord sur le rectangle
          normale = versPlateforme.normaliser();
          penetration = p.rayon - distance;
        } else {
          // Cas rare : le centre est entré dans le rectangle (grande vitesse).
          // On le ressort par le bord le plus proche.
          float gauche = p.pos.x - pl.x;
          float droite = pl.x + pl.largeur - p.pos.x;
          float haut   = p.pos.y - pl.y;
          float bas    = pl.y + pl.hauteur - p.pos.y;
          float mini = min(min(gauche, droite), min(haut, bas));

          if (mini == haut)        normale = new Vecteur3D(0, 1, 0);
          else if (mini == bas)    normale = new Vecteur3D(0, -1, 0);
          else if (mini == gauche) normale = new Vecteur3D(1, 0, 0);
          else                     normale = new Vecteur3D(-1, 0, 0);
          penetration = mini + p.rayon;
        }

        // Contact au repos (cours 6) : si la vitesse d'approche ne vient que de la gravité
        // appliquée pendant une frame (v.n <= g.n * dt), l'objet est stationnaire -> pas de rebond.
        // La gravité est projetée sur la normale (ex. : nulle contre un mur vertical).
        float vitesseApproche = p.velocite.scalaire(normale);
        float graviteNormale = new Vecteur3D(0, gravite, 0).scalaire(normale);
        float e = (vitesseApproche <= graviteNormale * temps) ? 0.0f : restitution;

        contacts.add(new Contact(p, null, e, normale, penetration));

        // Normale orientée vers le bas (y écran vers le bas) = la particule est posée sur la surface
        if (normale.y > 0.5f) {
          particulesAuSol.add(p);
        }
      }
    }
  }
}
