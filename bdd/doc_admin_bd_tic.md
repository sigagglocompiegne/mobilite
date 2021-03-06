![picto](https://github.com/sigagglocompiegne/orga_gest_igeo/blob/master/doc/img/geocompiegnois_2020_reduit_v2.png)

# Documentation d'administration de la base de données des données du réseau de transport urbain de l'Agglomération de la Région de Compiègne (TIC) #

## Principes

 ### Généralité
 
En 2016, la migration de l'infrastructure SIG de l'Agglomération de la Région de Compiègne a permis de réfléchir sur les données du réseau de transport. Avant, seules les données concernant les arrêts physiques étaient gérées par le service. Cette migration a mis en oeuvre une réflexion plus globale (lignes, dessertes, arrêts logiques et physiques) s'appuyant sur une norme amorcée par l'AFIMB et suivi par le [CERAMA](http://www.normes-donnees-tc.org/).

 ### Résumé fonctionnel
 
La base de données est principalement mise à jour par le service de l'information géographique concernant la saisie des tracés des lignes, qui s'appuie sur le référentiel des voies propre à l'Agglomération de la Région de Compiègne, l'insertion et la modification des arrêts (logiques ou physiques) ainsi que l'identification  des dessertes. Les données du patrimoine des arrêts physiques sont gérées par le service métier à travers l'application Web qui a été mise en oeuvre.

## Schéma fonctionnel

(à faire)

## Modèle relationnel simplifié

![picto](mcd_tic.png)


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

`geo_mob_rurbain_la` : Table géométrique contenant les informations des lieux d'arrêt ou point logique des arrêts du réseau de transport collectif de l'Agglomération de la Région de Compiègne (utilisation du modèle d'arrêt AFIMB de juin 2014)

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_la|Identifiant des leiux d'arrêt suivant la proposition de codification de mai 2014 (utilisation du modèle d'arrêt AFIMB de juin 2014 - (FR:insee:LA:id local:LOC))|character varying(30)| |
|date_sai|date de saisie de l'information|timestamp without time zone|now()|
|date_maj|date de mise à jour de l'information|timestamp without time zone| |
|modification|nature de la dernière modification (liste de valeur lt_mob_rurbain_modification)|character varying(2)|'00'::character varying|
|statut|statut de la ze (actif ou inactif) (référence à une table de valeur lt_mob_rurbain_statut)|character varying(2)|'10'::character varying|
|nom|nom de la zone d'embarquement (selon la charte de dénomination des arrêts)|character varying(50)| |
|nom_court|nom court de la zone d'embarquement|character varying(50)| |
|description|description libre de la zone d'embarquement|character varying(255)| |
|x_l93|Coordonnée X en mètre|numeric| |
|y_l93|Coordonnée Y en mètre|numeric| |
|date_deb|date de début d'utilisation de la ze par les voyageurs|timestamp without time zone| |
|date_fin|date de fin d'utilisation de la ze par les voyageurs|timestamp without time zone| |
|hierarchie|type hiérarchique du lieu d'arrêt ((référence à une table de valeur lt_mob_rurbain_hierarchie)|character varying(2)|'10'::character varying|
|insee|code insee de la commune|character varying(5)| |
|commune|libellé de la commune|character varying(80)| |
|id_parent|identifiant du lieux d'arrêt parent (Arrêt monomodal = Arrêt multimodal ou pôle monomodal, Pole monomodal = lieu d'arrêt multimodal, Arrêt multimodal = pas de parent)|character varying(30)| |
|latype|Type de lieux d'arrêt (référence à une table de valeur lt_mob_rurbain_latype)|character varying(2)|'10'::character varying|
|sens|Libellé du sens du tronçon par rapport à la desserte en transport|character varying(2)|'00'::character varying|
|angle|Angle pour la représentation de la flèche définissant le sens de desserte|integer|0|
|observ|Observations diverses|character varying(255)| |
|geom|géométrie des objets|USER-DEFINED| |
|v_tampon|Valeur du tampon autour d'un arrêt de transport pour exploitation des recherches d'adresse dans l'application Geo Gd Public (Plan interactif de l'Agglomération de la Région de Compiègne)|integer| |
|geom2|Champ géométrique contenant le tampon de rayonnement de l'arrêt pour exploitation des recherches par adresse dans l'application Geo Gd Public (Plan interactif de l'Agglomération de la Région de Compiègne). Ce champ est mis à jour selon la valeur du champ v_tampon par un trigger (par défaut le tampon est de 200mètres)|USER-DEFINED| |

* triggers :

  * `t_t1_geo_mob_rurbain_la` : gestion de la date de mise à jour
  * `t_t2_geo_mob_rurbain_la_insee_commune` : récupération automatique des codes insee et des libellés de communes
  * `t_t3_geo_mob_rurbain_la` : calcul automatique des zones tampons autour des points
  * `t_t6_geo_mob_rurbain_ze_xy` : calcul automatique des coordonnées X et Y des points

---

`geo_mob_rurbain_ze` : Table géométrique contenant les informations des zones d'embarquement ou point physique des arrêts du réseau de transport collectif de l'Agglomération de la Région de Compiègne (utilisation du modèle d''arrêt AFIMB de juin 2014)

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_ze|Identifiant des zones d'embarquement suivant la proposition de codification de mai 2014 (utilisation du modèle d'arrêt AFIMB de juin 2014 - (FR:insee:ZE:id local:LOC))|character varying(30)| |
|date_sai|date de saisie de l'information|timestamp without time zone|now()|
|date_maj|date de mise à jour de l'information|timestamp without time zone| |
|op_sai|opérateur de saisie|character varying(50)| |
|modification|nature de la dernière modification (liste de valeur lt_mob_rurbain_modification)|character varying(2)|'00'::character varying|
|src_geom|référentiel de saisie (liste de valeur lt_src_geom du schéma r_objet)|character varying(2)|'00'::character varying|
|statut|statut de la ze (actif ou inactif) (référence à une table de valeur lt_mob_rurbain_statut)|character varying(2)|'10'::character varying|
|nom|nom de la zone d'embarquement (selon la charte de dénomination des arrêts)|character varying(50)| |
|nom_court|nom court de la zone d'embarquement|character varying(50)| |
|description|description libre de la zone d'embarquement|character varying(255)| |
|x_l93|Coordonnée X en mètre|numeric| |
|y_l93|Coordonnée Y en mètre|numeric| |
|z_ngf|Altimétrie ngf du noeud en mètre|numeric| |
|date_deb|date de début d'utilisation de la ze par les voyageurs|timestamp without time zone| |
|date_fin|date de fin d'utilisation de la ze par les voyageurs|timestamp without time zone| |
|acces_ufr|accès possible en fauteuil roulant|boolean|false|
|sign_audi|indique la présence d'une signalisation auditive disponible|boolean|false|
|sign_visu|indique la présence d'une signalisation visuelle disponible|boolean|false|
|insee|code insee de la commune|character varying(5)| |
|commune|libellé de la commune|character varying(80)| |
|id_la|identifiant du lieux d'arrêt parent|character varying(30)| |
|mtransport|Mode de transport principal|character varying(2)|'20'::character varying|
|smtransport|Sous-mode de transport|character varying(2)|'00'::character varying|
|autransport|autre mode de transport desservant la zone d'embarquement|character varying(100)| |
|zetype|Type de zone d'embarquement|character varying(2)|'40'::character varying|
|observ|Observations diverses|character varying(255)| |
|geom|géométrie des objets|USER-DEFINED| |
|ppub|Existence d'une publicité|boolean|false|

