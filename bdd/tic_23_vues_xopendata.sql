/* TIC V1.0*/
/* Creation des vues applicatives publiques */
/* tic_23_vues_xopendata.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */


-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      REINITILAISATION                                                     ###
-- ###                                                                                                                           ###
-- #################################################################################################################################

DROP MATERIALIZED VIEW IF EXISTS x_opendata.xopendata_geo_vmr_tic_ligne;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad;

DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu_djf;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu_pu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu_sco;
DROP VIEW IF EXISTS x_apps_public.xappspublic_an_v_tic_la_gdpu_tad;

DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_la_tampon;
DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_ze_gdpu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf;
DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu;
DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco;
DROP VIEW IF EXISTS x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad;

-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      VUES OPENDATA                                                        ###
-- ###                                                                                                                           ###
-- #################################################################################################################################


-- View: x_opendata.xopendata_geo_vmr_tic_ligne

-- DROP MATERIALIZED VIEW x_opendata.xopendata_geo_vmr_tic_ligne;

CREATE MATERIALIZED VIEW x_opendata.xopendata_geo_vmr_tic_ligne
TABLESPACE pg_default
AS
 SELECT row_number() OVER () AS gid,
    l.id_ligne,
    l.nom_court,
    l.nom_ligne,
    g.valeur AS genre,
    f.valeur AS fonct,
    st_linemerge(st_union(t.geom)) AS geom
   FROM m_mobilite.lk_voirie_rurbain j
     LEFT JOIN r_objet.geo_objet_troncon t ON t.id_tronc = j.id_tronc
     LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON j.id_ligne::text = l.id_ligne::text
     LEFT JOIN m_mobilite.lt_mob_rurbain_genre g ON l.genre::text = g.code::text
     LEFT JOIN m_mobilite.lt_mob_rurbain_fonct f ON l.fonct::text = f.code::text
  WHERE j.statut::text = '10'::text AND l.nom_court::text <> 'Non renseigné'::text
  GROUP BY l.id_ligne, l.nom_court, g.valeur, f.valeur, l.nom_ligne
  ORDER BY l.nom_court
WITH DATA;


COMMENT ON MATERIALIZED VIEW x_opendata.xopendata_geo_vmr_tic_ligne
    IS 'Vue géométrique sur l''iténaire de toutes les lignes du réseau TIC (pour export téléchargement métadonnée)';

                                                    
