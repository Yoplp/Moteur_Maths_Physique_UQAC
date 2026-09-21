ArrayList<Projectile> projectiles = new ArrayList<Projectile>();

int projectileSelectionne = 0;
String[] nomsProjectiles = {"Balle", "Boulet", "Laser", "Boule de feu"};

Cible cibleActuelle;
int score = 0;
boolean jeuTermine = false;

// Chronométrage des frames
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

  cibleActuelle = new Cible();
  dernierTemps = millis();
}

void draw() {
  background(0);
  dessinerScene();

  int tempsActuel = millis();
  deltaTime = (tempsActuel - dernierTemps) / 1000.0; // en secondes
  dernierTemps = tempsActuel;


  // Mise à jour de la Physique
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
    p.integrer(deltaTime);

    Vecteur3D pos = p.pos;
    fill(p.couleur);
    noStroke();
    ellipse(pos.x, pos.y, p.rayon * 2, p.rayon * 2);

    if (p.pos.y>=600) {
      p.pos = new Vecteur3D(p.pos.x, 600, p.pos.z);
      p.velocite = new Vecteur3D(p.velocite.x, p.velocite.y * (-0.85), p.velocite.z);
    }

    if (p.pos.x<=10) {
      p.velocite = new Vecteur3D(p.velocite.x * (-1), p.velocite.y, p.velocite.z);
    }

    //text("Position : "+ int(pos.x)+ "...." + int(pos.y), pos.x, pos.y);       //Affichage position de la balle


    // Gestion de la collision
    if (!jeuTermine && cibleActuelle.estTouchee(p)) {
      projectiles.remove(i);
      score++;

      if (score >= 10) {
        jeuTermine = true;
      } else {
        cibleActuelle = new Cible();
      }
    }
    // Destruction si la balle sort complètement de l'écran
    else if (pos.y > height || pos.x > width || pos.x < 0) {
      projectiles.remove(i);
    }
  }

  // Affichage de la cible
  if (!jeuTermine) {
    cibleActuelle.dessiner();

    // Interface texte
    fill(255);
    textSize(14);
    text("Projectile sélectionné : " + nomsProjectiles[projectileSelectionne], 10, 20);
    text("Touches 1-4 pour changer, clic pour tirer", 10, 40);
    text("Frame time : " + nf(deltaTime * 1000, 0, 2) + " ms", 10, 60);

    // Score
    textSize(20);
    text("Score : " + score + " / 10", width - 150, 30);
  } else {
    fill(0, 255, 0);
    textSize(50);
    textAlign(CENTER);
    text("VICTOIRE !", width / 2, height / 2);
    textAlign(LEFT);
  }
}

Projectile creerProjectile(int type, Vecteur3D positionDepart, Vecteur3D direction) {
  switch(type) {
  case 1: // Boulet
    return new Projectile(TypeProjectile.BOULET, positionDepart, direction);
  case 2: // Laser
    return new Projectile(TypeProjectile.LASER, positionDepart, direction);
  case 3: // BDF
    return new Projectile(TypeProjectile.BOULE_DE_FEU, positionDepart, direction);
  default: // Balle (0) ou inconnu (défaute sur balle)
    return new Projectile(TypeProjectile.BALLE, positionDepart, direction);
  }
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
  projectiles.add(creerProjectile(projectileSelectionne, depart, direction));
}

void dessinerScene() {
  // Sol
  stroke(100);
  strokeWeight(4);
  line(0, height - 30, width, height - 30);
}
