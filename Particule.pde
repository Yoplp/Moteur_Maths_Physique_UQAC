class Particule{
  
  Vecteur3D acceleration;     //acceleration, velocité et position de la particule
  Vecteur3D velocite;
  Vecteur3D pos;
  float damping;                 //damping pour simuler les frottements
  float inverseMasse;
  color couleur;
  float rayon;
  
  Particule(Vecteur3D acceleration, Vecteur3D velocite, Vecteur3D pos, float damping, float masse, color couleur, float rayon){    //constructeur
    this.acceleration = acceleration;
    this.velocite = velocite;
    this.pos = pos;
    this.damping = damping;
    this.couleur = couleur;
    this.rayon = rayon;
    
    if (masse <= 0){                                   //calcul de inversemasse en fonction de la masse 
      inverseMasse = 0.0f;
    }
    else{
      inverseMasse = 1/masse;
    }
      
  }
  
  void set_acceleration(Vecteur3D new_acceleration){  //setters 
    acceleration = new_acceleration;
  }
  
  void set_pos(Vecteur3D new_pos){
    pos = new_pos;
  }
  
  void set_velocite(Vecteur3D new_velocite){
    velocite = new_velocite;
  }
  
  void set_damping(float new_damping){
    damping = new_damping;
  }
  
  void set_mass(float new_masse){
    if (new_masse == 0){
      inverseMasse = Float.POSITIVE_INFINITY;
    }
    else{
      inverseMasse = 1/new_masse;
    }
  }
  
  void set_inversemasse(float new_inverseMasse) {
      inverseMasse = new_inverseMasse;
  }
  
  Vecteur3D get_acceleration(){        //getters 
    return acceleration;
  }
  
  Vecteur3D get_pos(){
    return pos;
  }
  
  Vecteur3D get_velocite(){
    return velocite;
  }
  
  float get_damping(){
    return damping;
  }
  
  float get_inversemasse() {
    return inverseMasse;
  }
  
  void integrer(float temps){          //integrateur pour calculer la nouvelle position et la nouvelle vitesse de la particule
    if (inverseMasse <= 0.0f) {
      return;
    }
    
    
    Vecteur3D new_velocity;
    Vecteur3D new_position;
    
    new_velocity = (get_velocite().multiplier(get_damping())).ajouter(get_acceleration().multiplier(temps));
    new_position = get_pos().ajouter(new_velocity.multiplier(temps));
    
    set_velocite(new_velocity);                          //on remplace la vitesse et la position de la particule par nos calculs 
    set_pos(new_position);
  }
}