* triggers :

  * `t_t1_geo_mob_rurbain_ze` : gestion des données en cas d'insertion
  * `t_t2_geo_mob_rurbain_ze_delete` : gestion des données en cas de suppression
  * `t_t3_geo_mob_rurbain_ze_datemaj` : gestion de la date de mise à jour
  * `t_t4_geo_mob_rurbain_ze_datesai` : gestion de la date de saisie
  * `t_t5_geo_mob_rurbain_ze_insee_commune` : récupération des codes insee et des libellées de communes
  * `t_t6_geo_mob_rurbain_ze_xy` : calcul automatique des coordonnées X et Y des points
  * `t_t7_geo_vmr_tic_zela` : mise à jour du lien entre le lieu d'arrêt et les zones d'embarquement
  * `t_t8_geo_vmr_tic_ze_chalandise` : mise à jour des aires de chalendises
  * `t_t9_geo_vmr_tic_ze_nav` : mise à jour des données affichées dans la visionneuse
  * `t_t9_tab` : mise à jour des vues initialisant les indicateurs dans le tableau de bord


---

`an_mob_rurbain_passage` : Table permettant de déterminer les lignes en desserte au niveau des zones d'embarquement et des lieux d'arrêt

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|  
|id_en|Identifiant du passage|integer|nextval('m_mobilite.an_mob_rurbain_passage_iden_seq'::regclass)|
|id_ze|Identifiant des zones d'embarquement ou des localisations d'arrêt suivant la proposition de codification de mai 2014 (FR:[insee]:ZE:[id local]:LOC ou FR:insee:LA:id local:LOC)|character varying(30)| |
|id_ligne|Identifiant unique de la ligne|character varying(30)| |
|date_sai|date de saisie de l'information|timestamp without time zone|now()|
|date_maj|date de mise à jour de l'information|timestamp without time zone| |
|op_sai|opérateur de saisie|character varying(50)| |
|t_passage|type de passage (référence à une table de valeur lt_mob_rurbain_t_passage)|character varying(2)| |
|direction|libellé du terminus de direction|character varying(2)|'00'::character varying|

