// Middleware json-server : authentification simulée (séance 7).
//
// - POST /login {email, motDePasse} -> 200 {jeton, utilisateur} ou 401.
// - Toute autre requête exige l'en-tête « Authorization: Bearer <jeton> »,
//   sinon 401. L'application redirige alors vers l'écran de connexion.
//
// Les jetons valides sont gardés EN MÉMOIRE : redémarrer json-server les
// invalide tous, ce qui permet de tester la redirection sur 401.
//
// Simulation : un vrai serveur stockerait des mots de passe hachés et des
// jetons signés (JWT, par exemple), jamais en clair dans un fichier JSON.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

/** Jetons délivrés depuis le démarrage : jeton -> id de l'utilisateur. */
const jetonsValides = new Map();

module.exports = (req, res, next) => {
  // Requêtes de pré-vérification CORS : laissées passer.
  if (req.method === 'OPTIONS') return next();

  // Connexion. req.body est déjà décodé par le bodyParser de json-server.
  if (req.method === 'POST' && req.path === '/login') {
    const { email, motDePasse } = req.body || {};
    const db = JSON.parse(
      fs.readFileSync(path.join(__dirname, 'db.json'), 'utf8'),
    );
    const trouve = db.utilisateurs.find(
      (u) => u.email === email && u.motDePasse === motDePasse,
    );
    if (!trouve) {
      return res.status(401).jsonp({ erreur: 'Identifiants incorrects' });
    }
    const jeton = crypto.randomUUID();
    jetonsValides.set(jeton, trouve.id);
    // On ne renvoie jamais le mot de passe.
    const { motDePasse: _, ...utilisateur } = trouve;
    return res.status(200).jsonp({ jeton, utilisateur });
  }

  // Toutes les autres routes sont protégées.
  const entete = req.headers.authorization || '';
  const jeton = entete.startsWith('Bearer ') ? entete.slice(7) : null;
  if (!jeton || !jetonsValides.has(jeton)) {
    return res.status(401).jsonp({ erreur: 'Non authentifié' });
  }
  return next();
};
