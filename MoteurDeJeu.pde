ArrayList<Particule> particules = new ArrayList<Particule>();

int projectileSelectionne = 0; 
String[] nomsProjectiles = {"Balle", "Boulet", "Laser", "Boule de feu"};

// Chronométrage des frames
int dernierTemps;
float deltaTime;

void setup() {
  size(1280, 640);

  
  Vecteur3D a = new Vecteur3D(1, 2, 3);
  Vecteur3D b = new Vecteur3D(4, 5, 6);

  println("Norme de a : " + a.normeEuclidienne());
  println("Norme carrée de a : " + a.normeCarre());
  println("Normalisation : " + a.normaliser());
  println("Multiplication : " + a.multiplier(2));
  println("Addition : " + a.ajouter(b));
  println("Soustraction : " + a.soustraire(b));
  println("Produit par composantes : " + a.produitParComposante(b));
  println("Produit scalaire : " + a.scalaire(b));
  println("Produit vectoriel : " + a.produitVectoriel(b));
  
  
  TestVecteur3D tests = new TestVecteur3D();
  boolean reussite = tests.runTests(); 
  
  if (!reussite) {
    println("ERREUR : Un ou plusieurs tests ont échoué. Arrêt du moteur.");
    exit(); 
    return;   
  }
  
  dernierTemps = millis();
  
  
}

void draw() {
    background(0);
    dessinerScene();
    
    int tempsActuel = millis();
    deltaTime = (tempsActuel - dernierTemps) / 1000.0; // en secondes
    dernierTemps = tempsActuel;
    
    
    // Update de la Physique
    for (Particule p : particules) {
      p.integrer(deltaTime);
      Vecteur3D pos = p.get_pos();
      fill(p.couleur);
      noStroke();
      ellipse(pos.x, pos.y, p.rayon * 2, p.rayon * 2);
    }

    // Interface texte
    fill(255);
    textSize(14);
    text("Projectile sélectionné : " + nomsProjectiles[projectileSelectionne], 10, 20);
    text("Touches 1-4 pour changer, clic pour tirer", 10, 40);
    text("Frame time : " + nf(deltaTime * 1000, 0, 2) + " ms", 10, 60);
    
    
    
}

Particule creerProjectile(int type, Vecteur3D positionDepart, Vecteur3D direction) {
  float vitesseInitiale;
  float masse;
  float damping = 0.999; // frottement négligeable
  color couleur;
  float rayon;

  if (type == 0) { // Balle
    vitesseInitiale = 400;
    masse = 0.1;
    couleur = color(255, 255, 0);
    rayon = 6;
  } else if (type == 1) { // Boulet
    vitesseInitiale = 250;
    masse = 5.0;
    couleur = color(150, 150, 150);
    rayon = 16;
  } else if (type == 2) { // Laser
    vitesseInitiale = 800;
    masse = 0.01;
    damping = 1.0; 
    couleur = color(255, 0, 0);
    rayon = 4;
  } else { // Boule de feu
    vitesseInitiale = 150;
    masse = 2.0;
    couleur = color(255, 100, 0);
    rayon = 12;
  }

  Vecteur3D velocite = direction.normaliser().multiplier(vitesseInitiale);
  Vecteur3D acceleration = new Vecteur3D(0, 200, 0);
  
  return new Particule(acceleration, velocite, positionDepart, damping, masse, couleur, rayon);
}


void keyPressed() {
  if (key == '1') projectileSelectionne = 0;
  else if (key == '2') projectileSelectionne = 1;
  else if (key == '3') projectileSelectionne = 2;
  else if (key == '4') projectileSelectionne = 3;
}



void mousePressed() {
  Vecteur3D depart = new Vecteur3D(50, height - 50, 0);
  Vecteur3D cible = new Vecteur3D(mouseX, mouseY, 0);
  Vecteur3D direction = cible.soustraire(depart);
  particules.add(creerProjectile(projectileSelectionne, depart, direction));
  
}


void dessinerScene() {
  // Sol
  stroke(100);
  strokeWeight(4);
  line(0, height - 30, width, height - 30);
}