-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      VUES GRANDPUBLIC                                                     ###
-- ###                                                                                                                           ###
-- #################################################################################################################################

   -- View: x_apps_public.xappspublic_an_v_tic_la_gdpu

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu
 AS
 SELECT la.id_la,
    la.nom,
    lu1.num_ligne AS n_lu1,
    lu2.num_ligne AS n_lu2,
    djf.num_ligne AS n_djf,
    tad.num_ligne AS n_tad,
    pu.num_ligne AS n_pu,
    sco.num_ligne AS n_sco,
    ((((
        CASE
            WHEN lu1.num_ligne IS NOT NULL THEN lu1.num_ligne
            ELSE ''::text
        END ||
        CASE
            WHEN lu2.num_ligne IS NOT NULL THEN '-'::text || lu2.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN djf.num_ligne IS NOT NULL THEN '-'::text || djf.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN tad.num_ligne IS NOT NULL THEN '-'::text || tad.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN pu.num_ligne IS NOT NULL THEN '-'::text || pu.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN sco.num_ligne IS NOT NULL THEN '-'::text || sco.num_ligne
            ELSE ''::text
        END AS n_tic,
        CASE
            WHEN lu1.num_ligne ~~ '1%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_1.png"/>'::text
            ELSE NULL::text
        END AS img_l1,
        CASE
            WHEN lu1.num_ligne = '2'::text OR lu1.num_ligne ~~ '%-2'::text OR lu1.num_ligne ~~ '2-%'::text OR lu1.num_ligne ~~ '%-2-%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_2.png"/>'::text
            ELSE NULL::text
        END AS img_l2,
        CASE
            WHEN lu1.num_ligne ~~ '%3%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_3.png"/>'::text
            ELSE NULL::text
        END AS img_l3,
        CASE
            WHEN lu1.num_ligne ~~ '%4%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_4.png"/>'::text
            ELSE NULL::text
        END AS img_l4,
        CASE
            WHEN lu1.num_ligne ~~ '%5%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_5.png"/>'::text
            ELSE NULL::text
        END AS img_l5,
        CASE
            WHEN lu1.num_ligne ~~ '%6%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_6.png"/>'::text
            ELSE NULL::text
        END AS img_l6,
        CASE
            WHEN lu2.num_ligne ~~ 'ARC Express'::text OR lu2.num_ligne ~~ '%-ZA1'::text OR lu2.num_ligne ~~ '%-ZA1-%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_ARCExpress.png"/>'::text
            ELSE NULL::text
        END AS img_larcexpress,
        CASE
            WHEN lu2.num_ligne ~~ 'Navette HM'::text OR lu2.num_ligne ~~ '%-Navette HM'::text OR lu2.num_ligne ~~ '%-Navette HM-%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_NavetteHM.png"/>'::text
            ELSE NULL::text
        END AS img_hm,
        CASE
            WHEN djf.num_ligne ~~ 'D1'::text OR djf.num_ligne ~~ 'D1%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_D1.png"/>'::text
            ELSE NULL::text
        END AS img_ld1,
        CASE
            WHEN djf.num_ligne ~~ 'D2'::text OR djf.num_ligne ~~ '%-D2'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_D2.png"/>'::text
            ELSE NULL::text
        END AS img_ld2,
        CASE
            WHEN tad.num_ligne ~~ '%13%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_13.png"/>'::text
            ELSE NULL::text
        END AS img_l13,
        CASE
            WHEN tad.num_ligne ~~ '%14%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_14.png"/>'::text
            ELSE NULL::text
        END AS img_l14,
        CASE
            WHEN tad.num_ligne ~~ '%15%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_15.png"/>'::text
            ELSE NULL::text
        END AS img_l15,
        CASE
            WHEN tad.num_ligne ~~ '%16%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_16.png"/>'::text
            ELSE NULL::text
        END AS img_l16,
        CASE
            WHEN tad.num_ligne ~~ '%17%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_17.png"/>'::text
            ELSE NULL::text
        END AS img_l17,
        CASE
            WHEN tad.num_ligne ~~ '%18%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_18.png"/>'::text
            ELSE NULL::text
        END AS img_l18,
        CASE
            WHEN tad.num_ligne ~~ '%19%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_19.png"/>'::text
            ELSE NULL::text
        END AS img_l19,
        CASE
            WHEN tad.num_ligne ~~ '%20%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_20.png"/>'::text
            ELSE NULL::text
        END AS img_l20,
        CASE
            WHEN pu.num_ligne ~~ '%101%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_101.png"/>'::text
            ELSE NULL::text
        END AS img_l101,
        CASE
            WHEN pu.num_ligne ~~ '%103%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_103.png"/>'::text
            ELSE NULL::text
        END AS img_l103,
        CASE
            WHEN pu.num_ligne ~~ '%106%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_106.png"/>'::text
            ELSE NULL::text
        END AS img_l106,
        CASE
            WHEN pu.num_ligne ~~ '%107%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_107.png"/>'::text
            ELSE NULL::text
        END AS img_l107,
        CASE
            WHEN pu.num_ligne ~~ '%109%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_109.png"/>'::text
            ELSE NULL::text
        END AS img_l109,
        CASE
            WHEN pu.num_ligne ~~ '%111%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_111.png"/>'::text
            ELSE NULL::text
        END AS img_l111,
        CASE
            WHEN sco.num_ligne ~~ '%102%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_102.png"/>'::text
            ELSE NULL::text
        END AS img_l102,
        CASE
            WHEN sco.num_ligne ~~ '%104%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_104.png"/>'::text
            ELSE NULL::text
        END AS img_l104,
        CASE
            WHEN sco.num_ligne ~~ '%108%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_108.png"/>'::text
            ELSE NULL::text
        END AS img_l108,
        CASE
            WHEN sco.num_ligne ~~ '%110%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_110.png"/>'::text
            ELSE NULL::text
        END AS img_l110
   FROM m_mobilite.geo_mob_rurbain_la la
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1 lu1 ON la.id_la::text = lu1.id_la::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2 lu2 ON la.id_la::text = lu2.id_la::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_la_gdpu_djf djf ON la.id_la::text = djf.id_la::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_la_gdpu_pu pu ON la.id_la::text = pu.id_la::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_la_gdpu_sco sco ON la.id_la::text = sco.id_la::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_la_gdpu_tad tad ON la.id_la::text = tad.id_la::text
  WHERE la.statut::text = '10'::text
  ORDER BY la.id_la;

COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes en desserte du réseau TIC (intégré au FME export pour l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle)';

-- View: x_apps_public.xappspublic_an_v_tic_la_gdpu_djf

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_djf;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_djf
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT ze.id_la,
            l.nom_court
           FROM m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND ze.id_ze::text = p.id_ze::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text)
          ORDER BY ze.id_la
        ), req_la AS (
         SELECT geo_mob_rurbain_la.id_la,
            geo_mob_rurbain_la.nom
           FROM m_mobilite.geo_mob_rurbain_la
        )
 SELECT req_num_lu.id_la,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu,
    req_la
  WHERE req_num_lu.id_la::text = req_la.id_la::text
  GROUP BY req_num_lu.id_la;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_djf
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes dimanche et jours fériés en desserte du réseau TIC (intégré à la vue xapps_an_v_tic_la_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';


-- View: x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT ze.id_la,
            l.nom_court
           FROM m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND ze.id_ze::text = p.id_ze::text AND (l.nom_court::text = '1'::text OR l.nom_court::text = '2'::text OR l.nom_court::text = '3'::text OR l.nom_court::text = '4'::text OR l.nom_court::text = '5'::text OR l.nom_court::text = '6'::text)
        ), req_la AS (
         SELECT geo_mob_rurbain_la.id_la,
            geo_mob_rurbain_la.nom
           FROM m_mobilite.geo_mob_rurbain_la
        )
 SELECT req_num_lu.id_la,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu,
    req_la
  WHERE req_num_lu.id_la::text = req_la.id_la::text
  GROUP BY req_num_lu.id_la;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_1
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes urbaines (1 à 6) en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';


-- View: x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT ze.id_la,
            l.nom_court
           FROM m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND ze.id_ze::text = p.id_ze::text AND (l.nom_court::text = 'ARC Express'::text OR l.nom_court::text = 'Navette HM'::text)
        ), req_la AS (
         SELECT geo_mob_rurbain_la.id_la,
            geo_mob_rurbain_la.nom
           FROM m_mobilite.geo_mob_rurbain_la
        )
 SELECT req_num_lu.id_la,
    replace(replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text), '"'::text, ''::text) AS num_ligne
   FROM req_num_lu,
    req_la
  WHERE req_num_lu.id_la::text = req_la.id_la::text
  GROUP BY req_num_lu.id_la;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_lu_2
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes urbaines (ARC Express et HM) en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';


