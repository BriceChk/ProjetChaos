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
 ______          _      _     _____ _                     
 | ___ \        (_)    | |   /  __ \ |                    
 | |_/ / __ ___  _  ___| |_  | /  \/ |__   __ _  ___  ___ 
 |  __/ '__/ _ \| |/ _ \ __| | |   | '_ \ / _` |/ _ \/ __|
 | |  | | | (_) | |  __/ |_  | \__/\ | | | (_| | (_) \__ \
 \_|  |_|  \___/| |\___|\__|  \____/_| |_|\__,_|\___/|___/
               _/ |                                       
              |__/                                        
 
 Projet de fin d'année - Informatique et Sciences du Numérique - Terminale S Lycée Yourcenar Le Mans
 */

import controlP5.*;
import java.awt.Desktop;
import java.util.*;

String statut;                               // Correspond à l'état du programme : si il est sur la fenêtre d'accueil, si il va l'afficher, si il est sur une autre fenêtre ...
ArrayList<String> classes;                   // Liste qui contient toutes les classes disponibles
int classeActuelle;                          // Index de la classe actuellement séléctionnée dans la liste "classes"
ArrayList<String> salles;                    // Liste de toutes les salles
int salleActuelle;                           // Index de la salle actuellement séléctionnée
PImage flecheGauche;                         // Image correspondant à la flèche gauche utilisée sur l'écran de démarrage pour la séléction de classe / salle
PImage flecheDroite;                         // Image de la flèche droite
PImage croix;                                // Image de la croix pour supprimer un élève du plan de classe
ArrayList<String> eleves;                    // Liste des élèves de la classe actuellement chargée
String coordsEleveChoisi;                    // Coordonées sous forme "x y" de l'élève séléctionné lorsque le plan de classe est affiché
int indexEleveChoisi;                        // Index de l'élève qui est séléctionné dans la liste "eleves"
HashMap<String, String> elevesEtCoordonnees; // HashMap (association de deux objets) associant les coordonnées d'un élève dans le plan de classe sous forme "x y" au nom de cet élève
PFont verdana;                               // Police utilisée pour les éléments de ControlP5
ControlP5 cp5;                               // ControlP5, librairie qu'on utilise pour les zones de texte

void setup() {
  // Chargement des images des flèches et de la croix de suppression
  flecheDroite = loadImage("fleche_droite.png");
  flecheGauche = loadImage("fleche_gauche.png");
  croix = loadImage("croix.png");
  // Chargement de la police
  verdana = createFont("Verdana", 16);
  // Affichage de l'écran d'accueil
  ecranAccueil();
  
  // Message licence
  println("Copyright © 2017 Emmanuel Dupré la Tour, Lucas Lesourd, Brice Chkir");
  println("This program comes with ABSOLUTELY NO WARRANTY; for details see LICENCE file.");
  println("This is free software, and you are welcome to redistribute it");
  println("under certain conditions; see LICENCE file for details.");
  println("");
}

void draw() {
  // On exécute différentes fonctions en fonction de l'état du programme :
  switch (statut) {
  case "accueil_attente":
    setupAccueil();        // Les fonctions qui commencent par "setup" ne s'éxecutent qu'une seule fois car on change le statut dans ces fonctions
    break;
  case "accueil_pret":
    drawAccueil();         // Les fonctions draw tournent en boucle tant que l'on est dans le statut correspondant
    break;
  case "plan_attente":
    setupPlan();
    break;
  case "plan_pret":
    drawPlan();
    break;
  case "editeurSalle_attente":
    setupSalle();
    break;
  case "editeurSalle_pret":
    drawSalle();
    break;
  }
}

// Lorsque on clique sur la souris :
void mouseClicked() {
  switch(statut) {
  case "accueil_pret":
    mouseClickedAccueil();
    break;
  case "plan_pret":
    mouseClickedPlan();
    break;
  case "editeurSalle_pret":
    mouseClickedSalle();
    break;
  }
}