

//  Paramètres physiques 
final float GRAVITE = 320;                   // px/s², vers le bas 
final float MASSE = 2;
final float DEMI_COTE = 40;                  // cube de 80 px de côté
final float IMPULSION_LANCER = 800;          // J = F dt : le centre de masse part à J / m = 400 px/s
final float FRACTION_COIN = 0.35;            
final float AMORTISSEMENT_LINEAIRE = 1;      // 1 = aucun : la trajectoire du centre de masse reste une parabole exacte
final float AMORTISSEMENT_ANGULAIRE = 1;

//  Pas de temps 
final float DT_PHYSIQUE = 1.0 / 240.0;       // pas fixe de l'intégrateur (plusieurs pas par frame)
final float DT_MAX = 1.0 / 30.0;             // si une frame est trop longue, on la limite

//  Points d'application, dans le repère local du cube (y vers le bas, z vers la caméra) 
final String[] NOMS_POINTS = { "centre de masse", "coin haut-gauche", "coin haut-droit", "coin bas-gauche", "coin bas-droit" };
Vecteur3D[] pointsLocaux;

//  États du jeu 
final int PREPARATION = 0;
final int VOL = 1;
final int ATTERRI = 2;
int etat;

Boite cube;
Vecteur3D positionDepart;
Vecteur3D directionLancer;                 
int angleDirection = 0;                      
int angleElevation = 60;                     
int pointChoisi = 1;
boolean lancerEnAttente;                     
Vecteur3D impulsionAngulaire;                // r x J au moment du lancer 
float tempsDeVol;

ArrayList<Vecteur3D> traceCentre = new ArrayList<Vecteur3D>();
ArrayList<Vecteur3D> tracePoint = new ArrayList<Vecteur3D>();
float[][] etiquettes = new float[5][2];      // position à l'écran des numéros 0 à 4

//  Caméra 
float cameraLacet = 0.55;
float cameraTangage = 0.55;                  
float cameraDistance = 850;
Vecteur3D cibleCamera = new Vecteur3D(0, -120, 0);

int dernierTemps;
float tempsAccumule;


void setup() {
  size(1280, 720, P3D);

  TestVecteur3D testsVecteur = new TestVecteur3D();
  TestMatrices testsMatrices = new TestMatrices();
  boolean reussiteTests = testsVecteur.runTests();
  reussiteTests = testsMatrices.runTests() && reussiteTests;
  if (!reussiteTests) {
    println("ERREUR : Un ou plusieurs tests ont échoué. Arrêt du moteur.");
    exit();
    return;
  }

  pointsLocaux = new Vecteur3D[] {
    new Vecteur3D(0, 0, 0),
    new Vecteur3D(-DEMI_COTE, -DEMI_COTE, DEMI_COTE),
    new Vecteur3D( DEMI_COTE, -DEMI_COTE, DEMI_COTE),
    new Vecteur3D(-DEMI_COTE,  DEMI_COTE, DEMI_COTE),
    new Vecteur3D( DEMI_COTE,  DEMI_COTE, DEMI_COTE)
  };
  positionDepart = new Vecteur3D(0, -DEMI_COTE, 0);         // cube posé sur le sol (y = 0)

  sphereDetail(12);
  reinitialiser();
  dernierTemps = millis();
}


void reinitialiser() {

  float elevation = radians(angleElevation);
  directionLancer = directionHorizontale().multiplier(cos(elevation)).ajouter(new Vecteur3D(0, -sin(elevation), 0));

  cube = new Boite(MASSE, new Vecteur3D(DEMI_COTE, DEMI_COTE, DEMI_COTE), positionDepart);
  cube.orientation = new Quaternion().setAxeAngle(new Vecteur3D(0, 1, 0), -radians(angleDirection));
  cube.calculerDonneesDerivees();
  cube.acceleration = new Vecteur3D(0, GRAVITE, 0);
  cube.amortissementLineaire = AMORTISSEMENT_LINEAIRE;
  cube.amortissementAngulaire = AMORTISSEMENT_ANGULAIRE;

  traceCentre.clear();
  tracePoint.clear();
  impulsionAngulaire = new Vecteur3D(0, 0, 0);
  lancerEnAttente = false;
  tempsDeVol = 0;
  tempsAccumule = 0;
  etat = PREPARATION;
}


// Cap horizontal du tir : 0° = vers le fond (-z), 90° = vers la droite (+x), 180° = vers la caméra
Vecteur3D directionHorizontale() {
  float cap = radians(angleDirection);
  return new Vecteur3D(sin(cap), 0, -cos(cap));
}


