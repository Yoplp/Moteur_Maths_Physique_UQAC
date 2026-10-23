// Contact entre deux particules p1 et p2.
// p2 peut valoir null : c'est alors un contact avec le décor (masse infinie, vitesse nulle).
// La normale est orientée de p1 vers p2 (ou de p1 vers le décor).
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

  // Inverse de la masse de p2 (0 pour le décor = masse infinie)
  float inverseMasse2() {
    return (p2 == null) ? 0.0f : p2.getInverseMasse();
  }

  // Vitesse de p2 (nulle pour le décor)
  Vecteur3D velocite2() {
    return (p2 == null) ? new Vecteur3D(0, 0, 0) : p2.velocite;
  }


  // Page 6 du cours
  void resoudreInterpenetration() {
    float invMasse1 = p1.getInverseMasse();
    float invMasse2 = inverseMasse2();
    float sommeInvMasses = invMasse1 + invMasse2;

    // Deux objets immobiles : rien à déplacer
    if (sommeInvMasses <= 0.0f) {
      return;
    }

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
    float invMasse2 = inverseMasse2();
    float sommeInvMasses = invMasse1 + invMasse2;

    if (sommeInvMasses <= 0.0f) {
      return;
    }

    Vecteur3D vRel = p1.velocite.soustraire(velocite2());
    float vRelNormale = vRel.scalaire(normale);

    // Si les particules s'éloignent déjà l'une de l'autre, il n'y a pas d'impulsion à appliquer
    // (sinon l'impulsion les rapprocherait).
    if (vRelNormale <= 0.0f) {
      return;
    }

    float k = ((restitution + 1.0f) * vRelNormale) / sommeInvMasses;
    Vecteur3D impulsion = normale.multiplier(k);

    // v1' = v1 - (k*n)/m1
    p1.velocite = p1.velocite.soustraire(impulsion.multiplier(invMasse1));

    // v2 + (k*n)/m2
    if (p2 != null) {
      p2.velocite = p2.velocite.ajouter(impulsion.multiplier(invMasse2));
    }
  }
}
