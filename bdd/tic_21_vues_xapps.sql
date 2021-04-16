/* TIC V1.0*/
/* Creation des vues applicatives */
/* tic_21_vues_xapps.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */


-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                           DROP                                                          ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################

DROP MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab1;
DROP MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab2;
DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte;
DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte_descente;
DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_a;
DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_ar;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_arretdjf;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_arretpu;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_arretla;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_arretsco;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_arrettad;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_terminus;										   
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_terminus_djf;     
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_terminus_pu;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_terminus_sco;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_la_eti_terminus_tad;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_ligne_plan;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_lu_la_a;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_lu_la_ar;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_pu_la_a;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_pu_la_ar;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_sco_la_a;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_sco_la_ar;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_tad_la;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_ze;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_ze_200m;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_ze_500m;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_ze_nav;
DROP MATERIALIZED VIEW IF EXISTS x_apps.xapps_geo_vmr_tic_zela;

-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      VUES APPLICATIVES                                                    ###
-- ###                                                                                                                           ###
-- #################################################################################################################################


-- View: x_apps.an_vmr_rurbain_tab1

-- DROP MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab1;

CREATE MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab1
TABLESPACE pg_default
AS
 WITH req_nbarret AS (
         SELECT 1 AS gid,
            count(*) AS nb_arret_actif
           FROM m_mobilite.geo_mob_rurbain_ze
          WHERE geo_mob_rurbain_ze.statut::text = '10'::text
        ), req_longligne AS (
         WITH req_l AS (
                 SELECT an_mob_rurbain_ligne.id_ligne,
                    an_mob_rurbain_ligne.nom_court
                   FROM m_mobilite.an_mob_rurbain_ligne
                ), req_a AS (
                 SELECT l_1.id_ligne,
                    round(sum(st_length(t.geom)::numeric) / 1000::numeric, 1) AS aller
                   FROM m_mobilite.lk_voirie_rurbain j
                     LEFT JOIN r_objet.geo_objet_troncon t ON t.id_tronc = j.id_tronc
                     LEFT JOIN m_mobilite.an_mob_rurbain_ligne l_1 ON j.id_ligne::text = l_1.id_ligne::text
                  WHERE j.statut::text = '10'::text AND (j.desserte::text = '30'::text OR j.desserte::text = '20'::text OR j.desserte::text = '10'::text) AND (j.sens::text = '10'::text OR j.sens::text = '20'::text)
                  GROUP BY l_1.id_ligne
                ), req_r AS (
                 SELECT l_1.id_ligne,
                    round(sum(st_length(t.geom)::numeric) / 1000::numeric, 1) AS retour
                   FROM m_mobilite.lk_voirie_rurbain j
                     LEFT JOIN r_objet.geo_objet_troncon t ON t.id_tronc = j.id_tronc
                     LEFT JOIN m_mobilite.an_mob_rurbain_ligne l_1 ON j.id_ligne::text = l_1.id_ligne::text
                  WHERE j.statut::text = '10'::text AND (j.desserte::text = '30'::text OR j.desserte::text = '20'::text OR j.desserte::text = '10'::text) AND (j.sens::text = '10'::text OR j.sens::text = '30'::text)
                  GROUP BY l_1.id_ligne
                )
         SELECT 1 AS gid,
            sum(req_a.aller) + sum(req_r.retour) AS trajet
           FROM req_a,
            req_r,
            req_l
          WHERE req_a.id_ligne::text = req_l.id_ligne::text AND req_r.id_ligne::text = req_l.id_ligne::text
        )
 SELECT 1 AS gid,
    a.nb_arret_actif,
    l.trajet AS longligne
   FROM req_nbarret a,
    req_longligne l
  WHERE a.gid = l.gid
WITH DATA;

COMMENT ON MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab1
    IS 'Vue matérialisée rafraichie formatant la liste des lignes de bus urbaines pour recherche par ligne dans GEO';


-- View: x_apps.an_vmr_rurbain_tab2

-- DROP MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab2;

CREATE MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab2
TABLESPACE pg_default
AS
 SELECT DISTINCT row_number() OVER () AS gid,
        CASE
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['41'::character varying, '43'::character varying, '50'::character varying, '51'::character varying]::text[]) THEN 'Abris'::text
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['40'::character varying, '42'::character varying]::text[]) THEN 'Totem'::text
            WHEN geo_mob_rurbain_ze.zetype::text = '44'::text THEN 'Zébra'::text
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['46'::character varying, '47'::character varying, '48'::character varying, '49'::character varying]::text[]) THEN 'Autre'::text
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['45'::character varying, '00'::character varying]::text[]) THEN 'Non renseigné'::text
            ELSE NULL::text
        END AS zetype,
    count(*) AS nb_arret_actif
   FROM m_mobilite.geo_mob_rurbain_ze
  WHERE geo_mob_rurbain_ze.statut::text = '10'::text
  GROUP BY (
        CASE
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['41'::character varying, '43'::character varying, '50'::character varying, '51'::character varying]::text[]) THEN 'Abris'::text
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['40'::character varying, '42'::character varying]::text[]) THEN 'Totem'::text
            WHEN geo_mob_rurbain_ze.zetype::text = '44'::text THEN 'Zébra'::text
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['46'::character varying, '47'::character varying, '48'::character varying, '49'::character varying]::text[]) THEN 'Autre'::text
            WHEN geo_mob_rurbain_ze.zetype::text = ANY (ARRAY['45'::character varying, '00'::character varying]::text[]) THEN 'Non renseigné'::text
            ELSE NULL::text
        END)
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab2
    IS 'Vue matérialisée rafraichie contenant le nombre d''arrêt par type pour le TAB dans GEO';



-- View: x_apps.xapps_geo_vmr_tic_desserte

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte
TABLESPACE pg_default
AS
 SELECT ze.id_ze,
    string_agg((((l.nom_court::text || ' vers '::text) || t.valeur::text) || ' '::text) || f.valeur::text, chr(10)) AS text,
    string_agg(l.genre::text, ','::text) AS genre,
    ze.geom
   FROM m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.lt_mob_rurbain_terminus t,
    m_mobilite.lt_mob_rurbain_fonct f,
    m_mobilite.lt_mob_rurbain_passage vp,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE ze.id_ze::text = p.id_ze::text AND p.direction::text = t.code::text AND p.fonct::text = f.code::text AND p.t_passage::text = vp.code::text AND p.id_ligne::text = l.id_ligne::text AND (p.t_passage::text = '21'::text OR p.t_passage::text = '10'::text OR p.t_passage::text = '20'::text OR p.t_passage::text = '30'::text OR p.t_passage::text = '31'::text)
  GROUP BY ze.id_ze, ze.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte
    IS 'Vue géométrique pour la gestion des dessertes aux zones d''embarquement';

-- View: x_apps.xapps_geo_vmr_tic_desserte_descente

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte_descente;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte_descente
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    ze.id_ze,
    (((('Terminus descente'::text || chr(10)) || 'uniquement, ligne(s) : '::text) ||
        CASE
            WHEN p.t_passage::text = '22'::text OR p.t_passage::text = '32'::text THEN string_agg(substr(p.id_ligne::text, 15, 3), '-'::text)
            ELSE NULL::text
        END) || ' '::text) || f.valeur::text AS text,
    string_agg(l.genre::text, ','::text) AS genre,
    ze.geom
   FROM m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.lt_mob_rurbain_terminus t,
    m_mobilite.lt_mob_rurbain_fonct f,
    m_mobilite.lt_mob_rurbain_passage vp,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE ze.id_ze::text = p.id_ze::text AND p.direction::text = t.code::text AND p.fonct::text = f.code::text AND p.t_passage::text = vp.code::text AND p.id_ligne::text = l.id_ligne::text
  GROUP BY ze.id_ze, ze.geom, p.t_passage, f.valeur
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_desserte_descente
    IS 'Vue géométrique pour la gestion des dessertes aux zones d''embarquement (descente uniquement)';

