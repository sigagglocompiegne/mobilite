/* TIC V1.0*/
/* Creation des vues de gestion */
/* tic_20_vues_gestion.sql */
/*PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */


-- ###############################################################################################################################
-- ###                                                                                                                         ###
-- ###                                                           DROP                                                          ###
-- ###                                                                                                                         ###
-- ###############################################################################################################################


DROP VIEW IF EXISTS m_mobilite.geo_v_tic_gestion_desserte_ze;
DROP VIEW IF EXISTS m_mobilite.geo_v_tic_gestion_doc_ze;
DROP VIEW IF EXISTS m_mobilite.geo_v_tic_gestion_ligne;
DROP VIEW IF EXISTS m_mobilite.geo_v_tic_gestion_ligne_insert;
DROP VIEW IF EXISTS m_mobilite.geo_v_tic_ligne_plan;


-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      FONCTIONS                                                            ###
-- ###                                                                                                                           ###
-- #################################################################################################################################

-- ############################################################ ft_m_geo_v_tic_gestion_desserte_ze #########################################     

-- FUNCTION: m_mobilite.ft_m_geo_v_tic_gestion_desserte_ze()

-- DROP FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_desserte_ze();

CREATE FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_desserte_ze()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$


BEGIN

IF new.n_passage = '10' THEN

INSERT INTO m_mobilite.an_mob_rurbain_passage (id_ze,id_ligne,op_sai,t_passage,direction,fonct)
SELECT new.id_ze,new.id_ligne,new.op_sai,new.t_passage,new.direction,new.fonct;

RETURN new;

END IF;

IF new.n_passage = '20' THEN

UPDATE m_mobilite.an_mob_rurbain_passage 

	SET id_ligne=new.id_ligne, op_sai=new.op_sai, t_passage=new.t_passage, direction=new.direction,fonct=new.fonct

WHERE id_en = new.id_en;

RETURN new;

END IF;


IF new.n_passage = '30' THEN

DELETE FROM m_mobilite.an_mob_rurbain_passage WHERE id_en = old.id_en;

RETURN old;

END IF;

RETURN new;


END;
$BODY$;

COMMENT ON FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_desserte_ze()
    IS 'Fonction trigger pour la gestion des segments cyclables';


CREATE TRIGGER t_t1_geo_v_tic_gestion_desserte_ze
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_mobilite.geo_v_tic_gestion_desserte_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_v_tic_gestion_desserte_ze();
    
-- ############################################################ ft_m_geo_v_tic_gestion_doc_ze ######################################### 

-- FUNCTION: m_mobilite.ft_m_geo_v_tic_gestion_doc_ze()

-- DROP FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_doc_ze();

CREATE FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_doc_ze()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$


BEGIN
      
IF new.n_doc = '10' THEN

INSERT INTO m_mobilite.an_mob_rurbain_docze (id_ze,op_sai,f_doc,l_doc,d_doc,t_doc)
SELECT new.id_ze,new.op_sai,new.f_doc,new.l_doc,new.d_doc,new.t_doc;

RETURN new;

END IF;

IF new.n_doc = '20' THEN

UPDATE m_mobilite.an_mob_rurbain_docze 

	SET op_sai=new.op_sai, f_doc=new.f_doc, l_doc=new.l_doc,d_doc=new.d_doc, t_doc=new.t_doc

WHERE id_doc = new.id_doc;

RETURN new;

END IF;


IF new.n_doc = '30' THEN

DELETE FROM m_mobilite.an_mob_rurbain_docze WHERE id_doc = old.id_doc;

RETURN old;

END IF;

RETURN new;


END;
$BODY$;

COMMENT ON FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_doc_ze()
    IS 'Fonction trigger pour la gestion des documents liés au zone d''embarquement';


CREATE TRIGGER t_t1_geo_v_tic_gestion_doc_ze
    INSTEAD OF INSERT OR DELETE OR UPDATE 
    ON m_mobilite.geo_v_tic_gestion_doc_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_v_tic_gestion_doc_ze();


-- ############################################################ ft_m_geo_v_tic_gestion_ligne ######################################### 

-- FUNCTION: m_mobilite.ft_m_geo_v_tic_gestion_ligne()

-- DROP FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_ligne();

