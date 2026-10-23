
// Compteur du HUD : quand la valeur change, le nombre "rebondit" avec un
// mouvement harmonique simple amorti (cours 5 - Dynamique linéaire) :
//
//   EDO :       x''(t) = -w0² x(t) - 2 zeta w0 x'(t)
//   avec        w0 = racine(k / m)              fréquence angulaire sans damping
//               zeta = c / (2 racine(m k))      ratio de damping (< 1 : le système oscille)
//
//   Solution :  x(t) = (k1 cos(wd t) + k2 sin(wd t)) * e^(-zeta w0 t)
//   avec        wd = w0 racine(1 - zeta²)       fréquence réelle d'oscillation
//               k1 = x(0)    et    k2 = (zeta w0 x(0) + v(0)) / wd
class CompteurRebond {
  int valeur = -1;
  float tempsChangement = -100;    // instant (s) du dernier changement de valeur

  // Ressort virtuel du texte
  float k = 400;                   // constante d'élasticité
  float m = 1;                     // masse
  float c = 8;                     // coefficient de friction (Ff = -c x'(t))
  float x0 = 25;                   // étirement initial (pixels)
  float v0 = 0;                    // vitesse initiale

  void mettreAJour(int nouvelleValeur) {
    if (nouvelleValeur != valeur) {
      valeur = nouvelleValeur;
      tempsChangement = millis() / 1000.0f;   // on relance l'oscillation
    }
  }

  float deplacement() {
    float t = millis() / 1000.0f - tempsChangement;

    float w0 = sqrt(k / m);
    float zeta = c / (2 * sqrt(m * k));        // ici 0.2 : sous-amorti, ça oscille
    float wd = w0 * sqrt(1 - zeta * zeta);
    float k1 = x0;
    float k2 = (zeta * w0 * x0 + v0) / wd;

    return (k1 * cos(wd * t) + k2 * sin(wd * t)) * exp(-zeta * w0 * t);
  }

  void dessiner(float x, float y) {
    float d = deplacement();
    pushMatrix();
    translate(x, y - d);                   // rebond vertical
    scale(1 + d / 60.0f);                  // léger grossissement pendant le rebond
    textAlign(CENTER, CENTER);
    textSize(40);
    fill(200, 150, 0);
    text(valeur, 0, 0);
    popMatrix();
  }
}
