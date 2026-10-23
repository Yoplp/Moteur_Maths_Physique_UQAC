
// Le blob : un ensemble de particules reliées par des liens (ressort + câble).
// Un "morceau" = un groupe de particules reliées entre elles (composante connexe du graphe des liens).
// Couper des liens sépare le blob en plusieurs morceaux ; deux morceaux qui se touchent fusionnent.
//
// Le Blob est aussi un DetecteurContact : il génère les contacts "câble" de tous ses liens.
//
// Une particule "au joueur" fait partie du blob du joueur (ou a déjà été récupérée).
// Les autres sont les particules à récupérer, posées sur la carte.
class Blob implements DetecteurContact {
  ArrayList<Particule> particules = new ArrayList<Particule>();
  ArrayList<Lien> liens = new ArrayList<Lien>();
  RegistreForces registre;      // pour ajouter / retirer les ressorts quand on crée / coupe un lien

  float kRessort;
  float limiteElasticite;
  float distanceLien;           // deux particules plus proches que ça sont reliées lors d'une fusion

  // Par particule (même indice que dans "particules")
  ArrayList<Integer> idMorceau = new ArrayList<Integer>();
  ArrayList<Float> delaiFusion = new ArrayList<Float>();   // secondes avant de pouvoir refusionner
  ArrayList<Boolean> auJoueur = new ArrayList<Boolean>();  // true = appartient au joueur / récupérée
  int nbMorceaux = 0;

  final float DELAI_APRES_COUPE = 1.5f;   // empêche les deux moitiés de se recoller aussitôt
  final float VITESSE_SEPARATION = 90;   // petit "pop" des deux moitiés après la coupe (px/s)

  Blob(RegistreForces registre, float kRessort, float limiteElasticite, float distanceLien) {
    this.registre = registre;
    this.kRessort = kRessort;
    this.limiteElasticite = limiteElasticite;
    this.distanceLien = distanceLien;
  }

  void ajouterParticule(Particule p, boolean duJoueur) {
    particules.add(p);
    idMorceau.add(0);
    delaiFusion.add(0.0f);
    auJoueur.add(duJoueur);
  }

  int nbParticulesAuJoueur() {
    int n = 0;
    for (boolean b : auJoueur) {
      if (b) n++;
    }
    return n;
  }

  // Crée un lien entre les particules i et j
  void relier(int i, int j, float longueurRepos) {
    Lien l = new Lien(i, j, particules.get(i), particules.get(j), longueurRepos, kRessort, limiteElasticite);
    l.enregistrer(registre);
    liens.add(l);
  }

  // Relie toutes les paires de particules suffisamment proches (construction initiale du blob)
  void relierVoisins() {
    for (int i = 0; i < particules.size(); i++) {
      for (int j = i + 1; j < particules.size(); j++) {
        float d = distance(i, j);
        if (d < distanceLien) {
          relier(i, j, d);
        }
      }
    }
    calculerMorceaux();
  }

  float distance(int i, int j) {
    return particules.get(j).pos.soustraire(particules.get(i).pos).normeEuclidienne();
  }

  // ---------------------------------------------------------------------------
  // Câbles : quand un lien dépasse sa limite d'élasticité, on génère un contact
  @Override
    void ajouterContacts(ArrayList<Contact> contacts, float temps) {
    for (Lien l : liens) {
      l.cable.ajouterContacts(contacts, temps);
    }
  }

  // ---------------------------------------------------------------------------
  // Morceaux : parcours en largeur (BFS) du graphe particules / liens.
  // Chaque particule reçoit le numéro du morceau auquel elle appartient.
  void calculerMorceaux() {
    int n = particules.size();

    // Liste des voisins de chaque particule
    ArrayList<ArrayList<Integer>> voisins = new ArrayList<ArrayList<Integer>>();
    for (int i = 0; i < n; i++) {
      voisins.add(new ArrayList<Integer>());
      idMorceau.set(i, -1);
    }
    for (Lien l : liens) {
      voisins.get(l.ia).add(l.ib);
      voisins.get(l.ib).add(l.ia);
    }

    nbMorceaux = 0;
    for (int depart = 0; depart < n; depart++) {
      if (idMorceau.get(depart) != -1) {
        continue;                            // déjà visitée
      }
      // Nouveau morceau : on visite tout ce qui est relié à "depart"
      ArrayList<Integer> file = new ArrayList<Integer>();
      file.add(depart);
      idMorceau.set(depart, nbMorceaux);
      while (!file.isEmpty()) {
        int courant = file.remove(0);
        for (int v : voisins.get(courant)) {
          if (idMorceau.get(v) == -1) {
            idMorceau.set(v, nbMorceaux);
            file.add(v);
          }
        }
      }
      nbMorceaux++;
    }

    // Récupération : si un morceau contient une particule du joueur,
    // toutes les particules de ce morceau deviennent au joueur (définitivement).
    for (int i = 0; i < n; i++) {
      if (!auJoueur.get(i)) continue;
      for (int j = 0; j < n; j++) {
        if (idMorceau.get(j) == idMorceau.get(i)) {
          auJoueur.set(j, true);
        }
      }
    }
  }

