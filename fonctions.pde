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

// Centrer la fenêtre sur l'écran (La position définie est celle du coin supérieur gauche de la fenêtre)
void centrerFenetre() {
  surface.setLocation(displayWidth / 2 - width / 2, displayHeight / 2 - height / 2);
}

// Transformer un x et un y en texte pour le stocker dans l'hashmap ("x y")
String coordonnees(int x, int y, int largeur) {
  return x + " " + y + " " + largeur;
}

// Récupérer le x stocké dans l'hashmap
int transformerEnX(String s) {
  String t = s.split(" ")[0];
  return Integer.parseInt(t);
}

// Récupérer le y stocké dans l'hashmap
int transformerEnY(String s) {
  String t = s.split(" ")[1];
  return Integer.parseInt(t);
}

// Récupérer la largeur stocké dans l'hashmap
int transformerEnLargeur(String s) {
  String t = s.split(" ")[2];
  return Integer.parseInt(t);
}

// Fonction pour afficher un bouton dynamique (change de couleur si survolé)
void afficherBouton(String texte, int x, int y, int largeur, int hauteur) {
  fill(79, 84, 86);
  if (survole(x, y, largeur, hauteur)) {
    fill(46, 65, 89);
  }
  rect(x, y, largeur, hauteur);
  fill(255);
  text(texte, x, y, largeur, hauteur);
}

// Cette fonction retourne true si le bouton donné en parametre est survolé par la souris
boolean survole(int x, int y, int largeur, int hauteur) {
  return mouseX >= x && mouseX <= x + largeur && mouseY >= y && mouseY <= y + hauteur;
}