
//cours 5 page 6 pour les types de ressorts

class RessortParticules implements GenerateurForce {        //premier type de ressort : particule - particule
  Particule autre;
  float k;
  float longueurRepos;

  RessortParticules(Particule autre, float k, float longueurRepos) {          //chaque type de ressort comprend un constructeur et une fonction mettre à jour qui appelle forceRessort
    this.autre = autre;
    this.k = k;
    this.longueurRepos = longueurRepos;
  }

  void mettreAJourForce(Particule p, float duree) {
    p.ajouterForce(forceRessort(p.pos, autre.pos, k, longueurRepos, false));
  }
}

class RessortAncre implements GenerateurForce {        //deuxième type de ressort : particule - point
  Vecteur3D ancre;
  float k;
  float longueurRepos;

  RessortAncre(Vecteur3D ancre, float k, float longueurRepos) {
    this.ancre = ancre;
    this.k = k;
    this.longueurRepos = longueurRepos;
  }

  void mettreAJourForce(Particule p, float duree) {
    p.ajouterForce(forceRessort(p.pos, ancre, k, longueurRepos, false));
  }
}

class Bungee implements GenerateurForce {         //troisème type de ressort : bungee - à étirer pour qu'il tire
  Particule autre;
  float k;
  float longueurRepos;

  Bungee(Particule autre, float k, float longueurRepos) {
    this.autre = autre;
    this.k = k;
    this.longueurRepos = longueurRepos;
  }

  void mettreAJourForce(Particule p, float duree) {
    p.ajouterForce(forceRessort(p.pos, autre.pos, k, longueurRepos, true));
  }
}

class BungeeAncre implements GenerateurForce {       //quatrième type de ressort : bungee - point fixe
  Vecteur3D ancre;
  float k;
  float longueurRepos;

  BungeeAncre(Vecteur3D ancre, float k, float longueurRepos) {
    this.ancre = ancre;
    this.k = k;
    this.longueurRepos = longueurRepos;
  }

  void mettreAJourForce(Particule p, float duree) {
    p.ajouterForce(forceRessort(p.pos, ancre, k, longueurRepos, true));
  }
}


Vecteur3D forceRessort(Vecteur3D posP, Vecteur3D extremite, float k, float longueurRepos, boolean tireSeulement) {    //fonction qui retourne les forces qui s'ajoute à notre ressort en fonction du temps
  Vecteur3D d = posP.soustraire(extremite);
  float longueur = d.normeEuclidienne();

  if (longueur == 0.0f){                                  //cas spécifiques
    return new Vecteur3D(0, 0, 0);
  }
  if (tireSeulement && longueur <= longueurRepos){
    return new Vecteur3D(0, 0, 0);
  }

  float amplitude = k * (longueurRepos - longueur);       //  application de la loi de Hooke : F = k (l0 - l) - page 6 cours Dynamique Linéaire
  return d.normaliser().multiplier(amplitude);
}
