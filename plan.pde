/*
 Copyright © 2017 Emmanuel Dupré la Tour, Lucas Lesourd, Brice Chkir
 
 This file is part of Projet Chaos.
 
 Projet Chaos is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Projet Chaos is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Projet Chaos.  If not, see <http://www.gnu.org/licenses/>.
 */

String coordsEleveChoisi;                    // Coordonées sous forme "x y" de l'élève séléctionné lorsque le plan de classe est affiché
int indexEleveChoisi;                        // Index de l'élève qui est séléctionné dans la liste "eleves"
HashMap<String, String> elevesEtCoordonnees; // HashMap (association de deux objets) associant les coordonnées d'un élève dans le plan de classe sous forme "x y" au nom de cet élève
ArrayList<String> placesDesactivees;
HashMap<String, PImage> photos;

// Passer à l'affichage du plan de classe
void plan() {
  surface.setSize(1200, 800); // Changement de la taille de la fenêtre
  statut = "plan_attente";    // Changement du statut pour éxécuter setupPlan() au prochain tour de la boucle draw()
}

void setupPlan() {
  centrerFenetre();
  statut = "plan_pret"; // On change immédiatement le statut, au prochain tour de la boucle draw() ce sera drawPlan() qui sera éxécuté en boucle

  photos = new HashMap();                                                                      // Création de l'HashMap contenant le nom de l'élève avec sa photo
  File[] fichiersPhotos = dossierPhotos().listFiles();                                         // Liste des fichiers du dossier photos

  // Chargement des élèves, comme pour la salle et la classe
  File classe = new File(dossierEleves(), classes.get(classeActuelle) + ".txt");               // Fichier de la classe
  String[] lignesClasse = loadStrings(classe);                                                 // Liste des lignes de ce fichier
  eleves = new ArrayList();                                                                    // Initialisation de la liste des élèves
  for (String ligne : lignesClasse) {                                                          // Pour chaque ligne (élève) ...
    if (!ligne.startsWith("//")) { // On exclue les commentaires de le fichier de classe       // On vérifie que ce ne soit pas un commentaire
      eleves.add(ligne);                                                                       // On ajoute l'élève à la liste
      for (File file : fichiersPhotos) {                                                       // Pour chaque fichier photo, on vérifie que le nom du fichier contienne le nom de l'élève (tout mis en minuscules pour ne pas prendre en compte la casse)
        if (file.isFile() && file.getName().toLowerCase().contains(ligne.toLowerCase())) {
          PImage image = loadImage(file.getAbsolutePath());                                    // On charge l'image à partir de ce fichier
          if (image != null) {                                                                 // Si l'image n'est pas nulle (le fichier est d'un type supporté par Processing), on l'ajoute à la liste
            photos.put(ligne, image);
          }
        }
      }
    }
  }

  // On charge le fichier de la salle que l'on va lire ligne par ligne (stockées dans une liste de String)
  File salle = new File(dossierSalles(), salles.get(salleActuelle) + ".txt");
  lignes = loadStrings(salle);

  // Affichage du rectangle du professeur, de la classe et de la salle choisies
  fill(255);
  rect(450, 20, 300, 80);
  fill(0);
  text(classes.get(classeActuelle) + " - " + salles.get(salleActuelle), 450, 70, 300, 20); // On récupère les noms de classe et de la salle dans les listes avec l'index actuel
  textSize(30);
  text("Professeur", 450, 20, 300, 60);

  placesDesactivees = new ArrayList(); // Initialisation de la liste de places désactivées
  planAleatoire();                     // Mise du Chaos dans la liste des élèves : ils sont réorganisés aléatoirement
}  

