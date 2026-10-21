class Particule{
  Vecteur3D acceleration;
  Vecteur3D velocite;
  Vecteur3D pos;
  float frottements;
  float masse;
  float rayon;
  Vecteur3D forceAccumulee;
  
  Particule(Vecteur3D acceleration, Vecteur3D velocite, Vecteur3D pos, float frottements, float masse, float rayon){
    this.acceleration = acceleration;
    this.velocite = velocite;
    this.pos = pos;
    this.forceAccumulee = new Vecteur3D(0, 0, 0);
    this.frottements = frottements;
    this.masse = masse;
    this.rayon = rayon;
  }
  
  // FONCTIONS
  float getInverseMasse() {
    return (masse <= 0) ? 0.0f : 1/masse;
  }
  
  void ajouterForce(Vecteur3D force) {
    forceAccumulee = forceAccumulee.ajouter(force);
  }

  // Integrateur pour calculer la nouvelle position et la nouvelle vitesse de la particule
  void integrer(float temps){          
    if (this.getInverseMasse() <= 0.0f) {
      return;
    }
    
    Vecteur3D nouvelleVelocity;
    Vecteur3D nouvellePosition;
    
    Vecteur3D nacc = acceleration.ajouter(forceAccumulee.multiplier(getInverseMasse()));
    
    float amortissement = pow(frottements, temps);
    nouvelleVelocity = (velocite.multiplier(amortissement)).ajouter(nacc.multiplier(temps));
    nouvellePosition = pos.ajouter(nouvelleVelocity.multiplier(temps));
    
    // On remplace la vitesse et la position de la particule par nos calculs
    this.velocite = nouvelleVelocity; 
    this.pos = nouvellePosition;
  }
}
