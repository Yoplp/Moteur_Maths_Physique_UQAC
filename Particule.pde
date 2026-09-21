class Particule{
  Vecteur3D acceleration;
  Vecteur3D velocite;
  Vecteur3D pos;
  float frottements;
  float inverseMasse;
  float rayon;
  color couleur;
  
  Particule(Vecteur3D acceleration, Vecteur3D velocite, Vecteur3D pos, float frottements, float masse, float rayon, color couleur){
    this.acceleration = acceleration;
    this.velocite = velocite;
    this.pos = pos;
    this.frottements = frottements;
    this.inverseMasse = (masse <= 0) ? 0.0f : 1/masse;
    this.rayon = rayon;
    this.couleur = couleur;
  }
  
  // SETTERS
  void setAcceleration(Vecteur3D nouvelleAcceleration){ 
    this.acceleration = nouvelleAcceleration;
  }
  
  void setPos(Vecteur3D nouvellePosition){
    this.pos = nouvellePosition;
  }
  
  void setVelocite(Vecteur3D nouvelleVelocite){
    this.velocite = nouvelleVelocite;
  }
  
  void setFrottements(float nouveauxFrottements){
    this.frottements = nouveauxFrottements;
  }
  
  void setMasse(float nouvelleMasse){
    this.inverseMasse = (nouvelleMasse == 0) ? Float.POSITIVE_INFINITY : 1/nouvelleMasse; 
  }
  
  void setInverseMasse(float nouvelleInverseMasse) {
    this.inverseMasse = nouvelleInverseMasse;
  }

  void setRayon(float nouveauRayon) {
    this.rayon = nouveauRayon;
  }

  void setCouleur(color nouvelleCouleur) {
    this.couleur = nouvelleCouleur;
  }  
  
  // GETTERS
  Vecteur3D getAcceleration() { 
    return this.acceleration;
  }
  
  Vecteur3D getPos(){
    return this.pos;
  }
  
  Vecteur3D getVelocite(){
    return this.velocite;
  }
  
  float getFrottements(){
    return this.frottements;
  }

  float getMasse(){
    return (this.inverseMasse == 0) ? Float.POSITIVE_INFINITY : 1/this.inverseMasse;
  }
  
  float getInverseMasse() {
    return this.inverseMasse;
  }

  float getRayon() {
    return this.rayon;
  }

  color getCouleur() {
    return this.couleur;
  }

  // FONCTIONS
  // Integrateur pour calculer la nouvelle position et la nouvelle vitesse de la particule
  void integrer(float temps){          
    if (this.inverseMasse <= 0.0f) {
      return;
    }
    
    Vecteur3D nouvelleVelocity;
    Vecteur3D nouvellePosition;
    
    nouvelleVelocity = (this.velocite.multiplier(this.frottements)).ajouter(this.acceleration.multiplier(temps));
    nouvellePosition = this.pos.ajouter(nouvelleVelocity.multiplier(temps));
    
    // On remplace la vitesse et la position de la particule par nos calculs
    setVelocite(nouvelleVelocity); 
    setPos(nouvellePosition);
  }
}
