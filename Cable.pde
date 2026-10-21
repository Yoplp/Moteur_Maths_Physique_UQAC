class DetectionCable implements DetecteurContact {
  Particule p1;
  Particule p2;
  float longueurMax;
  float restitution;

  DetectionCable(Particule p1, Particule p2, float longueurMax, float restitution) {
    this.p1 = p1;
    this.p2 = p2;
    this.longueurMax = longueurMax;
    this.restitution = restitution;
  }

  @Override
    void ajouterContacts(ArrayList<Contact> contacts, float temps) {
    Vecteur3D vecteur = p2.pos.soustraire(p1.pos);
    float longueurActuelle = vecteur.normeEuclidienne();

    if (longueurActuelle <= longueurMax || longueurActuelle == 0.0f) {
      return;
    }

    Vecteur3D normale = p1.pos.soustraire(p2.pos).normaliser();
    float penetration = longueurActuelle - longueurMax;

    contacts.add(new Contact(p1, p2, restitution, normale, penetration));
  }
}