* triggers :

  * `t_t1_an_mob_rurbain_passage_datemaj` : gestion de la date de mise à jour
  * `t_t2_an_mob_rurbain_passage_datesai` : gestion de la date de saisie

---

`an_mob_rurbain_passage` : Table alphanumérique contenant l'ensemble des lignes urbaines, inter-urbaine, TAD et scolaire du réseau de transport collectif de l'ARC

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|
|id_ligne|Identifiant unique de la ligne|character varying(30)| |
|lib_res|libellé du réseau d'appartenance de la ligne|character varying(10)| |
|lib_exploi|Libellé de l'exploitant|character varying(50)| |
|lib_aot|Libellé de l'autorité organisatrice des transports|character varying(20)|'00'::character varying|
|nom_court|libellé court de la ligne (n°)|character varying(40)| |
|nom_ligne|Libellé de la ligne|character varying(255)| |
|acces_pmr|ligne accéssible aux personnes à mobilité réduite|boolean|false|
|genre|genre de la ligne (référence à une table de valeur lt_mob_rurbain_genre)|character varying(2)|'00'::character varying|
|fonct|période de fonctionnement (référence à une table de valeur lt_mob_rurbain_fonct)|character varying(2)|'00'::character varying|
|date_sai|date de saisie de l'information|timestamp without time zone|now()|
|date_maj|date de mise à jour de l'information|timestamp without time zone| |
|op_sai|opérateur de saisie ou de mise à jour de l'information|character varying(50)| |
|observ|Observations diverses|character varying(255)| |

* triggers :

  * `t_t1_an_mob_rurbain_ligne_datemaj` : gestion de la date de mise à jour
  * `t_t2_an_mob_rurbain_ligne_datesai` : gestion de la date de saisie
  * `t_t3_an_mob_rurbain_ligne_insert` : gestion des données à l'insertion d'une nouvelle ligne

---

`an_mob_rurbain_docze` : Table gérant la liste des documents associés à une zone d'embarquement

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|
|id|Identifiant de l'itinéraire|character varying(30)| |
|media|Champ Média de GEO|text| |
|miniature|Champ miniature de GEO|bytea| |
|n_fichier|Nom du fichier|text| |
|t_fichier|Type de média dans GEO|text| |
|op_sai|Libellé de l'opérateur ayant intégrer le document|character varying(100)| |
|date_sai|Date d'intégration du document|timestamp without time zone| |

* triggers :

  * `t_t1_an_mob_3v_planvelo_doc_media_date_sai` : gestion de la date de saisie

---

