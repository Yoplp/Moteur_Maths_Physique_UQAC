class DetectionTige implements DetecteurContact {
  Particule p1;
  Particule p2;
  float longueur;

  DetectionTige(Particule p1, Particule p2, float longueur) {
    this.p1 = p1;
    this.p2 = p2;
    this.longueur = longueur;
  }


  @Override
    void ajouterContacts(ArrayList<Contact> contacts, float temps) {
    // Distance entre p et p2
    Vecteur3D vecteurMilieu = p2.pos.soustraire(p1.pos);
    float distance = vecteurMilieu.normeEuclidienne();

    if (distance == longueur) {
      return;
    }

    Vecteur3D normale;
    float penetration;

    if (distance > longueur) {
      // Rapprocher
      normale = p1.pos.soustraire(p2.pos).normaliser();
      penetration = distance - longueur;
    } else {
      // Repousser
      normale = vecteurMilieu.normaliser();
      penetration = longueur - distance;
    }

    contacts.add(new Contact(p1, p2, 0.0f, normale, penetration));
  }
}