void lancer() {
  traceCentre.add(cube.position);
  tracePoint.add(cube.pointLocalVersMonde(pointsLocaux[pointChoisi]));
  lancerEnAttente = true;
  etat = VOL;
}


// Un pas de l'intégrateur. Pas de collisions dans cette phase : le vol s'arrête quand
// le centre de masse redescend à sa hauteur de départ.
void etapePhysique(float dt) {
  if (lancerEnAttente) {
    // L'impulsion J est donnée en un seul pas (F = J / dt) et répartie en deux forces.
    // Principe de d'Alembert : les forces et les torques s'additionnent.
    //  - (1 - FRACTION_COIN) J au centre de masse : lance le cube sans le faire tourner ;
    //  - FRACTION_COIN J au point choisi : pousse aussi le centre de masse et produit tau = r x F.
    // Le centre de masse reçoit toujours J en entier (même parabole), seule la rotation est plus lente.
    Vecteur3D impulsion = directionLancer.multiplier(IMPULSION_LANCER);
    Vecteur3D impulsionCoin = impulsion.multiplier(FRACTION_COIN);
    Vecteur3D pointMonde = cube.pointLocalVersMonde(pointsLocaux[pointChoisi]);
    impulsionAngulaire = pointMonde.soustraire(cube.position).produitVectoriel(impulsionCoin);
    cube.ajouterForce(impulsion.soustraire(impulsionCoin).multiplier(1 / dt));
    cube.ajouterForceAuPoint(impulsionCoin.multiplier(1 / dt), pointMonde);
    lancerEnAttente = false;
  }

  cube.integrer(dt);
  tempsDeVol += dt;
  traceCentre.add(cube.position);
  tracePoint.add(cube.pointLocalVersMonde(pointsLocaux[pointChoisi]));

  if (cube.velocite.y > 0 && cube.position.y >= positionDepart.y) {
    etat = ATTERRI;
  }
}


void draw() {
  int maintenant = millis();
  float deltaTime = min((maintenant - dernierTemps) / 1000.0, DT_MAX);
  dernierTemps = maintenant;

  if (etat == VOL) {
    tempsAccumule += deltaTime;
    while (tempsAccumule >= DT_PHYSIQUE && etat == VOL) {
      etapePhysique(DT_PHYSIQUE);
      tempsAccumule -= DT_PHYSIQUE;
    }
  }

  background(235, 238, 245);
  placerCamera();
  lights();
  dessinerSol();
  dessinerTraces();
  dessinerCentreDeMasse();
  dessinerPointApplication();
  if (etat == PREPARATION) {
    dessinerFleche();
  }

  // Le cube est semi-transparent : on le dessine en dernier, sans écrire dans le tampon de profondeur,
  // pour que le centre de masse et les axes restent visibles à travers.
  hint(DISABLE_DEPTH_MASK);
  cube.afficher(150);
  hint(ENABLE_DEPTH_MASK);

  calculerEtiquettes();
  dessinerHUD();
}


//  Affichage 3D 
void placerCamera() {
  float x = cibleCamera.x + cameraDistance * cos(cameraTangage) * sin(cameraLacet);
  float y = cibleCamera.y - cameraDistance * sin(cameraTangage);
  float z = cibleCamera.z + cameraDistance * cos(cameraTangage) * cos(cameraLacet);
  camera(x, y, z, cibleCamera.x, cibleCamera.y, cibleCamera.z, 0, 1, 0);
}

void dessinerSol() {
  stroke(195, 200, 215);
  strokeWeight(1);
  for (int x = -650; x <= 650; x += 50) line(x, 0, -650, x, 0, 650);
  for (int z = -650; z <= 650; z += 50) line(-650, 0, z, 650, 0, z);

  // Point de chute théorique du centre de masse (croix rouge au sol)
  Vecteur3D chute = positionDepart.ajouter(directionHorizontale().multiplier(porteeTheorique()));
  if (etat == PREPARATION) {
    stroke(245, 130, 0, 120);                    // cap du tir au sol
    line(positionDepart.x, 0, positionDepart.z, chute.x, 0, chute.z);
  }
  stroke(220, 60, 60);
  strokeWeight(2);
  line(chute.x - 15, 0, chute.z - 15, chute.x + 15, 0, chute.z + 15);
  line(chute.x - 15, 0, chute.z + 15, chute.x + 15, 0, chute.z - 15);
}