-- View: x_apps_public.xappspublic_an_v_tic_la_gdpu_pu

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_pu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_pu
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT ze.id_la,
            l.nom_court
           FROM m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND ze.id_ze::text = p.id_ze::text AND (l.nom_court::text = '101'::text OR l.nom_court::text = '103'::text OR l.nom_court::text = '106'::text OR l.nom_court::text = '107'::text OR l.nom_court::text = '109'::text OR l.nom_court::text = '111'::text)
        ), req_la AS (
         SELECT geo_mob_rurbain_la.id_la,
            geo_mob_rurbain_la.nom
           FROM m_mobilite.geo_mob_rurbain_la
        )
 SELECT req_num_lu.id_la,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu,
    req_la
  WHERE req_num_lu.id_la::text = req_la.id_la::text
  GROUP BY req_num_lu.id_la;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_pu
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes péri_urbain (hors ARC Express) en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';

-- View: x_apps_public.xappspublic_an_v_tic_la_gdpu_sco

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_sco;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_sco
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT ze.id_la,
            l.nom_court
           FROM m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND ze.id_ze::text = p.id_ze::text AND (l.nom_court::text = '102'::text OR l.nom_court::text = '104'::text OR l.nom_court::text = '108'::text OR l.nom_court::text = '110'::text)
        ), req_la AS (
         SELECT geo_mob_rurbain_la.id_la,
            geo_mob_rurbain_la.nom
           FROM m_mobilite.geo_mob_rurbain_la
        )
 SELECT req_num_lu.id_la,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu,
    req_la
  WHERE req_num_lu.id_la::text = req_la.id_la::text
  GROUP BY req_num_lu.id_la;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_sco
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';