void drawPlan() {
  // Boutons Accueil et Réorganiser :
  textSize(16);
  afficherBouton("Accueil", 20, 20, 200, 80);
  afficherBouton("Réorganiser", 235, 20, 200, 80);
  aidePlan("Il est " + hour() + ":" + minute() + ":" + second() + ", nous sommes le " + day() + "/" + month() + "/" + year() + ".\nClic gauche sur un élève pour débuter un échange de place\nClic droit pour désactiver une place");

  // Si aucune case n'est séléctionnée, on affiche le plan et les croix + photo
  if (coordsEleveChoisi == "") {                                                               // Si aucune case n'est séléctionnée il y a "" dans la variable de ses coordonnées
    afficherPlan();                                                                            // On réaffiche le plan propre

    for (Map.Entry<String, String> entry : elevesEtCoordonnees.entrySet()) {                   // Pour chaque élève affiché et ses coordonnées (chaque entrée de l'HashMap), ...
      String nom = entry.getKey();                                                             // Nom de cet élève récupéré dans l'HashMap (Clé de l'entrée)
      String coords = entry.getValue();                                                        // Coordonnées de cet élève sous forme "x y"
      int x = transformerEnX(coords);                                                          // x récupéré à partir de "coords"
      int y = transformerEnY(coords);                                                          // y pareil
      int largeurTable = transformerEnLargeur(coords);

      if (survole(x, y, largeurTable, 80)) {                                                   // Si la souris survole la table de cet élève, ...
        image(croix, x + 5, y + 5);                                                            // On affiche la croix permettant de le supprimer
        aidePlan("Cliquez sur la croix pour enlever l'élève du plan\n(si il est absent par exemple)");

        // On affiche l'éventuelle photo
        if (photos.containsKey(nom)) {                                                         // Si la photo de cet élève existe
          PImage photo = photos.get(nom);                                                      // On la récupère dans la liste
          photo.resize(0, 128);                                                                // On redimensionne la photo (x = 0 permet de garder les proportions tout en définissant la hauteur)
          image(photo, 50, 650);                                                               // On l'affiche
        }
      }
    }
  } else {
    // Si une case est séléctionnée, on affiche le message d'aide correspondant
    aidePlan("Cliquez sur l'élève avec qui " + eleves.get(indexEleveChoisi) + " doit échanger sa place, ou cliquez à nouveau sur la place pour annuler.");
  }
}

// Cette fonction permet d'afficher le cadre d'aide en haut à droite
void aidePlan(String texte) {
  fill(79, 84, 86);
  rect(765, 20, 410, 80);
  textSize(14);
  fill(255);
  text(texte, 767, 20, 408, 80);
}

void mouseClickedPlan() {
  // Ce code s'éxecute lorsque le plan de classe est affiché et qu'on clique sur la souris
  if (mouseButton == LEFT) { // Clic gauche

    // Bouton Accueil
    if (survole(20, 20, 200, 80)) {
      ecranAccueil(); // On retourne sur l'écran d'accueil
    }

    // Bouton réorganiser
    if (survole(235, 20, 200, 80)) {
      planAleatoire(); // On refait un plan aléatoire
    }

    // On vérifie si on a cliqué sur un élève : pour chaque élève, ...
    for (Map.Entry<String, String> entry : elevesEtCoordonnees.entrySet()) {
      String nom = entry.getKey();
      String coords = entry.getValue();
      int x = transformerEnX(coords);
      int y = transformerEnY(coords);
      int largeurTable = transformerEnLargeur(coords);

      if (survole(x + 5, y + 5, 25, 20)) {               // Si on a cliqué sur la croix d'un élève ...
        eleves.remove(nom);                              // on l'enlève de la liste
      } else if (survole(x, y, largeurTable, 80)) {      // Sinon, si a cliqué sur la table quand même ..
        if (coordsEleveChoisi == "") {                   // Si aucun élève n'était séléctionné auparavant, on le séléctionne
          coordsEleveChoisi = coords;                    // On stocke ses coordonnées
          indexEleveChoisi = eleves.indexOf(nom);        // Et sa position dans la liste eleves

          // On affiche le rectangle en marron
          fill(86, 65, 65);
          rect(x, y, largeurTable, 80);

          // Le nom de l'élève en blanc
          fill(255);
          textSize(16);
          textLeading(15); // Diminuer l'écart entre les lignes pour faire passer les noms longs dans la case
          text(nom, x + 5, y, largeurTable - 10, 80);
        } else {
          if (coords == coordsEleveChoisi) {                                 // Si on a re-cliqué sur l'élève déjà séléctionné, on le déséléctionne
            coordsEleveChoisi = "";
          } else {                                                           // Sinon on a cliqué sur un autre élève
            Collections.swap(eleves, indexEleveChoisi, eleves.indexOf(nom)); // On les inverse dans la liste des élèves
            coordsEleveChoisi = "";                                          // On enlève les coordonnées de l'élève choisi (on peut laisser indexEleveChoisi
          }                                                                  // tel quel, on ne l'utilise jamais pour faire des vérifications)
        }
      }
    }
  } else if (coordsEleveChoisi == "") { // Clic droit : désactiver / activer place. On ne désactive / active pas de place lorsque on déplace un élève car le plan ne s'actualise pas pendant ce temps là
    boolean desactive = false;   // Permet de savoir si on vient de désactiver une place, pour ne pas la réactiver instantanément

    // Désactivation de l'éventuelle place cliquée (Pour chaque place, on vérifie si on a cliqué dessus. Si c'est le cas, on ajoute ses coordonnées à la liste des tables désactivées)
    for (Map.Entry<String, String> entry : elevesEtCoordonnees.entrySet()) {
      String coords = entry.getValue();
      int x = transformerEnX(coords);
      int y = transformerEnY(coords);
      int largeurTable = transformerEnLargeur(coords);
      if (survole(x, y, largeurTable, 80)) {
        placesDesactivees.add(coords);
        desactive = true;
      }
    }

    // Réactivation
    if (!desactive) { // Si on ne vient pas de désactiver une table (sans cette vérification, elle serait immédiatement réactivée)
      // On doit créer une nouvelle liste à partir de placesDesactivees car on ne peut pas modifier une liste lorsque on en
      // fait le tour avec une boucle for.
      for (String coords : new ArrayList<String>(placesDesactivees)) {
        int x = transformerEnX(coords);
        int y = transformerEnY(coords);
        int largeurTable = transformerEnLargeur(coords);
        if (survole(x, y, largeurTable, 80)) {
          placesDesactivees.remove(coords);
        }
      }
    }
  }
}