void dessinerTraces() {
  noFill();
  strokeWeight(3);
  stroke(20);                     // trajectoire du centre de masse
  dessinerCourbe(traceCentre);
  if (pointChoisi != 0) {
    stroke(245, 130, 0);          // trajectoire du point où la force a été appliquée
    dessinerCourbe(tracePoint);
  }
}

void dessinerCourbe(ArrayList<Vecteur3D> points) {
  beginShape();
  for (Vecteur3D p : points) vertex(p.x, p.y, p.z);
  endShape();
}

void dessinerCentreDeMasse() {
  Vecteur3D c = cube.position;
  // Axes locaux du cube = colonnes de la matrice de rotation R
  float longueur = DEMI_COTE * 1.6;
  strokeWeight(2);
  int[] couleurs = { color(220, 40, 40), color(40, 170, 60), color(40, 80, 220) };
  for (int i = 0; i < 3; i++) {
    Vecteur3D bout = c.ajouter(cube.transformation.getAxe(i).multiplier(longueur));
    stroke(couleurs[i]);
    line(c.x, c.y, c.z, bout.x, bout.y, bout.z);
  }
  noStroke();
  fill(20);
  pushMatrix();
  translate(c.x, c.y, c.z);
  sphere(7);
  popMatrix();
}

void dessinerPointApplication() {
  if (pointChoisi == 0) return;
  Vecteur3D p = cube.pointLocalVersMonde(pointsLocaux[pointChoisi]);
  noStroke();
  fill(245, 130, 0);
  pushMatrix();
  translate(p.x, p.y, p.z);
  sphere(6);
  popMatrix();
}

// Prévisualisation : flèche orange qui pousse sur le point choisi, dans la direction du lancer
void dessinerFleche() {
  Vecteur3D pointe = cube.pointLocalVersMonde(pointsLocaux[pointChoisi]);
  Vecteur3D queue = pointe.soustraire(directionLancer.multiplier(130));
  Vecteur3D base = pointe.soustraire(directionLancer.multiplier(24));
  // Deux vecteurs perpendiculaires à la flèche pour dessiner la pointe, quelle que soit la direction
  Vecteur3D cote1 = directionLancer.produitVectoriel(new Vecteur3D(0, 1, 0));
  if (cote1.normeEuclidienne() < 0.01) cote1 = new Vecteur3D(1, 0, 0);      // tir vertical
  cote1 = cote1.normaliser().multiplier(10);
  Vecteur3D cote2 = directionLancer.produitVectoriel(cote1);
  stroke(245, 130, 0);
  strokeWeight(4);
  ligne(queue, pointe);
  ligne(pointe, base.ajouter(cote1));
  ligne(pointe, base.soustraire(cote1));
  ligne(pointe, base.ajouter(cote2));
  ligne(pointe, base.soustraire(cote2));
}

void ligne(Vecteur3D a, Vecteur3D b) {
  line(a.x, a.y, a.z, b.x, b.y, b.z);
}

// Position à l'écran des numéros des points (à faire pendant que la caméra 3D est active)
void calculerEtiquettes() {
  for (int i = 0; i < pointsLocaux.length; i++) {
    Vecteur3D p = cube.pointLocalVersMonde(pointsLocaux[i].multiplier(1.35));
    etiquettes[i][0] = screenX(p.x, p.y, p.z);
    etiquettes[i][1] = screenY(p.x, p.y, p.z);
  }
}


