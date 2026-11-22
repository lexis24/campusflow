# Serveur simulé CampusFlow (séance 7)

`db.json` contient les tâches, les cours et les utilisateurs. **json-server** en fait une API REST complète, et le middleware `auth.js` y ajoute une **authentification simulée** par jeton.

## Lancer le serveur (avec authentification, pour l'application)

```bash
npm install -g json-server@0.17.4   # une seule fois
cd server
json-server --watch db.json --host 127.0.0.1 --port 3000 --middlewares ./auth.js
```

**Compte de démonstration :** `sanata.ouedraogo@exemple.bf` / `campus2026`

**Pourquoi `--host 127.0.0.1` ?** Sous Windows, avec un Node.js récent, json-server écoute par défaut sur `localhost`, que Node peut traduire en adresse **IPv6 `::1`** uniquement. Le navigateur y arrive, mais l'émulateur Android, qui joint l'ordinateur par `10.0.2.2` (l'IPv4 `127.0.0.1`), obtient « Serveur injoignable ». On force donc l'écoute en IPv4. On n'utilise pas `0.0.0.0`, qui ouvrirait le serveur à tout le réseau local.

## Voir le JSON brut dans le navigateur

Avec l'authentification, `http://localhost:3000/taches` répond **401** sans jeton : c'est voulu. Pour simplement consulter les données, on lance le serveur **sans** le middleware :

```bash
json-server --watch db.json --host 127.0.0.1 --port 3000
```

## Authentification simulée (`auth.js`)

| Requête | Réponse |
|---|---|
| `POST /login` `{"email", "motDePasse"}` correct | `200 {"jeton": "...", "utilisateur": {...}}` (sans le mot de passe) |
| `POST /login` incorrect | `401 {"erreur": "Identifiants incorrects"}` |
| toute autre requête sans `Authorization: Bearer <jeton>` valide | `401 {"erreur": "Non authentifié"}` |

Les jetons sont gardés **en mémoire** : **redémarrer json-server les invalide tous**. C'est le moyen le plus simple de tester la redirection vers l'écran de connexion sur 401.

⚠️ Il s'agit d'une simulation pédagogique. Un vrai serveur stockerait des mots de passe **hachés** et délivrerait des jetons **signés et datés** (JWT, par exemple), servis en **HTTPS**.

## Ressources (avec le jeton)

| Requête | Effet |
|---|---|
| `GET /taches`, `GET /taches/t3` | lire |
| `POST /taches` | créer (écrit dans `db.json`) |
| `PATCH /taches/t3` `{"done": true}` | cocher |
| `DELETE /taches/t3` | supprimer |
| `GET /cours`, `GET /utilisateurs` | autres ressources |

Depuis l'**émulateur Android**, l'ordinateur s'appelle **`10.0.2.2`** : l'application appelle `http://10.0.2.2:3000`.

Les noms de champs (`id`, `title`, `description`, `dueDate`, `done`, `courseId`…) correspondent aux `fromJson` du package `campusflow_models` (séance 3).
