class Particule{
  Vecteur3D acceleration;
  Vecteur3D velocite;
  Vecteur3D pos;
  float frottements;
  float masse;
  
  Particule(Vecteur3D acceleration, Vecteur3D velocite, Vecteur3D pos, float frottements, float masse){
    this.acceleration = acceleration;
    this.velocite = velocite;
    this.pos = pos;
    this.frottements = frottements;
    this.masse = masse;
  }
  
  // FONCTIONS
  float getInverseMasse() {
    return (masse <= 0) ? 0.0f : 1/masse;
  }

  // Integrateur pour calculer la nouvelle position et la nouvelle vitesse de la particule
  void integrer(float temps){          
    if (this.getInverseMasse() <= 0.0f) {
      return;
    }
    
    Vecteur3D nouvelleVelocity;
    Vecteur3D nouvellePosition;
    
    float amortissement = pow(frottements, temps);
    nouvelleVelocity = (velocite.multiplier(amortissement)).ajouter(acceleration.multiplier(temps));
    nouvellePosition = pos.ajouter(nouvelleVelocity.multiplier(temps));
    
    // On remplace la vitesse et la position de la particule par nos calculs
    this.velocite = nouvelleVelocity; 
    this.pos = nouvellePosition;
  }
}