-- View: x_apps_public.xappspublic_an_v_tic_la_gdpu_tad

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_tad;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_tad
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT ze.id_la,
            l.nom_court
           FROM m_mobilite.geo_mob_rurbain_ze ze,
            m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND ze.id_ze::text = p.id_ze::text AND (l.nom_court::text = '13'::text OR l.nom_court::text = '14'::text OR l.nom_court::text = '15'::text OR l.nom_court::text = '16'::text OR l.nom_court::text = '17'::text OR l.nom_court::text = '18'::text OR l.nom_court::text = '19'::text OR l.nom_court::text = '20'::text)
        ), req_la AS (
         SELECT geo_mob_rurbain_la.id_la,
            geo_mob_rurbain_la.nom
           FROM m_mobilite.geo_mob_rurbain_la
        )
 SELECT req_num_lu.id_la,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu,
    req_la
  WHERE req_num_lu.id_la::text = req_la.id_la::text
  GROUP BY req_num_lu.id_la;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_la_gdpu_tad
    IS 'Vue alphanumétique des lieux d''arrêt avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_la_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';


-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu
 AS
 SELECT ze.id_ze,
    lu1.num_ligne AS n_lu1,
    lu2.num_ligne AS n_lu2,
    djf.num_ligne AS n_djf,
    tad.num_ligne AS n_tad,
    pu.num_ligne AS n_pu,
    sco.num_ligne AS n_sco,
    ((((
        CASE
            WHEN lu1.num_ligne IS NOT NULL THEN lu1.num_ligne
            ELSE ''::text
        END ||
        CASE
            WHEN lu2.num_ligne IS NOT NULL THEN '-'::text || lu2.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN djf.num_ligne IS NOT NULL THEN '-'::text || djf.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN tad.num_ligne IS NOT NULL THEN '-'::text || tad.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN pu.num_ligne IS NOT NULL THEN '-'::text || pu.num_ligne
            ELSE ''::text
        END) ||
        CASE
            WHEN sco.num_ligne IS NOT NULL THEN '-'::text || sco.num_ligne
            ELSE ''::text
        END AS n_tic,
        CASE
            WHEN lu1.num_ligne ~~ '1%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_1.png"/>'::text
            ELSE NULL::text
        END AS img_l1,
        CASE
            WHEN lu1.num_ligne = '2'::text OR lu1.num_ligne ~~ '%-2'::text OR lu1.num_ligne ~~ '2-%'::text OR lu1.num_ligne ~~ '%-2-%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_2.png"/>'::text
            ELSE NULL::text
        END AS img_l2,
        CASE
            WHEN lu1.num_ligne ~~ '%3%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_3.png"/>'::text
            ELSE NULL::text
        END AS img_l3,
        CASE
            WHEN lu1.num_ligne ~~ '%4%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_4.png"/>'::text
            ELSE NULL::text
        END AS img_l4,
        CASE
            WHEN lu1.num_ligne ~~ '%5%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_5.png"/>'::text
            ELSE NULL::text
        END AS img_l5,
        CASE
            WHEN lu1.num_ligne ~~ '%6%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_6.png"/>'::text
            ELSE NULL::text
        END AS img_l6,
        CASE
            WHEN lu2.num_ligne ~~ 'ARC Express'::text OR lu2.num_ligne ~~ '%-ARC Express'::text OR lu2.num_ligne ~~ '%-ARC Express-%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_ARCExpress.png"/>'::text
            ELSE NULL::text
        END AS img_lae,
        CASE
            WHEN lu2.num_ligne ~~ 'Navette HM'::text OR lu2.num_ligne ~~ '%-Navette HM'::text OR lu2.num_ligne ~~ '%-Navette HM-%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_NavetteHM.png"/>'::text
            ELSE NULL::text
        END AS img_hm,
        CASE
            WHEN djf.num_ligne ~~ 'D1'::text OR djf.num_ligne ~~ 'D1%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_D1.png"/>'::text
            ELSE NULL::text
        END AS img_ld1,
        CASE
            WHEN djf.num_ligne ~~ 'D2'::text OR djf.num_ligne ~~ '%-D2'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_D2.png"/>'::text
            ELSE NULL::text
        END AS img_ld2,
        CASE
            WHEN tad.num_ligne ~~ '%13%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_13.png"/>'::text
            ELSE NULL::text
        END AS img_l13,
        CASE
            WHEN tad.num_ligne ~~ '%14%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_14.png"/>'::text
            ELSE NULL::text
        END AS img_l14,
        CASE
            WHEN tad.num_ligne ~~ '%15%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_15.png"/>'::text
            ELSE NULL::text
        END AS img_l15,
        CASE
            WHEN tad.num_ligne ~~ '%16%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_16.png"/>'::text
            ELSE NULL::text
        END AS img_l16,
        CASE
            WHEN tad.num_ligne ~~ '%17%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_17.png"/>'::text
            ELSE NULL::text
        END AS img_l17,
        CASE
            WHEN tad.num_ligne ~~ '%18%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_18.png"/>'::text
            ELSE NULL::text
        END AS img_l18,
        CASE
            WHEN tad.num_ligne ~~ '%19%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_19.png"/>'::text
            ELSE NULL::text
        END AS img_l19,
        CASE
            WHEN tad.num_ligne ~~ '%20%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_20.png"/>'::text
            ELSE NULL::text
        END AS img_l20,
        CASE
            WHEN pu.num_ligne ~~ '%101%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_101.png"/>'::text
            ELSE NULL::text
        END AS img_l101,
        CASE
            WHEN pu.num_ligne ~~ '%103%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_103.png"/>'::text
            ELSE NULL::text
        END AS img_l103,
        CASE
            WHEN pu.num_ligne ~~ '%106%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_106.png"/>'::text
            ELSE NULL::text
        END AS img_l106,
        CASE
            WHEN pu.num_ligne ~~ '%107%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_107.png"/>'::text
            ELSE NULL::text
        END AS img_l107,
        CASE
            WHEN pu.num_ligne ~~ '%109%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_109.png"/>'::text
            ELSE NULL::text
        END AS img_l109,
        CASE
            WHEN pu.num_ligne ~~ '%111%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_111.png"/>'::text
            ELSE NULL::text
        END AS img_l111,
        CASE
            WHEN sco.num_ligne ~~ '%102%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_102.png"/>'::text
            ELSE NULL::text
        END AS img_l102,
        CASE
            WHEN sco.num_ligne ~~ '%104%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_104.png"/>'::text
            ELSE NULL::text
        END AS img_l104,
        CASE
            WHEN sco.num_ligne ~~ '%108%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_108.png"/>'::text
            ELSE NULL::text
        END AS img_l108,
        CASE
            WHEN sco.num_ligne ~~ '%110%'::text THEN '<img src="http://geo.compiegnois.fr/documents/metiers/mob/tic/logo/ligne_110.png"/>'::text
            ELSE NULL::text
        END AS img_l110
   FROM m_mobilite.geo_mob_rurbain_ze ze
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1 lu1 ON ze.id_ze::text = lu1.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2 lu2 ON ze.id_ze::text = lu2.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf djf ON ze.id_ze::text = djf.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu pu ON ze.id_ze::text = pu.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco sco ON ze.id_ze::text = sco.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad tad ON ze.id_ze::text = tad.id_ze::text
  WHERE ze.statut::text = '10'::text
  ORDER BY ze.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes en desserte du réseau TIC  (intégré au FME d''export pour l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle)';

-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT p.id_ze,
            l.nom_court
           FROM m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text)
        )
 SELECT req_num_lu.id_ze,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu
  GROUP BY req_num_lu.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_djf
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes dimanche et jours fériés en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';


-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT p.id_ze,
            l.nom_court
           FROM m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND (l.nom_court::text = '1'::text OR l.nom_court::text = '2'::text OR l.nom_court::text = '3'::text OR l.nom_court::text = '4'::text OR l.nom_court::text = '5'::text OR l.nom_court::text = '6'::text)
        )
 SELECT req_num_lu.id_ze,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu
  GROUP BY req_num_lu.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_1
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes urbaines (1 à 6) en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';

