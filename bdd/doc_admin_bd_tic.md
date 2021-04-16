![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base de données des données du réseau de transport urbain de l'Agglomération de la Région de Compiègne (TIC) #

## Principes
 ### Généralité
 
(à rédiger)
 
 ### Résumé fonctionnel
 
(à rédiger)

## Schéma fonctionnel

(à faire)

## Modèle relationnel simplifié

(à faire)


## Dépendances

La base de données du réseau de transport urbain s'appuie sur des référentiels préexistants constituant autant de dépendances nécessaires pour l'implémentation de la base PEI.

|schéma | table | description | usage |
|:---|:---|:---|:---|   
|r_objet|lt_src_geom|domaine de valeur générique d'une table géographique|référentiel utilisé pour la saisie des données|
|r_objet|geo_objet_troncon|Classe décrivant un troncon du filaire de voie à circulation terrestre|urbanisation des tronçons de voie de la base de données locales des voies pour la regénération des tracés de lignes|

---

## Classes d'objets

L'ensemble des classes d'objets unitaires sont stockées dans le schéma m_mobilite, celles dérivées et applicatives dans le schéma `x_apps`, celles dérivées pour les exports opendata dans le schéma `x_opendata` et celles dérivées pour l'exploitation dans l'application Grand Public Plan Interactif dansle schéma `x_apps_public`.

### Classe d'objet géographique et patrimoniale

`geo_dec_pav_lieu` : table géographique des lieux de collecte.

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  


* triggers :

  * `t_t1_geo_dec_pav_lieu_datemaj` : intégration de la date de mise à jour
  

  
### classes d'objets applicatives de gestion :

Sans objet

---

### classes d'objets applicatives métiers sont classés dans le schéma x_apps :
 
`x_apps.xapps_geo_v_dec_pav_lieu_orient` : Vue géométrique des liens entre les lieux de collecte supprimés, déplacés (nouvel emplacement)



### classes d'objets applicatives grands publics sont classés dans le schéma x_apps_public :

`x_apps_public.xappspublic_geo_dec_pav_verre` : Vue géographique présentant les données servant à l''export pour l''appli Gd Public des conteneurs verres 


### classes d'objets opendata sont classés dans le schéma x_opendata :

(à produire)

## Liste de valeurs

`lt_pav_contpos` : Liste permettant de décrire les types de position du conteneur'

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|code du type de position du conteneur|character varying(2)| |
|valeur|libellé du type de position du conteneur|character varying(30)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|10|Aérien|
|20|Enterré|
|00|Non renseigné|
|30|Semi-enterré|

---




---

## Log

Sans objet

## Erreur

Sans objet

---

## Projet QGIS pour la gestion

(à intégrer)

## Traitement automatisé mis en place (Workflow de l'ETL FME)

### Production des plans de lignes numériques

(à intégrer)

## Export Grand Public

Cet export est géré dans le Workflow global d'envoi des données à la base déportée de GEO pour l'alimentation de l'application Plan Intéractif.

## Export Open Data

Cet export est géré dans le Workflow global d'envoi des données à la base déportée de GEO pour l'alimentation de l'application Plan Intéractif.

---