CREATE FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_ligne()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$



BEGIN
	
	-- si je supprimer un tronçon desservi par une ligne du réseau TIC
	IF new.typ_modif = '30' THEN
	        DELETE FROM m_mobilite.lk_voirie_rurbain WHERE id_tronc=new.id_troncn AND id_ligne=new.id_lignen;
	END IF;

        -- si je modifie un tronçon desservi déjà desservi par une ligne du réseau TIC
	IF new.typ_modif = '20' THEN
                UPDATE m_mobilite.lk_voirie_rurbain 
                SET 
                   sens = new.sens,
                   desserte = new.desserte,
                   statut = new.statut,
                   n_car = new.n_car
                WHERE id_tronc=new.id_troncn AND id_ligne=new.id_lignen;
	END IF;


	return new;
END
$BODY$;


CREATE TRIGGER t_t1_geo_v_tic_gestion_ligne
    INSTEAD OF UPDATE 
    ON m_mobilite.geo_v_tic_gestion_ligne
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_v_tic_gestion_ligne();
    
-- ############################################################ ft_m_geo_v_tic_gestion_ligne_insert #########################################     

-- FUNCTION: m_mobilite.ft_m_geo_v_tic_gestion_ligne_insert()

-- DROP FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_ligne_insert();

CREATE FUNCTION m_mobilite.ft_m_geo_v_tic_gestion_ligne_insert()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$


BEGIN
        -- fonction uniquement pour insérer une desserte de TIC sur un tronçon


		INSERT INTO m_mobilite.lk_voirie_rurbain VALUES (new.id_tronc,new.id_lignen, new.sensn, new.desserten, new.statutn,now(),now(), new.n_carn);



	return new;
END
$BODY$;

CREATE TRIGGER t_t1_geo_v_tic_gestion_ligne_insert
    INSTEAD OF UPDATE 
    ON m_mobilite.geo_v_tic_gestion_ligne_insert
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_v_tic_gestion_ligne_insert();

-- ############################################################ ft_m_geo_v_tic_ligne_plan #########################################   

-- FUNCTION: m_mobilite.ft_m_geo_v_tic_ligne_plan()

-- DROP FUNCTION m_mobilite.ft_m_geo_v_tic_ligne_plan();

CREATE FUNCTION m_mobilite.ft_m_geo_v_tic_ligne_plan()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$


BEGIN

UPDATE m_mobilite.an_mob_rurbain_ligne 

	SET lib_res=new.lib_res, lib_exploi=new.lib_exploi, lib_aot=new.lib_aot, nom_ligne=new.nom_ligne,acces_pmr=new.acces_pmr, genre=new.genre, fonct=new.fonct, date_maj=now(),op_sai=new.op_sai,observ=new.observ

WHERE id_ligne = new.id_ligne;

RETURN new;


END;
$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_v_tic_ligne_plan()
    IS 'Fonction trigger pour la gestion des informations des lignes';


CREATE TRIGGER t_t1_geo_v_tic_ligne_plan
    INSTEAD OF UPDATE 
    ON m_mobilite.geo_v_tic_ligne_plan
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_v_tic_ligne_plan();    

-- ############################################################ ft_m_ajout_ligne #########################################   
-- FUNCTION: m_mobilite.ft_m_ajout_ligne()

-- DROP FUNCTION m_mobilite.ft_m_ajout_ligne();

CREATE FUNCTION m_mobilite.ft_m_ajout_ligne()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

new.id_ligne := 'FR:200067965:' || new.nom_court;


return new;
END$BODY$;

COMMENT ON FUNCTION m_mobilite.ft_m_ajout_ligne()
    IS 'Fonction dont l''objet est de créer l''identifiant de la ligne à l''insertion.';

-- Trigger: t_t3_an_mob_rurbain_ligne_insert

-- DROP TRIGGER t_t3_an_mob_rurbain_ligne_insert ON m_mobilite.an_mob_rurbain_ligne;

CREATE TRIGGER t_t3_an_mob_rurbain_ligne_insert
    BEFORE INSERT
    ON m_mobilite.an_mob_rurbain_ligne
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_ajout_ligne();

