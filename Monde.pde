
// Le "game world" : il contient toutes les particules actives et enchaîne,
// à chaque pas de temps, les 4 étapes du moteur :
//   1. générateurs de forces   2. intégration   3. détection des contacts   4. résolution
class Monde {
  ArrayList<Particule> particules = new ArrayList<Particule>();
  ArrayList<DetecteurContact> detecteurs = new ArrayList<DetecteurContact>();
  RegistreForces registre = new RegistreForces();
  ResolveurCollisions resolveur = new ResolveurCollisions();

  // Nombre de contacts traités au dernier pas (affiché dans le HUD)
  int nbContacts = 0;

  void ajouterParticule(Particule p) {
    particules.add(p);
  }

  void ajouterDetecteur(DetecteurContact d) {
    detecteurs.add(d);
  }

  void etape(float dt) {
    // 1. Chaque générateur ajoute sa force dans l'accumulateur de sa particule
    registre.mettreAJourForces(dt);

    // 2. Intégration d'Euler : a = F/m, puis v et x (l'accumulateur est vidé ensuite)
    for (Particule p : particules) {
      p.integrer(dt);
    }

    // 3. Chaque détecteur (collisions, câbles, décor...) ajoute ses contacts dans la liste
    ArrayList<Contact> contacts = new ArrayList<Contact>();
    for (DetecteurContact d : detecteurs) {
      d.ajouterContacts(contacts, dt);
    }
    nbContacts = contacts.size();

    // 4. Résolution par impulsions + correction de l'interpénétration
    resolveur.resoudreCollisions(contacts, particules.size());
  }
}
