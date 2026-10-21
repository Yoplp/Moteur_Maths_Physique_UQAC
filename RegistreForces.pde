
import java.util.ArrayList;

class RegistreForces {                      // Transcription java page 4 cours Dynamique linéaire
  private class Enregistrement {
    Particule particule;
    GenerateurForce generateur;
    Enregistrement(Particule p, GenerateurForce g) { particule = p; generateur = g; }
  }

  private ArrayList<Enregistrement> registre = new ArrayList<Enregistrement>();

  void ajouter(Particule p, GenerateurForce g) { registre.add(new Enregistrement(p, g)); }

  void retirer(Particule p, GenerateurForce g) {
    registre.removeIf(e -> e.particule == p && e.generateur == g);
  }

  void vider() { registre.clear(); }

  void mettreAJourForces(float duree) {
    for (Enregistrement e : registre)
      e.generateur.mettreAJourForce(e.particule, duree);
  }
}
