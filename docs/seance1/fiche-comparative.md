# Séance 1 : fiche comparative Android / iOS

**Cas étudié :** CampusFlow, une application étudiante de suivi des cours, des échéances et des tâches, destinée à l'Afrique francophone. Le pays de référence est le **Burkina Faso**.

## 1. Le marché dans notre contexte

| Zone | Android | iOS | Période |
|---|---|---|---|
| Monde | 69,17 % | 30,81 % | septembre 2026 |
| Afrique | 83,03 % | 16,92 % | octobre 2026 |
| **Burkina Faso** | **92,7 %** | **7,26 %** | octobre 2026 |

- **Mesure :** part des pages web vues depuis un appareil mobile, par système d'exploitation.
- **Source :** StatCounter Global Stats (pages « mobile » Afrique et Burkina Faso, relevées en octobre 2026). Le chiffre mondial est celui du cours de la séance 1 (diapo 8).

**Ce que ces chiffres mesurent, et ce qu'ils ne mesurent pas.** Ils décrivent l'**activité web**, pas le nombre d'appareils (parc installé) ni les ventes (cours, séance 1, diapo 11). Ils restent un bon indicateur de ce que les étudiants ont réellement en main. Au Burkina Faso, un utilisateur mobile sur quatorze environ est sur iOS : un sur six au niveau africain, trois sur dix au niveau mondial.

## 2. Les 14 critères

Les colonnes Android et iOS reprennent le cours (séance 1, diapos 16 et 17). Les deux dernières colonnes décrivent ce qui change dans notre contexte et ce que nous en concluons pour CampusFlow.

