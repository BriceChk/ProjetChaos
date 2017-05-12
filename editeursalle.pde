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

String[] lignes;                              // Liste des lignes du fichier de salle à modifier
HashMap<String, String> tablesEtCoordonnees;  // Liste associant les coordonnées d'une table dans la liste
// des lignes aux coordonnées sur l'écran : "xFichier yFichier 0" => "x y largeurTable"
HashMap<String, String> espacesEtCoordonnees; // Pareil mais pour les espaces
ArrayList<String> tablesInvisibles;           // Liste des coordonnées des tables invisibles "xFichier yFichier 0"
int xCurseur, yCurseur;                       // Coordonnées du curseur dans la liste des lignes

void editeurSalle() {
  surface.setSize(1200, 800);
  statut = "editeurSalle_attente";
}

void setupSalle() {
  centrerFenetre();
  statut = "editeurSalle_pret";

  // Chargement du fichier de la salle
  eleves = new ArrayList();
  File salle = new File(sketchPath("salles/" + salles.get(salleActuelle) + ".txt"));
  lignes = loadStrings(salle);

  // Affichage du rectangle du professeur, de la classe et de la salle choisies.
  background(60, 63, 65);
  fill(255);
  rect(450, 20, 300, 80);
  fill(0);
  text(salles.get(salleActuelle), 450, 70, 300, 20); // On récupère le nom de la salle dans la liste avec l'index actuel
  textSize(30);
  text("Professeur", 450, 20, 300, 60);

  // Initialisation du curseur à 0
  yCurseur = xCurseur = 0; 

  // Affichage du plan de classe
  afficherEditeurSalle();
}

void drawSalle() {
  // Bouton accueil
  textSize(16);
  afficherBouton("Accueil", 20, 20, 100, 80);

  // Boutons d'ajout
  textSize(12);
  afficherBouton("Ajouter espace", 130, 20, 97, 35);
  afficherBouton("Ajouter table", 237, 20, 97, 35);
  afficherBouton("Ajouter table invisible", 344, 20, 97, 35);
  // Boutons d'ajout avec ligne
  afficherBouton("Ajouter ligne + espace", 130, 65, 97, 35);
  afficherBouton("Ajouter ligne + table", 237, 65, 97, 35);
  afficherBouton("Ajouter ligne + table invisible", 344, 65, 97, 35);

  // On réaffiche l'éditeur entier
  afficherEditeurSalle();

  // On affiche les croix sur les tables :
  // Pour chaque entrée de la liste de tables, on récupère la valeur de l'entrée qui est les coordonnées de la table sur l'écran.
  // On récupère le x, le y, la largeur de table à partir de cette valeur ("x y largeurTable"), et si la souris est sur la table
  // on affiche la croix.
  for (Map.Entry<String, String> entry : tablesEtCoordonnees.entrySet()) {
    String coords = entry.getValue();
    int x = transformerEnX(coords);
    int y = transformerEnY(coords);
    int largeurTable = transformerEnLargeur(coords);
    if (survole(x, y, largeurTable, 80)) {
      image(croix, x + 5, y + 5);
    }
  }

  // On affiche les croix sur les espaces (pareil que pour les tables)
  for (Map.Entry<String, String> entry : espacesEtCoordonnees.entrySet()) {
    String coords = entry.getValue();
    int x = transformerEnX(coords);
    int y = transformerEnY(coords);
    if (survole(x, y, 20, 80)) {
      image(croix, x + 2, y + 5);
    }
  }

  // Affichage du curseur :
  // On regroupe tables & espaces dans la même liste, afin de trouver les coordonnées du curseur
  // (qui correspondent à celle d'une table ou d'un espace dans le fichier)
  HashMap<String, String> tablesEtEspaces = new HashMap();
  tablesEtEspaces.putAll(espacesEtCoordonnees);
  tablesEtEspaces.putAll(tablesEtCoordonnees);

  // Style du curseur (épaisseur et couleur)
  strokeWeight(4);
  stroke(255, 0, 0);
  // On récupère les coordonnées du curseur sur l'écran à partir de la liste créée juste avant
  String coordsCurseur = tablesEtEspaces.get(coordonnees(xCurseur, yCurseur, 0));

  // Si il y a des tables dans la liste + éventuelle prise en compte d'erreur,
  // on récupère x et y et on affiche le curseur (ligne rouge)
  if (tablesEtEspaces.size() != 0 && coordsCurseur != null) {
    int x = transformerEnX(coordsCurseur);
    int y = transformerEnY(coordsCurseur);
    line(x, y, x, y + 80);
  } else {
    // Sinon, on affiche le curseur au début de l'éditeur vide.
    line(20, 120, 20, 200);
  }

  // Epaisseur et couleur de bordure de base
  strokeWeight(1);
  stroke(95);
}