-- ############################################################ ft_m_geo_mob_rurbain_la #########################################   
-- FUNCTION: m_mobilite.ft_m_geo_mob_rurbain_la()

-- DROP FUNCTION m_mobilite.ft_m_geo_mob_rurbain_la();

CREATE FUNCTION m_mobilite.ft_m_geo_mob_rurbain_la()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$


DECLARE v_insee character varying(5);

BEGIN



IF (TG_OP = 'INSERT') THEN

	v_insee := (select insee from r_osm.geo_osm_commune where st_intersects(new.geom,geom));
	new.id_la := 'FR:' || v_insee || ':LA:' || (SELECT nextval('m_mobilite.geo_mob_rurbain_la_id_la_seq'::regclass)) || ':LOC';
	new.nom := (SELECT DISTINCT nom FROM m_mobilite.geo_mob_rurbain_ze WHERE st_intersects(st_buffer(new.geom,50), geom) = true);
	UPDATE m_mobilite.geo_mob_rurbain_ze SET id_la = new.id_la WHERE st_intersects(st_buffer(new.geom,50), geom) = true;

	RETURN new;

END IF;

IF (TG_OP = 'DELETE') THEN

UPDATE m_mobilite.geo_mob_rurbain_ze SET id_la = null WHERE id_la=old.id_la;

RETURN old;

END IF;

IF (TG_OP = 'UPDATE') THEN

UPDATE m_mobilite.geo_mob_rurbain_ze SET date_maj = new.date_maj WHERE id_la=new.id_la;

RETURN new;

END IF;

RETURN new;

END;
$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_mob_rurbain_la()
    IS 'Fonction trigger pour la gestion des insertions et supression dans la classe objet lieu d''arrêt et identifiant lieu d''arrêt dans la table geo_mob_rurbain_ze';

								   
-- Trigger: t_t1_geo_mob_rurbain_la

-- DROP TRIGGER t_t1_geo_mob_rurbain_la ON m_mobilite.geo_mob_rurbain_la;

CREATE TRIGGER t_t1_geo_mob_rurbain_la
    BEFORE INSERT OR DELETE OR UPDATE 
    ON m_mobilite.geo_mob_rurbain_la
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_mob_rurbain_la();
								   
-- ############################################################ ft_m_geo_mob_rurbain_la_tampon #########################################   
-- FUNCTION: m_mobilite.ft_m_geo_mob_rurbain_la_tampon()

-- DROP FUNCTION m_mobilite.ft_m_geo_mob_rurbain_la_tampon();

CREATE FUNCTION m_mobilite.ft_m_geo_mob_rurbain_la_tampon()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$



BEGIN

update m_mobilite.geo_mob_rurbain_la set geom2 = st_buffer(geom,new.v_tampon) where id_la=new.id_la;

return new;

END;
$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_mob_rurbain_la_tampon()
    IS 'Fonction trigger pour mise à jour du tampon d''emprise de l''arrêt si v_tampon est modifiée';

-- Trigger: t_t3_geo_mob_rurbain_la

-- DROP TRIGGER t_t3_geo_mob_rurbain_la ON m_mobilite.geo_mob_rurbain_la;

CREATE TRIGGER t_t3_geo_mob_rurbain_la
    AFTER UPDATE OF v_tampon
    ON m_mobilite.geo_mob_rurbain_la
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_mob_rurbain_la_tampon();
								   
-- ############################################################ ft_m_geo_mob_rurbain_tab #########################################   
-- FUNCTION: m_mobilite.ft_m_geo_mob_rurbain_tab()

-- DROP FUNCTION m_mobilite.ft_m_geo_mob_rurbain_tab();

CREATE FUNCTION m_mobilite.ft_m_geo_mob_rurbain_tab()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN

REFRESH MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab1;
REFRESH MATERIALIZED VIEW x_apps.an_vmr_rurbain_tab2;

return new;

END;
$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_mob_rurbain_tab()
    IS 'Fonction trigger pour mise à jour indicateurs affichés dans le tableau de bord applicatif GEO';

-- Trigger: t_t9_tab

-- DROP TRIGGER t_t9_tab ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t9_tab
    AFTER UPDATE 
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_mob_rurbain_tab();
								   