| N° | Critère | Android | iOS | Ce qui change au Burkina Faso / en Afrique francophone | Conséquence pour CampusFlow |
|:--:|---|---|---|---|---|
| 1 | **Philosophie** | Open source (AOSP), multi-constructeurs | Fermé, matériel et logiciel intégrés | Grâce au modèle ouvert, il existe beaucoup de téléphones à bas prix. Résultat : 92,7 % d'Android au Burkina, contre 69 % dans le monde. | **Android est la cible prioritaire.** iOS reste minoritaire mais ne doit pas être exclu. |
| 2 | **Architecture** | Noyau Linux, ART | Darwin / XNU, Cocoa Touch | Sur Android, la même application tourne sur des processeurs très différents, de l'entrée de gamme au haut de gamme. | Il faut une application compilée et légère : Flutter compile en code natif ARM. On teste sur un émulateur modeste. |
| 3 | **Environnement** | Android Studio (Windows, macOS, Linux) | Xcode (macOS uniquement) | Les machines disponibles pour les étudiants et les petites équipes sont surtout des PC Windows ou Linux (c'est notre cas). Un Mac représente un coût important. | On développe et on teste sous Windows avec Android Studio. La compilation iOS est repoussée à plus tard, sur un Mac ou un service de compilation. |
| 4 | **Langage** | Kotlin (Java), Jetpack Compose | Swift, SwiftUI / UIKit | Faire du natif, c'est deux langages et deux compétences à recruter ou à apprendre, ce qui est lourd pour une petite équipe locale. | **Un seul langage (Dart) et une seule base de code avec Flutter.** |
| 5 | **Modèle d'application** | Activités, services, paquet APK / AAB | Scènes et vues, paquet IPA | Un APK peut s'installer sans passer par le magasin : partage direct, réseau local du campus. Il faut alors autoriser les « sources inconnues ». | On publie un AAB sur Google Play. Pendant une phase pilote, on peut aussi diffuser un APK signé depuis une source officielle (site de l'université). |
| 6 | **Cycle de vie** | onCreate → onResume → onPause → onDestroy | Active → inactive → arrière-plan → suspendue | Sur des appareils qui ont peu de mémoire, le système ferme plus souvent les applications en arrière-plan. La saisie en cours peut alors être perdue. | Les données de référence sont sur le serveur (séance 7). L'interface doit pouvoir se reconstruire à partir de l'état, pas de variables locales fragiles. |
| 7 | **Matériel** | Nombreux constructeurs et gammes | Quelques modèles, un seul constructeur | Le parc Android local est dominé par l'entrée et le milieu de gamme : petits écrans, peu de stockage. C'est une observation, pas une mesure chiffrée. | Interface sobre, peu de dépendances, images légères. La mise en page doit s'adapter (LayoutBuilder, séance 5). |
| 8 | **Permissions** | Demandées à l'exécution, par permission | Demandées à l'exécution, avec un texte justificatif | La confiance se gagne en ne demandant que le nécessaire, surtout si l'application circule hors des magasins. | On demande le minimum : Internet, et les notifications plus tard pour les rappels. Pas de caméra, pas de contacts. |
| 9 | **Stockage** | Bac à sable, stockage cloisonné, Keystore | Bac à sable, Keychain | Les appareils d'entrée de gamme ont peu d'espace libre. Les identifiants doivent rester protégés même si le téléphone est partagé ou perdu. | Le jeton de connexion est rangé dans le **stockage sécurisé** (Keystore / Keychain), jamais en clair (séance 7). L'empreinte locale reste faible. |
| 10 | **Sécurité** | Signature, Play Protect, bac à sable | Signature, revue, bac à sable | Si on diffuse un APK hors du magasin, on se prive d'une partie des contrôles du magasin, et il existe un risque d'APK modifiés. | On signe l'application, on la diffuse uniquement depuis des sources officielles, et on passe par HTTPS en production. |
| 11 | **Distribution** | Google Play, autres magasins, installation directe | App Store, ouverture variable selon la région | Il faut un compte développeur payant (frais uniques chez Google, abonnement annuel chez Apple), réglé en ligne. Ça peut être un frein (hypothèse à vérifier). | Google Play en priorité. App Store seulement si la demande iOS le justifie. |
| 12 | **Fragmentation** | Versions d'OS, constructeurs, tailles d'écran | Faible : adoption rapide des nouvelles versions | Beaucoup de versions d'Android et de tailles d'écran circulent en même temps sur le campus. | On choisit une version minimale d'Android raisonnable, on fait une interface adaptative (seuil de 840 dp) et on teste sur plusieurs tailles. |
| 13 | **Mises à jour** | Selon le constructeur et l'opérateur | Directes par Apple, appareils compatibles | Les appareils d'entrée de gamme reçoivent peu de mises à jour du système, donc d'anciennes versions restent longtemps en service. Les mises à jour d'applications consomment des données mobiles (hypothèse sur le comportement des utilisateurs). | On prend en charge des versions d'Android anciennes et on garde un paquet de petite taille, pour que les mises à jour soient légères. |
| 14 | **Contraintes développeur** | Tests sur de nombreux appareils | Mac obligatoire, revue App Store | Il faut tester sur des appareils représentatifs du parc local, pas seulement sur un téléphone récent. | Tests sur l'émulateur Android et, idéalement, sur un vrai téléphone d'entrée de gamme. iOS en second temps. |



## Sources

- StatCounter Global Stats, part des systèmes d'exploitation mobiles, octobre 2026 :
  - Afrique : <https://gs.statcounter.com/os-market-share/mobile/africa>
  - Burkina Faso : <https://gs.statcounter.com/os-market-share/mobile/burkina-faso>
- M.COMPAORE, *Programmation mobile, séance 1 : Écosystème mobile*, U-AUBEN, 2026 : diapo 8 (répartition mondiale), diapo 11 (lecture critique d'un pourcentage), diapos 16-17 (les 14 critères).
- Frais des comptes développeurs : Google Play Console <https://support.google.com/googleplay/android-developer/answer/6112435> et Apple Developer Program <https://developer.apple.com/programs/>.