  // Indices des particules du même morceau que la particule "index"
  ArrayList<Integer> morceauDe(int index) {
    ArrayList<Integer> resultat = new ArrayList<Integer>();
    int id = idMorceau.get(index);
    for (int i = 0; i < particules.size(); i++) {
      if (idMorceau.get(i) == id) {
        resultat.add(i);
      }
    }
    return resultat;
  }

  // Centre de masse d'un morceau : somme(m_i * x_i) / somme(m_i)
  Vecteur3D centreDeMasse(ArrayList<Integer> morceau) {
    Vecteur3D somme = new Vecteur3D(0, 0, 0);
    float masseTotale = 0;
    for (int i : morceau) {
      Particule p = particules.get(i);
      somme = somme.ajouter(p.pos.multiplier(p.masse));
      masseTotale += p.masse;
    }
    return somme.multiplier(1.0f / masseTotale);
  }

  // Particule du joueur la plus proche d'un point (sert à sélectionner un morceau au clic)
  int particuleJoueurPlusProche(Vecteur3D point) {
    int meilleur = 0;
    float meilleureDistance = Float.MAX_VALUE;
    for (int i = 0; i < particules.size(); i++) {
      if (!auJoueur.get(i)) continue;
      float d = particules.get(i).pos.soustraire(point).normeEuclidienne();
      if (d < meilleureDistance) {
        meilleureDistance = d;
        meilleur = i;
      }
    }
    return meilleur;
  }

  // ---------------------------------------------------------------------------
  // Clic gauche (lance-pierre) : au relâchement, on donne une impulsion J au morceau,
  // dans la direction centre -> souris. J est proportionnelle à la longueur du trait
  // (pleine puissance à partir de "distancePleine" pixels).
  //
  // Tout morceau reçoit la même impulsion, répartie sur ses particules :
  //   delta_v = J / masseTotale  -> un petit morceau part plus vite, donc plus haut !
  Vecteur3D vitesseDeLancer(int index, Vecteur3D cible, float impulsionMax, float distancePleine, float vitesseMax) {
    ArrayList<Integer> morceau = morceauDe(index);
    Vecteur3D direction = cible.soustraire(centreDeMasse(morceau));
    float distance = direction.normeEuclidienne();
    if (distance < 1.0f) {
      return new Vecteur3D(0, 0, 0);
    }

    float masseTotale = 0;
    for (int i : morceau) {
      masseTotale += particules.get(i).masse;
    }

    float impulsion = impulsionMax * min(distance / distancePleine, 1.0f);
    float deltaV = min(impulsion / masseTotale, vitesseMax);
    return direction.normaliser().multiplier(deltaV);
  }

  // Le morceau doit toucher le sol pour pouvoir se lancer (sinon on pourrait voler)
  boolean peutSeLancer(int index, HashSet<Particule> auSol) {
    for (int i : morceauDe(index)) {
      if (auSol.contains(particules.get(i))) {
        return true;
      }
    }
    return false;
  }

  // Applique la variation de vitesse à toutes les particules du morceau
  void lancer(int index, Vecteur3D deltaV) {
    for (int i : morceauDe(index)) {
      Particule p = particules.get(i);
      p.velocite = p.velocite.ajouter(deltaV);
    }
  }

  // ---------------------------------------------------------------------------
  // Clic droit : la "lame" est le segment [lameA, lameB] parcouru par la souris pendant la frame.
  // Tout lien qui croise ce segment est supprimé (comme Fruit Ninja).
  int couper(Vecteur3D lameA, Vecteur3D lameB) {
    Vecteur3D lame = lameB.soustraire(lameA);
    if (lame.normeEuclidienne() < 1.0f) {
      return 0;
    }
    // Normale de la lame (perpendiculaire dans le plan de l'écran)
    Vecteur3D normaleLame = new Vecteur3D(-lame.y, lame.x, 0).normaliser();

    int nbCoupes = 0;
    HashSet<Particule> dejaPoussees = new HashSet<Particule>();   // une seule poussée par particule
    for (int i = liens.size() - 1; i >= 0; i--) {
      Lien l = liens.get(i);
      if (!segmentsSeCroisent(lameA, lameB, l.a.pos, l.b.pos)) {
        continue;
      }

      l.retirer(registre);
      liens.remove(i);
      nbCoupes++;

      // Chaque extrémité est poussée de son côté de la lame
      if (dejaPoussees.add(l.a)) separer(l.a, l.ia, lameA, normaleLame);
      if (dejaPoussees.add(l.b)) separer(l.b, l.ib, lameA, normaleLame);
    }

    if (nbCoupes > 0) {
      calculerMorceaux();
    }
    return nbCoupes;
  }

