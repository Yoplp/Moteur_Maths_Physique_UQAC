
// Générateurs de forces de base (cours 5 - Dynamique linéaire) : gravité et friction.

class ForceGravite implements GenerateurForce {      // F = m * g
  Vecteur3D gravite;

  ForceGravite(Vecteur3D gravite) {
    this.gravite = gravite;
  }

  void mettreAJourForce(Particule p, float duree) {
    if (p.getInverseMasse() <= 0.0f) {       // masse infinie
      return;
    }
    p.ajouterForce(gravite.multiplier(p.masse));
  }
}

// Friction cinétique (partie B "Forces de friction") : F = -v̂ * (k1 * |v| + k2 * |v|²)
// Elle s'oppose à la vélocité et devient importante quand l'objet va vite (terme en |v|²).
class ForceFriction implements GenerateurForce {
  float k1;   // coefficient linéaire 
  float k2;   // coefficient quadratique 

  ForceFriction(float k1, float k2) {
    this.k1 = k1;
    this.k2 = k2;
  }

  void mettreAJourForce(Particule p, float duree) {
    float vitesse = p.velocite.normeEuclidienne();
    if (vitesse == 0.0f) {                   // particule immobile : pas de friction
      return;
    }

    float amplitude = k1 * vitesse + k2 * vitesse * vitesse;
    // La force est opposée à la vitesse
    p.ajouterForce(p.velocite.normaliser().multiplier(-amplitude));
  }
}
