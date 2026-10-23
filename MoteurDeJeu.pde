
// --- Paramètres physiques (unités : pixels, secondes, masse = 1 par particule) ---
final float GRAVITE = 700;              // px/s²
final float FROTTEMENTS = 0.6;          // damping de l'intégrateur : v *= 0.6^dt
final float FRICTION_K1 = 0.3;          // traînée linéaire
final float FRICTION_K2 = 0.0005;       // traînée quadratique
final float RESTITUTION_PARTICULES = 0.1;
final float RESTITUTION_DECOR = 0.25;

// --- Paramètres du blob ---
final float RAYON = 10;
final float ESPACEMENT = 22;            // distance entre deux particules voisines au départ
final float DISTANCE_LIEN = 46;         // on relie les particules plus proches que ça
final float K_RESSORT = 400;            // raideur des ressorts (loi de Hooke)
final float LIMITE_ELASTICITE = 1.5;    // au-delà de 150 % de la longueur au repos : câble

// --- Paramètres de contrôle ---
final float IMPULSION_LANCER = 6000;    // impulsion totale J maximale donnée au morceau
final float DISTANCE_PLEINE = 200;      // longueur du trait (px) pour la pleine puissance
final float VITESSE_LANCER_MAX = 1200;  // plafond de delta_v = J / masse

// --- Pas de temps ---
final float DT_MAX = 1.0 / 30.0;        // si une frame est trop longue, on la limite
final float TEMPS_PARTIE = 180;         // secondes

Monde monde;
Blob blob;
DetectionDecor decor;
ArrayList<Plateforme> plateformes;
CompteurRebond compteur = new CompteurRebond();

int indexControle;                      // une particule du morceau contrôlé par le joueur
int nbADepart;                          // particules du blob au début de la partie
float tempsRestant;
boolean enVisee;                       
boolean victoire;
boolean defaite;

// Traînée de la lame (clic droit), pour l'effet visuel
ArrayList<Vecteur3D> traceLame = new ArrayList<Vecteur3D>();

// Chronométrage des frames (comme en phase 1)
int dernierTemps;
float deltaTime;


void setup() {
  size(1280, 640);

  TestVecteur3D tests = new TestVecteur3D();
  boolean reussiteTests = true;
  reussiteTests = !(reussiteTests && !tests.runTests());

  if (!reussiteTests) {
    println("ERREUR : Un ou plusieurs tests ont échoué. Arrêt du moteur.");
    exit();
    return;
  }

  initialiserPartie();
  dernierTemps = millis();
}


void initialiserPartie() {
  monde = new Monde();
  blob = new Blob(monde.registre, K_RESSORT, LIMITE_ELASTICITE, DISTANCE_LIEN);

  //  Décor 
  plateformes = new ArrayList<Plateforme>();
  plateformes.add(new Plateforme(-100, 610, 1480, 130));     // sol
  plateformes.add(new Plateforme(-100, -100, 1480, 100));    // plafond (hors écran)
  plateformes.add(new Plateforme(-100, -100, 100, 840));     // mur gauche
  plateformes.add(new Plateforme(1280, -100, 100, 840));     // mur droit

  plateformes.add(new Plateforme(520, 540, 160, 22));        // basse      (70 px)  : blob entier
  plateformes.add(new Plateforme(880, 470, 120, 22));        // moyenne    (140 px) : <= 10 particules
  plateformes.add(new Plateforme(260, 420, 180, 22));        // haute      (190 px) : <= 8
  plateformes.add(new Plateforme(520, 300, 160, 22));        // très haute (310 px) : <= 6, ou depuis la haute
  plateformes.add(new Plateforme(760, 200, 120, 22));        // sommet     (410 px) : <= 5, ou depuis la très haute

  
  plateformes.add(new Plateforme(1060, 410, 25, 200));       // mur du couloir
  plateformes.add(new Plateforme(1085, 410, 140, 24));       // toit du couloir

  // Blob de départ 
  int[] rangees = {3, 4, 3};
  float hauteurRangee = ESPACEMENT * sqrt(3) / 2;
  for (int r = 0; r < rangees.length; r++) {
    for (int k = 0; k < rangees[r]; k++) {
      float x = 120 + (k - (rangees[r] - 1) / 2.0) * ESPACEMENT;
      float y = 590 - r * hauteurRangee;
      creerParticule(x, y, true);
    }
  }
  blob.relierVoisins();
  nbADepart = blob.particules.size();

  // Particules à récupérer
  creerParticule(380, 595, false);      // au sol
  creerParticule(600, 525, false);      // plateforme basse
  creerParticule(940, 455, false);      // plateforme moyenne
  creerParticule(350, 405, false);      // plateforme haute
  creerParticule(600, 285, false);      // plateforme très haute
  creerParticule(820, 185, false);      // sommet
  creerParticule(1150, 395, false);     // sur le toit du couloir
  creerParticule(1150, 595, false);     // au fond du couloir
  blob.calculerMorceaux();

  // Détecteurs de contacts
  decor = new DetectionDecor(monde.particules, plateformes, RESTITUTION_DECOR, GRAVITE);
  monde.ajouterDetecteur(new DetectionCollisions(monde.particules, RESTITUTION_PARTICULES));
  monde.ajouterDetecteur(blob);   // câbles des liens trop étirés
  monde.ajouterDetecteur(decor);

  indexControle = 0;
  tempsRestant = TEMPS_PARTIE;
  enVisee = false;
  victoire = false;
  defaite = false;
  traceLame.clear();
}

