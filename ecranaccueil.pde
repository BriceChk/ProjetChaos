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

// Afficher l'écran d'accueil
void ecranAccueil() {
  surface.setSize(450, 500);  // Changement de la taille de la fenêtre
  statut = "accueil_attente"; // Ce statut permettra d'éxecuter la fonction setupAccueil() au prochain tour de la boucle draw(), ce qui est nécéssaire pour son affichage suite au changement de taille de la fenêtre
}

void setupAccueil() {
  // Ce code ne s'éxecute qu'une fois lors de l'affichage de l'écran d'accueil.
  statut = "accueil_pret";                              // On change immédiatement le statut, au prochain tour de la boucle draw() ce sera drawAccueil() qui sera éxécuté en boucle

  stroke(95);                                           // Couleur des bordures des rectangles
  surface.setTitle("Plan de classe");                   // Titre de la fenêtre

  cp5 = new ControlP5(this);                            // Initialisation de ControlP5
  cp5.setColorBackground(0xff4f5456);                   // Changement de la couleur de fond des éléments CP5 (0xff + code habituel)

  // Chargement des classes :
  classeActuelle = 0;                                   // On choisit la première classe de la liste
  classes = new ArrayList();                            // On initialise la liste
  File dossierEleves = new File(sketchPath("eleves"));  // On ouvre le dossier eleves qui est dans le dossier du projet (sketchPath() permet de se placer dans le dossier du projet)
  File[] fichiersEleves = dossierEleves.listFiles();    // On liste les fichiers de ce dossier

  for (File file : fichiersEleves) {                    // Pour chaque fichier, on l'ajoute à la liste en gardant le nom du fichier sans .txt pour le nom de la classe
    if (file.isFile()) {
      classes.add(file.getName().replace(".txt", ""));
    }
  }

  // Chargement des dispositions de salle de la même manière que la liste des classes
  salleActuelle = 0;
  salles = new ArrayList();
  File dossierSalles = new File(sketchPath("salles"));
  File[] fichiersSalles = dossierSalles.listFiles();

  for (File file : fichiersSalles) {
    if (file.isFile()) {
      salles.add(file.getName().replace(".txt", ""));
    }
  }

  // On initialise cette variable car elle sera utilisée même si on a rien à mettre dedans
  coordsEleveChoisi = "";

  // Couleur de fond, police, centrage de fenetre
  background(60, 63, 65);
  textSize(16);
  textAlign(CENTER, CENTER); // Cela permet d'afficher le texte au centre du rectangle que l'on met en paramètre de text("texte", x, y, largeur, hauteur)
  centrerFenetre();

  // Texte correspondant aux choix de classe / salle
  fill(255);
  text("Choisir une classe", 50, 150, 350, 25);
  text("Choisir une disposition de salle", 50, 285, 350, 25);

  // Affichage des flèches
  image(flecheGauche, 10, 315);
  image(flecheDroite, 410, 315);
  image(flecheGauche, 10, 180);
  image(flecheDroite, 410, 180);

  // Affichage du nom du logiciel
  fill(79, 84, 86);
  textSize(12);
  textAlign(LEFT);
  text("Emmanuel Dupré la Tour, Lucas Lesourd, Brice Chkir", 5, 5, 450, 15);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(40);
  text("Plan de classe", 0, 20, 450, 100);
  textSize(16);
  text("Projet Chaos", 90, 90, 100, 20);
  textSize(16);
}

