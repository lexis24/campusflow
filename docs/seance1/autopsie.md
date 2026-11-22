# Séance 1 : autopsie de Windows Phone

**Question :** pourquoi Windows Phone a-t-il disparu, alors que Microsoft disposait de moyens considérables ?

**Repères**
- Windows Phone 7 sort fin 2010, après l'iPhone (2007) et le premier téléphone Android (2008) (cours, séance 1, diapo 4).
- En octobre 2017, Microsoft annonce l'arrêt des nouvelles fonctionnalités et du nouveau matériel [1].
- Le support de Windows 10 Mobile prend fin le 10 décembre 2019. Microsoft recommande alors à ses clients de passer à Android ou iOS [6].

Les trois causes retenues viennent de trois familles différentes vues en cours (séance 1, diapo 6). Elles sont classées de la plus importante à la moins importante.

---

## Cause n° 1 : écosystème d'applications (l'effet de réseau)

**Ce qui s'est passé.** Peu d'utilisateurs, donc peu d'intérêt pour les développeurs. Peu d'applications, donc peu de raisons d'acheter un Windows Phone. Ce cercle vicieux ne s'est jamais inversé.

**Le fait qui le prouve.** En octobre 2017, Joe Belfiore, vice-président de Microsoft chargé de Windows, explique publiquement ce qui s'est passé [1][2] :
- Microsoft a **payé des développeurs** et **écrit des applications à leur place** pour combler le manque ;
- malgré cela, le **nombre d'utilisateurs** restait trop faible pour que la plupart des entreprises investissent dans la plateforme.

**Pourquoi elle est classée en premier.**
- C'est la cause que **Microsoft invoque elle-même** au moment d'abandonner la plateforme.
- Les deux autres causes **agissent à travers elle** : le retard et le modèle de licence ont freiné la croissance du parc d'utilisateurs, ce qui a alimenté le manque d'applications.
- C'est aussi la conclusion du cours : « Les systèmes ne meurent pas de leur technique, mais de leur écosystème » (séance 1, diapo 20).

---

## Cause n° 2 : stratégie et timing

**Ce qui s'est passé.** Microsoft arrive tard, puis change plusieurs fois de cap.
- **Une arrivée tardive.** Fin 2010, iOS et Android ont déjà deux à trois ans d'avance pour attirer utilisateurs, développeurs et opérateurs.
- **Des utilisateurs abandonnés.** En juin 2012, Microsoft annonce que les téléphones sous Windows Phone 7 ne recevront **pas** Windows Phone 8, qui repose sur un nouveau noyau et demande un nouveau matériel. Ils n'ont droit qu'à une version 7.8 partielle [3]. Les premiers acheteurs, les plus fidèles, voient leur téléphone dépassé au bout de deux ans environ.
- **Un rachat qui échoue.** Microsoft rachète la division appareils de Nokia : rachat annoncé le 3 septembre 2013, pour 5,44 milliards d'euros brevets compris, et finalisé en avril 2014 [4]. Le 8 juillet 2015, Microsoft passe une dépréciation d'environ 7,6 milliards de dollars sur cette activité et annonce jusqu'à 7 800 suppressions de postes, surtout dans les téléphones [5].

**Pourquoi elle est classée deuxième.** C'est elle qui explique **pourquoi l'écosystème n'a jamais atteint la masse critique** : on ne rattrape pas un effet de réseau en arrivant en dernier, puis en cassant la continuité pour ses propres utilisateurs. Mais ces erreurs auraient pu être surmontées si les applications avaient suivi. Elle reste donc une cause aggravante, pas la cause finale.

---

## Cause n° 3 : modèle de plateforme

**Ce qui s'est passé.** Le cours résume les modèles qui ont gagné : « Android : licence ouverte aux constructeurs. iOS : intégration totale. Les autres : ni l'un ni l'autre » (séance 1, diapo 6). Windows Phone est dans ce troisième cas.
- **Ce n'était pas un modèle ouvert comme Android.** Les constructeurs payaient une licence à Microsoft, alors qu'Android ne leur coûtait rien. Microsoft ne supprime ce coût qu'en avril 2014, pour les appareils de moins de 9 pouces [7][8], soit plus de trois ans après le lancement.
- **Ce n'était pas une intégration totale comme iOS.** Microsoft n'a contrôlé le matériel qu'en rachetant Nokia, en 2014. Les autres constructeurs avaient alors peu de raisons de continuer, ce qui a rendu la plateforme dépendante d'un seul fabricant.

**Pourquoi elle est classée troisième.** Le modèle de licence a **limité le nombre de constructeurs et de téléphones bon marché**, donc le nombre d'utilisateurs. C'est un frein réel, mais il a été levé en 2014 sans changer l'issue : c'est la preuve qu'il n'était pas décisif à lui seul.

---

## Synthèse et leçon pour CampusFlow

| Rang | Famille (cours) | Rôle dans la disparition |
|:--:|---|---|
| 1 | Écosystème d'applications | Cause finale, reconnue par Microsoft : pas assez d'utilisateurs pour attirer les applications |
| 2 | Stratégie et timing | Arrivée tardive, rupture avec WP7, rachat de Nokia déprécié : l'écosystème ne décolle pas |
| 3 | Modèle de plateforme | Licence payante, puis dépendance à Nokia : peu de constructeurs, peu de téléphones |

**Leçon pour notre projet :** il faut cibler les plateformes où se trouvent déjà les utilisateurs et un écosystème vivant, c'est-à-dire Android et iOS, plutôt que parier sur une plateforme minoritaire. C'est l'un des arguments du [paragraphe de décision](decision-campusflow.md).

## Sources

1. Fortune, article sur les déclarations de Joe Belfiore et la fin de Windows Phone, 9 octobre 2017. <https://fortune.com/2017/10/09/microsoft-windows-phone-dead/>
2. TechCrunch, « This is not a drill: Microsoft admits Windows Phone is dead for real », 9 octobre 2017. <https://techcrunch.com/2017/10/09/this-is-not-a-drill-microsoft-admits-windows-phone-is-dead-for-real/>
3. AnandTech, « Existing Windows Phone 7 devices will get updated to Windows Phone 7.8, not Windows 8 », juin 2012. <https://www.anandtech.com/show/6029>
4. Microsoft News Center, « Microsoft to acquire Nokia's devices & services business… », 3 septembre 2013. <https://news.microsoft.com/source/2013/09/03/microsoft-to-acquire-nokias-devices-services-business-license-nokias-patents-and-mapping-services/>
5. Microsoft News Center, « Microsoft announces restructuring of phone hardware business », 8 juillet 2015. <https://news.microsoft.com/source/2015/07/08/microsoft-announces-restructuring-of-phone-hardware-business/>
6. Microsoft Learn, « Support ending for Windows 10 Mobile ». <https://learn.microsoft.com/en-us/lifecycle/announcements/windows-10-mobile-end-of-support>
7. Microsoft News Center, « Microsoft showcases latest updates to Windows, opportunities for developers », 3 avril 2014. <https://news.microsoft.com/source/2014/04/03/microsoft-showcases-latest-updates-to-windows-opportunities-for-developers/>
8. Windows Central, « Microsoft drops Windows royalty fee for devices with screens under nine inches », avril 2014. <https://windowscentral.com/windows-drops-royalty-fee-devices-screens-under-nine-inches>
9. COMPAORE M., *Programmation mobile, séance 1 : Écosystème mobile*, U-AUBEN, 2026 : diapos 4, 6 et 20.
