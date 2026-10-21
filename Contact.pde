class Contact {
  Particule p1;
  Particule p2;
  float restitution;
  Vecteur3D normale;
  float penetration;

  Contact(Particule p1, Particule p2, float restitution, Vecteur3D normale, float penetration) {
    this.p1 = p1;
    this.p2 = p2;
    this.restitution = restitution;
    this.normale = normale;
    this.penetration = penetration;
  }
  
  void resoudre() {
    resoudreInterpenetration();
    resoudreImpulsion();
  }
  
  
  // Page 6 du cours
  void resoudreInterpenetration() {
    float invMasse1 = p1.getInverseMasse();
    float invMasse2 = p2.getInverseMasse();
    float sommeInvMasses = invMasse1 + invMasse2;
    
    // d*(1/ma + 1/mb)*n
    Vecteur3D deplacementMasseInv = normale.multiplier(penetration / sommeInvMasses);
    
    
    // Calcul Delta_Pb
    if (invMasse1 > 0.0f) {
      Vecteur3D deltaP1 = deplacementMasseInv.multiplier(invMasse1);
      p1.pos = p1.pos.soustraire(deltaP1);
    }
    
    // Calcul Delta_Pa
    if (invMasse2 > 0.0f) {
      Vecteur3D deltaP2 = deplacementMasseInv.multiplier(invMasse2);
      p2.pos = p2.pos.ajouter(deltaP2);
    }
    
  }
  
  // Page 4 du cours
  void resoudreImpulsion() {
    float invMasse1 = p1.getInverseMasse();
    float invMasse2 = p2.getInverseMasse();
    float sommeInvMasses = invMasse1 + invMasse2;
    
    Vecteur3D vRel = p1.velocite.soustraire(p2.velocite);
    float vRelNormale = vRel.scalaire(normale);
    float k = ((restitution + 1.0f) * vRelNormale) / sommeInvMasses;
    Vecteur3D impulsion = normale.multiplier(k);
    
    // v1' = v1 - (k*n)/m1
    p1.velocite = p1.velocite.soustraire(impulsion.multiplier(invMasse1));
    
    // v2 + (k*n)/m2
    p2.velocite = p2.velocite.ajouter(impulsion.multiplier(invMasse2));
 
  }

}
