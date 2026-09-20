ArrayList<Particle> particules = new ArrayList<Particle>();

int projectileSelectionne = 0; 
String[] nomsProjectiles = {"Balle", "Boulet", "Laser", "Boule de feu"};

// Chronométrage des frames
int dernierTemps;
float deltaTime;

void setup() {
  size(640, 640);

  
  Vector3D a = new Vector3D(1, 2, 3);
  Vector3D b = new Vector3D(4, 5, 6);

  println("Norme de a : " + a.magnitude());
  println("Norme carrée de a : " + a.magnitudeSquared());
  println("Normalisation : " + a.normalized());
  println("Multiplication : " + a.multiply(2));
  println("Addition : " + a.add(b));
  println("Soustraction : " + a.subtract(b));
  println("Produit par composantes : " + a.componentMultiply(b));
  println("Produit scalaire : " + a.dot(b));
  println("Produit vectoriel : " + a.cross(b));
  
  
  TestVector3D tests = new TestVector3D();
  tests.runTests();
  
  dernierTemps = millis();
  
  
}

void draw() {
    background(0);
    
    int tempsActuel = millis();
    deltaTime = (tempsActuel - dernierTemps) / 1000.0; // en secondes
    dernierTemps = tempsActuel;
    
    
    // Update de la Physique
    for (Particle p : particules) {
      p.integrer(deltaTime);
      Vector3D pos = p.get_pos();
      fill(255);
      noStroke();
      ellipse(pos.x, pos.y, 10, 10);
    }

    // Interface texte
    fill(255);
    textSize(14);
    text("Projectile sélectionné : " + nomsProjectiles[projectileSelectionne], 10, 20);
    text("Touches 1-4 pour changer, clic pour tirer", 10, 40);
    text("Frame time : " + nf(deltaTime * 1000, 0, 2) + " ms", 10, 60);
    
    
    
}

Particle creerProjectile(int type, Vector3D positionDepart, Vector3D direction) {
  float vitesseInitiale;
  float masse;
  float damping = 0.999; // frottement négligeable

  if (type == 0) { // Balle
    vitesseInitiale = 400;
    masse = 0.1;
  } else if (type == 1) { // Boulet
    vitesseInitiale = 250;
    masse = 5.0;
  } else if (type == 2) { // Laser
    vitesseInitiale = 800;
    masse = 0.01;
    damping = 1.0; 
  } else { // Boule de feu
    vitesseInitiale = 150;
    masse = 2.0;
  }

  Vector3D velocite = direction.normalized().multiply(vitesseInitiale);
  Vector3D acceleration = new Vector3D(0, 200, 0);
  
  return new Particle(acceleration, velocite, positionDepart, damping, masse);
}


void keyPressed() {
  if (key == '1') projectileSelectionne = 0;
  else if (key == '2') projectileSelectionne = 1;
  else if (key == '3') projectileSelectionne = 2;
  else if (key == '4') projectileSelectionne = 3;
}



void mousePressed() {
  Vector3D depart = new Vector3D(50, height - 50, 0);
  Vector3D cible = new Vector3D(mouseX, mouseY, 0);
  Vector3D direction = cible.subtract(depart);
  particules.add(creerProjectile(projectileSelectionne, depart, direction));
  
}