-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT p.id_ze,
            l.nom_court
           FROM m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND (l.nom_court::text = 'ARC Express'::text OR l.nom_court::text = 'Navette HM'::text)
        )
 SELECT req_num_lu.id_ze,
    replace(replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text), '"'::text, ''::text) AS num_ligne
   FROM req_num_lu
  GROUP BY req_num_lu.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_lu_2
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes urbaines (ARC Express et HM) en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';

-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT p.id_ze,
            l.nom_court
           FROM m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND (l.nom_court::text = '101'::text OR l.nom_court::text = '103'::text OR l.nom_court::text = '106'::text OR l.nom_court::text = '107'::text OR l.nom_court::text = '109'::text OR l.nom_court::text = '111'::text)
        )
 SELECT req_num_lu.id_ze,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu
  GROUP BY req_num_lu.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_pu
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes péri_urbain (hors ARC Express) en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';

-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT p.id_ze,
            l.nom_court
           FROM m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND (l.nom_court::text = '102'::text OR l.nom_court::text = '104'::text OR l.nom_court::text = '108'::text OR l.nom_court::text = '110'::text)
        )
 SELECT req_num_lu.id_ze,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu
  GROUP BY req_num_lu.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_sco
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';

-- View: x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad

-- DROP VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad
 AS
 WITH req_num_lu AS (
         SELECT DISTINCT p.id_ze,
            l.nom_court
           FROM m_mobilite.an_mob_rurbain_passage p,
            m_mobilite.an_mob_rurbain_ligne l
          WHERE p.id_ligne::text = l.id_ligne::text AND (l.nom_court::text = '13'::text OR l.nom_court::text = '14'::text OR l.nom_court::text = '15'::text OR l.nom_court::text = '16'::text OR l.nom_court::text = '17'::text OR l.nom_court::text = '18'::text OR l.nom_court::text = '19'::text OR l.nom_court::text = '20'::text)
        )
 SELECT req_num_lu.id_ze,
    replace(replace(replace(array_agg(req_num_lu.nom_court ORDER BY (req_num_lu.nom_court::text))::text, '{'::text, ''::text), '}'::text, ''::text), ','::text, '-'::text) AS num_ligne
   FROM req_num_lu
  GROUP BY req_num_lu.id_ze;