void drawAccueil() {
  // Ce code s'éxecute en boucle une fois l'écran d'accueil affiché, pour les boutons et textes suceptibles de changer.

  // Bouton pour valider
  afficherBouton("Créer le plan de classe", 125, 435, 200, 50); 

  textSize(13);
  // Boutons créer / éditer
  afficherBouton("Créer une classe", 50, 235, 170, 40);
  afficherBouton("Editer la classe", 230, 235, 170, 40);
  afficherBouton("Créer une salle", 50, 370, 170, 40);
  afficherBouton("Editer la salle", 230, 370, 170, 40);

  textSize(16);
  // Nom de la classe
  fill(79, 84, 86);                                    // Couleur du rectangle
  rect(50, 175, 350, 50);                              // Rectangle
  fill(255);                                           // Couleur du texte
  text(classes.get(classeActuelle), 50, 175, 350, 50); // On affiche le nom de la classe en récupérant le string à la position classeActuelle dans la liste des classes

  // Nom de la salle
  fill(79, 84, 86);
  rect(50, 310, 350, 50);
  fill(255);
  text(salles.get(salleActuelle), 50, 310, 350, 50);
}

void mouseClickedAccueil() {
  // Ce code s'éxecute lorsque l'écran d'accueil est affiché et qu'on clique sur la souris.
  // A chaque bouton cliqué on enlève tous les éléments de ControlP5, par sécurité.

  // Créer le plan de classe
  if (survole(125, 435, 200, 50)) {
    enleverControlP5();
    plan();
  }

  // Salle suivante
  if (survole(410, 315, 25, 39)) {
    enleverControlP5();
    salleSuivante();
  }

  // Salle précédente
  if (survole(10, 315, 25, 39)) {
    enleverControlP5();
    sallePrecedente();
  }

  // Classe suivante
  if (survole(410, 180, 25, 39)) {
    enleverControlP5();
    classeSuivante();
  }

  // Classe précédente
  if (survole(10, 180, 25, 39)) {
    enleverControlP5();
    classePrecedente();
  }

  // Créer classe
  if (survole(50, 235, 170, 40)) {
    enleverControlP5();
    cp5.addTextfield(" ")        
      .setPosition(51, 175)
      .setSize(310, 50)
      .setAutoClear(false)
      .setFont(verdana);
    ;

    cp5.addBang("CREER")
      .setPosition(351, 175)
      .setSize(50, 50)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(verdana);
    ;
  }

  // Editer classe
  if (survole(230, 235, 170, 40)) {
    enleverControlP5();
    editerClasse();
  }

  // Créer salle
  if (survole(50, 370, 170, 40)) {
    enleverControlP5();
    cp5.addTextfield("   ")        
      .setPosition(51, 310)
      .setSize(310, 50)
      .setAutoClear(false)
      .setFont(verdana);
    ;

    cp5.addBang("Creer")
      .setPosition(351, 310)
      .setSize(50, 50)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      .setFont(verdana);
    ;
  }

  // Editer salle
  if (survole(230, 370, 170, 40)) {
    enleverControlP5();
    editeurSalle();
  }
}

// Fonction de retour du bouton valider pour la création de classe
void CREER() {
  Textfield field = cp5.get(Textfield.class, " ");                                  // On récupère la zone de texte correspondant à la création de classe
  String nomClasse = field.getText();                                               // On en extrait le texte tapé par l'utilisateur
  if (nomClasse.length() > 0) {                                                     // Si il a tapé quelques chose ...
    File fichier = new File(sketchPath("eleves/" + nomClasse + ".txt"));            // On initialise le fichier de cette classe
    if (fichier.exists()) {                                                         // Si il existe déjà, on avertit l'utilisateur
      //TODO afficher message erreur ecran accueil
    } else {                                                                        // Sinon, on le crée, avec structure try/catch (on touche à un fichier)
      try {
        fichier.createNewFile();                                                    // Création du fichier (vide)
        PrintWriter out = new PrintWriter(fichier);                                 // On initialise de quoi écrire dans ce fichier et on ajoute des commentaires par défaut
        out.println("// Lister les élèves, un par ligne, sous ces commentaires.");
        out.println("// Exemple : François Mekouyansky");
        out.close();
        classes.add(nomClasse);                                                     // On l'ajoute à la liste des classes
        classeActuelle = classes.indexOf(nomClasse);                                // On définie la classe actuelle sur cette nouvelle classe
        enleverControlP5();                                                         // On enlève tous les éléments ControlP5
        editerClasse();                                                             // On ouvre l'édition de la classe
      } 
      catch (IOException e) {
        // En cas d'erreur, on ne fait rien (il ne devrait pas y avoir d'erreur !)
      }
    }
  }
}

