class Particle{
  
  Vector3D acceleration;     //acceleration, velocité et position de la particule
  Vector3D velocite;
  Vector3D pos;
  float damping;                 //damping pour simuler les frottements
  float inverseMasse;
  
  Particle(Vector3D acceleration, Vector3D velocite, Vector3D pos, float damping, float masse){    //constructeur
    this.acceleration = acceleration;
    this.velocite = velocite;
    this.pos = pos;
    this.damping = damping;
    
    if (masse == 0){                                   //calcul de inversemasse en fonction de la masse 
      inverseMasse = Float.POSITIVE_INFINITY;
    }
    else{
      inverseMasse = 1/masse;
    }
      
  }
  
  void set_acceleration(Vector3D new_acceleration){  //setters 
    acceleration = new_acceleration;
  }
  
  void set_pos(Vector3D new_pos){
    pos = new_pos;
  }
  
  void set_velocite(Vector3D new_velocite){
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
  
  Vector3D get_acceleration(){        //getters 
    return acceleration;
  }
  
  Vector3D get_pos(){
    return pos;
  }
  
  Vector3D get_velocite(){
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
    
    
    Vector3D new_velocity;
    Vector3D new_position;
    
    new_velocity = (get_velocite().multiply(get_damping())).add(get_acceleration().multiply(temps));
    new_position = get_pos().add(new_velocity.multiply(temps));
    
    set_velocite(new_velocity);                          //on remplace la vitesse et la position de la particule par nos calculs 
    set_pos(new_position);
  }
}