COMMENT ON VIEW x_apps_public.xappspublic_an_v_tic_ze_gdpu_tad
    IS 'Vue alphanumétique des zones d''embarquement avec le numéro des lignes scolaires en desserte du réseau TIC (intégré à la vue an_v_tic_ze_gdpu pour export dans l''application GEO Gd Public pour l''affichage des lignes dans les résultats de recherche et info-bulle';

-- View: x_apps_public.xappspublic_geo_v_tic_la_tampon

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_la_tampon;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_la_tampon
 AS
 SELECT geo_mob_rurbain_la.id_la,
    geo_mob_rurbain_la.date_sai,
    geo_mob_rurbain_la.date_maj,
    geo_mob_rurbain_la.op_sai,
    geo_mob_rurbain_la.modification,
    geo_mob_rurbain_la.statut,
    geo_mob_rurbain_la.nom,
    geo_mob_rurbain_la.nom_court,
    geo_mob_rurbain_la.description,
    geo_mob_rurbain_la.x_l93,
    geo_mob_rurbain_la.y_l93,
    geo_mob_rurbain_la.date_deb,
    geo_mob_rurbain_la.date_fin,
    geo_mob_rurbain_la.hierarchie,
    geo_mob_rurbain_la.insee,
    geo_mob_rurbain_la.commune,
    geo_mob_rurbain_la.id_parent,
    geo_mob_rurbain_la.sens,
    geo_mob_rurbain_la.angle,
    geo_mob_rurbain_la.observ,
    geo_mob_rurbain_la.v_tampon,
    geo_mob_rurbain_la.geom2
   FROM m_mobilite.geo_mob_rurbain_la
  WHERE geo_mob_rurbain_la.statut::text = '10'::text
  ORDER BY geo_mob_rurbain_la.nom;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_la_tampon
    IS 'Vue géométrique contenant les tampons d''emprise des lieux d''arrêt pour EXPORT FME et recherche des adresse dans ses tampons pour remonter l''arrêt et les lignes en desserte';


-- View: x_apps_public.xappspublic_geo_v_tic_ze_gdpu

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu
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
     LEFT JOIN x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu lu ON ze.id_ze::text = lu.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf djf ON ze.id_ze::text = djf.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu pu ON ze.id_ze::text = pu.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad tad ON ze.id_ze::text = tad.id_ze::text
     LEFT JOIN x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco sco ON ze.id_ze::text = sco.id_ze::text
  WHERE ze.statut::text = '10'::text;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu
    IS 'Vue géométrique des zones d''embarquement avec les lignes en desserte du réseau TIC (intégré  au FME d''export pour exploitation dans l''application grand public Plan d''Agglomération Interactif (fiche information))';