void Creer() {
  Textfield field = cp5.get(Textfield.class, "   ");                     // On récupère la zone de texte correspondant à la création de salle
  String nomSalle = field.getText();                                     // On en extrait le texte tapé par l'utilisateur
  if (nomSalle.length() > 0) {                                           // Si il a tapé quelques chose ...
    File fichier = new File(sketchPath("salles/" + nomSalle + ".txt"));  // On initialise le fichier de cette salle
    if (fichier.exists()) {                                              // Si il existe déjà, on avertit l'utilisateur
      //TODO afficher message erreur ecran accueil
    } else {                                                             // Sinon, on le crée, avec structure try/catch (on touche à un fichier)
      try {
        fichier.createNewFile();                                         // Création du fichier (vide)
        salles.add(nomSalle);                                            // On l'ajoute à la liste des salles
        salleActuelle = salles.indexOf(nomSalle);                        // On définie la salle actuelle sur cette nouvelle salle
        enleverControlP5();                                              // On enlève tous les éléments ControlP5
        editeurSalle();                                                  // On ouvre l'éditeur de salle
      } 
      catch(IOException e) {
        // En cas d'erreur, on ne fait rien (il ne devrait pas y avoir d'erreur !)
      }
    }
  }
}

// Fonction permettant d'ouvrir le fichier texte d'une classe dans l'éditeur de texte du PC
void editerClasse() {
  File fichier = new File(sketchPath("eleves/" + classes.get(classeActuelle) + ".txt"));  // On charge le fichier correspondant à la classe actuelle
  if (fichier.exists() && Desktop.isDesktopSupported()) {                                 // On vérifie tout de même qu'il existe, et que l'ordinateur supporte l'édition 
    try {
      Desktop.getDesktop().edit(fichier);                                                 // On ouvre l'éditeur avec le fichier. Structure try/catch car il s'agie d'une opération sur un fichier (IO)
    } 
    catch (IOException e) {
      // En cas d'erreur, on ne fait rien (il ne devrait pas y avoir d'erreur !)
    }
  }
}

// Fonction permettant d'enlever tous les éléments éventuellement ajoutés avec ControlP5.
void enleverControlP5() {
  if (cp5.get(Textfield.class, " ") != null) {
    cp5.get(Textfield.class, " ").remove();
  }
  if (cp5.get(Textfield.class, "   ") != null) {
    cp5.get(Textfield.class, "   ").remove();
  }
  if (cp5.get(Bang.class, "Creer") != null) {
    cp5.get(Bang.class, "Creer").remove();
  }
  if (cp5.get(Bang.class, "CREER") != null) {
    cp5.get(Bang.class, "CREER").remove();
  }
}

// Choisir la classe suivante
void classeSuivante() {
  classeActuelle++;                         // On incrémente l'index de la classe actuelle
  if (classeActuelle == classes.size()) {   // Si on arrive au bout de la liste, on repart à zéro
    classeActuelle = 0;
  }
}

// Choisir la classe précédente
void classePrecedente() {
  classeActuelle--;
  if (classeActuelle == -1) {               // Si on est passé dans un index négatif, on repart du bout de la liste des classes
    classeActuelle = classes.size() - 1;
  }
}

// Choisir la salle suivante (même fonctionnement que pour les classes)
void salleSuivante() {
  salleActuelle++;
  if (salleActuelle == salles.size()) {
    salleActuelle = 0;
  }
}

// Choisir la salle précédente (même fonctionnement que pour les classes)
void sallePrecedente() {
  salleActuelle--;
  if (salleActuelle == -1) {
    salleActuelle = salles.size() - 1;
  }
}