-- View: x_apps.xapps_geo_vmr_tic_djf_la_a

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_a;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_a
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND (la.sens::text = '20'::text OR la.sens::text = '30'::text) AND l.genre::text = '50'::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_a
    IS 'Vue géométrique des lieux d''arrêt (sens aller ou retour) des lignes Dimanches et Jours fériés du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_djf_la_ar

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_ar;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_ar
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND la.sens::text = '10'::text AND l.genre::text = '50'::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_djf_la_ar
    IS 'Vue géométrique des lieux d''''arrêt (sens aller et retour) des lignes Dimanches et Jours fériés du réseau TIC';

						
-- View: x_apps.xapps_geo_vmr_tic_la_eti_arretdjf

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretdjf;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretdjf
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
        CASE
            WHEN la.nom::text = 'Centre Commercial Royallieu'::text THEN 'Ctre Cial Royallieu'::character varying
            ELSE la.nom
        END AS nom,
        CASE
            WHEN la.nom::text = 'Bataillon de France'::text THEN 100
            WHEN la.nom::text = 'Cimetière Nord'::text THEN 100
            WHEN la.nom::text = 'L''Echarde'::text THEN 100
            WHEN la.nom::text = 'Castors'::text THEN 100
            WHEN la.nom::text = 'Mairie de Venette'::text THEN 100
            WHEN la.nom::text = 'Hauts de Venette'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN la.nom::text = 'Parc de Loisirs'::text THEN 15
            WHEN la.nom::text = 'Centre de Recherches'::text THEN 15
            WHEN la.nom::text = 'Edmond Rostand'::text THEN 15
            WHEN la.nom::text = 'Robert Desnos'::text THEN 10
            WHEN la.nom::text = 'Bataillon de France'::text THEN '-15'::integer
            WHEN la.nom::text = 'Cimetière Nord'::text THEN '-15'::integer
            WHEN la.nom::text = 'L''Echarde'::text THEN '-15'::integer
            WHEN la.nom::text = 'Castors'::text THEN '-15'::integer
            WHEN la.nom::text = 'Mairie de Venette'::text THEN '-10'::integer
            WHEN la.nom::text = 'Hauts de Venette'::text THEN '-15'::integer
            WHEN la.nom::text = 'Joseph Cugnot'::text THEN 5
            WHEN la.nom::text = 'Sports nautiques'::text THEN 10
            ELSE 10
        END AS decalage_horiz,
        CASE
            WHEN la.nom::text = 'Parc de Loisirs'::text THEN 10
            WHEN la.nom::text = 'Vivier Corax'::text THEN 10
            WHEN la.nom::text = 'Centre Commercial Royallieu'::text THEN 15
            WHEN la.nom::text = 'André Malraux'::text THEN '-15'::integer
            WHEN la.nom::text = 'Robert Desnos'::text THEN 10
            WHEN la.nom::text = 'Clos des Roses'::text THEN '-10'::integer
            WHEN la.nom::text = 'Anatole France'::text THEN 10
            WHEN la.nom::text = 'Robida'::text THEN '-10'::integer
            WHEN la.nom::text = 'De Lattre de Tassigny'::text THEN 10
            WHEN la.nom::text = 'Carnot'::text THEN '-10'::integer
            WHEN la.nom::text = 'Domeliers'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saint-Corneille'::text THEN '-10'::integer
            WHEN la.nom::text = 'Roger Couttolenc'::text THEN '-10'::integer
            WHEN la.nom::text = 'Eglise Saint-Germain'::text THEN '-10'::integer
            WHEN la.nom::text = 'Hippolyte Bottier'::text THEN '-10'::integer
            WHEN la.nom::text = 'Sports nautiques'::text THEN '-10'::integer
            WHEN la.nom::text = 'Soissons'::text THEN 10
            WHEN la.nom::text = 'Rue de Clermont'::text THEN '-10'::integer
            WHEN la.nom::text = 'Castors'::text THEN '-5'::integer
            WHEN la.nom::text = 'Château de Venette'::text THEN 5
            WHEN la.nom::text = 'Mairie de Venette'::text THEN 5
            WHEN la.nom::text = 'Joseph Cugnot'::text THEN 10
            WHEN la.nom::text = 'Hôpital'::text THEN 5
            WHEN la.nom::text = 'Guy Denielou'::text THEN 5
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN la.nom::text = ''::text THEN 0
            ELSE 0
        END AS angle,
    la.geom
   FROM m_mobilite.geo_mob_rurbain_la la,
    m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '50'::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text) AND la.nom::text <> 'Gare'::text AND la.nom::text <> 'Multiplexe'::text AND la.nom::text <> 'Bellicart'::text
WITH DATA;



COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretdjf
    IS 'Vue géographique représentant les noms des lieux d''arrêts des lignes DJF pour l''affichage dans GEO';

-- View: x_apps.xapps_geo_vmr_tic_la_eti_arretla

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretla;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretla
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
        CASE
            WHEN la.nom::text = 'Centre Commercial Royallieu'::text THEN 'Ctre Cial Royallieu'::character varying
            WHEN la.nom::text = 'Poincaré Centre Commercial'::text THEN 'Poincaré Ctre Cial'::character varying
            ELSE la.nom
        END AS nom,
        CASE
            WHEN la.nom::text = 'Cailloux'::text THEN 100
            WHEN la.nom::text = 'Lycée Charles de Gaulle'::text THEN 100
            WHEN la.nom::text = 'Mercure'::text THEN 50
            WHEN la.id_la::text = 'FR:60159:LA:125:LOC'::text THEN 100
            WHEN la.nom::text = 'Blaise Pascal'::text THEN 100
            WHEN la.nom::text = 'Docteur Guérin'::text THEN 100
            WHEN la.nom::text = 'Hôpital de jour'::text THEN 100
            WHEN la.nom::text = 'Saint-Côme'::text THEN 100
            WHEN la.nom::text = 'Stade du Clos des Roses'::text THEN 100
            WHEN la.nom::text = 'Etats-Unis'::text THEN 100
            WHEN la.id_la::text = 'FR:60159:LA:268:LOC'::text THEN 100
            WHEN la.id_la::text = 'FR:60159:LA:266:LOC'::text THEN 100
            WHEN la.nom::text = 'Bataillon de France'::text THEN 100
            WHEN la.nom::text = 'Cimetière Nord'::text THEN 100
            WHEN la.nom::text = 'L''Echarde'::text THEN 100
            WHEN la.nom::text = 'Aventis'::text THEN 100
            WHEN la.nom::text = 'Stade Robert Dubois'::text THEN 100
            WHEN la.nom::text = 'Castors'::text THEN 100
            WHEN la.nom::text = 'Mairie de Venette'::text THEN 100
            WHEN la.nom::text = 'Hauts de Venette'::text THEN 100
            WHEN la.nom::text = 'Square Nolet'::text THEN 100
            WHEN la.nom::text = 'Camp de Royallieu'::text THEN 100
            WHEN la.nom::text = 'Longues Rayes'::text THEN 100
            WHEN la.nom::text = 'Verberie - Eglise'::text THEN 100
            WHEN la.nom::text = 'Automne'::text THEN 100
            WHEN la.nom::text = 'Jean Monnet'::text THEN 100
            WHEN la.nom::text = 'Allée des Nymphes'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN la.nom::text = 'Cailloux'::text THEN '-15'::integer
            WHEN la.nom::text = 'Camp du Roy'::text THEN 10
            WHEN la.nom::text = 'Multiplexe'::text THEN 15
            WHEN la.nom::text = 'Joseph Cugnot'::text THEN 15
            WHEN la.nom::text = 'Parc de Loisirs'::text THEN 15
            WHEN la.nom::text = 'Lycée Charles de Gaulle'::text THEN '-15'::integer
            WHEN la.nom::text = 'Chemin d''Armancourt'::text THEN 15
            WHEN la.id_la::text = 'FR:60159:LA:123:LOC'::text THEN 15
            WHEN la.id_la::text = 'FR:60159:LA:125:LOC'::text THEN '-15'::integer
            WHEN la.nom::text = 'Stalingrad'::text THEN 15
            WHEN la.nom::text = 'Huy-Senlis'::text THEN 15
            WHEN la.nom::text = 'Royallieu'::text THEN 15
            WHEN la.nom::text = 'Blaise Pascal'::text THEN '-15'::integer
            WHEN la.nom::text = 'Docteur Guérin'::text THEN '-5'::integer
            WHEN la.nom::text = 'Jean L''Huillier'::text THEN 15
            WHEN la.nom::text = 'Centre de Recherches'::text THEN 15
            WHEN la.nom::text = 'Edmond Rostand'::text THEN 15
            WHEN la.nom::text = 'Mémorial'::text THEN 15
            WHEN la.nom::text = 'Robert Desnos'::text THEN 10
            WHEN la.nom::text = 'Hôpital de jour'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saint-Côme'::text THEN '-5'::integer
            WHEN la.nom::text = 'Stade du Clos des Roses'::text THEN '-10'::integer
            WHEN la.nom::text = 'Centre culturel'::text THEN 15
            WHEN la.nom::text = 'Delaidde'::text THEN 15
            WHEN la.nom::text = 'Etats-Unis'::text THEN 0
            WHEN la.id_la::text = 'FR:60159:LA:268:LOC'::text THEN '-15'::integer
            WHEN la.id_la::text = 'FR:60159:LA:266:LOC'::text THEN '-15'::integer
            WHEN la.nom::text = 'Harlay'::text THEN 5
            WHEN la.nom::text = 'Bataillon de France'::text THEN '-15'::integer
            WHEN la.nom::text = 'Cimetière Nord'::text THEN '-15'::integer
            WHEN la.nom::text = 'L''Echarde'::text THEN '-15'::integer
            WHEN la.nom::text = 'Aventis'::text THEN '-15'::integer
            WHEN la.nom::text = 'Stade Robert Dubois'::text THEN '-15'::integer
            WHEN la.nom::text = 'Castors'::text THEN '-15'::integer
            WHEN la.nom::text = 'Mairie de Venette'::text THEN '-10'::integer
            WHEN la.nom::text = 'Hauts de Venette'::text THEN '-15'::integer
            WHEN la.nom::text = 'Square Nolet'::text THEN '-15'::integer
            WHEN la.nom::text = 'Camp de Royallieu'::text THEN '-5'::integer
            WHEN la.nom::text = 'Longues Rayes'::text THEN '-5'::integer
            WHEN la.nom::text = 'Verberie - Eglise'::text THEN '-10'::integer
            WHEN la.nom::text = 'Automne'::text THEN '-15'::integer
            WHEN la.nom::text = 'Jean Monnet'::text THEN '-15'::integer
            WHEN la.nom::text = 'Belin'::text THEN 10
            WHEN la.nom::text = 'Armistice'::text THEN 5
            WHEN la.nom::text = 'Allée des Nymphes'::text THEN '-20'::integer
            ELSE 10
        END AS decalage_horiz,
        CASE
            WHEN la.nom::text = 'Camp du Roy'::text THEN '-5'::integer
            WHEN la.nom::text = 'Multiplexe'::text THEN 5
            WHEN la.nom::text = 'Parc de Loisirs'::text THEN 10
            WHEN la.nom::text = 'Mercure'::text THEN 15
            WHEN la.nom::text = 'CIMA'::text THEN 15
            WHEN la.nom::text = 'Vivier Corax'::text THEN 10
            WHEN la.id_la::text = 'FR:60159:LA:125:LOC'::text THEN '-10'::integer
            WHEN la.nom::text = 'Stalingrad'::text THEN 5
            WHEN la.nom::text = 'Centre Commercial Royallieu'::text THEN 15
            WHEN la.nom::text = 'Docteur Guérin'::text THEN 15
            WHEN la.nom::text = 'André Malraux'::text THEN '-15'::integer
            WHEN la.nom::text = 'Docteur Calmette'::text THEN '-10'::integer
            WHEN la.nom::text = 'Pillet Will'::text THEN '-10'::integer
            WHEN la.nom::text = 'Abbaye'::text THEN 10
            WHEN la.nom::text = 'Robert Desnos'::text THEN 10
            WHEN la.nom::text = 'Hôpital de jour'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saint-Côme'::text THEN '-10'::integer
            WHEN la.nom::text = 'Clos des Roses'::text THEN '-10'::integer
            WHEN la.nom::text = 'Stade du Clos des Roses'::text THEN 10
            WHEN la.nom::text = 'Croix Rouge'::text THEN '-10'::integer
            WHEN la.nom::text = 'Anatole France'::text THEN 10
            WHEN la.nom::text = 'Raleigh'::text THEN 10
            WHEN la.nom::text = 'Delaidde'::text THEN 10
            WHEN la.nom::text = 'Saint-Fiacre'::text THEN '-5'::integer
            WHEN la.nom::text = 'Robida'::text THEN '-10'::integer
            WHEN la.nom::text = 'De Lattre de Tassigny'::text THEN 10
            WHEN la.nom::text = 'Carnot'::text THEN '-10'::integer
            WHEN la.nom::text = 'Domeliers'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saint-Corneille'::text THEN '-10'::integer
            WHEN la.nom::text = 'Roger Couttolenc'::text THEN '-10'::integer
            WHEN la.nom::text = 'Eglise Saint-Germain'::text THEN '-10'::integer
            WHEN la.nom::text = 'Harlay'::text THEN '-10'::integer
            WHEN la.nom::text = 'Hippolyte Bottier'::text THEN '-10'::integer
            WHEN la.nom::text = 'Sports nautiques'::text THEN 10
            WHEN la.nom::text = 'Soissons'::text THEN 10
            WHEN la.nom::text = 'Georges Clémenceau'::text THEN '-10'::integer
            WHEN la.nom::text = 'Paul Cosyns'::text THEN '-10'::integer
            WHEN la.nom::text = 'Aventis'::text THEN 10
            WHEN la.nom::text = 'Barbillon'::text THEN 15
            WHEN la.nom::text = 'Rue de Clermont'::text THEN '-10'::integer
            WHEN la.nom::text = 'République'::text THEN '-10'::integer
            WHEN la.nom::text = 'Poincaré Centre Commercial'::text THEN '-5'::integer
            WHEN la.nom::text = 'La Planchette'::text THEN '-5'::integer
            WHEN la.nom::text = 'Castors'::text THEN '-5'::integer
            WHEN la.nom::text = 'Château de Venette'::text THEN 5
            WHEN la.nom::text = 'Mairie de Venette'::text THEN 5
            WHEN la.nom::text = 'Square Nolet'::text THEN '-5'::integer
            WHEN la.nom::text = 'Camp de Royallieu'::text THEN 10
            WHEN la.nom::text = 'Matra Lecuru'::text THEN '-5'::integer
            WHEN la.nom::text = 'Longues Rayes'::text THEN 10
            WHEN la.nom::text = 'Verberie - Eglise'::text THEN 10
            WHEN la.nom::text = 'Lotissement du Moulin'::text THEN '-15'::integer
            WHEN la.nom::text = 'Etats-Unis'::text THEN 15
            WHEN la.nom::text = 'Armistice'::text THEN 10
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN la.nom::text = ''::text THEN 0
            ELSE 0
        END AS angle,
    la.geom
   FROM m_mobilite.geo_mob_rurbain_la la,
    m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '10'::text AND ze.statut::text = '10'::text AND l.nom_court::text <> 'D1'::text AND l.nom_court::text <> 'D2'::text AND la.nom::text <> 'Centre Commercial Jaux-Venette'::text AND la.nom::text <> 'Ferdinand de Lesseps'::text AND la.nom::text <> 'Hôpital'::text AND la.nom::text <> 'Guy Deniélou'::text AND la.nom::text <> 'Palais'::text AND la.nom::text <> 'Gare'::text AND la.nom::text <> 'Bellicart'::text AND la.nom::text <> 'Marronniers'::text AND la.nom::text <> 'Gare routière'::text AND la.nom::text <> 'Ouïnels'::text AND la.nom::text <> 'Port à Carreaux'::text AND la.nom::text <> 'Hauts de Margny'::text AND la.nom::text <> 'Petite Prée'::text AND la.nom::text <> 'Verberie - Aramont'::text AND la.nom::text <> 'Bois de Plaisance'::text
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretla
    IS 'Vue géographique représentant les noms des lieux d''arrêts des LU pour l''affichage dans GEO';

-- View: x_apps.xapps_geo_vmr_tic_la_eti_arretpu

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretpu;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretpu
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
        CASE
            WHEN la.nom::text = ''::text THEN ''::character varying
            ELSE la.nom
        END AS nom,
        CASE
            WHEN la.nom::text = 'Lycée Charles de Gaulle'::text THEN 100
            WHEN la.nom::text = 'Lycée Mireille Grenet'::text THEN 100
            WHEN la.nom::text = 'Lycée Pierre d''Ailly'::text THEN 100
            WHEN la.nom::text = 'Malassise'::text THEN 100
            WHEN la.nom::text = 'Saintines - Curie'::text THEN 100
            WHEN la.nom::text = 'Saintines - Jaurès'::text THEN 100
            WHEN la.nom::text = 'Néry - Vaucelle'::text THEN 100
            WHEN la.nom::text = 'Béthisy-St-Martin - Place'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN la.nom::text = 'Route de Compiègne'::text THEN 20
            WHEN la.nom::text = 'Lycée Charles de Gaulle'::text THEN '-15'::integer
            WHEN la.nom::text = 'Lycée Mireille Grenet'::text THEN '-10'::integer
            WHEN la.nom::text = 'Lycée Pierre d''Ailly'::text THEN '-5'::integer
            WHEN la.nom::text = 'Bac à l''Aumône'::text THEN 15
            WHEN la.nom::text = 'Barbillon'::text THEN 5
            WHEN la.nom::text = 'Choisy-au-Bac - Centre'::text THEN '-5'::integer
            WHEN la.nom::text = 'Linières'::text THEN 5
            WHEN la.nom::text = 'Francport - Pont'::text THEN 5
            WHEN la.nom::text = 'Malassise'::text THEN '-5'::integer
            WHEN la.nom::text = 'Saintines - Curie'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saintines - Mairie'::text THEN 10
            WHEN la.nom::text = 'Saintines - Jaurès'::text THEN '-10'::integer
            WHEN la.nom::text = 'Néry - Vaucelle'::text THEN '-10'::integer
            WHEN la.nom::text = 'Béthisy-St-Pierre - Place'::text THEN 5
            WHEN la.nom::text = 'Saint-Vaast-de-Longmont - Clos Châtelaine'::text THEN 5
            ELSE 10
        END AS decalage_horiz,
        CASE
            WHEN la.nom::text = 'Parc de Loisirs'::text THEN 10
            WHEN la.nom::text = 'Hôpital'::text THEN 5
            WHEN la.nom::text = 'Le Bac'::text THEN 10
            WHEN la.nom::text = 'Lycée Charles de Gaulle'::text THEN 15
            WHEN la.nom::text = 'Lycée Pierre d''Ailly'::text THEN '-15'::integer
            WHEN la.nom::text = 'Varanval'::text THEN 10
            WHEN la.nom::text = 'Le Meux - Croisette'::text THEN 10
            WHEN la.nom::text = 'Les Clos Blancs'::text THEN 5
            WHEN la.nom::text = 'Port à Carreaux'::text THEN '-10'::integer
            WHEN la.nom::text = 'Maubon'::text THEN 5
            WHEN la.nom::text = 'Marronniers'::text THEN 10
            WHEN la.nom::text = 'Barbillon'::text THEN '-15'::integer
            WHEN la.nom::text = 'Choisy-au-Bac - Centre'::text THEN '-20'::integer
            WHEN la.nom::text = 'Royaumont'::text THEN '-20'::integer
            WHEN la.nom::text = 'Linières'::text THEN 10
            WHEN la.nom::text = 'Rue Victor Hugo'::text THEN 10
            WHEN la.nom::text = 'Francport - Pont'::text THEN '-15'::integer
            WHEN la.nom::text = 'Saint-Jean-aux-Bois'::text THEN 10
            WHEN la.nom::text = 'Malassise'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saint-Vaast-de-Longmont - Clos Châtelaine'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saintines - Curie'::text THEN '-10'::integer
            WHEN la.nom::text = 'Saintines - Mairie'::text THEN 10
            WHEN la.nom::text = 'Saintines - Jaurès'::text THEN '-10'::integer
            WHEN la.nom::text = 'Béthisy-St-Martin - Place'::text THEN '-15'::integer
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN la.nom::text = ''::text THEN 0
            ELSE 0
        END AS angle,
    la.geom
   FROM m_mobilite.geo_mob_rurbain_la la,
    m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE la.statut::text = '10'::text AND la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '20'::text AND la.nom::text <> 'Gare routière'::text AND la.nom::text <> 'Mabonnerie'::text AND la.nom::text <> 'Eglise'::text AND la.nom::text <> 'Jonquières - Château'::text AND la.nom::text <> 'Le Meux - Centre'::text AND la.nom::text <> 'Armancourt'::text AND la.nom::text <> 'Bienville'::text AND la.nom::text <> 'Janville - Mairie'::text AND la.nom::text <> 'Francport - Château'::text AND la.nom::text <> 'Vieux-Moulin'::text AND la.nom::text <> 'La Brévière'::text AND la.nom::text <> 'Néry - Eglise'::text AND la.nom::text <> 'Verberie - Eglise'::text
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretpu
    IS 'Vue géographique représentant les noms des lieux d''arrêts des lignes PU pour l''affichage dans GEO';

-- View: x_apps.xapps_geo_vmr_tic_la_eti_arretsco

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretsco;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretsco
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
        CASE
            WHEN la.nom::text = ''::text THEN ''::character varying
            ELSE la.nom
        END AS nom,
        CASE
            WHEN la.nom::text = ''::text THEN 0
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN la.nom::text = 'Route de Compiègne'::text THEN 20
            WHEN la.nom::text = 'Bac à l''Aumône'::text THEN 15
            WHEN la.nom::text = 'Barbillon'::text THEN 5
            WHEN la.nom::text = 'Choisy-au-Bac - Centre'::text THEN '-5'::integer
            WHEN la.nom::text = 'Linières'::text THEN 5
            WHEN la.nom::text = 'Francport - Pont'::text THEN 5
            ELSE 10
        END AS decalage_horiz,
        CASE
            WHEN la.nom::text = 'Le Bac'::text THEN 10
            WHEN la.nom::text = 'Varanval'::text THEN 10
            WHEN la.nom::text = 'Le Meux - Croisette'::text THEN 10
            WHEN la.nom::text = 'Les Clos Blancs'::text THEN 5
            WHEN la.nom::text = 'Port à Carreaux'::text THEN '-10'::integer
            WHEN la.nom::text = 'Maubon'::text THEN 5
            WHEN la.nom::text = 'Marronniers'::text THEN 10
            WHEN la.nom::text = 'Choisy-au-Bac - Centre'::text THEN '-20'::integer
            WHEN la.nom::text = 'Royaumont'::text THEN '-20'::integer
            WHEN la.nom::text = 'Linières'::text THEN 10
            WHEN la.nom::text = 'Rue Victor Hugo'::text THEN 10
            WHEN la.nom::text = 'Francport - Pont'::text THEN '-15'::integer
            WHEN la.nom::text = 'Ouïnels'::text THEN '-10'::integer
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN la.nom::text = ''::text THEN 0
            ELSE 0
        END AS angle,
    la.geom
   FROM m_mobilite.geo_mob_rurbain_la la,
    m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '40'::text AND la.nom::text <> 'Mabonnerie'::text AND la.nom::text <> 'Eglise'::text AND la.nom::text <> 'Jonquières - Ecole'::text AND la.nom::text <> 'Jonquières - Château'::text AND la.nom::text <> 'Le Meux - Centre'::text AND la.nom::text <> 'Armancourt'::text AND la.nom::text <> 'Bienville'::text AND la.nom::text <> 'Janville - Mairie'::text AND la.nom::text <> 'Francport - Château'::text AND la.nom::text <> 'Linières'::text AND la.nom::text <> 'Collège Debussy'::text
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arretsco
    IS 'Vue géographique représentant les noms des lieux d''arrêts des lignes scolaires pour l''affichage dans GEO';

							
							-- View: x_apps.xapps_geo_vmr_tic_la_eti_arrettad

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arrettad;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arrettad
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
        CASE
            WHEN la.nom::text = ''::text THEN ''::character varying
            ELSE la.nom
        END AS nom,
        CASE
            WHEN la.nom::text = 'Bouquy'::text THEN 100
            WHEN la.nom::text = 'Pérelles'::text THEN 100
            WHEN la.nom::text = 'Maubon'::text THEN 100
            WHEN la.nom::text = 'Cimetière de Janville'::text THEN 100
            WHEN la.nom::text = 'Vivier Frère Robert'::text THEN 100
            WHEN la.nom::text = 'Mabonnerie'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN la.nom::text = 'Route de Compiègne'::text THEN 20
            WHEN la.nom::text = 'Lycée Charles de Gaulle'::text THEN '-15'::integer
            WHEN la.nom::text = 'Bac à l''Aumône'::text THEN 15
            WHEN la.nom::text = 'Linières'::text THEN 5
            WHEN la.nom::text = 'Francport - Pont'::text THEN 5
            WHEN la.nom::text = 'Malassise'::text THEN '-5'::integer
            WHEN la.nom::text = 'Bouquy'::text THEN '-10'::integer
            WHEN la.nom::text = 'Pérelles'::text THEN '-10'::integer
            WHEN la.nom::text = 'Rumigny'::text THEN 0
            WHEN la.nom::text = 'Cimetière de Janville'::text THEN '-10'::integer
            WHEN la.nom::text = 'Maubon'::text THEN '-10'::integer
            WHEN la.nom::text = 'Vivier Frère Robert'::text THEN '-10'::integer
            WHEN la.nom::text = 'Mabonnerie'::text THEN '-10'::integer
            ELSE 10
        END AS decalage_horiz,
        CASE
            WHEN la.nom::text = 'Hôpital'::text THEN 5
            WHEN la.nom::text = 'Le Bac'::text THEN 10
            WHEN la.nom::text = 'Varanval'::text THEN 10
            WHEN la.nom::text = 'Le Meux - Croisette'::text THEN 10
            WHEN la.nom::text = 'Maubon'::text THEN 5
            WHEN la.nom::text = 'Linières'::text THEN 10
            WHEN la.nom::text = 'Francport - Pont'::text THEN '-15'::integer
            WHEN la.nom::text = 'Saint-Jean-aux-Bois'::text THEN 10
            WHEN la.nom::text = 'Malassise'::text THEN '-10'::integer
            WHEN la.nom::text = 'Rumigny'::text THEN 15
            WHEN la.nom::text = 'Mabonnerie'::text THEN 5
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN la.nom::text = ''::text THEN 0
            ELSE 0
        END AS angle,
    la.geom
   FROM m_mobilite.geo_mob_rurbain_la la,
    m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '30'::text AND la.nom::text <> 'Gare'::text AND la.nom::text <> 'St-Vaast de Longmont - Mairie'::text AND la.nom::text <> 'Jonquières - Château'::text AND la.nom::text <> 'Varanval'::text AND la.nom::text <> 'Hôpital'::text AND la.nom::text <> 'La Brévière'::text AND la.nom::text <> 'Janville - Ile J.Lenoble'::text AND la.nom::text <> 'Compiègne - Armistice'::text AND la.nom::text <> 'Lachelle - Place'::text AND la.nom::text <> 'Janville - Ile J. Lenoble'::text AND la.nom::text <> 'Verberie - Aramont'::text
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_arrettad
    IS 'Vue géographique représentant les noms des lieux d''arrêts des lignes AlloTIC pour l''affichage dans GEO';

-- View: x_apps.xapps_geo_vmr_tic_la_eti_terminus

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN c.nom::text || ' - 1-2-3-4-5-6-HM-Arc Express'::text
            WHEN c.nom::text = 'Guy Deniélou'::text THEN c.nom::text || ' - 1-2-3-5-6-Arc Express'::text
            WHEN c.nom::text = 'Centre Commercial Jaux-Venette'::text THEN 'Centre Cial Jaux-Venette'::text || '- 2-4'::text
            WHEN c.nom::text = 'Bois de Plaisance'::text THEN 'Bois de Plaisance'::text || '- 4-6'::text
            ELSE (c.nom::text || ' - '::text) || string_agg(c.nom_court::text, '-'::text)
        END AS text,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN 0
            WHEN c.nom::text = 'Hôpital'::text THEN 100
            WHEN c.nom::text = 'Ferdinand de Lesseps'::text THEN 100
            WHEN c.nom::text = 'Petite Prée'::text THEN 0
            WHEN c.nom::text = 'Centre Commercial Jaux-Venette'::text THEN 100
            WHEN c.nom::text = 'Guy Deniélou'::text THEN 100
            WHEN c.nom::text = 'Palais'::text THEN 0
            WHEN c.nom::text = 'Ouïnels'::text THEN 100
            WHEN c.nom::text = 'Hauts de Margny'::text THEN 100
            WHEN c.nom::text = 'Port à Carreaux'::text THEN 100
            WHEN c.nom::text = 'Marronniers'::text THEN 0
            WHEN c.nom::text = 'Verberie - Aramont'::text THEN 100
            WHEN c.nom::text = 'Bois de Plaisance'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN c.nom::text = 'Centre Commercial Jaux-Venette'::text THEN '-5'::integer
            WHEN c.nom::text = 'Ferdinand de Lesseps'::text THEN 15
            WHEN c.nom::text = 'Marronniers'::text THEN 15
            WHEN c.nom::text = 'Port à Carreaux'::text THEN 10
            WHEN c.nom::text = 'Hauts de Margny'::text THEN '-25'::integer
            WHEN c.nom::text = 'Petite Prée'::text THEN 10
            WHEN c.nom::text = 'Verberie - Aramont'::text THEN 15
            WHEN c.nom::text = 'Guy Deniélou'::text THEN 0
            WHEN c.nom::text = 'Bois de Plaisance'::text THEN 15
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN 20
            WHEN c.nom::text = 'Hôpital'::text THEN '-20'::integer
            WHEN c.nom::text = 'Ferdinand de Lesseps'::text THEN '-20'::integer
            WHEN c.nom::text = 'Centre Commercial Jaux-Venette'::text THEN '-15'::integer
            WHEN c.nom::text = 'Guy Deniélou'::text THEN '-20'::integer
            WHEN c.nom::text = 'Palais'::text THEN 20
            WHEN c.nom::text = 'Ouïnels'::text THEN '-20'::integer
            WHEN c.nom::text = 'Hauts de Margny'::text THEN '-20'::integer
            WHEN c.nom::text = 'Marronniers'::text THEN 10
            WHEN c.nom::text = 'Port à Carreaux'::text THEN '-10'::integer
            WHEN c.nom::text = 'Petite Prée'::text THEN 10
            WHEN c.nom::text = 'Verberie - Aramont'::text THEN '-10'::integer
            WHEN c.nom::text = 'Bois de Plaisance'::text THEN '-10'::integer
            ELSE 0
        END AS decalage_horiz,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND la.statut::text = '10'::text AND l.genre::text = '10'::text AND l.nom_court::text <> 'E2'::text AND l.nom_court::text <> 'D1'::text AND l.nom_court::text <> 'D2'::text AND (p.t_passage::text = '20'::text OR p.t_passage::text = '30'::text OR p.t_passage::text = '31'::text OR p.t_passage::text = '21'::text) AND la.nom::text <> 'Multiplexe'::text AND la.nom::text <> 'Gare routière'::text
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus
    IS 'Vue géographique représentant les terminus LU avec leur nom et ligne associée';

-- View: x_apps.xapps_geo_vmr_tic_la_eti_terminus_djf

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_djf;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_djf
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN c.nom::text || ' - D1-D2'::text
            WHEN c.nom::text = 'Bellicart'::text THEN c.nom::text || ' - D1-D2'::text
            WHEN c.nom::text = 'Multiplexe'::text THEN c.nom::text || ' - D1-D2'::text
            ELSE NULL::text
        END AS text,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN 0
            WHEN c.nom::text = 'Bellicart'::text THEN 0
            WHEN c.nom::text = 'Multiplexe'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN 0
            WHEN c.nom::text = 'Bellicart'::text THEN 0
            WHEN c.nom::text = 'Multiplexe'::text THEN 0
            ELSE 0
        END AS decalage_vert,
        CASE
            WHEN c.nom::text = 'Gare'::text THEN 15
            WHEN c.nom::text = 'Bellicart'::text THEN 15
            WHEN c.nom::text = 'Multiplexe'::text THEN '-20'::integer
            ELSE 0
        END AS decalage_horiz,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '50'::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text) AND (la.nom::text = 'Bellicart'::text OR la.nom::text = 'Gare'::text OR la.nom::text = 'Multiplexe'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_djf
    IS 'Vue géographique représentant les terminus des lignes du dimanche et jours fériés avec leur nom et ligne associée';

-- View: x_apps.xapps_geo_vmr_tic_la_eti_terminus_pu

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_pu;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_pu
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
        CASE
            WHEN c.nom::text = 'Eglise'::text THEN c.nom::text || ' - 103'::text
            WHEN c.nom::text = 'Mabonnerie'::text THEN c.nom::text || ' - 103'::text
            WHEN c.nom::text = 'La Brévière'::text THEN c.nom::text || ' - 101'::text
            WHEN c.nom::text = 'Vieux-Moulin'::text THEN c.nom::text || ' - 101'::text
            WHEN c.nom::text = 'Francport - Château'::text THEN c.nom::text || ' - 106'::text
            WHEN c.nom::text = 'Jonquières - Château'::text THEN c.nom::text || ' - 107'::text
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN c.nom::text || ' - 107'::text
            WHEN c.nom::text = 'Armancourt'::text THEN c.nom::text || ' - 107'::text
            WHEN c.nom::text = 'Gare routière'::text THEN c.nom::text || ' - 101-103-106-107-109'::text
            WHEN c.nom::text = 'Bienville'::text THEN c.nom::text || ' - 109'::text
            WHEN c.nom::text = 'Janville - Mairie'::text THEN c.nom::text || ' - 109'::text
            WHEN c.nom::text = 'Verberie - Eglise'::text THEN ((c.nom::text || ' - 111'::text) || chr(10)) || '(correspondance ARCExpress)'::text
            WHEN c.nom::text = 'Néry - Eglise'::text THEN c.nom::text || ' - 111'::text
            ELSE NULL::text
        END AS text,
        CASE
            WHEN c.nom::text = 'Eglise'::text THEN 0
            WHEN c.nom::text = 'Mabonnerie'::text THEN 100
            WHEN c.nom::text = 'La Brévière'::text THEN 100
            WHEN c.nom::text = 'Vieux-Moulin'::text THEN 0
            WHEN c.nom::text = 'Francport - Château'::text THEN 0
            WHEN c.nom::text = 'Jonquières - Château'::text THEN 100
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN 100
            WHEN c.nom::text = 'Armancourt'::text THEN 0
            WHEN c.nom::text = 'Gare routière'::text THEN 0
            WHEN c.nom::text = 'Bienville'::text THEN 100
            WHEN c.nom::text = 'Janville - Mairie'::text THEN 0
            WHEN c.nom::text = 'Verberie - Eglise'::text THEN 100
            WHEN c.nom::text = 'Néry - Eglise'::text THEN 0
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN c.nom::text = 'Eglise'::text THEN 25
            WHEN c.nom::text = 'Mabonnerie'::text THEN '-10'::integer
            WHEN c.nom::text = 'La Brévière'::text THEN '-20'::integer
            WHEN c.nom::text = 'Vieux-Moulin'::text THEN 20
            WHEN c.nom::text = 'Francport - Château'::text THEN 20
            WHEN c.nom::text = 'Jonquières - Château'::text THEN '-20'::integer
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN '-20'::integer
            WHEN c.nom::text = 'Armancourt'::text THEN 20
            WHEN c.nom::text = 'Gare routière'::text THEN 20
            WHEN c.nom::text = 'Bienville'::text THEN '-20'::integer
            WHEN c.nom::text = 'Janville - Mairie'::text THEN 20
            WHEN c.nom::text = 'Verberie - Eglise'::text THEN 90
            WHEN c.nom::text = 'Néry - Eglise'::text THEN 10
            ELSE 0
        END AS decalage_horiz,
        CASE
            WHEN c.nom::text = 'Eglise'::text THEN 15
            WHEN c.nom::text = 'Mabonnerie'::text THEN 15
            WHEN c.nom::text = 'Gare routière'::text THEN 10
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN 10
            WHEN c.nom::text = 'Francport - Château'::text THEN 15
            WHEN c.nom::text = 'Verberie - Eglise'::text THEN 25
            ELSE 0
        END AS decalage_vert,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '20'::text AND (l.nom_court::text = '101'::text OR l.nom_court::text = '103'::text OR l.nom_court::text = '106'::text OR l.nom_court::text = '107'::text OR l.nom_court::text = '109'::text OR l.nom_court::text = '111'::text) AND (la.nom::text = 'Eglise'::text OR la.nom::text = 'Mabonnerie'::text OR la.nom::text = 'La Brévière'::text OR la.nom::text = 'Vieux-Moulin'::text OR la.nom::text = 'Francport - Château'::text OR la.nom::text = 'Jonquières - Château'::text OR la.nom::text = 'Le Meux - Centre'::text OR la.nom::text = 'Armancourt'::text OR la.nom::text = 'Gare routière'::text OR la.nom::text = 'Bienville'::text OR la.nom::text = 'Janville - Mairie'::text OR la.nom::text = 'Verberie - Eglise'::text OR la.nom::text = 'Néry - Eglise'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_pu
    IS 'Vue géographique représentant les terminus des lignes péri-urbaines avec leur nom et ligne associée';

												      -- View: x_apps.xapps_geo_vmr_tic_la_eti_terminus_sco

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_sco;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_sco
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
        CASE
            WHEN c.nom::text = 'Eglise'::text THEN c.nom::text || ' - 104'::text
            WHEN c.nom::text = 'Mabonnerie'::text THEN c.nom::text || ' - 104'::text
            WHEN c.nom::text = 'Jonquières - Ecole'::text THEN c.nom::text || ' - 108'::text
            WHEN c.nom::text = 'Jonquières - Château'::text THEN c.nom::text || ' - 104'::text
            WHEN c.nom::text = 'Armancourt'::text THEN c.nom::text || ' - 104-108'::text
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN c.nom::text || ' - 104-108'::text
            WHEN c.nom::text = 'Hameau de Mercières'::text THEN c.nom::text || ' - 104'::text
            WHEN c.nom::text = 'Mairie de Lacroix-Saint-Ouen'::text THEN 'Mairie de Lacroix-St-Ouen'::text || ' - 108'::text
            WHEN c.nom::text = 'Ecole des Bruyères'::text THEN c.nom::text || ' - 104'::text
            WHEN c.nom::text = 'Collège Jules Verne'::text THEN c.nom::text || ' - 104'::text
            WHEN c.nom::text = 'Francport - Château'::text THEN c.nom::text || ' - 102'::text
            WHEN c.nom::text = 'Janville - Mairie'::text THEN c.nom::text || ' - 110'::text
            WHEN c.nom::text = 'Bienville'::text THEN c.nom::text || ' - 110'::text
            WHEN c.nom::text = 'Collège Debussy'::text THEN c.nom::text || ' - 108-110'::text
            WHEN c.nom::text = 'Collège Ferdinand Bac'::text THEN c.nom::text || ' - 102'::text
            WHEN c.nom::text = 'Linières'::text THEN c.nom::text || ' - 102-110'::text
            ELSE NULL::text
        END AS text,
        CASE
            WHEN c.nom::text = 'Eglise'::text THEN 0
            WHEN c.nom::text = 'Mabonnerie'::text THEN 100
            WHEN c.nom::text = 'Jonquières - Ecole'::text THEN 0
            WHEN c.nom::text = 'Jonquières - Château'::text THEN 100
            WHEN c.nom::text = 'Armancourt'::text THEN 0
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN 0
            WHEN c.nom::text = 'Hameau de Mercières'::text THEN 0
            WHEN c.nom::text = 'Mairie de Lacroix-Saint-Ouen'::text THEN 100
            WHEN c.nom::text = 'Ecole des Bruyères'::text THEN 0
            WHEN c.nom::text = 'Collège Jules Verne'::text THEN 0
            WHEN c.nom::text = 'Francport - Château'::text THEN 0
            WHEN c.nom::text = 'Janville - Mairie'::text THEN 100
            WHEN c.nom::text = 'Bienville'::text THEN 100
            WHEN c.nom::text = 'Collège Debussy'::text THEN 100
            WHEN c.nom::text = 'Collège Ferdinand Bac'::text THEN 0
            WHEN c.nom::text = 'Linières'::text THEN 0
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN c.nom::text = 'Jonquières - Château'::text THEN '-10'::integer
            WHEN c.nom::text = 'Jonquières - Ecole'::text THEN 15
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN 15
            WHEN c.nom::text = 'Bienville'::text THEN '-15'::integer
            ELSE 10
        END AS decalage_horiz,
        CASE
            WHEN c.nom::text = 'Jonquières - Ecole'::text THEN 10
            WHEN c.nom::text = 'Le Meux - Centre'::text THEN 10
            WHEN c.nom::text = 'Linières'::text THEN 10
            WHEN c.nom::text = 'Francport - Château'::text THEN 15
            ELSE 0
        END AS decalage_vert,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '40'::text AND (l.nom_court::text = '102'::text OR l.nom_court::text = '104'::text OR l.nom_court::text = '108'::text OR l.nom_court::text = '110'::text) AND (la.nom::text = 'Eglise'::text OR la.nom::text = 'Mabonnerie'::text OR la.nom::text = 'Jonquières - Ecole'::text OR la.nom::text = 'Jonquières - Château'::text OR la.nom::text = 'Armancourt'::text OR la.nom::text = 'Le Meux - Centre'::text OR la.nom::text = 'Hameau de Mercières'::text OR la.nom::text = 'Mairie de Lacroix-Saint-Ouen'::text OR la.nom::text = 'Ecole des Bruyères'::text OR la.nom::text = 'Collège Jules Verne'::text OR la.nom::text = 'Francport - Château'::text OR la.nom::text = 'Janville - Mairie'::text OR la.nom::text = 'Bienville'::text OR la.nom::text = 'Collège Debussy'::text OR la.nom::text = 'Collège Ferdinand Bac'::text OR la.nom::text = 'Linières'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_sco
    IS 'Vue géographique représentant les terminus des lignes scolaires avec leur nom et ligne associée';


-- View: x_apps.xapps_geo_vmr_tic_la_eti_terminus_tad

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_tad;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_tad
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
        CASE
            WHEN c.nom::text = 'St-Vaast de Longmont - Mairie'::text THEN c.nom::text || ' - 13'::text
            WHEN c.nom::text = 'Jonquières - Château'::text THEN c.nom::text || ' - 14'::text
            WHEN c.nom::text = 'La Brévière'::text THEN c.nom::text || ' - 15'::text
            WHEN c.nom::text = 'Compiègne - Armistice'::text THEN c.nom::text || ' - 16'::text
            WHEN c.nom::text = 'Varanval'::text THEN c.nom::text || ' - 17'::text
            WHEN c.nom::text = 'Lachelle - Place'::text THEN c.nom::text || ' - 18'::text
            WHEN c.nom::text = 'Janville - Ile J.Lenoble'::text THEN c.nom::text || ' - 19'::text
            WHEN c.nom::text = 'Gare'::text THEN c.nom::text || ' - 13-14-15-16-17-18-19'::text
            WHEN c.nom::text = 'Hôpital'::text THEN c.nom::text || ' - 13-14-15-16-17-18-19'::text
            WHEN c.nom::text = 'Eglise'::text THEN c.nom::text || ' - 20 (13)'::text
            WHEN c.nom::text = 'Verberie - Aramont'::text THEN c.nom::text || ' - 20'::text
            ELSE NULL::text
        END AS text,
        CASE
            WHEN c.nom::text = 'St-Vaast de Longmont - Mairie'::text THEN 100
            WHEN c.nom::text = 'Jonquières - Château'::text THEN 100
            WHEN c.nom::text = 'La Brévière'::text THEN 100
            WHEN c.nom::text = 'Compiègne - Armistice'::text THEN 0
            WHEN c.nom::text = 'Varanval'::text THEN 100
            WHEN c.nom::text = 'Lachelle - Place'::text THEN 100
            WHEN c.nom::text = 'Janville - Ile J.Lenoble'::text THEN 0
            WHEN c.nom::text = 'Collège Jules Verne'::text THEN 0
            WHEN c.nom::text = 'Gare'::text THEN 0
            WHEN c.nom::text = 'Hôpital'::text THEN 0
            WHEN c.nom::text = 'Verberie - Aramont'::text THEN 100
            ELSE 0
        END AS ancrage_horiz,
        CASE
            WHEN c.nom::text = 'Lachelle - Place'::text THEN '-10'::integer
            WHEN c.nom::text = 'Jonquières - Château'::text THEN '-10'::integer
            WHEN c.nom::text = 'Varanval'::text THEN '-10'::integer
            WHEN c.nom::text = 'Hôpital'::text THEN 10
            WHEN c.nom::text = 'Mabonnerie'::text THEN '-10'::integer
            WHEN c.nom::text = 'Gare'::text THEN 10
            WHEN c.nom::text = 'Janville - Ile J.Lenoble'::text THEN 10
            WHEN c.nom::text = 'Compiègne - Armistice'::text THEN 10
            WHEN c.nom::text = 'La Brévière'::text THEN '-5'::integer
            WHEN c.nom::text = 'Eglise'::text THEN 15
            WHEN c.nom::text = 'Verberie - Aramont'::text THEN '-15'::integer
            WHEN c.nom::text = 'St-Vaast de Longmont - Mairie'::text THEN '-15'::integer
            ELSE 0
        END AS decalage_horiz,
        CASE
            WHEN c.nom::text = 'La Brévière'::text THEN 10
            ELSE 0
        END AS decalage_vert,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '30'::text AND (l.nom_court::text = '13'::text OR l.nom_court::text = '14'::text OR l.nom_court::text = '15'::text OR l.nom_court::text = '16'::text OR l.nom_court::text = '17'::text OR l.nom_court::text = '18'::text OR l.nom_court::text = '19'::text OR l.nom_court::text = '20'::text) AND (la.nom::text = 'St-Vaast de Longmont - Mairie'::text OR la.nom::text = 'Jonquières - Château'::text OR la.nom::text = 'Lachelle - Place'::text OR la.nom::text = 'Janville - Ile J.Lenoble'::text OR la.nom::text = 'Compiègne - Armistice'::text OR la.nom::text = 'La Brévière'::text OR la.nom::text = 'Varanval'::text OR la.nom::text = 'Gare'::text OR la.nom::text = 'Hôpital'::text OR la.nom::text = 'Verberie - Aramont'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_la_eti_terminus_tad
    IS 'Vue géographique représentant les terminus des lignes Allo''TIC avec leur nom et ligne associée';

-- View: x_apps.xapps_geo_vmr_tic_ligne_plan

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ligne_plan;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ligne_plan
TABLESPACE pg_default
AS
 WITH req_ligne AS (
         SELECT row_number() OVER () AS row_id,
            l_1.id_ligne,
            l_1.lib_res,
            l_1.lib_exploi,
            l_1.lib_aot,
            l_1.nom_court,
            l_1.nom_ligne,
            l_1.acces_pmr,
            l_1.genre,
            l_1.fonct,
            l_1.date_sai,
            l_1.date_maj,
            l_1.op_sai,
            l_1.observ,
            st_linemerge(st_union(o.geom))::geometry(MultiLineString,2154) AS geom
           FROM m_mobilite.an_mob_rurbain_ligne l_1,
            m_mobilite.lk_voirie_rurbain v,
            r_objet.geo_objet_troncon o
          WHERE l_1.id_ligne::text = v.id_ligne::text AND v.id_tronc = o.id_tronc AND l_1.genre::text <> '00'::text AND l_1.fonct::text <> 'ZZ'::text
          GROUP BY l_1.id_ligne, l_1.lib_res, l_1.lib_exploi, l_1.lib_aot, l_1.nom_court, l_1.nom_ligne, l_1.acces_pmr, l_1.genre, l_1.fonct, l_1.date_sai, l_1.date_maj, l_1.op_sai, l_1.observ
        ), req_calcul AS (
         WITH req_l AS (
                 SELECT an_mob_rurbain_ligne.id_ligne,
                    an_mob_rurbain_ligne.nom_court
                   FROM m_mobilite.an_mob_rurbain_ligne
                ), req_a AS (
                 SELECT l_1.id_ligne,
                    round(sum(st_length(t.geom)::numeric) / 1000::numeric, 1) AS aller
                   FROM m_mobilite.lk_voirie_rurbain j
                     LEFT JOIN r_objet.geo_objet_troncon t ON t.id_tronc = j.id_tronc
                     LEFT JOIN m_mobilite.an_mob_rurbain_ligne l_1 ON j.id_ligne::text = l_1.id_ligne::text
                  WHERE j.statut::text = '10'::text AND (j.desserte::text = '30'::text OR j.desserte::text = '20'::text OR j.desserte::text = '10'::text) AND (j.sens::text = '10'::text OR j.sens::text = '20'::text)
                  GROUP BY l_1.id_ligne
                ), req_r AS (
                 SELECT l_1.id_ligne,
                    round(sum(st_length(t.geom)::numeric) / 1000::numeric, 1) AS retour
                   FROM m_mobilite.lk_voirie_rurbain j
                     LEFT JOIN r_objet.geo_objet_troncon t ON t.id_tronc = j.id_tronc
                     LEFT JOIN m_mobilite.an_mob_rurbain_ligne l_1 ON j.id_ligne::text = l_1.id_ligne::text
                  WHERE j.statut::text = '10'::text AND (j.desserte::text = '30'::text OR j.desserte::text = '20'::text OR j.desserte::text = '10'::text) AND (j.sens::text = '10'::text OR j.sens::text = '30'::text)
                  GROUP BY l_1.id_ligne
                )
         SELECT req_l.id_ligne,
            req_l.nom_court AS ligne,
            req_a.aller,
            req_r.retour,
            round((req_a.aller + req_r.retour) / 2::numeric, 1) AS moyenne,
            req_a.aller + req_r.retour AS trajet
           FROM req_a,
            req_r,
            req_l
          WHERE req_a.id_ligne::text = req_l.id_ligne::text AND req_r.id_ligne::text = req_l.id_ligne::text
        )
 SELECT row_number() OVER () AS row_id,
    l.id_ligne,
    l.lib_res,
    l.lib_exploi,
    l.lib_aot,
    l.nom_court,
    l.nom_ligne,
    l.acces_pmr,
    l.genre,
    l.fonct,
    l.date_sai,
    l.date_maj,
    l.op_sai,
    l.observ,
    c.aller,
    c.retour,
    c.moyenne,
    c.trajet,
        CASE
            WHEN l.nom_court::text = 'ARC Express'::text THEN 'http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_ARCExpress.png'::text
            WHEN l.nom_court::text = 'Navette HM'::text THEN 'http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_NavetteHM.png'::text
            ELSE ('http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_'::text || l.nom_court::text) || '.png'::text
        END AS l_logo,
    string_agg(((('<a href="http://geo.compiegnois.fr/documents/metiers/mob/tic/'::text || d.n_fichier::text) || '" target = "_blank">'::text) || d.l_fichier::text) || '</a>'::text, '  '::text) AS l_urlfic,
        CASE
            WHEN l.nom_court::text = '1'::text THEN 1
            WHEN l.nom_court::text = '2'::text THEN 2
            WHEN l.nom_court::text = '3'::text THEN 3
            WHEN l.nom_court::text = '4'::text THEN 4
            WHEN l.nom_court::text = '5'::text THEN 5
            WHEN l.nom_court::text = '6'::text THEN 6
            WHEN l.nom_court::text = 'ARC Express'::text THEN 7
            WHEN l.nom_court::text = 'Navette HM'::text THEN 8
            WHEN l.nom_court::text = '101'::text THEN 9
            WHEN l.nom_court::text = '102'::text THEN 10
            WHEN l.nom_court::text = '103'::text THEN 11
            WHEN l.nom_court::text = '104'::text THEN 12
            WHEN l.nom_court::text = '106'::text THEN 13
            WHEN l.nom_court::text = '107'::text THEN 14
            WHEN l.nom_court::text = '108'::text THEN 15
            WHEN l.nom_court::text = '109'::text THEN 16
            WHEN l.nom_court::text = '110'::text THEN 17
            WHEN l.nom_court::text = 'D1'::text THEN 18
            WHEN l.nom_court::text = 'D2'::text THEN 19
            WHEN l.nom_court::text = '13'::text THEN 20
            WHEN l.nom_court::text = '14'::text THEN 21
            WHEN l.nom_court::text = '15'::text THEN 22
            WHEN l.nom_court::text = '16'::text THEN 23
            WHEN l.nom_court::text = '17'::text THEN 24
            WHEN l.nom_court::text = '18'::text THEN 25
            WHEN l.nom_court::text = '19'::text THEN 26
            ELSE NULL::integer
        END AS tri_ligne,
    l.geom
   FROM req_ligne l
     JOIN req_calcul c ON l.id_ligne::text = c.id_ligne::text
     LEFT JOIN m_mobilite.an_mob_rurbain_docligne d ON l.id_ligne::text = d.id_ligne::text
  GROUP BY l.id_ligne, l.lib_res, l.lib_exploi, l.lib_aot, l.nom_court, l.nom_ligne, l.acces_pmr, l.genre, l.fonct, l.date_sai, l.date_maj, l.op_sai, l.observ, c.ligne, c.aller, c.retour, c.moyenne, c.trajet, l.geom
  ORDER BY l.genre, l.fonct, l.nom_court
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ligne_plan
    IS 'Vue matérialisée rafraichie formatant la liste des lignes de bus du réseau TIC pour la recherche par ligne dans GEO et le TAB';

-- View: x_apps.xapps_geo_vmr_tic_lu_la_a

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_lu_la_a;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_lu_la_a
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND la.statut::text = '10'::text AND (la.sens::text = '20'::text OR la.sens::text = '30'::text) AND l.genre::text = '10'::text AND l.nom_court::text <> 'D1'::text AND l.nom_court::text <> 'D2'::text
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_lu_la_a
    IS 'Vue géométrique des lieux d''arrêt (sens aller ou retour) des lignes urbaines du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_lu_la_ar

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_lu_la_ar;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_lu_la_ar
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND la.statut::text = '10'::text AND la.sens::text = '10'::text AND l.genre::text = '10'::text AND l.nom_court::text <> 'D1'::text AND l.nom_court::text <> 'D2'::text
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_lu_la_ar
    IS 'Vue géométrique des lieux d''''arrêt (sens aller et retour) des lignes urbaines du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_pu_la_a

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_pu_la_a;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_pu_la_a
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.statut::text = '10'::text AND la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND (la.sens::text = '20'::text OR la.sens::text = '30'::text) AND l.genre::text = '20'::text AND (l.nom_court::text = '101'::text OR l.nom_court::text = '103'::text OR l.nom_court::text = '106'::text OR l.nom_court::text = '107'::text OR l.nom_court::text = '109'::text OR l.nom_court::text = '111'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_pu_la_a
    IS 'Vue géométrique des lieux d''arrêt (sens aller ou retour) des lignes PU du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_pu_la_ar

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_pu_la_ar;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_pu_la_ar
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.statut::text = '10'::text AND la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND la.sens::text = '10'::text AND l.genre::text = '20'::text AND (l.nom_court::text = '101'::text OR l.nom_court::text = '103'::text OR l.nom_court::text = '106'::text OR l.nom_court::text = '107'::text OR l.nom_court::text = '109'::text OR l.nom_court::text = '111'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_pu_la_ar
    IS 'Vue géométrique des lieux d''''arrêt (sens aller et retour) des lignes PU du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_sco_la_a

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_sco_la_a;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_sco_la_a
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND (la.sens::text = '20'::text OR la.sens::text = '30'::text) AND l.genre::text = '40'::text AND (l.nom_court::text = '102'::text OR l.nom_court::text = '104'::text OR l.nom_court::text = '108'::text OR l.nom_court::text = '110'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_sco_la_a
    IS 'Vue géométrique des lieux d''arrêt (sens aller ou retour) des lignes scolaires du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_sco_la_ar

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_sco_la_ar;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_sco_la_ar
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND la.sens::text = '10'::text AND l.genre::text = '40'::text AND (l.nom_court::text = '102'::text OR l.nom_court::text = '104'::text OR l.nom_court::text = '108'::text OR l.nom_court::text = '110'::text)
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_sco_la_ar
    IS 'Vue géométrique des lieux d''''arrêt (sens aller et retour) des lignes scolaires du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_tad_la

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_tad_la;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_tad_la
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    c.nom,
    string_agg(c.nom_court::text, '-'::text) AS num_ligne,
    c.sens,
    c.angle,
    count(*) AS nb_ligne,
    c.geom
   FROM ( SELECT row_number() OVER (ORDER BY p.id_ligne) AS compteur,
            count(*) AS compteur1,
            la.nom,
            l.nom_court,
            la.sens,
            la.angle,
            la.geom
           FROM m_mobilite.geo_mob_rurbain_la la,
            m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text AND l.genre::text = '30'::text
          GROUP BY la.nom, l.nom_court, la.sens, la.angle, la.geom, p.id_ligne) c
  GROUP BY c.nom, c.sens, c.angle, c.geom
WITH DATA;



COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_tad_la
    IS 'Vue géométrique des lieux d''''arrêt des lignes Allo''Tic (TAD) du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_ze

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    ze.nom,
    ze.zetype,
    ze.sign_visu,
    string_agg(l.genre::text, ','::text) AS genre,
    ze.geom
   FROM m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text
  GROUP BY ze.nom, ze.zetype, ze.sign_visu, ze.geom
WITH DATA;



COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze
    IS 'Vue géométrique des zones d''embarquement des lignes du réseau TIC';

-- View: x_apps.xapps_geo_vmr_tic_ze_200m

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_200m;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_200m
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS gid,
    st_union(st_buffer(ze.geom, 200::double precision))::geometry(MultiPolygon,2154) AS geom
   FROM m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE ze.id_ze::text = p.id_ze::text AND l.id_ligne::text = p.id_ligne::text AND ze.statut::text = '10'::text
WITH DATA;



COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_200m
    IS 'Vue matérialisée rafraichie (trigger de rafraichissement si données ZE ou passage MAJ) géométrique des zones de chalandise (200m) de chaque arrêt actif';

-- View: x_apps.xapps_geo_vmr_tic_ze_500m

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_500m;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_500m
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS gid,
    st_union(st_buffer(ze.geom, 500::double precision))::geometry(MultiPolygon,2154) AS geom
   FROM m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE ze.id_ze::text = p.id_ze::text AND l.id_ligne::text = p.id_ligne::text AND ze.statut::text = '10'::text
WITH DATA;

COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_500m
    IS 'Vue matérialisée rafraichie (trigger de rafraichissement si données ZE ou passage MAJ) géométrique des zones de chalandise (500m) de chaque arrêt actif';
	      
-- View: x_apps.xapps_geo_vmr_tic_ze_nav

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_nav;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_nav
TABLESPACE pg_default
AS
 SELECT ze.id_ze,
    ze.nom,
    lu.ligne_urbaine,
    djf.ligne_djf,
    pu.ligne_pu,
    tad.ligne_tad,
    sco.ligne_sco,
    ze.geom
   FROM m_mobilite.geo_mob_rurbain_ze ze
     LEFT JOIN m_mobilite.geo_v_tic_ze_nav_lu lu ON ze.id_ze::text = lu.id_ze::text
     LEFT JOIN m_mobilite.geo_v_tic_ze_nav_djf djf ON ze.id_ze::text = djf.id_ze::text
     LEFT JOIN m_mobilite.geo_v_tic_ze_nav_pu pu ON ze.id_ze::text = pu.id_ze::text
     LEFT JOIN m_mobilite.geo_v_tic_ze_nav_tad tad ON ze.id_ze::text = tad.id_ze::text
     LEFT JOIN m_mobilite.geo_v_tic_ze_nav_sco sco ON ze.id_ze::text = sco.id_ze::text
  WHERE ze.statut::text = '10'::text
WITH DATA;



COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_ze_nav
    IS 'Vue matérialisée rafraichie (trigger de rafraichissement si données ZE ou passage MAJ) géométrique des zones d''embarquement avec les lignes en desserte du réseau TIC pour exploitation dans le navigateur carto (recherche et affichage)';

-- View: x_apps.xapps_geo_vmr_tic_zela

-- DROP MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_zela;

CREATE MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_zela
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS row_id,
    string_agg(l.genre::text, ','::text) AS genre,
    st_makeline(la.geom, ze.geom)::geometry(LineString,2154) AS geom
   FROM m_mobilite.geo_mob_rurbain_la la,
    m_mobilite.geo_mob_rurbain_ze ze,
    m_mobilite.an_mob_rurbain_passage p,
    m_mobilite.an_mob_rurbain_ligne l
  WHERE la.id_la::text = ze.id_la::text AND ze.id_ze::text = p.id_ze::text AND p.id_ligne::text = l.id_ligne::text
  GROUP BY (st_makeline(la.geom, ze.geom)::geometry(LineString,2154))
WITH DATA;



COMMENT ON MATERIALIZED VIEW x_apps.xapps_geo_vmr_tic_zela
    IS 'Vue géométrique des liens entre ZE et LA';