`an_mob_rurbain_docligne` : Table alphanumérique contenant les documents relatifs à ligne de transport (plusieurs documents peuvent être rattachés à une ligne (horaire, plan, ...)

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|
|id_doc|Identifiant unique|integer|nextval('m_mobilite.an_mob_rurbain_docligne_iddoc_seq'::regclass)|
|id_ligne|Identifiant unique de la ligne|character varying(30)| |
|date_sai|date de saisie de l'information|timestamp without time zone|now()|
|date_maj|date de mise à jour de l'information|timestamp without time zone| |
|date_dutil|date de début d'application des fiches horaires|timestamp without time zone| |
|date_futil|date de fin d'application des fiches horaires|timestamp without time zone| |
|op_sai|opérateur de saisie ou de mise à jour de l'information|character varying(50)| |
|n_fichier|nom du fichier (avec extension)|character varying(100)| |
|l_fichier|Descriptif du fichier|character varying(255)| |
|observ|Observations diverses|character varying(255)| |

* triggers :

  * `t_t1_an_mob_rurbain_docligne_datemaj` : gestion de la date de mise à jour
  * `t_t2_an_mob_rurbain_docligne_datesai` : gestion de la date de saisie


---

`lk_voirie_rurbain` : Table alphanumérique de liaison entre les tronçons de voies et lignes urbaines, interurbaines, TAD et scolaire du réseau de transport collectif de l'ARC

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|
|id_tronc|Identifiant du tronçon voirie (issu de la table geo_objet_troncon)|bigint| |
|id_ligne|Identifiant unique de la ligne|character varying(30)| |
|sens|Indique le sens de desserte de la ligne (référence à une table de valeur lt_mob_rurbain_sens)|character varying(2)|'00'::character varying|
|desserte|Détermine la typologie de desserte de la ligne (référence à une table de valeur lt_mob_rurbain_desserte)|character varying(2)|'00'::character varying|
|statut|statut du tronçon par rapport à la ligne (actif ou inactif) (référence à une table de valeur lt_mob_rurbain_status)|character varying(2)|'00'::character varying|
|date_sai|date de saisie de l'information|timestamp without time zone|now()|
|date_maj|date de mise à jour de l'information|timestamp without time zone| |
|n_car|Numéro des cars des lignes péri-urbaines desservis sur le tronçon. Ce numéro est composé du numéro de la igne et du numéro du car (ex : 10111, car 11 de la igne 101)|character varying(100)| |

* triggers :

  * `t_t2_lk_voirie_rurbain_datemaj` : gestion de la date de mise à jour
  * `t_t1_lk_voirie_rurbain_datesai` : gestion de la date de saisie


## Liste de valeurs

`lt_mob_rurbain_desserte` : Liste de valeurs du type de desserte de l'offre de transport

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du type de desserte du tronçon par le réseau de transport|character varying(2)| |
|valeur|Libellé du type de desserte du tronçon par le réseau de transport|character varying(30)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Principale|
|20|Variante|
|30|AlloTic|
|40|Haut-le-pied|

---

`lt_mob_rurbain_fonct` : Liste de valeurs des jours de fonctionnement

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des jours de fonctionnement|character varying(2)| |
|valeur|Libellé des jours de fonctionnement|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|du lundi au Samedi|
|20|le dimanche et les jours fériés (sauf l'été, le 1er mai, 25 décembre, 1er janvier)|
|12|du lundi au samedi (en période scolaire)|
|14|du lundi au vendredi (sauf en août)|
|16|le mercredi et le samedi (en période scolaire)|
|17|le lundi, mardi, jeudi et vendredi (en période scolaire)|
|40|En période scolaire|
|50|les jours de marché|
|80|du lundi au samedi (sur réservation)|
|24|le samedi soir|
|81|du lundi au samedi (cf fiche horaire pour les jours de fonctionnement)|
|19|le mercredi (période scolaire)|
|2|du lundi au samedi (vacances scolaires uniquement)|
|82|du lundi au vendredi (en période scolaire)|
|ZZ|Plus en service|

---

`lt_mob_rurbain_genre` : Liste de valeurs du genre de ligne de transport

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du genre de ligne de transport|character varying(2)| |
|valeur|Libellé du genre de ligne de transport|character varying(30)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Urbain|
|20|Péri-Urbain|
|30|TAD|
|40|Scolaire|
|50|DJF|

---

`lt_mob_rurbain_hierarchie` : Liste des types de hiérarchie des points d'arrêt

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des hiérarchies|character varying(2)| |
|valeur|Libellé des hiérarchies|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Lieu d'arrêt MONOMODAL|
|20|POLE MONOMODAL|
|30|Lieu d'arrêt MULTIMODAL|

---

`lt_mob_rurbain_latype` : Liste de valeurs des types de lieux d'arrêt

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du type du lieu d'arrêt|character varying(2)| |
|valeur|Libellé du type du lieu d'arrêt|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Arrêt de bus sur la voirie|
|20|Gare routière|
|30|Station d'autocars|

---

`lt_mob_rurbain_modification` : Liste de valeurs de la nature de la dernière modification d'une donnée zone d'embarquement

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code de la nature de la dernière modification|character varying(2)| |
|valeur|Libellé de la nature de la dernière modification|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Création|
|20|Mise à jour|
|30|Suppression|

---

`lt_mob_rurbain_mtransport` : Liste de valeurs des modes de transport (principaux ou en sous-mode)

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des modes de transport|character varying(2)| |
|valeur|Libellé des modes de transport|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|20|Bus|
|21|Car|
|60|Taxi|
|70|Minibus|

---

`lt_mob_rurbain_passage` : Liste de valeurs des types de passage aux zones d'embarquement ou aux lieux d'arrêt

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des types de passage|character varying(2)| |
|valeur|Libellé des types de passage|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Simple passage|
|31|Terminus (départ variante)|
|32|Terminus (arrivée variante)|
|21|Terminus (départ)|
|22|Terminus (arrivée)|
|40|Dépose uniquement|

---

`lt_mob_rurbain_sens` : Liste de valeurs du sens de desserte de l'offre de transport

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du sens du tronçon par rapport à la desserte en transport|character varying(2)| |
|valeur|Libellé du sens du tronçon par rapport à la desserte en transport|character varying(30)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Aller-Retour|
|20|Aller|
|30|Retour|

---

`lt_mob_rurbain_statut` : Liste de valeurs du statut du tronçon desservit par une offre de transport

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code du statut de la version du tronçon sur la desserte en offre de transport|character varying(2)| |
|valeur|Libellé du statut de la version du tronçon sur la desserte en offre de transport|character varying(30)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Actif|
|20|Inactif|
|30|Projet|

---

`lt_mob_rurbain_t_doc` : Liste de valeurs des types de doucment rattaché aux zones d'embarquement

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des types de doucment rattaché aux zones d'embarquement|character varying(2)| |
|valeur|Libellé des valeurs des types de doucment rattaché aux zones d'embarquement|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|10|Photographie|
|20|Fiche(s) horaire(s)|

---

`lt_mob_rurbain_terminus` : Liste des libellés de terminus des lignes de transport

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des terminus|character varying(2)| |
|valeur|Libellé des terminus|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|01|Gare|
|02|Hôpital|
|03|Bellicart|
|04|Marronniers|
|05|Port à Carreaux|
|06|Ouïnels|
|07|Palais|
|08|Centre Commercial Jaux-Venette|
|09|Ferdinand de Lesseps|
|11|Hauts de Margny|
|12|Ouïnels - Port à Carreaux|
|13|Bellicart - Marroniers|
|14|Ferdinand de Lesseps - Hôpital|
|17|Compiègne - Gare Routière|
|18|Collège Ferdinand Bac|
|22|Gare - Multiplexe|
|23|Multiplexe|
|24|St-Jean-aux-Bois - La Brévière|
|25|St-Sauveur - Eglise|
|28|Bienville|
|39|Ecole des Bruyères|
|43|Le Meux - Centre|
|21|Choisy-au-Bac - Sergenteret|
|52|Jaux - Varanval|
|53|Lacroix-St-Ouen - Mairie|
|41|Le Meux - Croisette|
|19|Collège Debussy|
|15|ZI Le Meux - Petite Prée|
|57|St-Sauveur - Mabonnerie|
|58|Lachelle - Place|
|55|Janville - Ile J.Lenoble|
|30|Jonquières - Château|
|60|Gare - Palais|
|56|Compiègne - Armistice|
|61|Vers Compiègne|
|62|Depuis Compiègne|
|63|Choisy-au-Bac|
|40|Collège Jules Verne|
|54|Hameau de Mercières|
|64|Jonquières - Ecole|
|27|Janville - Mairie|
|65|Choisy-au-Bac - Linières|
|90|(dépose uniquement)|
|66|Verberie - Aramont|
|67|St-Vaast-de-Longmont - Mairie|
|68|Camp des Sablons|
|69|Les Lycées|
|70|Bois de Plaisance|
|36|Guy Deniélou|
|71|Verberie - Mairie|
|72|Néry - Eglise|

---

`lt_mob_rurbain_zetype` : Liste de valeurs des types de zones d'embarquement

|Nom attribut | Définition | Type  | Valeurs par défaut |
|:---|:---|:---|:---|    
|code|Code des types|character varying(2)| |
|valeur|Libellé des types de zones d'embarquement|character varying(100)| |


Particularité(s) à noter : aucune


Valeurs possibles :

|code | valeur |
|:---|:---|  
|00|Non renseigné|
|40|Arrêt de bus, autocar (avec poteau)|
|41|Arrêt de bus, autocar (avec abris)|
|42|Quai de bus, autocar (avec poteau)|
|43|Quai de bus, autocar (avec abris)|
|44|Arrêt de bus, autocar (zébra seul)|
|45|Arrêt de bus, autocar (sans matérialisation)|
|48|Arrêt de bus, autocar (avec panneau routier)|
|46|Arrêt de bus, autocar (BIV seule)|
|47|Quai de bus, autocar (BIV seule)|
|50|Arrêt de bus, autocar (abris avec BIV)|
|51|Quai de bus, autocar (abris avec BIV)|
|49|Arrêt de bus, autocar (sur panneau routier)|

## classes d'objets applicatives de gestion :

`geo_v_tic_gestion_desserte_ze` : Vue éditable pour la gestion des dessertes de ligne aux zones d''embarquement

`geo_v_tic_gestion_doc_ze` : Vue éditable pour la gestion des documents liés aux zones d''embarquement

`geo_v_tic_gestion_ligne` : Vue éditable pour la gestion des données des lignes du réseau TIC (ajout, modification ou suppression de la desserte des tronçons du référentiel de voiries)

`geo_v_tic_gestion_ligne_insert` : Vue éditable pour la gestion des données des lignes du réseau TIC (uniquement ajout de la desserte des tronçons du référentiel de voiries)

`geo_v_tic_ligne_plan` : Vue regroupant le tracé de toutes les lignes pour aides à l'affichage du QGIS de gestion des données du réseau TIC (filtre par n° de ligne)

---

## classes d'objets applicatives métiers sont classés dans le schéma x_apps :
 
`x_apps.an_vmr_rurbain_tab1` : Vue matérialisée rafraichie formatant la liste des lignes de bus urbaines pour recherche par ligne dans GEO

`x_apps.an_vmr_rurbain_tab2` : Vue matérialisée rafraichie contenant le nombre d'arrêt par type pour le TAB dans GEO

`x_apps.xapps_geo_vmr_tic_desserte` : Vue géométrique pour la gestion des dessertes aux zones d'embarquement

`x_apps.xapps_geo_vmr_tic_desserte_descente` : Vue géométrique pour la gestion des dessertes aux zones d'embarquement (descente uniquement)

`x_apps.xapps_geo_vmr_tic_djf_la_a` : Vue géométrique des lieux d'arrêt (sens aller ou retour) des lignes Dimanches et Jours fériés du réseau TIC

`x_apps.xapps_geo_vmr_tic_djf_la_ar` : Vue géométrique des lieux d'arrêt (sens aller et retour) des lignes Dimanches et Jours fériés du réseau TIC

`x_apps.xapps_geo_vmr_tic_la_eti_arretdjf` : Vue géographique représentant les noms des lieux d''arrêts des lignes DJF pour l'affichage dans GEO

`x_apps.xapps_geo_vmr_tic_la_eti_arretla` : Vue géographique représentant les noms des lieux d'arrêts des LU pour l'affichage dans GEO

`x_apps.xapps_geo_vmr_tic_la_eti_arretpu` : Vue géographique représentant les noms des lieux d'arrêts des lignes PU pour l'affichage dans GEO

`x_apps.xapps_geo_vmr_tic_la_eti_arretsco` : Vue géographique représentant les noms des lieux d'arrêts des lignes scolaires pour l'affichage dans GEO

`x_apps.xapps_geo_vmr_tic_la_eti_arrettad` : Vue géographique représentant les noms des lieux d'arrêts des lignes AlloTIC pour l'affichage dans GEO

`x_apps.xapps_geo_vmr_tic_la_eti_terminus` : Vue géographique représentant les terminus LU avec leur nom et ligne associée

`x_apps.xapps_geo_vmr_tic_la_eti_terminus_djf` : Vue géographique représentant les terminus des lignes du dimanche et jours fériés avec leur nom et ligne associée

`x_apps.xapps_geo_vmr_tic_la_eti_terminus_pu` : Vue géographique représentant les terminus des lignes péri-urbaines avec leur nom et ligne associée

`x_apps.xapps_geo_vmr_tic_la_eti_terminus_sco` : Vue géographique représentant les terminus des lignes scolaires avec leur nom et ligne associée

`x_apps.xapps_geo_vmr_tic_la_eti_terminus_tad` : Vue géographique représentant les terminus des lignes AlloTIC avec leur nom et ligne associée

`x_apps.xapps_geo_vmr_tic_ligne_plan` : Vue matérialisée rafraichie formatant la liste des lignes de bus du réseau TIC pour la recherche par ligne dans GEO et le TAB

`x_apps.xapps_geo_vmr_tic_lu_la_a` : Vue géométrique des lieux d''arrêt (sens aller ou retour) des lignes urbaines du réseau TIC

`x_apps.xapps_geo_vmr_tic_lu_la_ar` : Vue géométrique des lieux d'arrêt (sens aller et retour) des lignes urbaines du réseau TIC

`x_apps.xapps_geo_vmr_tic_pu_la_a` : Vue géométrique des lieux d'arrêt (sens aller ou retour) des lignes PU du réseau TIC

`x_apps.xapps_geo_vmr_tic_pu_la_ar` : Vue géométrique des lieux d'arrêt (sens aller et retour) des lignes PU du réseau TIC

`x_apps.xapps_geo_vmr_tic_sco_la_a` : Vue géométrique des lieux d'arrêt (sens aller ou retour) des lignes scolaires du réseau TIC

`x_apps.xapps_geo_vmr_tic_sco_la_ar` : Vue géométrique des lieux d'arrêt (sens aller et retour) des lignes scolaires du réseau TIC

`x_apps.xapps_geo_vmr_tic_tad_la` : Vue géométrique des lieux d'arrêt des lignes AlloTic (TAD) du réseau TIC

`x_apps.xapps_geo_vmr_tic_ze` : Vue géométrique des zones d'embarquement des lignes du réseau TIC

`x_apps.xapps_geo_vmr_tic_ze_200m` : Vue matérialisée rafraichie (trigger de rafraichissement si données ZE ou passage MAJ) géométrique des zones de chalandise (200m) de chaque arrêt actif

`x_apps.xapps_geo_vmr_tic_ze_500m` : Vue matérialisée rafraichie (trigger de rafraichissement si données ZE ou passage MAJ) géométrique des zones de chalandise (500m) de chaque arrêt actif

`x_apps.xapps_geo_vmr_tic_ze_nav` : Vue matérialisée rafraichie (trigger de rafraichissement si données ZE ou passage MAJ) géométrique des zones d''embarquement avec les lignes en desserte du réseau TIC pour exploitation dans le navigateur carto (recherche et affichage)

`x_apps.xapps_geo_vmr_tic_zela` : Vue géométrique des liens entre ZE et LA


## classes d'objets applicatives grands publics sont classés dans le schéma x_apps_public :

`x_apps_public.xappspublic_an_v_tic_la_gdpu` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes en desserte du réseau TIC (intégré au FME export pour l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle)

`x_apps_public.xappspublic_an_v_tic_la_gdpu_djf` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes dimanche et jours fériés en desserte du réseau TIC (intégré à la vue xapps_an_v_tic_la_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes urbaines (1 à 6) en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes urbaines (ARC Express et HM) en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_la_gdpu_pu` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes péri_urbain (hors ARC Express) en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_la_gdpu_sco` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_la_gdpu_tad` : Vue alphanumétique des lieux d'arrêt avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_ze_gdpu` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes en desserte du réseau TIC  (intégré au FME d'export pour l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle)

`x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes dimanche et jours fériés en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes urbaines (1 à 6) en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes urbaines (ARC Express et HM) en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes péri_urbain (hors ARC Express) en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad` : Vue alphanumétique des zones d'embarquement avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l'application GEO Gd Public pour l'affichage des lignes dans les résultats de recherche et info-bulle

`x_apps_public.xappspublic_geo_v_tic_la_tampon` : Vue géométrique contenant les tampons d'emprise des lieux d'arrêt pour EXPORT FME et recherche des adresse dans ses tampons pour remonter l'arrêt et les lignes en desserte

`x_apps_public.xappspublic_geo_v_tic_ze_gdpu` : Vue géométrique des zones d'embarquement avec les lignes en desserte du réseau TIC (intégré  au FME d'export pour exploitation dans l'application grand public Plan d'Agglomération Interactif (fiche information))

`x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf` : Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes Dimanche et jours fériés. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l'affichage de la fiche info dans l'application grand public Plan d'Agglo interactif

`x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu` : Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes urbaines. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l'affichage de la fiche info dans l''application grand public Plan d'Agglo interactif

`x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu` : Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes péri-urbaines. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l'affichage de la fiche info dans l'application grand public Plan d'Agglo interactif

`x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco` : Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes scolaires. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l'affichage de la fiche info dans l'application grand public Plan d'Agglo interactif


`x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad` : Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes AlloTic. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l'affichage de la fiche info dans l'application grand public Plan d'Agglo interactif


## classes d'objets opendata sont classés dans le schéma x_opendata :

`x_apps_public.xopendata_geo_vmr_tic_ligne` : Vue géométrique sur l'iténaire de toutes les lignes du réseau TIC (pour export téléchargement métadonnée)

---

## Log

Sans objet

## Erreur

Sans objet

---

## Projet QGIS pour la gestion

Un projet sous QGIS 2.14 a été réalisé pour gérer les lieux d'arrêt, les zones d'embarquement, le tracé des lignes et les dessertes aux zones d'embarquement
R:\Projets\Metiers\1608TRA-ARC-RefTransportCollectif\04-Base de données\2016-08-10_Test_Gestion_Tic.qgs

Ce projet sera ultérieurement intégré dans l'espace des procédures partagées après finalisation.

## Traitement automatisé mis en place (Workflow de l'ETL FME)

### Production des plans de lignes numériques

Un traitement a été réalisé pour chaque type de réseau afin de produire un plan numérique des lignes avec les décalages lorsque celles-ci ont un parcours commun.
Ce traitement fera l'objet d'amélioration continue afin de mieux apparéhender ces décalages.

Ces traitements sont stockés ici :

R:\Ressources\4-Partage\3-Procedures\FME\prod\MOB

* TIC_plan_reseau_bus_djf.fmw : pour le plan du réseau du dimanche et des jours fériés

* TIC_plan_reseau_bus_interurbain.fmw : pour le plan du réseau péri-urbain

* TIC_plan_reseau_bus_scolaire.fmw : pour le plan du réseau solaire

* TIC_plan_reseau_bus_tad.fmw : pour le plan du réseau AlloTic

* TIC_plan_reseau_bus_urbain.fmw : pour le plan du réseau urbain


### Export Grand Public

Cet export est géré dans le Workflow global d'envoi des données à la base déportée de GEO pour l'alimentation de l'application Plan Intéractif. Par défaut la partie concernant les données du réseau ne sont pas activés. Il sont activés manuellement pour un envoi ponctuel lors des mises à jour.

R:\Ressources\4-Partage\3-Procedures\FME\prod\APPS_GD_PUBLIC\PLAN_INTERACTIF.fmw

### Export Open Data

Cet export est géré dans un workflow spécifique non automatisé. Il est lancé manuellement après la mise à jour du réseau.

R:\Ressources\4-Partage\3-Procedures\FME\prod\OPEN-DATA\TIC_metadonnees.fmw

---

