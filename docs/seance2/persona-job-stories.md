# Séance 2 : persona et job stories

## Persona : Sanata *(persona fictif)*

| | |
|---|---|
| **Identité** | Sanata, 21 ans, étudiante en Licence 3 Informatique à Ouagadougou |
| **Appareil** | Smartphone Android de milieu de gamme (Samsung Galaxy A) |
| **Connexion** | Wi-Fi du campus en journée, forfait de données mobiles le reste du temps |
| **Contexte** | Plusieurs cours par semestre et des **projets de groupe** menés en parallèle. Elle fait de **longs trajets** entre son domicile et le campus, ce qui réduit son temps de travail à la maison. Elle consulte surtout son téléphone entre deux cours. |
| **D'où viennent ses échéances** | Du **groupe WhatsApp de la promotion**, où le délégué et certains enseignants publient les annonces, et des **annonces orales** faites en fin de cours |
| **Difficultés** | 1. L'annonce d'un rendu se **noie dans le groupe WhatsApp**, sous des dizaines de messages. <br> 2. Une date **annoncée à l'oral** n'est jamais notée, puis elle est **oubliée**. <br> 3. Elle n'a **aucune vue d'ensemble** : impossible de voir d'un coup ce qui est à faire, ce qui est fait et ce qui est en retard. |
| **Objectif** | **S'organiser à l'avance**, c'est-à-dire planifier sa semaine plutôt que travailler dans l'urgence |

> « Le lundi, je ne sais jamais vraiment ce qui tombe cette semaine. Je remonte le groupe WhatsApp, j'essaie de me souvenir de ce que le prof a dit… et je découvre parfois un rendu au dernier moment. »

## Job stories

Le modèle vient du cours (séance 2, diapo 6) : **Quand** [situation], **je veux** [action], **pour** [résultat].

### Job story 1 : consulter sa semaine
> **Quand** je commence ma semaine, le lundi matin entre deux cours,
> **je veux** voir d'un coup d'œil ce qui est à rendre et ce qui est déjà en retard,
> **pour** planifier mon travail à l'avance au lieu de découvrir les rendus au dernier moment.

### Job story 2 : enregistrer une échéance dès qu'elle est annoncée
> **Quand** un enseignant annonce un devoir à l'oral en fin de cours, ou que le délégué le publie dans le groupe WhatsApp,
> **je veux** l'enregistrer en quelques secondes avec son cours et sa date,
> **pour** ne plus dépendre de ma mémoire ni du fil des messages.

### Job story complémentaire : clore un rendu
> **Quand** je viens de déposer un devoir,
> **je veux** le marquer comme fait,
> **pour** que ma liste ne montre plus que ce qui me reste à faire.

## Du besoin à l'application

Ce tableau montre comment chaque besoin sera traduit dans CampusFlow, et à quelle séance.

| Besoin de Sanata | Réponse dans CampusFlow | Séance |
|---|---|---|
| Pas de vue d'ensemble (job story 1) | Écran **Échéances** : liste triée par date et filtres **à faire / faites / en retard** | 5 et 6 |
| Annonce noyée ou oubliée (job story 2) | **Bouton flottant « + »** qui ouvre le formulaire **Nouvelle tâche** (titre, cours, date) | 5 |
| Clore un rendu (job story complémentaire) | Bouton **« Marquer comme fait »** sur l'écran Détail, visible partout grâce à l'état partagé | 5 et 6 |
| Consulte entre deux cours, sur un téléphone de milieu de gamme | Interface utilisable **à une main**, cibles tactiles de 48 dp, chargement léger | 2 (design system) |