-- ############################################################ ft_m_geo_mob_rurbain_ze #########################################   
-- FUNCTION: m_mobilite.ft_m_geo_mob_rurbain_ze()

-- DROP FUNCTION m_mobilite.ft_m_geo_mob_rurbain_ze();

CREATE FUNCTION m_mobilite.ft_m_geo_mob_rurbain_ze()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE v_insee character varying(5);



BEGIN


v_insee := (select insee from r_osm.geo_osm_commune where st_intersects(new.geom,geom));
new.id_ze := 'FR:' || v_insee || ':ZE:' || nextval('m_mobilite.geo_mob_rurbain_ze_id_ze_seq'::regclass) || ':LOC';

--INSERT INTO m_mobilite.an_mob_rurbain_passage (id_ze, id_ligne,date_sai,date_maj) SELECT new.id_ze,'FR:246001010:99',now(),now();
INSERT INTO m_mobilite.an_mob_rurbain_docze (id_ze,t_doc) SELECT new.id_ze,'00';
INSERT INTO m_mobilite.an_mob_rurbain_gestze (id_ze,t_equi,etat) SELECT new.id_ze,'00','00';
return new;

END;
$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_mob_rurbain_ze()
    IS 'Fonction trigger pour mise à jour de la classe objet zone d''emabarquement';

-- Trigger: t_t1_geo_mob_rurbain_ze

-- DROP TRIGGER t_t1_geo_mob_rurbain_ze ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t1_geo_mob_rurbain_ze
    BEFORE INSERT
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_mob_rurbain_ze();
									
-- ############################################################ ft_m_geo_mob_rurbain_ze_delete #########################################   
-- FUNCTION: m_mobilite.ft_m_geo_mob_rurbain_ze_delete()

-- DROP FUNCTION m_mobilite.ft_m_geo_mob_rurbain_ze_delete();

CREATE FUNCTION m_mobilite.ft_m_geo_mob_rurbain_ze_delete()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

DECLARE v_insee character varying(5);



BEGIN


DELETE FROM m_mobilite.an_mob_rurbain_passage WHERE id_ze = old.id_ze;
DELETE FROM m_mobilite.an_mob_rurbain_gestze WHERE id_ze = old.id_ze;
DELETE FROM m_mobilite.an_mob_rurbain_docze WHERE id_ze = old.id_ze;

return old;

END;
$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_mob_rurbain_ze_delete()
    IS 'Fonction trigger pour supprimer les dépendances des objets zone d''emabarquement';

									
-- Trigger: t_t2_geo_mob_rurbain_ze_delete

-- DROP TRIGGER t_t2_geo_mob_rurbain_ze_delete ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t2_geo_mob_rurbain_ze_delete
    AFTER DELETE
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_mob_rurbain_ze_delete();
									
-- ############################################################ ft_m_stat_ze_chalandise #########################################   
-- FUNCTION: m_mobilite.ft_m_stat_ze_chalandise()

-- DROP FUNCTION m_mobilite.ft_m_stat_ze_chalandise();

CREATE FUNCTION m_mobilite.ft_m_stat_ze_chalandise()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$

BEGIN

     REFRESH MATERIALIZED VIEW m_mobilite.geo_vmr_tic_ze_200m;
	 REFRESH MATERIALIZED VIEW m_mobilite.geo_vmr_tic_ze_500m;

     return new;

END;

$BODY$;

-- Trigger: t_t8_geo_vmr_tic_ze_chalandise

-- DROP TRIGGER t_t8_geo_vmr_tic_ze_chalandise ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t8_geo_vmr_tic_ze_chalandise
    AFTER INSERT OR DELETE OR UPDATE 
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_stat_ze_chalandise();
									
																
-- ############################################################ ft_m_geo_mob_zela_vuemat #########################################   
-- FUNCTION: m_mobilite.ft_m_geo_mob_zela_vuemat()

-- DROP FUNCTION m_mobilite.ft_m_geo_mob_zela_vuemat();

CREATE FUNCTION m_mobilite.ft_m_geo_mob_zela_vuemat()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$BEGIN

REFRESH MATERIALIZED VIEW m_mobilite.geo_vmr_tic_zela WITH DATA;

return new;
END$BODY$;


