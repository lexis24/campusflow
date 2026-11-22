# Séance 2 : parcours utilisateur « suivre mes échéances »

**Persona :** [Sanata](persona-job-stories.md), 21 ans, en L3 Informatique à Ouagadougou.
**Situation de départ :** le parcours décrit ce qu'elle fait **aujourd'hui, sans CampusFlow**. Pour chaque étape, il indique son action, la friction qu'elle rencontre et l'**opportunité** que l'application peut saisir (méthode du cours, séance 2, diapo 7).

| | 1. Planifier | 2. Consulter | 3. Ajouter | 4. Être rappelée | 5. Rendre |
|---|---|---|---|---|---|
| **Action** | Recopie les dates des rendus dans un cahier | Entre deux cours, croise le groupe WhatsApp, ses notes et sa mémoire | Quand un devoir est annoncé à l'oral, le note sur un coin de cahier | Attend qu'un camarade poste « c'est pour demain ! » dans le groupe | Dépose le devoir, souvent réalisé la veille |
| **Friction** | Le cahier reste à la maison à cause des longs trajets, et il n'est jamais à jour | Trois sources à croiser, et aucune ne donne la vue complète | La note se perd, ou la date est notée sans le cours concerné | Le rappel dépend des autres et arrive souvent trop tard | Stress et travail bâclé dans l'urgence |
| **Opportunité** | Une **seule liste** d'échéances, toujours dans la poche | Un écran **Échéances** trié par date, avec les filtres **à faire / faites / en retard** | **Ajout en 3 appuis** : bouton « + », titre, cours, date | Un **rappel visuel** : dates relatives (« Demain », « Dans 3 jours ») et retards mis en évidence par la couleur d'erreur du thème | **« Marquer comme fait »** : la liste ne montre plus que ce qui reste |
| **Écran ou fonction** | Échéances | Échéances + filtres | Nouvelle tâche (formulaire) | Échéances (affichage des dates) | Détail |

## Lecture du parcours

- **Le point de rupture est l'étape 3, « Ajouter ».** Une échéance mal notée au moment de l'annonce fausse toutes les étapes suivantes : elle n'apparaît ni au planning, ni à la consultation, ni au rappel. C'est pourquoi l'ajout doit être **le plus court possible**, et ce critère servira pour juger les wireframes (« Le parcours est-il le plus court ? Compter les appuis », séance 2, diapo 19).
- **Les étapes 1, 2 et 4 se résolvent sur le même écran**, Échéances. Ça confirme le choix d'en faire l'écran d'accueil, derrière la connexion.
- **Le rappel reste visuel dans la version 1.** Les notifications push avant l'échéance constituent une **perspective** : elles ne font pas partie des séances 1 à 7, et la décision de la séance 1 ne les promet pas.

## Lien avec les job stories

| Étapes | Job story |
|---|---|
| 1, 2, 4 | Job story 1 : voir d'un coup d'œil ce qui est à rendre et ce qui est en retard |
| 3 | Job story 2 : enregistrer une échéance en quelques secondes |
| 5 | Job story complémentaire : marquer un rendu comme fait |