void keyPressed() {
  if (keyCode == UP) {    // Flèche haut
    yCurseur--;           // On diminue le y curseur, c'est à dire l'index de la ligne sur laquelle il est
    verifierCurseur();
  }
  if (keyCode == DOWN) {  // Flèche bas
    yCurseur++;
    verifierCurseur();
  }
  if (keyCode == LEFT) {  // Flèche gauche
    xCurseur--;           // On diminue le x curseur, c'est à dire sa position sur la ligne sur laquelle il est
    verifierCurseur();
  }
  if (keyCode == RIGHT) { // Flèche droite
    xCurseur++;
    verifierCurseur();
  }
}

void mouseClickedSalle() {
  // Ce code s'éxecute lorsque le plan de classe est affiché

  // Bouton Nouveau plan
  if (survole(20, 20, 100, 80)) {
    ecranAccueil();
  }

  // Bouton ajout d'espace                     
  if (survole(130, 20, 97, 35)) {
    ajouterCaractere(' ');
  }

  // Bouton ajout ligne + espace
  if (survole(130, 65, 97, 35)) {
    ajouterLigneEtCaractere(' ');
  }

  // Bouton ajout table
  if (survole(237, 20, 97, 35)) {
    ajouterCaractere('c');
  }

  // Bouton ajout table + espace
  if (survole(237, 65, 97, 35)) {
    ajouterLigneEtCaractere('c');
  }

  // Bouton ajout table invisible
  if (survole(344, 20, 97, 35)) {
    ajouterCaractere('i');
  }

  // Bouton ajout table invisible + espace
  if (survole(344, 65, 97, 35)) {
    ajouterLigneEtCaractere('i');
  }

  // Croix sur les tables
  for (Map.Entry<String, String> entry : tablesEtCoordonnees.entrySet()) {
    String coordsFichier = entry.getKey();
    String coords = entry.getValue();
    int x = transformerEnX(coords);
    int y = transformerEnY(coords);

    if (survole(x + 5, y + 5, 20, 20)) { // Si la souris est sur la croix, on supprime le caractère aux coordonnées dans le fichier (ligne et position dans la ligne) 
      supprimerCaractere(coordsFichier);
    }
  }

  // Croix sur les espaces
  for (Map.Entry<String, String> entry : espacesEtCoordonnees.entrySet()) {
    String coordsFichier = entry.getKey();
    String coords = entry.getValue();
    int x = transformerEnX(coords);
    int y = transformerEnY(coords);

    if (survole(x + 5, y + 5, 20, 20)) {
      supprimerCaractere(coordsFichier);
    }
  }
}

void supprimerCaractere(String coordsFichier) {
  int x = transformerEnX(coordsFichier);
  int y = transformerEnY(coordsFichier);

  // Suppression du caractère
  String ligne = lignes[y];                      // On récupère la ligne qui correspond au y du caractère à supprimer dans la liste des lignes du fichier
  StringBuilder sb = new StringBuilder(ligne);   // On initialise un StringBuilder, qui permet de faire quelques opérations plus avancées sur des chaines de caractères
  sb.deleteCharAt(x);                            // On supprime le caractère à la position x dans la ligne à l'aide du StringBuilder
  if (sb.length() == 0) {                        // Si il n'y a plus rien dans cette ligne ...
    ArrayList<String> array = new ArrayList();   // On crée une ArrayList intermédiaire qui va nous servir qu'à enlever la ligne vide 
    for (String s : lignes) {                    // On ajoute toutes les lignes du fichier dans l'ArrayList (dans la liste "lignes", la ligne modifiée n'est pas encore remplacée)
      array.add(s);
    }
    array.remove(y);                             // On supprime la ligne qui doit être vide
    lignes = new String[array.size()];           // On ré-initialise la variable "lignes" par un array String[] basique, avec en paramètre le nombre d'éléments de l'ArrayList (nécéssaire pour pouvoir transformer l'ArrayList en String[])
    lignes = array.toArray(lignes);              // On transforme l'ArrayList en String[] en la stockant dans "lignes"
  } else {
    lignes[y] = sb.toString();                   // Sinon on remplace directement la ligne modifée dans la liste "lignes"
  }
  enregistrerFichier();                          // On enregistre le fichier et on vérifie si le curseur a des coordonnées existantes
  verifierCurseur();
}

