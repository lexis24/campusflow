# Séance 1 : décision pour CampusFlow

| | Décision |
|---|---|
| **Cible** | Les étudiants du supérieur en Afrique francophone, en priorité au Burkina Faso |
| **Plateformes** | Android en priorité, iOS ensuite avec le même code. Le Web est hors du périmètre de la version 1. |
| **Approche** | Cross-platform avec **Flutter** (Dart), une seule base de code |

## Paragraphe de décision

CampusFlow s'adresse aux **étudiants du supérieur en Afrique francophone**, en commençant par le Burkina Faso. Ils y gèrent leurs cours, leurs échéances et leurs tâches sur un téléphone qui est, dans **92,7 % des cas, un Android**, contre 83 % en Afrique et 69 % dans le monde (StatCounter, octobre 2026, part des pages web vues sur mobile ; voir la [fiche comparative](fiche-comparative.md)). La version 1 vise donc **Android en priorité**, testée sur des appareils modestes et de tailles d'écran variées. **iOS suivra avec le même code**, pour ne pas exclure la minorité équipée d'un iPhone. Nous retenons une approche **cross-platform avec Flutter** plutôt que le natif, pour trois raisons. D'abord, un seul langage et une seule base de code suffisent là où le natif imposerait Kotlin et Swift à une petite équipe. Ensuite, le développement est possible sous Windows, alors que le natif iOS exige un Mac. Enfin, Flutter produit une application compilée et légère, adaptée au parc local. L'[autopsie de Windows Phone](autopsie.md) confirme ce choix : une plateforme meurt de son écosystème, il faut donc aller là où sont déjà les utilisateurs et les applications, c'est-à-dire Android et iOS. Le Web et un **mode hors ligne** (consultation sans connexion) restent des **perspectives** pour une version ultérieure. Ils ne sont pas des engagements de la version 1.
