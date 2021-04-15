![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Prescriptions spécifiques (locales) pour la gestion des données du réseau de transport urbain de l'Agglomération de la Région de Compiègne (TIC)
[ ] à rédiger [x] en cours de rédaction [ ] finaliser

Ensemble des éléments constituant la mise en oeuvre de la base de données sur la mobilité ainsi que l'exploitation des données dans l'application dédiée.

- Script d'initialisation de la base de données
  * [Suivi des modifications](bdd/tic_00_trace.sql)
  * [Création  de la structure initiale](bdd/tic_10_squelette.sql)
  * [Création des vues de gestion](bdd/tic_20_vues_gestion.sql)
  * [Création des vues applicatives](bdd/tic_21_vues_xapps.sql)
  * [Création des vues OpenData](bdd/tic_23_vues_xopendata.sql)
  * [Création des privilèges](bdd/tic_99_grant.sql)
- Documentation d'administration de la base
- Documentation d'administration de l'application


## Contexte

L’ARC est engagée dans un plan de modernisation numérique pour l’exercice de ses missions de services publics. L’objectif poursuivi vise à permettre à la collectivité de se doter d’outil d’aide à la décision et d’optimiser l’organisation de ses services. Ces objectifs se déclinent avec la mise en place d’outils informatiques adaptés au quotidien des services et le nécessaire retour auprès de la collectivité, des informations (données) produites et gérées par ses prestataires. 

L’ARC privilégie donc une organisation dans laquelle l’Interface Homme Machine (IHM) du métier assure l’alimentation d’un entrepôt de données territoriales. Cette stratégie « agile » permet de répondre au plus près des besoins des services dans une trajectoire soutenable assurant à la fois une bonne maitrise des flux d’information et un temps d’acculturation au sein de l’organisation.

## Voir aussi

- [Portail des normes pour les données d'offre du transport collectif](http://www.normes-donnees-tc.org/)

## Jeu de données consolidé

Vous pouvez retrouver le jeu de données sur les lignes du réseau de l'Agglomération de la Région en cliquant [ici](https://geo.compiegnois.fr/geonetwork/srv/fre/catalog.search#/metadata/e32c4bdb-5103-4f0b-a83b-64ffaca59879). Ce jeu de données vous donnera accès également aux arrêts logiques et physiques.