COMMENT ON FUNCTION m_mobilite.ft_m_geo_mob_zela_vuemat()
    IS 'Fonction dont l''objet est de rafraichir (avec les données) les vues matérialisées induites par la mises à jour de la table des zones d''embarquement';

									
-- Trigger: t_t7_geo_vmr_tic_zela

-- DROP TRIGGER t_t7_geo_vmr_tic_zela ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t7_geo_vmr_tic_zela
    AFTER INSERT OR DELETE OR UPDATE 
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE m_mobilite.ft_m_geo_mob_zela_vuemat();
									
									
-- ############################################################ triggers génériques ################################################
									
-- Trigger: t_t1_an_mob_rurbain_docligne_datemaj

-- DROP TRIGGER t_t1_an_mob_rurbain_docligne_datemaj ON m_mobilite.an_mob_rurbain_docligne;

CREATE TRIGGER t_t1_an_mob_rurbain_docligne_datemaj
    BEFORE INSERT OR UPDATE 
    ON m_mobilite.an_mob_rurbain_docligne
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_maj();
									
-- Trigger: t_t2_an_mob_rurbain_docligne_datesai

-- DROP TRIGGER t_t2_an_mob_rurbain_docligne_datesai ON m_mobilite.an_mob_rurbain_docligne;

CREATE TRIGGER t_t2_an_mob_rurbain_docligne_datesai
    BEFORE INSERT
    ON m_mobilite.an_mob_rurbain_docligne
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_sai();
									
									
-- Trigger: t_t1_an_mob_3v_planvelo_doc_media_date_sai

-- DROP TRIGGER t_t1_an_mob_3v_planvelo_doc_media_date_sai ON m_mobilite.an_mob_rurbain_docze;

CREATE TRIGGER t_t1_an_mob_3v_planvelo_doc_media_date_sai
    BEFORE INSERT
    ON m_mobilite.an_mob_rurbain_docze
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_sai();
									
-- Trigger: t_t1_an_mob_rurbain_ligne_datemaj

-- DROP TRIGGER t_t1_an_mob_rurbain_ligne_datemaj ON m_mobilite.an_mob_rurbain_ligne;

CREATE TRIGGER t_t1_an_mob_rurbain_ligne_datemaj
    BEFORE INSERT OR UPDATE 
    ON m_mobilite.an_mob_rurbain_ligne
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_maj();
									
-- Trigger: t_t2_an_mob_rurbain_ligne_datesai

-- DROP TRIGGER t_t2_an_mob_rurbain_ligne_datesai ON m_mobilite.an_mob_rurbain_ligne;

CREATE TRIGGER t_t2_an_mob_rurbain_ligne_datesai
    BEFORE INSERT
    ON m_mobilite.an_mob_rurbain_ligne
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_sai();
									
-- Trigger: t_t1_an_mob_rurbain_passage_datemaj

-- DROP TRIGGER t_t1_an_mob_rurbain_passage_datemaj ON m_mobilite.an_mob_rurbain_passage;

CREATE TRIGGER t_t1_an_mob_rurbain_passage_datemaj
    BEFORE INSERT OR UPDATE 
    ON m_mobilite.an_mob_rurbain_passage
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_maj();
									
-- Trigger: t_t2_an_mob_rurbain_passage_datesai

-- DROP TRIGGER t_t2_an_mob_rurbain_passage_datesai ON m_mobilite.an_mob_rurbain_passage;

CREATE TRIGGER t_t2_an_mob_rurbain_passage_datesai
    BEFORE INSERT
    ON m_mobilite.an_mob_rurbain_passage
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_sai();
									
-- Trigger: t_t2_geo_mob_rurbain_la_insee_commune

-- DROP TRIGGER t_t2_geo_mob_rurbain_la_insee_commune ON m_mobilite.geo_mob_rurbain_la;

CREATE TRIGGER t_t2_geo_mob_rurbain_la_insee_commune
    BEFORE INSERT OR UPDATE OF geom
    ON m_mobilite.geo_mob_rurbain_la
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_commune_pl();
									
-- Trigger: t_t6_geo_mob_rurbain_ze_xy

-- DROP TRIGGER t_t6_geo_mob_rurbain_ze_xy ON m_mobilite.geo_mob_rurbain_la;