void ajouterCaractere(char c) {
  if (lignes.length == 0) {          // Si le plan est vide (à la création par exemple) on doit également ajouter une ligne
    ajouterLigneEtCaractere(c);
    return;
  }
  String ligne = lignes[yCurseur];   // On récupère la ligne à modifier
  ligne = ligne.substring(0, xCurseur) + c + ligne.substring(xCurseur, ligne.length()); // On sépare la partie de la ligne avant et après la position du curseur, et on intercale le caractère (char) à ajouter entre les deux
  lignes[yCurseur] = ligne;          // On remplace la ligne modifée dans la liste "lignes"
  enregistrerFichier();              // Enregistrement et vérification du curseur
  verifierCurseur();
}

void ajouterLigneEtCaractere(char c) {
  ArrayList<String> array = new ArrayList();             // On crée une ArrayList intermédiaire dans laquelle on ajoute les lignes de la liste "lignes" jusqu'à celle du curseur
  if (lignes.length != 0) {
    for (int y = 0; y <= yCurseur; y++) {
      array.add(lignes[y]);
    }
  }
  array.add(c + "");                                     // On ajoute une ligne avec le caractère
  for (int y = yCurseur + 1; y < lignes.length; y++) {   // On ajoute toutes les autres lignes après le curseur
    array.add(lignes[y]);
  }
  lignes = new String[array.size()];                     // On remplace la liste "lignes" et on enregistre
  lignes = array.toArray(lignes);
  enregistrerFichier();
  verifierCurseur();
}

void verifierCurseur() {
  if (yCurseur == -1) {                           // Si l'index y ou x du curseur est négatif, on le remet à 0
    yCurseur = 0;
  }
  if (xCurseur == -1) {
    xCurseur = 0;
  }
  if (yCurseur >= lignes.length) {                // Pour vérifier la position du curseur, on vérifie qu'il ne soit pas sur une ligne qui n'existe pas (y trop grand)
    yCurseur = lignes.length - 1;
  }
  if (lignes.length != 0) {                       // Et si il y a des lignes, qu'il ne soit pas plus loin (x) que la longueur de la ligne sur laquelle il est
    if (xCurseur >= lignes[yCurseur].length()) {
      xCurseur = lignes[yCurseur].length() - 1;
    }
  } else {                                        // Si il n'y a pas de ligne il est au début du plan
    yCurseur = 0;
    xCurseur = 0;
  }
}

void enregistrerFichier() {  // On utilise une structure try/catch car on doit toucher à des fichiers, ce qui peut génerer une erreur
  try {
    // On initialise un PrintWriter qui permet d'écrire dans un fichier. On lui donne en paramètre le chemin du fichier de la salle
    // actuelle à partir du dossier du projet avec sketchPath()
    PrintWriter out = new PrintWriter(sketchPath("salles/" + salles.get(salleActuelle) + ".txt"));
    // On écrit chaque ligne de la liste "lignes" dans le fichier
    for (String s : lignes) {
      out.println(s);
    }
    // On ferme l'écriture
    out.close();
  }
  catch(IOException e) { // En cas d'erreur
    println("Erreur lors de l'écriture du fichier salle");
  }
}

