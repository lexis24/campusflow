# Serveur simulé CampusFlow (séance 7)

`db.json` contient les tâches, les cours et les utilisateurs. **json-server** en fait une API REST complète.

## Lancer le serveur

```bash
npm install -g json-server@0.17.4   # une seule fois
cd server
json-server --watch db.json --port 3000
```

## Ressources

| Adresse | Contenu |
|---|---|
| <http://localhost:3000/taches> | les tâches (JSON brut) |
| <http://localhost:3000/cours> | les cours |
| <http://localhost:3000/utilisateurs> | les utilisateurs |

| Requête | Effet |
|---|---|
| `GET /taches/t3` | une tâche |
| `POST /taches` | crée une tâche (écrite dans `db.json`) |
| `PATCH /taches/t3` | modifie une partie d'une tâche, par exemple `{"done": true}` |
| `DELETE /taches/t3` | supprime une tâche |

Depuis l'**émulateur Android**, l'ordinateur s'appelle **`10.0.2.2`** et non `localhost` : l'application appelle donc `http://10.0.2.2:3000`.

Les noms de champs (`id`, `title`, `description`, `dueDate`, `done`, `courseId`…) correspondent aux `fromJson` du package `campusflow_models` (séance 3).
