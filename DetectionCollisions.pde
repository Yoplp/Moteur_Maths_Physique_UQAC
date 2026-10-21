class DetectionCollisions implements DetecteurContact {

  ArrayList<Particule> particules;
  float restitutionDefaut;

  DetectionCollisions(ArrayList<Particule> particules, float restitutionDefaut) {
    this.particules = particules;
    this.restitutionDefaut = restitutionDefaut; // Coefficient de restitution (e)
  }

  @Override
    void ajouterContacts(ArrayList<Contact> contacts, float temps) {
    int n = particules.size();

    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        Particule p1 = particules.get(i);
        Particule p2 = particules.get(j);

        Vecteur3D vecteurMilieu = p2.pos.soustraire(p1.pos);
        float distance = vecteurMilieu.normeEuclidienne();
        float sommeRayons = p1.rayon + p2.rayon;

        // dist((x, y, z) ,(a, b, c)) < a + b
        if (distance < sommeRayons) {
          Vecteur3D normale = vecteurMilieu.normaliser();
          float penetration = sommeRayons - distance;
          float restitution = restitutionDefaut;


          // Contact au Repos
          Vecteur3D vRel = p1.velocite.soustraire(p2.velocite);
          float vRelNormale = vRel.scalaire(normale);

          Vecteur3D accRel = p1.acceleration.soustraire(p2.acceleration);
          float vAccNormale = accRel.multiplier(temps).scalaire(normale);

          // g * dt >= v
          if (vAccNormale >= vRelNormale) {
            restitution = 0.0f;
          }

          contacts.add(new Contact(p1, p2, restitution, normale, penetration));
        }
      }
    }
  }
}