// Crée une particule soumise à la gravité et à la friction, et l'ajoute au monde et au blob
void creerParticule(float x, float y, boolean duJoueur) {
  Particule p = new Particule(
    new Vecteur3D(0, 0, 0),         // accélération constante 
    new Vecteur3D(0, 0, 0),         // vitesse
    new Vecteur3D(x, y, 0),         // position
    FROTTEMENTS, 1.0, RAYON);

  monde.ajouterParticule(p);
  monde.registre.ajouter(p, new ForceGravite(new Vecteur3D(0, GRAVITE, 0)));
  monde.registre.ajouter(p, new ForceFriction(FRICTION_K1, FRICTION_K2));
  blob.ajouterParticule(p, duJoueur);
}


void draw() {
  // Durée de la frame précédente, appliquée à la frame courante
  int tempsActuel = millis();
  deltaTime = (tempsActuel - dernierTemps) / 1000.0; // en secondes
  dernierTemps = tempsActuel;
  float dt = min(deltaTime, DT_MAX);

  if (!victoire && !defaite) {
    mettreAJourJeu(dt);
  }

  //  Affichage
  background(245);
  for (Plateforme pl : plateformes) {
    pl.dessiner();
  }
  blob.dessiner(indexControle);
  dessinerVisee();
  dessinerLame();
  dessinerHUD();
}


void mettreAJourJeu(float dt) {
  tempsRestant -= dt;

  Vecteur3D souris = new Vecteur3D(mouseX, mouseY, 0);

  // Clic droit : coupe le long du trajet de la souris pendant cette frame
  if (mousePressed && mouseButton == RIGHT) {
    blob.couper(new Vecteur3D(pmouseX, pmouseY, 0), souris);
    traceLame.add(souris);
  }
  if (traceLame.size() > 12 || (!(mousePressed && mouseButton == RIGHT) && traceLame.size() > 0)) {
    traceLame.remove(0);     // la traînée s'efface progressivement
  }

  // Physique : un pas de temps de la durée de la frame
  monde.etape(dt);

  // Fusion des morceaux qui se touchent (et donc récupération des particules)
  blob.mettreAJour(dt);

  // Conditions de fin de partie : victoire quand toutes les particules forment un seul morceau
  if (blob.nbMorceaux == 1) {
    victoire = true;
  } else if (tempsRestant <= 0) {
    tempsRestant = 0;
    defaite = true;
  }
}


// trait pendant la visée 
void dessinerVisee() {
  if (!enVisee || victoire || defaite) {
    return;
  }
  Vecteur3D centre = blob.centreDeMasse(blob.morceauDe(indexControle));

  if (blob.peutSeLancer(indexControle, decor.particulesAuSol)) {
    stroke(60, 120, 220);
  } else {
    stroke(160);
  }
  strokeWeight(2);
  line(centre.x, centre.y, mouseX, mouseY);
}


