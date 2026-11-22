# Séance 2 : briefs donnés à Claude Design

## Brief 1 : les 6 écrans du parcours principal

```
Contexte : application mobile CampusFlow, suivi des cours, échéances et tâches
d'un étudiant. Navigation principale par une barre inférieure à 3 destinations :
Échéances, Cours, Profil. L'écran Connexion précède l'application.

Utilisateur : Sanata, 21 ans, L3 Informatique à Ouagadougou. Smartphone Android
de milieu de gamme, utilisé à une main entre deux cours. Ses échéances arrivent
par le groupe WhatsApp de la promo et par des annonces orales.

Tâche : voir d'un coup d'œil ce qui est à rendre et en retard, ajouter une tâche
en 3 appuis maximum, marquer un rendu comme fait.

Contraintes : écran 360×800 dp, Material 3, cibles tactiles de 48 dp minimum,
contraste AA, chaque icône accompagnée d'un libellé.

Format : 6 wireframes basse fidélité, un par écran :
1. Connexion : logo, champ e-mail, champ mot de passe, bouton « Se connecter ».
2. Échéances : barre de titre, liste des tâches (titre, cours, date relative
   « Demain », « Dans 3 jours », « En retard »), filtres À faire / Faites /
   En retard, bouton flottant « + », barre de navigation inférieure.
3. Détail d'une tâche : retour, titre, cours, date d'échéance, statut,
   description, bouton principal « Marquer comme fait ».
4. Nouvelle tâche : fermer, champs Titre (obligatoire), Cours (liste), Date,
   Description, bouton « Enregistrer ».
5. Cours : liste des cours avec enseignant et nombre de tâches, barre inférieure.
6. Profil : nom, e-mail, nombre de tâches terminées, bouton « Se déconnecter »,
   barre inférieure.

Style : sobre, niveaux de gris, grille visible, un seul accent pour l'action
principale de chaque écran. Contenu réaliste en français (ex. « Rapport projet
réseaux · Demain », « TP Bases de données · Dans 3 jours »).
```

---

## Brief 2 : trois variantes de l'écran Échéances

```
Contexte : application mobile CampusFlow, écran « Échéances », l'écran d'accueil
après la connexion. Il résout trois étapes du parcours : planifier, consulter,
être rappelée.

Utilisateur : Sanata, étudiante en L3, Android milieu de gamme, à une main,
quelques secondes entre deux cours.

Tâche : en moins de 3 secondes, savoir ce qui est à rendre cette semaine et ce
qui est en retard ; ajouter une tâche en 3 appuis maximum.

Contraintes : 360×800 dp, Material 3, cibles 48 dp, contraste AA, bouton
flottant « + » et barre inférieure Échéances · Cours · Profil conservés.

Format : 3 variantes basse fidélité de structures réellement différentes :
- Variante A : liste chronologique simple + filtres en puces (chips)
  À faire / Faites / En retard en haut.
- Variante B : liste groupée par période avec en-têtes de section
  (En retard, Aujourd'hui, Cette semaine, Plus tard).
- Variante C : bandeau de résumé en haut (compteurs « 3 à faire »,
  « 1 en retard ») puis cartes de tâches.

Style : sobre, niveaux de gris, grille visible, un seul accent.
```

---

## Brief 3 (facultatif) : version tablette

Ce brief prépare la séance 5 (seuil de 840 dp) et la section « tailles de fenêtre » du design system.

```
Même écran Échéances (variante retenue), en largeur étendue 1280×800 dp :
liste à gauche, détail de la tâche sélectionnée à droite (liste et détail côte
à côte, au-delà de 840 dp). Basse fidélité, mêmes contraintes et style.
```
