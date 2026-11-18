
//   Linéaire     : position p, vélocité v,           a     = g + F / m
//   Rotationnel  : orientation q, vélocité angulaire w, alpha = J^-1 * tau
//
// F et tau sont accumulés pendant le pas de temps (principe de d'Alembert : F = somme des Fi,
// tau = somme des tau_i), puis consommés par integrer().
class CorpsRigide {
  // Linéaire 
  float inverseMasse;
  Vecteur3D position;              
  Vecteur3D velocite;
  Vecteur3D acceleration;          
  float amortissementLineaire;     

  // Rotationnel 
  Quaternion orientation;
  Vecteur3D rotation;              // vélocité angulaire w rad/s
  float amortissementAngulaire;    
  Matrix3 tenseurInverseLocal;     // J^-1 dans le repère de l'objet : constant

  // Données dérivées, recalculées après chaque changement d'orientation 
  Matrix4 transformation;          // objet -> monde (rotation R puis translation p)
  Matrix3 tenseurInverseMonde;     // J^-1 monde = R J^-1 R^T

  // Accumulateurs 
  Vecteur3D forceAccumulee;
  Vecteur3D torqueAccumule;

  CorpsRigide(float masse, Matrix3 tenseurInertieLocal, Vecteur3D position) {
    this.inverseMasse = (masse <= 0) ? 0 : 1 / masse;
    this.tenseurInverseLocal = tenseurInertieLocal.inverse();
    this.position = position;
    this.velocite = new Vecteur3D(0, 0, 0);
    this.acceleration = new Vecteur3D(0, 0, 0);
    this.orientation = new Quaternion();
    this.rotation = new Vecteur3D(0, 0, 0);
    this.amortissementLineaire = 1;
    this.amortissementAngulaire = 1;
    viderAccumulateurs();
    calculerDonneesDerivees();
  }

  // appelé dès que la position ou l'orientation change.
  void calculerDonneesDerivees() {
    orientation.normaliser();
    transformation = orientation.toMatrix4(position);
    // Le tenseur est connu dans le repère de l'objet : on le ramène dans le repère monde
    tenseurInverseMonde = tenseurInverseLocal.versRepereMonde(transformation.getMatrix3());
  }


  // appliquée au centre de masse : aucune rotation induite.
  void ajouterForce(Vecteur3D force) {
    forceAccumulee = forceAccumulee.ajouter(force);
  }

  // Force appliquée en un point du monde : elle contribue à F et produit un torque 
  void ajouterForceAuPoint(Vecteur3D force, Vecteur3D pointMonde) {
    Vecteur3D r = pointMonde.soustraire(position);
    forceAccumulee = forceAccumulee.ajouter(force);
    torqueAccumule = torqueAccumule.ajouter(r.produitVectoriel(force));
  }

  // Même chose avec un point exprimé dans le repère de l'objet (ex. un coin de la boîte).
  void ajouterForceAuPointLocal(Vecteur3D force, Vecteur3D pointLocal) {
    ajouterForceAuPoint(force, pointLocalVersMonde(pointLocal));
  }

  void viderAccumulateurs() {
    forceAccumulee = new Vecteur3D(0, 0, 0);
    torqueAccumule = new Vecteur3D(0, 0, 0);
  }

  // Changements de repère
  Vecteur3D pointLocalVersMonde(Vecteur3D pointLocal) {
    return transformation.mult(pointLocal);
  }

  Vecteur3D directionLocaleVersMonde(Vecteur3D directionLocale) {
    return transformation.multDirection(directionLocale);
  }

  // Intégrateur
  void integrer(float dt) {
    if (inverseMasse <= 0) {         // masse infinie : le corps ne bouge pas
      viderAccumulateurs();
      return;
    }

    //  Accélérations linéaire et angulaire
    Vecteur3D a = acceleration.ajouter(forceAccumulee.multiplier(inverseMasse));
    Vecteur3D alpha = tenseurInverseMonde.mult(torqueAccumule);

    //  Vélocités : v = v * amort^dt + a dt   et   w = w * amort^dt + alpha dt
    velocite = velocite.multiplier(pow(amortissementLineaire, dt)).ajouter(a.multiplier(dt));
    rotation = rotation.multiplier(pow(amortissementAngulaire, dt)).ajouter(alpha.multiplier(dt));

    //  Position et orientation : p = p + v dt   et   q = q + 1/2 [0, w] q dt (puis normalisation)
    position = position.ajouter(velocite.multiplier(dt));
    orientation.integrer(rotation, dt);

    //  Matrice de transformation et tenseur d'inertie monde pour le prochain pas
    calculerDonneesDerivees();

    //  Les forces ont été consommées par ce pas de temps
    viderAccumulateurs();
  }
}
