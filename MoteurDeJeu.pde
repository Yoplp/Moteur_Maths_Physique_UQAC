ArrayList<Projectile> projectiles = new ArrayList<Projectile>();

int projectileSelectionne = 0;
String[] nomsProjectiles = {"Balle", "Boulet", "Laser", "Boule de feu"};

Cible cibleActuelle;
int score = 0;
int munitions = 30; 
boolean victoire = false;
boolean defaite = false;

float puissanceTir = 400;

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
  dessinerVecteurVisee();

  int tempsActuel = millis();
  deltaTime = (tempsActuel - dernierTemps) / 1000.0; // en secondes
  dernierTemps = tempsActuel;

  
  // Mise à jour de la Physique
  for (int i = projectiles.size() - 1; i >= 0; i--) {
    Projectile p = projectiles.get(i);
<<<<<<< Updated upstream
    
    if (!victoire && !defaite) { // verifie qu'il n y a ni défaite ni victoire pour simuler la physique
      p.integrer(deltaTime);
      p.enregistrerPosition();
  
      p.dessinerTrajectoire();
      p.dessiner();
  
      if (p.pos.y>=600) {
        p.pos = new Vecteur3D(p.pos.x, 600, p.pos.z);
        p.velocite = new Vecteur3D(p.velocite.x, p.velocite.y * (-0.85), p.velocite.z);
      }
  
      if (p.pos.x<=10) {
        p.velocite = new Vecteur3D(p.velocite.x * (-1), p.velocite.y, p.velocite.z);
      }
=======
    p.integrer(deltaTime);
    p.enregistrerPosition();

    p.dessinerTrajectoire();
    p.dessiner();

    if (p.pos.y + p.rayon >= height - 60) {
      p.pos = new Vecteur3D(p.pos.x, (height - 60) - p.rayon, p.pos.z);
      p.velocite = new Vecteur3D(p.velocite.x, p.velocite.y * (-0.85), p.velocite.z);
>>>>>>> Stashed changes
    }
    //text("Position : "+ int(pos.x)+ "...." + int(pos.y), pos.x, pos.y);       //Affichage position de la balle


    // Gestion de la collision
    if (!victoire && !defaite) {
      if (cibleActuelle.estTouchee(p)) {
        projectiles.remove(i);
        score++;
  
        if (score >= 10) {
          victoire = true;
        } else {
          cibleActuelle = new Cible();
        }
      }
      // Destruction si la balle sort complètement de l'écran
      else if (p.pos.y > height || p.pos.x > width || p.pos.x < 0) {
        projectiles.remove(i);
      }
    }
  }
  
  if (!victoire && munitions <= 0 && projectiles.isEmpty() && score < 10) {
    defaite = true;
  }
  // Affichage de la cible
  if (!victoire && !defaite) {
    cibleActuelle.dessiner();

    // Interface texte
    fill(255);
    textSize(14);
    text("Projectile sélectionné : " + nomsProjectiles[projectileSelectionne], 10, 20);
    text("Touches 1-4 pour changer, clic pour tirer", 10, 40);
    text("Frame time : " + nf(deltaTime * 1000, 0, 2) + " ms", 10, 60);
    text("Puissance du tir (Flèches Haut/Bas pour modifier) : " + int(puissanceTir), 10, 80);
    
    // Dessin de la barre de puissance 
    fill(100); // Fond de la jauge gris
    rect(10, 90, 200, 15);
    fill(255, 200, 0); // Jauge orange/jaune
    float largeurJauge = map(puissanceTir, 50, 600, 0, 200); // map() convertit la puissance (50-600) en pixels (0-200)
    rect(10, 90, largeurJauge, 15);
    
    // Score et munitions
    textSize(20);
    text("Score : " + score + " / 10", width - 150, 30);
    text("Munitions : " + munitions + " / 30", width - 165, 60);
  } else {
    // Écrans de fin Victoire ou Défaite
    textAlign(CENTER);
    if (victoire) {
      fill(0, 255, 0);
      textSize(50);
      text("VICTOIRE !", width / 2, height / 2 - 30);
    } else if (defaite) {
      fill(255, 0, 0);
      textSize(50);
      text("DÉFAITE...", width / 2, height / 2 - 30);
    }
    fill(255);
    textSize(20);
    text("Cliquez n'importe où pour rejouer", width / 2, height / 2 + 20); // Bouton texte pour rejouer
    textAlign(LEFT);
  }
}

Projectile creerProjectile(int type, Vecteur3D positionDepart, Vecteur3D direction, float vitesse) {
  switch(type) {
  case 1: // Boulet
    return new Projectile(TypeProjectile.BOULET, positionDepart, direction, vitesse);
  case 2: // Laser
    return new Projectile(TypeProjectile.LASER, positionDepart, direction, TypeProjectile.LASER.vitesse);
  case 3: // BDF
    return new Projectile(TypeProjectile.BOULE_DE_FEU, positionDepart, direction, vitesse);
  default: // Balle (0) ou inconnu (défaute sur balle)
    return new Projectile(TypeProjectile.BALLE, positionDepart, direction, vitesse);
  }
}

void keyPressed() {
  if (key == '1') projectileSelectionne = 0;
  else if (key == '2') projectileSelectionne = 1;
  else if (key == '3') projectileSelectionne = 2;
  else if (key == '4') projectileSelectionne = 3;
  
  if (keyCode == UP) puissanceTir = min(600, puissanceTir + 50);
  if (keyCode == DOWN) puissanceTir = max(50, puissanceTir - 50);
}

void mousePressed() {
<<<<<<< Updated upstream
  if (victoire || defaite) {
    // le clic réinitialise la partie
    score = 0;
    munitions = 30;
    victoire = false;
    defaite = false;
    projectiles.clear();
    cibleActuelle = new Cible(); 
  } else if (munitions > 0) {
    Vecteur3D depart = new Vecteur3D(50, height - 50, 0);
    Vecteur3D cible = new Vecteur3D(mouseX, mouseY, 0);
    Vecteur3D direction = cible.soustraire(depart);
    projectiles.add(creerProjectile(projectileSelectionne, depart, direction, puissanceTir));
    munitions--;
  }
=======
  Vecteur3D depart = new Vecteur3D(50, height - 60, 0);
  Vecteur3D cible = new Vecteur3D(mouseX, mouseY, 0);
  Vecteur3D direction = cible.soustraire(depart);
  projectiles.add(creerProjectile(projectileSelectionne, depart, direction));
>>>>>>> Stashed changes
}

void dessinerScene() {
  // Sol
  stroke(100);
  fill(255);
  strokeWeight(4);
  line(0, height - 60, width, height - 60);
}

void dessinerVecteurVisee() {
  Vecteur3D depart = new Vecteur3D(50, height - 60, 0);
  Vecteur3D cible = new Vecteur3D(mouseX, mouseY, 0);
  Vecteur3D direction = cible.soustraire(depart).normaliser();
  
  // Viseur
  stroke(28, 114, 212, 220);
  strokeWeight(4);
  float longueurViseur = 90.0f;
  line(depart.x, depart.y, depart.x + direction.x * longueurViseur, depart.y + direction.y * longueurViseur);
  
}