-- View: x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf
 AS
 WITH req_ze AS (
         SELECT geo_mob_rurbain_ze.id_ze,
            geo_mob_rurbain_ze.nom,
            geo_mob_rurbain_ze.geom
           FROM m_mobilite.geo_mob_rurbain_ze
          WHERE geo_mob_rurbain_ze.statut::text = '10'::text
        ), req_desserte_djf AS (
         SELECT DISTINCT p.id_ze,
            (l.nom_court::text || ' vers '::text) || t.valeur::text AS nom_court
           FROM m_mobilite.an_mob_rurbain_passage p
             LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON p.id_ligne::text = l.id_ligne::text
             LEFT JOIN m_mobilite.lt_mob_rurbain_terminus t ON p.direction::text = t.code::text
          WHERE l.genre::text = '10'::text AND (l.nom_court::text = 'D1'::text OR l.nom_court::text = 'D2'::text) AND (p.t_passage::text = '22'::text OR p.t_passage::text = '10'::text OR p.t_passage::text = '32'::text OR p.t_passage::text = '40'::text)
          ORDER BY p.id_ze
        )
 SELECT DISTINCT req_ze.id_ze,
    req_ze.nom,
    replace(replace(replace(replace(array_agg(req_desserte_djf.nom_court ORDER BY req_desserte_djf.nom_court)::text, '"'::text, ''::text), '}'::text, ''::text), '{'::text, ''::text), ','::text, chr(10))::character varying(500) AS ligne_djf,
    req_ze.geom
   FROM req_ze,
    req_desserte_djf
  WHERE req_ze.id_ze::text = req_desserte_djf.id_ze::text
  GROUP BY req_ze.id_ze, req_ze.nom, req_ze.geom;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_djf
    IS 'Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes Dimanche et jours fériés. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l ''affichage de la fiche info dans l''application grand public Plan d''Agglo interactif';


-- View: x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu
 AS
 WITH req_ze AS (
         SELECT geo_mob_rurbain_ze.id_ze,
            geo_mob_rurbain_ze.nom,
            geo_mob_rurbain_ze.geom
           FROM m_mobilite.geo_mob_rurbain_ze
          WHERE geo_mob_rurbain_ze.statut::text = '10'::text
        ), req_desserte_lu AS (
         SELECT DISTINCT p.id_ze,
            (l.nom_court::text || ' vers '::text) || t.valeur::text AS nom_court
           FROM m_mobilite.an_mob_rurbain_passage p
             LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON p.id_ligne::text = l.id_ligne::text
             LEFT JOIN m_mobilite.lt_mob_rurbain_terminus t ON p.direction::text = t.code::text
          WHERE l.genre::text = '10'::text AND l.nom_court::text <> 'D1'::text AND l.nom_court::text <> 'D2'::text AND (p.t_passage::text = '22'::text OR p.t_passage::text = '10'::text OR p.t_passage::text = '31'::text OR p.t_passage::text = '40'::text)
          ORDER BY p.id_ze
        )
 SELECT DISTINCT req_ze.id_ze,
    req_ze.nom,
    replace(replace(replace(replace(array_agg(req_desserte_lu.nom_court ORDER BY req_desserte_lu.nom_court)::text, '"'::text, ''::text), '}'::text, ''::text), '{'::text, ''::text), ','::text, chr(10))::character varying(500) AS ligne_urbaine,
    req_ze.geom
   FROM req_ze,
    req_desserte_lu
  WHERE req_ze.id_ze::text = req_desserte_lu.id_ze::text
  GROUP BY req_ze.id_ze, req_ze.nom, req_ze.geom;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_lu
    IS 'Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes urbaines. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l ''affichage de la fiche info dans l''application grand public Plan d''Agglo interactif';

-- View: x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu
 AS
 WITH req_ze AS (
         SELECT geo_mob_rurbain_ze.id_ze,
            geo_mob_rurbain_ze.nom,
            geo_mob_rurbain_ze.geom
           FROM m_mobilite.geo_mob_rurbain_ze
          WHERE geo_mob_rurbain_ze.statut::text = '10'::text
        ), req_desserte_pu AS (
         SELECT DISTINCT p.id_ze,
            (l.nom_court::text || ' '::text) || t.valeur::text AS nom_court
           FROM m_mobilite.an_mob_rurbain_passage p
             LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON p.id_ligne::text = l.id_ligne::text
             LEFT JOIN m_mobilite.lt_mob_rurbain_terminus t ON p.direction::text = t.code::text
          WHERE l.genre::text = '20'::text AND (p.t_passage::text = '22'::text OR p.t_passage::text = '10'::text OR p.t_passage::text = '31'::text OR p.t_passage::text = '40'::text)
          ORDER BY p.id_ze
        )
 SELECT DISTINCT req_ze.id_ze,
    req_ze.nom,
    replace(replace(replace(replace(array_agg(req_desserte_pu.nom_court ORDER BY req_desserte_pu.nom_court)::text, '"'::text, ''::text), '}'::text, ''::text), '{'::text, ''::text), ','::text, chr(10))::character varying(500) AS ligne_pu,
    req_ze.geom
   FROM req_ze,
    req_desserte_pu
  WHERE req_ze.id_ze::text = req_desserte_pu.id_ze::text
  GROUP BY req_ze.id_ze, req_ze.nom, req_ze.geom;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_pu
    IS 'Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes péri-urbaines. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l''affichage de la fiche info dans l''application grand public Plan d''Agglo interactif';