//  Interface 2D 
void dessinerHUD() {
  hint(DISABLE_DEPTH_TEST);
  noLights();
  camera();                       // retour au repère de l'écran

  if (etat == PREPARATION) {
    textAlign(CENTER, CENTER);
    textSize(20);
    for (int i = 0; i < pointsLocaux.length; i++) {
      fill(i == pointChoisi ? color(245, 130, 0) : color(60));
      float decalage = (i == 0) ? -18 : 0;      // le 0 est au centre : on le décale au-dessus de la sphère
      text(i, etiquettes[i][0], etiquettes[i][1] + decalage);
    }
  }

  noStroke();
  fill(255, 230);
  rect(12, 12, 660, (etat == PREPARATION) ? 96 : 200, 8);
  fill(30);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Lancer d'un cube : corps rigide en rotation", 24, 22);
  textSize(13);
  text("0-4 : point   Q/E : direction   A/D : angle   ESPACE : lancer   R : recommencer   souris : caméra", 24, 46);
  text("Point d'application : " + pointChoisi + " (" + NOMS_POINTS[pointChoisi] + ")"
     + ((pointChoisi != 0) ? ", " + round(FRACTION_COIN * 100) + " % de la force sur ce coin, le reste au centre de masse" : ""), 24, 66);

  if (etat == PREPARATION) {
    text("Choisis un point puis appuie sur ESPACE.", 24, 84);
  } else {
    text("Temps de vol : " + nf(tempsDeVol, 0, 2) + " s", 24, 86);
    text("Centre de masse : " + formater(cube.position) + "    |v| = " + nf(cube.velocite.normeEuclidienne(), 0, 1) + " px/s", 24, 104);
    text("Vélocité angulaire w : " + formater(cube.rotation) + "    |w| = " + nf(cube.rotation.normeEuclidienne(), 0, 2) + " rad/s", 24, 122);
    text("Impulsion angulaire au lancer r x J : " + formater(impulsionAngulaire), 24, 140);
    if (etat == ATTERRI) {
      float dx = cube.position.x - positionDepart.x;
      float dz = cube.position.z - positionDepart.z;
      text("Portée mesurée : " + nf(sqrt(dx * dx + dz * dz), 0, 1) + " px   (théorique v0² sin(2a) / g : "
         + nf(porteeTheorique(), 0, 1) + " px)", 24, 162);
      text("R ou 0-4 pour relancer.", 24, 182);
    }
  }

  // Barres de réglage du tir
  noStroke();
  fill(255, 230);
  rect(12, height - 118, 400, 106, 8);
  dessinerBarre("Direction (Q / E) : " + angleDirection + "°   (0° = fond, 90° = droite)", angleDirection, 0, 360, 28, height - 84);
  dessinerBarre("Angle de la force (A / D) : " + angleElevation + "°", angleElevation, 10, 90, 28, height - 34);
  hint(ENABLE_DEPTH_TEST);
}

// Barre horizontale graduée tous les 10°, remplie jusqu'à la valeur courante
void dessinerBarre(String titre, float valeur, float min, float max, float x, float y) {
  float largeur = 360;
  float t = (valeur - min) / (max - min);
  fill(30);
  textAlign(LEFT, BOTTOM);
  textSize(13);
  text(titre, x, y - 6);
  noStroke();
  fill(215, 219, 230);
  rect(x, y, largeur, 10, 5);
  fill(245, 130, 0);
  rect(x, y, largeur * t, 10, 5);
  stroke(150);
  strokeWeight(1);
  for (float v = min; v <= max + 0.01; v += 10) {
    float gx = x + largeur * (v - min) / (max - min);
    line(gx, y + 13, gx, y + 17);
  }
  noStroke();
  fill(30);
  ellipse(x + largeur * t, y + 5, 14, 14);
}

String formater(Vecteur3D v) {
  return "(" + nf(v.x, 0, 1) + ", " + nf(v.y, 0, 1) + ", " + nf(v.z, 0, 1) + ")";
}

// Portée d'un projectile lancé à v0 = J / m sous l'angle a, sans frottement : v0² sin(2a) / g
float porteeTheorique() {
  float v0 = IMPULSION_LANCER / MASSE;
  return v0 * v0 * sin(2 * radians(angleElevation)) / GRAVITE;
}


//  Contrôles 
void keyPressed() {
  if (key >= '0' && key <= '4') {
    pointChoisi = key - '0';
    if (etat != PREPARATION) reinitialiser();
  } else if (key == ' ' && etat == PREPARATION) {
    lancer();
  } else if (key == 'r' || key == 'R') {
    reinitialiser();
  } else if (key == 'q' || key == 'Q') {        // direction : 10° vers la gauche
    angleDirection = (angleDirection + 350) % 360;
    reinitialiser();
  } else if (key == 'e' || key == 'E') {        // direction : 10° vers la droite
    angleDirection = (angleDirection + 10) % 360;
    reinitialiser();
  } else if (key == 'a' || key == 'A') {        // angle de la force : 10° plus bas
    angleElevation = max(10, angleElevation - 10);
    reinitialiser();
  } else if (key == 'd' || key == 'D') {        // angle de la force : 10° plus haut
    angleElevation = min(90, angleElevation + 10);
    reinitialiser();
  }
}

void mouseDragged() {
  cameraLacet -= (mouseX - pmouseX) * 0.01;
  cameraTangage = constrain(cameraTangage + (mouseY - pmouseY) * 0.01, 0.05, 1.4);
}

void mouseWheel(MouseEvent evenement) {
  cameraDistance = constrain(cameraDistance + evenement.getCount() * 40, 400, 2000);
}