void dessinerLame() {
  noFill();
  for (int i = 1; i < traceLame.size(); i++) {
    Vecteur3D a = traceLame.get(i - 1);
    Vecteur3D b = traceLame.get(i);
    stroke(120, 120, 140, 255.0 * i / traceLame.size());
    strokeWeight(1 + 4.0 * i / traceLame.size());
    line(a.x, a.y, b.x, b.y);
  }
}


void dessinerHUD() {
  int taille = blob.morceauDe(indexControle).size();
  int aRecuperer = blob.particules.size() - nbADepart;
  int recuperees = blob.nbParticulesAuJoueur() - nbADepart;

  // Compteur de particules attachées au blob contrôlé (avec rebond amorti)
  compteur.mettreAJour(taille);
  fill(40);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Particules attachées au blob", 20, 15);
  compteur.dessiner(70, 65);

  textAlign(LEFT, TOP);
  textSize(14);
  fill(40);
  text("Récupérées : " + recuperees + " / " + aRecuperer, 20, 100);
  text("Morceaux du blob : " + (blob.nbMorceaux - (aRecuperer - recuperees)), 20, 120);
  // Vitesse de lancer à pleine puissance pour le morceau sélectionné (vers le haut)
  Vecteur3D centre = blob.centreDeMasse(blob.morceauDe(indexControle));
  Vecteur3D cibleMax = centre.ajouter(new Vecteur3D(0, -DISTANCE_PLEINE, 0));
  float vMax = blob.vitesseDeLancer(indexControle, cibleMax, IMPULSION_LANCER, DISTANCE_PLEINE, VITESSE_LANCER_MAX).normeEuclidienne();
  text("Lancer max : Δv = J / m = " + int(vMax) + " px/s", 20, 140);
  text("Temps restant : " + nf(tempsRestant, 0, 1) + " s", 20, 160);

  // Durée de frame en temps réel
  textAlign(RIGHT, TOP);
  text("Durée de frame : " + nf(deltaTime * 1000, 0, 1) + " ms (" + int(frameRate) + " FPS)", width - 20, 15);
  text("Contacts : " + monde.nbContacts + "   Liens : " + blob.liens.size(), width - 20, 35);

  textAlign(CENTER, BOTTOM);
  fill(200);                        // texte clair : il est dessiné sur le sol noir
  text("Clic gauche glissé puis relâché : lancer   |   Clic droit glissé : couper   |   R : recommencer", width / 2, height - 8);

  // Écran de fin
  if (victoire || defaite) {
    fill(0, 0, 0, 150);
    noStroke();
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(48);
    text(victoire ? "Victoire !" : "Temps écoulé !", width / 2, height / 2 - 30);
    textSize(20);
    String detail = victoire
      ? "Blob complet (" + blob.particules.size() + " particules) en " + nf(TEMPS_PARTIE - tempsRestant, 0, 1) + " s"
      : "Particules récupérées : " + recuperees + " / " + aRecuperer + ", morceaux restants : " + blob.nbMorceaux;
    text(detail + "   -   R pour recommencer", width / 2, height / 2 + 25);
  }
}


void keyPressed() {
  if (key == 'r' || key == 'R') {
    initialiserPartie();
  }
}

void mousePressed() {
  // Clic gauche près d'un morceau du joueur : il devient le morceau contrôlé
  if (mouseButton == LEFT) {
    Vecteur3D souris = new Vecteur3D(mouseX, mouseY, 0);
    int proche = blob.particuleJoueurPlusProche(souris);
    if (blob.particules.get(proche).pos.soustraire(souris).normeEuclidienne() < 60) {
      indexControle = proche;
    }
    enVisee = true;
  }
}

void mouseReleased() {
  // Relâchement du clic gauche : le morceau est lancé vers la souris (s'il touche le sol)
  if (mouseButton == LEFT && enVisee) {
    enVisee = false;
    if (victoire || defaite || !blob.peutSeLancer(indexControle, decor.particulesAuSol)) {
      return;
    }
    Vecteur3D deltaV = blob.vitesseDeLancer(indexControle, new Vecteur3D(mouseX, mouseY, 0),
                                            IMPULSION_LANCER, DISTANCE_PLEINE, VITESSE_LANCER_MAX);
    blob.lancer(indexControle, deltaV);
  }
}