CREATE TRIGGER t_t6_geo_mob_rurbain_ze_xy
    BEFORE INSERT OR UPDATE OF geom
    ON m_mobilite.geo_mob_rurbain_la
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_xy_l93();
									
-- Trigger: t_t3_geo_mob_rurbain_ze_datemaj

-- DROP TRIGGER t_t3_geo_mob_rurbain_ze_datemaj ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t3_geo_mob_rurbain_ze_datemaj
    BEFORE INSERT OR UPDATE 
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_maj();
									
-- Trigger: t_t4_geo_mob_rurbain_ze_datesai

-- DROP TRIGGER t_t4_geo_mob_rurbain_ze_datesai ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t4_geo_mob_rurbain_ze_datesai
    BEFORE INSERT
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_sai();
									
									
-- Trigger: t_t5_geo_mob_rurbain_ze_insee_commune

-- DROP TRIGGER t_t5_geo_mob_rurbain_ze_insee_commune ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t5_geo_mob_rurbain_ze_insee_commune
    BEFORE INSERT OR UPDATE OF geom
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_commune_pl();
									
-- Trigger: t_t6_geo_mob_rurbain_ze_xy

-- DROP TRIGGER t_t6_geo_mob_rurbain_ze_xy ON m_mobilite.geo_mob_rurbain_ze;

CREATE TRIGGER t_t6_geo_mob_rurbain_ze_xy
    BEFORE INSERT OR UPDATE OF geom
    ON m_mobilite.geo_mob_rurbain_ze
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_xy_l93();
									
-- Trigger: t_t1_lk_voirie_rurbain_datesai

-- DROP TRIGGER t_t1_lk_voirie_rurbain_datesai ON m_mobilite.lk_voirie_rurbain;

CREATE TRIGGER t_t1_lk_voirie_rurbain_datesai
    BEFORE INSERT
    ON m_mobilite.lk_voirie_rurbain
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_sai();
									
-- Trigger: t_t2_lk_voirie_rurbain_datemaj

-- DROP TRIGGER t_t2_lk_voirie_rurbain_datemaj ON m_mobilite.lk_voirie_rurbain;

CREATE TRIGGER t_t2_lk_voirie_rurbain_datemaj
    BEFORE INSERT OR UPDATE 
    ON m_mobilite.lk_voirie_rurbain
    FOR EACH ROW
    EXECUTE PROCEDURE public.ft_r_timestamp_maj();									
									
-- #################################################################################################################################
-- ###                                                                                                                           ###
-- ###                                                      VUES DE GESTION                                                      ###
-- ###                                                                                                                           ###
-- #################################################################################################################################

-- ############################################################ geo_v_tic_gestion_desserte_ze #########################################    

-- View: m_mobilite.geo_v_tic_gestion_desserte_ze

-- DROP VIEW m_mobilite.geo_v_tic_gestion_desserte_ze;

CREATE OR REPLACE VIEW m_mobilite.geo_v_tic_gestion_desserte_ze
 AS
 SELECT p.id_en,
    ze.id_ze,
    '00'::character varying AS n_passage,
    p.id_ligne,
    p.op_sai,
    p.t_passage,
    p.direction,
    p.fonct,
    ze.geom
   FROM m_mobilite.geo_mob_rurbain_ze ze
     LEFT JOIN m_mobilite.an_mob_rurbain_passage p ON ze.id_ze::text = p.id_ze::text;

COMMENT ON VIEW m_mobilite.geo_v_tic_gestion_desserte_ze
    IS 'Vue éditable pour la gestion des dessertes de ligne aux zones d''embarquement';

-- ############################################################ geo_v_tic_gestion_doc_ze #########################################   

-- View: m_mobilite.geo_v_tic_gestion_doc_ze

-- DROP VIEW m_mobilite.geo_v_tic_gestion_doc_ze;

CREATE OR REPLACE VIEW m_mobilite.geo_v_tic_gestion_doc_ze
 AS
 SELECT row_number() OVER () AS row_id,
    d.gid AS id_doc,
    ze.id_ze,
    '00'::character varying AS n_doc,
    d.date_sai,
    d.op_sai,
    d.n_fichier AS f_doc,
    d.t_fichier AS l_doc,
    ze.geom
   FROM m_mobilite.geo_mob_rurbain_ze ze
     LEFT JOIN m_mobilite.an_mob_rurbain_docze d ON ze.id_ze::text = d.id::text;