void afficherEditeurSalle() {
  tablesEtCoordonnees = new HashMap();  // On initialse les HashMap qui nous servent à stocker les coordonnées des tables et espaces sur l'écran en fonction de leurs coordonnées dans le fichier de la salle (liste "lignes")
  espacesEtCoordonnees = new HashMap(); 
  tablesInvisibles = new ArrayList();   // De même pour la liste des tables invisibles, qui contient leurs coordonnées sur l'écran uniquement

  // On affiche un grand rectangle pour effacer le précédent plan afficher
  fill(60, 63, 65);
  stroke(60, 63, 65);
  rect(0, 110, 1200, 690);
  stroke(95); // On garde une bordure pour les tables ET espaces / tables invisibles pour les repérer

  // On initialise le y à partir duquel on affiche nos éléments, et le y du fichier texte
  int y = 120;
  int yFichierTexte = 0;

  for (String ligne : lignes) {                                                                                      // Pour chaque ligne du plan ...
    int tables = 0, espaces = 0, largeur = 1160, x = 20, xFichierTexte = 0;                                          // On initialise le nombre d'espaces / places / la largeur dispo / le x pour afficher les éléments / le x du fichier texte
    char[] caracteres = ligne.toCharArray();                                                                         // On sépare les caractère de la ligne dans une liste de caractères
    for (char caractere : caracteres) {                                                                                  // Pour chacun des caractères de la ligne, on vérifie si c'est un espace ou une table (invisble ou non) pour les compter
      if (caractere == ' ') {
        espaces++;
      } else {
        tables++;
      }
    }

    if (tables == 0 && espaces != 0) {                                                                               // Si il n'y a aucune table et qu'il y a des espaces, on affiche uniquement ceux-ci
      for (char caractere : caracteres) {                                                                            // Pour chaque caractère qui est un espace ... Donc on a pas besoins de vérifier ce que c'est : "caractere" est inutilisé mais on doit utiliser la boucle for quand même
        espacesEtCoordonnees.put(coordonnees(xFichierTexte, yFichierTexte, 0), coordonnees(x, y, 0));                // On ajoute l'espace dans l'HashMap des espaces, avec ses coordonnées dans le fichier texte et sur l'écran (largeurTable = 0 dans coordonnees() car un espace a une largeur de 20px) 
        fill(60, 63, 65);                                                                                            // On l'affiche de la même couleur que le fond
        rect(x, y, 20, 80);
        x += 20;                                                                                                     // On incrémente le x d'affichage des éléments et le x du fichier
        xFichierTexte++;
      }
    } else {                                                                                                         // Si il y a des tables ...
      largeur -= espaces * 20;                                                                                       // On soustrait à la largeur disponible sur le plan, la largeur prise par les espaces qui sont de taille fixe (20px)
      int largeurTable = largeur / tables;                                                                           // On calcule la largeur des tables en divisant la largeur disponible par le nombre de tables

      for (char signe : caracteres) {                                                                                // Pour chaque caractère de la ligne ...
        if (signe == ' ') {                                                                                          // Si c'est un espace, on l'ajoute à l'HashMap et on affiche le rectangle
          espacesEtCoordonnees.put(coordonnees(xFichierTexte, yFichierTexte, 0), coordonnees(x, y, 0));
          fill(60, 63, 65);
          rect(x, y, 20, 80);
          x += 20;                                                                                                   // On incrémente le x d'une largeur d'espace
        } else {                                                                                                     // Sinon, si c'est une table invisible on l'ajoute à la liste des tables invisibles, on l'affiche avec sa couleur
          if (signe == 'i') {
            tablesInvisibles.add(coordonnees(xFichierTexte, yFichierTexte, 0));
            fill(60, 63, 65);
            rect(x, y, largeurTable, 80);
          } else {                                                                                                   // Si c'est une table normale on l'affiche blanche
            fill(255);
            rect(x, y, largeurTable, 80);
          }

          tablesEtCoordonnees.put(coordonnees(xFichierTexte, yFichierTexte, 0), coordonnees(x, y, largeurTable));    // Dans les deux cas on stocke les coordonnées dans l'HashMap des tables avec la largeurTable cette fois
          x += largeurTable;                                                                                         // On incrémente le x d'une largeur de table
        }
        xFichierTexte++;                                                                                             // On incrémente le x du fichier texte de 1 pour passer au caractère suivant
      }
    }

    y += 100;          // Après avoir fait le tour des caractères, on incrémente le y d'affichage de 100 pour aller à la ligne (20px d'écart entre chaque ligne qui font 80px d'épaisseur) et le y du fichier de 1
    yFichierTexte++;
  }
}