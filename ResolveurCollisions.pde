class ResolveurCollisions {
  
  void resoudreCollisions(ArrayList<Contact> contacts, int nbParticules) {
    int limiteMax = 2 * nbParticules;
    int nbCollisionsResous = 0;
    
    for (int i = 0; i < contacts.size(); i++) {
      if (nbCollisionsResous >= limiteMax) {
        break;
      }
      
      Contact c = contacts.get(i);
      c.resoudre();
      nbCollisionsResous++;
      
    }
  }
}