COMMENT ON VIEW m_mobilite.geo_v_tic_gestion_doc_ze
    IS 'Vue éditable pour la gestion des documents liés aux zones d''embarquement';
    
    
-- ############################################################ geo_v_tic_gestion_ligne #########################################       


-- View: m_mobilite.geo_v_tic_gestion_ligne

-- DROP VIEW m_mobilite.geo_v_tic_gestion_ligne;

CREATE OR REPLACE VIEW m_mobilite.geo_v_tic_gestion_ligne
 AS
 SELECT row_number() OVER () AS row_id,
    t.id_tronc,
    '00'::character varying AS typ_modif,
    0::bigint AS id_troncn,
    'FR:246001010:99'::text AS id_lignen,
        CASE
            WHEN j.id_ligne IS NULL THEN 'FR:246001010:99'::character varying
            ELSE j.id_ligne
        END AS id_ligne,
        CASE
            WHEN j.sens IS NULL THEN '10'::character varying
            ELSE j.sens
        END AS sens,
        CASE
            WHEN j.desserte IS NULL THEN '10'::character varying
            ELSE j.desserte
        END AS desserte,
        CASE
            WHEN j.statut IS NULL THEN '10'::character varying
            ELSE j.statut
        END AS statut,
    j.n_car,
    t.geom
   FROM r_objet.geo_objet_troncon t
     LEFT JOIN m_mobilite.lk_voirie_rurbain j ON j.id_tronc = t.id_tronc
     LEFT JOIN m_mobilite.an_mob_rurbain_ligne l ON j.id_ligne::text = l.id_ligne::text;

COMMENT ON VIEW m_mobilite.geo_v_tic_gestion_ligne
    IS 'Vue éditable pour la gestion des données des lignes du réseau TIC (ajout, modification ou suppression de la desserte des tronçons du référentiel de voiries)';


-- ############################################################ geo_v_tic_gestion_ligne_insert #########################################   

-- View: m_mobilite.geo_v_tic_gestion_ligne_insert

-- DROP VIEW m_mobilite.geo_v_tic_gestion_ligne_insert;

CREATE OR REPLACE VIEW m_mobilite.geo_v_tic_gestion_ligne_insert
 AS
 SELECT row_number() OVER () AS row_id,
    t.id_tronc,
    'FR:246001010:99'::character varying AS id_lignen,
    '10'::character varying AS sensn,
    '10'::character varying AS desserten,
    '10'::character varying AS statutn,
    ''::character varying AS n_carn,
    t.geom
   FROM r_objet.geo_objet_troncon t;

COMMENT ON VIEW m_mobilite.geo_v_tic_gestion_ligne_insert
    IS 'Vue éditable pour la gestion des données des lignes du réseau TIC (uniquement ajout de la desserte des tronçons du référentiel de voiries)';

-- ############################################################ geo_v_tic_ligne_plan #########################################   

-- View: m_mobilite.geo_v_tic_ligne_plan

-- DROP VIEW m_mobilite.geo_v_tic_ligne_plan;

CREATE OR REPLACE VIEW m_mobilite.geo_v_tic_ligne_plan
 AS
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
    st_linemerge(st_union(o.geom))::geometry(MultiLineString,2154) AS geom
   FROM m_mobilite.an_mob_rurbain_ligne l,
    m_mobilite.lk_voirie_rurbain v,
    r_objet.geo_objet_troncon o
  WHERE l.id_ligne::text = v.id_ligne::text AND v.id_tronc = o.id_tronc AND l.genre::text = '10'::text
  GROUP BY l.id_ligne, l.lib_res, l.lib_exploi, l.lib_aot, l.nom_court, l.nom_ligne, l.acces_pmr, l.genre, l.fonct, l.date_sai, l.date_maj, l.op_sai, l.observ;

COMMENT ON VIEW m_mobilite.geo_v_tic_ligne_plan
    IS 'Vue regroupant le tracé de toutes les lignes pour aides à l''affichage du QGIS de gestion des données du réseau TIC (filtre par n° de ligne)';