  void separer(Particule p, int index, Vecteur3D pointLame, Vecteur3D normaleLame) {
    // Signe du produit scalaire = de quel côté de la lame se trouve la particule
    float cote = p.pos.soustraire(pointLame).scalaire(normaleLame) >= 0 ? 1 : -1;
    p.velocite = p.velocite.ajouter(normaleLame.multiplier(cote * VITESSE_SEPARATION));
    delaiFusion.set(index, DELAI_APRES_COUPE);
  }

  // Test d'intersection de deux segments [p1,p2] et [q1,q2] en 2D :
  // les extrémités de chaque segment doivent être de part et d'autre de l'autre segment
  // (produits vectoriels de signes opposés).
  boolean segmentsSeCroisent(Vecteur3D p1, Vecteur3D p2, Vecteur3D q1, Vecteur3D q2) {
    float d1 = produitVectoriel2D(q2.soustraire(q1), p1.soustraire(q1));
    float d2 = produitVectoriel2D(q2.soustraire(q1), p2.soustraire(q1));
    float d3 = produitVectoriel2D(p2.soustraire(p1), q1.soustraire(p1));
    float d4 = produitVectoriel2D(p2.soustraire(p1), q2.soustraire(p1));
    return (d1 * d2 < 0) && (d3 * d4 < 0);
  }

  // Composante z du produit vectoriel (le seul non nul pour deux vecteurs du plan)
  float produitVectoriel2D(Vecteur3D u, Vecteur3D v) {
    return u.produitVectoriel(v).z;
  }

  // ---------------------------------------------------------------------------
  // Fusion : si deux particules de morceaux différents se touchent, on relie les deux morceaux.
  // On crée un lien entre toutes les paires proches (une de chaque morceau).
  void mettreAJour(float dt) {
    for (int i = 0; i < delaiFusion.size(); i++) {
      delaiFusion.set(i, max(0, delaiFusion.get(i) - dt));
    }

    for (int i = 0; i < particules.size(); i++) {
      for (int j = i + 1; j < particules.size(); j++) {
        if (idMorceau.get(i) == idMorceau.get(j)) continue;
        if (delaiFusion.get(i) > 0 || delaiFusion.get(j) > 0) continue;

        Particule pi = particules.get(i);
        Particule pj = particules.get(j);
        if (distance(i, j) < pi.rayon + pj.rayon + 3) {
          fusionner(idMorceau.get(i), idMorceau.get(j));
          return;        // une fusion par frame suffit, les morceaux sont recalculés
        }
      }
    }
  }

  void fusionner(int morceauA, int morceauB) {
    for (int i = 0; i < particules.size(); i++) {
      if (idMorceau.get(i) != morceauA) continue;
      for (int j = 0; j < particules.size(); j++) {
        if (idMorceau.get(j) != morceauB) continue;
        float d = distance(i, j);
        if (d < distanceLien) {
          // Longueur au repos = distance actuelle (au minimum le contact des deux cercles)
          relier(i, j, max(d, particules.get(i).rayon + particules.get(j).rayon + 2));
        }
      }
    }
    calculerMorceaux();
  }

  // ---------------------------------------------------------------------------
  void dessiner(int indexControle) {
    for (Lien l : liens) {
      l.dessiner();
    }

    int morceauControle = idMorceau.get(indexControle);
    for (int i = 0; i < particules.size(); i++) {
      Particule p = particules.get(i);

      // Particule à récupérer : halo qui pulse pour attirer l'oeil
      if (!auJoueur.get(i)) {
        float pulsation = 6 + 4 * sin(millis() / 200.0f);
        noFill();
        stroke(255, 140, 0, 160);
        strokeWeight(2);
        ellipse(p.pos.x, p.pos.y, 2 * p.rayon + pulsation * 2, 2 * p.rayon + pulsation * 2);
        strokeWeight(3);
        stroke(230, 110, 0);
        fill(255, 180, 60);
        ellipse(p.pos.x, p.pos.y, 2 * p.rayon, 2 * p.rayon);
        continue;
      }

      strokeWeight(3);
      stroke(200, 150, 0);
      if (idMorceau.get(i) == morceauControle) {
        fill(255, 205, 0);            // morceau contrôlé : jaune vif
      } else {
        fill(255, 240, 160);          // autres morceaux : jaune pâle
      }
      if (delaiFusion.get(i) > 0) {
        stroke(230, 120, 0, 120);     // fraîchement coupée : ne peut pas encore fusionner
      }
      ellipse(p.pos.x, p.pos.y, 2 * p.rayon, 2 * p.rayon);
    }
  }
}