// Mélanger les élèves dans la liste
void planAleatoire() {
  Collections.shuffle(eleves);
}

// Afficher le plan sans modifier la liste des élèves
void afficherPlan() {
  elevesEtCoordonnees = new HashMap(); // On initialise l'HashMap ou on la vide si un plan a déjà été affiché
  int y = 120;                         // La coordonnée y à partir de laquelle on affiche les places
  textSize(16);                        // Paramètres du texte (taille et interligne)
  textLeading(15);

  fill(60, 63, 65);
  stroke(60, 63, 65);
  rect(0, 110, 1200, 690);
  stroke(95);

  ArrayList<String> copieEleves = new ArrayList(eleves); // On créée une copie de la liste des élèves, que l'on peut modifier sans problèmes par la suite

  // Pour chaque ligne, ...
  for (String ligne : lignes) {
    int places = 0, espaces = 0, largeur = 1160, x = 20;         // On va compter le nombre de tables, d'espaces entre tables. On dispose au départ d'une largeur de 1160 pixels, et on commence à 20px du bord pour afficher les places
    char[] caracteres = ligne.toCharArray();                     // On crée une liste des caractères de la ligne lue
    for (char caractere : caracteres) {                          // Pour chaque caractère, on vérifie si c'est un espace ou un autre caractère et on incrémente la variable qui correspond.
      if (caractere == ' ') {                                    // Un espace correspond à un espace sur le plan, un autre caractère correspond à une table
        espaces++;
      } else {
        places++;
      }
    }

    if (places == 0) {
      // Si il n'y a aucune place de configurée
      y += 100;
      continue;
    }

    largeur -= espaces * 20;                                       // On calcule la place qu'il reste pour les tables, les espaces ayant une largeur fixe.
    int largeurTable = largeur / places;                           // On en déduit la largeur d'une table avec l'espace qu'il reste.

    for (char caractere : caracteres) {                            // On refait le tour des caractères, cette fois pour afficher le rectangle ou compter l'espace
      if (caractere == ' ') {                                      // Si c'est un espace, on incrémente le x de 20 et on passe au caractère suivant
        x += 20;
      } else {                                                     // Si c'est un caractère, ...
        if (caractere == 'i') {                                    // Si c'est une table invisible, on ne cherche pas a afficher de rectangle ni de nom
          x += largeurTable;
          continue;
        }

        String coords = coordonnees(x, y, largeurTable);           // On transforme les coordonnées de la table ou il va être placé en texte pour le stocker dans l'HashMap

        // On affiche la table (grise si désactivée)
        if (placesDesactivees.contains(coords)) {
          fill(220);
        } else {
          fill(255);
        }
        rect(x, y, largeurTable, 80);

        if (!placesDesactivees.contains(coords) && copieEleves.size() != 0) {  // Si il reste des élèves dans la liste des élèves à afficher et que la place n'est pas désactivée, ...
          String nomEleve = copieEleves.get(0);                                // On récupère son nom que l'on met dans le texte à afficher sur la table et on l'enlève de la liste
          copieEleves.remove(0);
          elevesEtCoordonnees.put(nomEleve, coords);
          fill(0);
          text(nomEleve, x + 5, y, largeurTable - 10, 80);       // On affiche le texte avec une petite marge pour pas qu'il soit collé aux bordures de la table
        }

        x += largeurTable;  // On incrémente la coordonnée x d'une largeur de table pour passer au caractère suivant
      }
    }
    // Une fois qu'on a fait le tour des caractères de la ligne, on passe à la ligne suivante en incrémentant la coordonnée y.
    y += 100;
  }

  if (copieEleves.size() != 0) { // Si il y a des élèves non affichés, on l'indique à l'écran
    String texte = "Elèves non affichés : ";
    for (String eleve : copieEleves) {
      texte += eleve + ", ";
    }
    texte = texte.substring(0, texte.length() - 2);

    fill(255);
    textAlign(LEFT, LEFT);
    text(texte, 20, y, 1180, 100);
    textAlign(CENTER, CENTER);
  }
}