-- View: x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco
 AS
 WITH req_ze AS (
         SELECT geo_mob_rurbain_ze.id_ze,
            geo_mob_rurbain_ze.nom,
            geo_mob_rurbain_ze.geom
           FROM m_mobilite.geo_mob_rurbain_ze
          WHERE geo_mob_rurbain_ze.statut::text = '10'::text
        ), req_desserte_pu AS (
         SELECT DISTINCT p.id_ze,
            (l.nom_court::text || ' Vers '::text) || t.valeur::text AS nom_court
           FROM m_mobilite.an_mob_rurbain_passage p
             LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON p.id_ligne::text = l.id_ligne::text
             LEFT JOIN m_mobilite.lt_mob_rurbain_terminus t ON p.direction::text = t.code::text
          WHERE l.genre::text = '40'::text AND (p.t_passage::text = '22'::text OR p.t_passage::text = '10'::text OR p.t_passage::text = '31'::text OR p.t_passage::text = '40'::text)
          ORDER BY p.id_ze
        )
 SELECT DISTINCT req_ze.id_ze,
    req_ze.nom,
    replace(replace(replace(replace(array_agg(req_desserte_pu.nom_court ORDER BY req_desserte_pu.nom_court)::text, '"'::text, ''::text), '}'::text, ''::text), '{'::text, ''::text), ','::text, chr(10))::character varying(500) AS ligne_sco,
    req_ze.geom
   FROM req_ze,
    req_desserte_pu
  WHERE req_ze.id_ze::text = req_desserte_pu.id_ze::text
  GROUP BY req_ze.id_ze, req_ze.nom, req_ze.geom;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_sco
    IS 'Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes scolaires. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l''affichage de la fiche info dans l''application grand public Plan d''''Agglo interactif';

-- View: x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad

-- DROP VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad;

CREATE OR REPLACE VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad
 AS
 WITH req_ze AS (
         SELECT geo_mob_rurbain_ze.id_ze,
            geo_mob_rurbain_ze.nom,
            geo_mob_rurbain_ze.geom
           FROM m_mobilite.geo_mob_rurbain_ze
          WHERE geo_mob_rurbain_ze.statut::text = '10'::text
        ), req_desserte_pu AS (
         SELECT DISTINCT p.id_ze,
            (l.nom_court::text || ' Vers '::text) || t.valeur::text AS nom_court
           FROM m_mobilite.an_mob_rurbain_passage p
             LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON p.id_ligne::text = l.id_ligne::text
             LEFT JOIN m_mobilite.lt_mob_rurbain_terminus t ON p.direction::text = t.code::text
          WHERE l.genre::text = '30'::text AND (p.t_passage::text = '22'::text OR p.t_passage::text = '10'::text OR p.t_passage::text = '31'::text OR p.t_passage::text = '40'::text)
          ORDER BY p.id_ze
        )
 SELECT DISTINCT req_ze.id_ze,
    req_ze.nom,
    replace(replace(replace(replace(array_agg(req_desserte_pu.nom_court ORDER BY req_desserte_pu.nom_court)::text, '"'::text, ''::text), '}'::text, ''::text), '{'::text, ''::text), ','::text, chr(10))::character varying(500) AS ligne_tad,
    req_ze.geom
   FROM req_ze,
    req_desserte_pu
  WHERE req_ze.id_ze::text = req_desserte_pu.id_ze::text
  GROUP BY req_ze.id_ze, req_ze.nom, req_ze.geom;


COMMENT ON VIEW x_apps_public.xappspublic_geo_v_tic_ze_gdpu_tad
    IS 'Vue géométrique formattant pour chaque ZE le n° de ligne et sa direction pour les lignes AlloTic. Cette vue permet de générer la vue geo_v_tic_ze_gdpu (export shape via FME) pour la gestion de l''affichage de la fiche info dans l''application grand public Plan d''Agglo interactif';









                       
                          
