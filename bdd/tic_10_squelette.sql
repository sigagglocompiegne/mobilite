/* TIC V1.0*/
/* Creation du squelette de la structure des données */
/* tic_10_squelette.sql */
/* PostGIS*/

/* Propriétaire : GeoCompiegnois - http://geo.compiegnois.fr/ */
/* Auteur : Grégory Bodet */


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SCHEMA                                                                        ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- SCHEMA: m_mobilite

-- DROP SCHEMA m_mobilite ;

CREATE SCHEMA m_mobilite
    AUTHORIZATION create_sig;

COMMENT ON SCHEMA m_mobilite
    IS 'Données géographiques métiers sur le thème de la mobilité (circulation douce, transport en commun, ...)';


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SEQUENCE                                                                      ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- SEQUENCE: m_mobilite.an_mob_rurbain_docligne_iddoc_seq

-- DROP SEQUENCE m_mobilite.an_mob_rurbain_docligne_iddoc_seq;

CREATE SEQUENCE m_mobilite.an_mob_rurbain_docligne_iddoc_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
    
-- SEQUENCE: m_mobilite.an_mob_rurbain_docze_iddoc_seq

-- DROP SEQUENCE m_mobilite.an_mob_rurbain_docze_iddoc_seq;

CREATE SEQUENCE m_mobilite.an_mob_rurbain_docze_iddoc_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
    
 -- SEQUENCE: m_mobilite.an_mob_rurbain_passage_iden_seq

-- DROP SEQUENCE m_mobilite.an_mob_rurbain_passage_iden_seq;

CREATE SEQUENCE m_mobilite.an_mob_rurbain_passage_iden_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;

-- SEQUENCE: m_mobilite.geo_mob_rurbain_la_id_la_seq

-- DROP SEQUENCE m_mobilite.geo_mob_rurbain_la_id_la_seq;

CREATE SEQUENCE m_mobilite.geo_mob_rurbain_la_id_la_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
    
-- SEQUENCE: m_mobilite.geo_mob_rurbain_ze_id_ze_seq

-- DROP SEQUENCE m_mobilite.geo_mob_rurbain_ze_id_ze_seq;

CREATE SEQUENCE m_mobilite.geo_mob_rurbain_ze_id_ze_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
    
 -- SEQUENCE: m_mobilite.lk_voirie_rurbain_gid_seq

-- DROP SEQUENCE m_mobilite.lk_voirie_rurbain_gid_seq;

CREATE SEQUENCE m_mobilite.lk_voirie_rurbain_gid_seq
    INCREMENT 1
    START 1
    MINVALUE 1
    MAXVALUE 9223372036854775807
    CACHE 1;
    
    
 -- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                REINITIALISATION DU MODELE                                                    ###
-- ###                                                                                                                                              ###
-- #################################################################################################################################################### 

DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_desserte;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_genre;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_hierarchie;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_latype;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_modification;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_mtransport;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_passage;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_sens;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_statut;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_t_doc;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_terminus;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_zetype;
DROP TABLE IF EXISTS m_mobilite.lt_mob_rurbain_fonct;

DROP TABLE IF EXISTS m_mobilite.an_mob_rurbain_docligne;
DROP TABLE IF EXISTS m_mobilite.an_mob_rurbain_docze;
DROP TABLE IF EXISTS m_mobilite.an_mob_rurbain_ligne;
DROP TABLE IF EXISTS m_mobilite.an_mob_rurbain_passage;
DROP TABLE IF EXISTS m_mobilite.geo_mob_rurbain_la;
DROP TABLE IF EXISTS m_mobilite.geo_mob_rurbain_ze;
DROP TABLE IF EXISTS m_mobilite.lk_voirie_rurbain;

DROP SEQUENCE IF EXISTS m_mobilite.lk_voirie_rurbain_gid_seq;
DROP SEQUENCE IF EXISTS  m_mobilite.geo_mob_rurbain_ze_id_ze_seq;
DROP SEQUENCE IF EXISTS  m_mobilite.geo_mob_rurbain_la_id_la_seq;
DROP SEQUENCE IF EXISTS  m_mobilite.an_mob_rurbain_passage_iden_seq;
DROP SEQUENCE IF EXISTS  m_mobilite.an_mob_rurbain_docligne_iddoc_seq;
DROP SEQUENCE IF EXISTS  m_mobilite.an_mob_rurbain_docligne_iddoc_seq;


-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINE DE VALEURS                                                            ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- ################################################################# lt_mob_rurbain_desserte ###############################################
    
-- Table: m_mobilite.lt_mob_rurbain_desserte

-- DROP TABLE m_mobilite.lt_mob_rurbain_desserte;

CREATE TABLE m_mobilite.lt_mob_rurbain_desserte
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_desserte_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_desserte(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Principale'),
('20','Variante'),
('30','AlloTic'),
('40','Haut-le-pied');

-- ################################################################# lt_mob_rurbain_fonct ###############################################
-- Table: m_mobilite.lt_mob_rurbain_fonct

-- DROP TABLE m_mobilite.lt_mob_rurbain_fonct;

CREATE TABLE m_mobilite.lt_mob_rurbain_fonct
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_fonct_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_fonct(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','du lundi au Samedi'),
('20','le dimanche et les jours fériés (sauf l''été, le 1er mai, 25 décembre, 1er janvier)'),
('12','du lundi au samedi (en période scolaire)'),
('14','du lundi au vendredi (sauf en août)'),
('16','le mercredi et le samedi (en période scolaire)'),
('17','le lundi, mardi, jeudi et vendredi (en période scolaire)'),
('40','En période scolaire'),
('50','les jours de marché'),
('80','du lundi au samedi (sur réservation)'),
('24','le samedi soir'),
('81','du lundi au samedi (cf fiche horaire pour les jours de fonctionnement)'),
('19','le mercredi (période scolaire)'),
('2','du lundi au samedi (vacances scolaires uniquement)'),
('82','du lundi au vendredi (en période scolaire)'),
('ZZ','Plus en service');

-- ################################################################# lt_mob_rurbain_genre ###############################################
-- Table: m_mobilite.lt_mob_rurbain_genre

-- DROP TABLE m_mobilite.lt_mob_rurbain_genre;

CREATE TABLE m_mobilite.lt_mob_rurbain_genre
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_genre_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_genre(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Urbain'),
('20','Péri-Urbain'),
('30','TAD'),
('40','Scolaire'),
('50','DJF');

-- ################################################################# lt_mob_rurbain_hierarchie ###############################################
-- Table: m_mobilite.lt_mob_rurbain_hierarchie

-- DROP TABLE m_mobilite.lt_mob_rurbain_hierarchie;

CREATE TABLE m_mobilite.lt_mob_rurbain_hierarchie
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_hierarchie_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_hierarchie(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Lieu d''arrêt MONOMODAL'),
('20','POLE MONOMODAL'),
('30','Lieu d''arrêt MULTIMODAL');

-- ################################################################# lt_mob_rurbain_latype ###############################################

-- Table: m_mobilite.lt_mob_rurbain_latype

-- DROP TABLE m_mobilite.lt_mob_rurbain_latype;

CREATE TABLE m_mobilite.lt_mob_rurbain_latype
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_latype_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;


INSERT INTO m_mobilite.lt_mob_rurbain_latype(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Arrêt de bus sur la voirie'),
('20','Gare routière'),
('30','Station d''autocars');

-- ################################################################# lt_mob_rurbain_modification ###############################################
-- Table: m_mobilite.lt_mob_rurbain_modification

-- DROP TABLE m_mobilite.lt_mob_rurbain_modification;

CREATE TABLE m_mobilite.lt_mob_rurbain_modification
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_modification_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_modification(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Création'),
('20','Mise à jour'),
('30','Suppression');

-- ################################################################# lt_mob_rurbain_mtransport ###############################################

-- Table: m_mobilite.lt_mob_rurbain_mtransport

-- DROP TABLE m_mobilite.lt_mob_rurbain_mtransport;

CREATE TABLE m_mobilite.lt_mob_rurbain_mtransport
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_mtransport_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_mtransport(
            code, valeur)
    VALUES
('00','Non renseigné'),
('20','Bus'),
('21','Car'),
('60','Taxi'),
('70','Minibus');

-- ################################################################# lt_mob_rurbain_passage ###############################################

-- Table: m_mobilite.lt_mob_rurbain_passage

-- DROP TABLE m_mobilite.lt_mob_rurbain_passage;

CREATE TABLE m_mobilite.lt_mob_rurbain_passage
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_passage_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_passage(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Simple passage'),
('31','Terminus (départ variante)'),
('32','Terminus (arrivée variante)'),
('21','Terminus (départ)'),
('22','Terminus (arrivée)'),
('40','Dépose uniquement');

-- ################################################################# lt_mob_rurbain_sens ###############################################

-- Table: m_mobilite.lt_mob_rurbain_sens

-- DROP TABLE m_mobilite.lt_mob_rurbain_sens;

CREATE TABLE m_mobilite.lt_mob_rurbain_sens
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_sens_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_sens(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Aller-Retour'),
('20','Aller'),
('30','Retour');

-- ################################################################# lt_mob_rurbain_statut ###############################################
-- Table: m_mobilite.lt_mob_rurbain_statut

-- DROP TABLE m_mobilite.lt_mob_rurbain_statut;

CREATE TABLE m_mobilite.lt_mob_rurbain_statut
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(30) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_statut_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_statut(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Actif'),
('20','Inactif'),
('30','Projet');

-- ################################################################# lt_mob_rurbain_t_doc ###############################################
-- Table: m_mobilite.lt_mob_rurbain_t_doc

-- DROP TABLE m_mobilite.lt_mob_rurbain_t_doc;

CREATE TABLE m_mobilite.lt_mob_rurbain_t_doc
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_t_doc_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_t_doc(
            code, valeur)
    VALUES
('00','Non renseigné'),
('10','Photographie'),
('20','Fiche(s) horaire(s)');

-- ################################################################# lt_mob_rurbain_terminus ###############################################

-- Table: m_mobilite.lt_mob_rurbain_terminus

-- DROP TABLE m_mobilite.lt_mob_rurbain_terminus;

CREATE TABLE m_mobilite.lt_mob_rurbain_terminus
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_terminus_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_terminus(
            code, valeur)
    VALUES
('00','Non renseigné'),
('01','Gare'),
('02','Hôpital'),
('03','Bellicart'),
('04','Marronniers'),
('05','Port à Carreaux'),
('06','Ouïnels'),
('07','Palais'),
('08','Centre Commercial Jaux-Venette'),
('09','Ferdinand de Lesseps'),
('11','Hauts de Margny'),
('12','Ouïnels - Port à Carreaux'),
('13','Bellicart - Marroniers'),
('14','Ferdinand de Lesseps - Hôpital'),
('17','Compiègne - Gare Routière'),
('18','Collège Ferdinand Bac'),
('22','Gare - Multiplexe'),
('23','Multiplexe'),
('24','St-Jean-aux-Bois - La Brévière'),
('25','St-Sauveur - Eglise'),
('28','Bienville'),
('39','Ecole des Bruyères'),
('43','Le Meux - Centre'),
('21','Choisy-au-Bac - Sergenteret'),
('52','Jaux - Varanval'),
('53','Lacroix-St-Ouen - Mairie'),
('41','Le Meux - Croisette'),
('19','Collège Debussy'),
('15','ZI Le Meux - Petite Prée'),
('57','St-Sauveur - Mabonnerie'),
('58','Lachelle - Place'),
('55','Janville - Ile J.Lenoble'),
('30','Jonquières - Château'),
('60','Gare - Palais'),
('56','Compiègne - Armistice'),
('61','Vers Compiègne'),
('62','Depuis Compiègne'),
('63','Choisy-au-Bac'),
('40','Collège Jules Verne'),
('54','Hameau de Mercières'),
('64','Jonquières - Ecole'),
('27','Janville - Mairie'),
('65','Choisy-au-Bac - Linières'),
('90','(dépose uniquement)'),
('66','Verberie - Aramont'),
('67','St-Vaast-de-Longmont - Mairie'),
('68','Camp des Sablons'),
('69','Les Lycées'),
('70','Bois de Plaisance'),
('36','Guy Deniélou'),
('71','Verberie - Mairie'),
('72','Néry - Eglise');

-- ################################################################# lt_mob_rurbain_zetype ###############################################
-- Table: m_mobilite.lt_mob_rurbain_zetype

-- DROP TABLE m_mobilite.lt_mob_rurbain_zetype;

CREATE TABLE m_mobilite.lt_mob_rurbain_zetype
(
    code character varying(2) COLLATE pg_catalog."default" NOT NULL,
    valeur character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT lt_mob_rurbain_zetype_pkey PRIMARY KEY (code)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

INSERT INTO m_mobilite.lt_mob_rurbain_zetype(
            code, valeur)
    VALUES
('00','Non renseigné'),
('40','Arrêt de bus, autocar (avec poteau)'),
('41','Arrêt de bus, autocar (avec abris)'),
('42','Quai de bus, autocar (avec poteau)'),
('43','Quai de bus, autocar (avec abris)'),
('44','Arrêt de bus, autocar (zébra seul)'),
('45','Arrêt de bus, autocar (sans matérialisation)'),
('48','Arrêt de bus, autocar (avec panneau routier)'),
('46','Arrêt de bus, autocar (BIV seule)'),
('47','Quai de bus, autocar (BIV seule)'),
('50','Arrêt de bus, autocar (abris avec BIV)'),
('51','Quai de bus, autocar (abris avec BIV)'),
('49','Arrêt de bus, autocar (sur panneau routier)');

-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                TABLE                                                           		    ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################# TABLE an_mob_rurbain_docligne ###############################################

-- Table: m_mobilite.an_mob_rurbain_docligne

-- DROP TABLE m_mobilite.an_mob_rurbain_docligne;

CREATE TABLE m_mobilite.an_mob_rurbain_docligne
(
    id_doc integer NOT NULL DEFAULT nextval('m_mobilite.an_mob_rurbain_docligne_iddoc_seq'::regclass),
    id_ligne character varying(30) COLLATE pg_catalog."default" NOT NULL,
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    date_dutil timestamp without time zone,
    date_futil timestamp without time zone,
    op_sai character varying(50) COLLATE pg_catalog."default",
    n_fichier character varying(100) COLLATE pg_catalog."default",
    l_fichier character varying(255) COLLATE pg_catalog."default",
    observ character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT an_mob_rurbain_docligne_pkey PRIMARY KEY (id_doc)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- ################################################################# TABLE an_mob_rurbain_docze ###############################################
-- Table: m_mobilite.an_mob_rurbain_docze

-- DROP TABLE m_mobilite.an_mob_rurbain_docze;

CREATE TABLE m_mobilite.an_mob_rurbain_docze
(
    gid integer NOT NULL DEFAULT nextval('m_mobilite.an_mob_rurbain_docze_iddoc_seq'::regclass),
    id character varying(30) COLLATE pg_catalog."default",
    media text COLLATE pg_catalog."default",
    miniature bytea,
    n_fichier text COLLATE pg_catalog."default",
    t_fichier text COLLATE pg_catalog."default",
    op_sai character varying(100) COLLATE pg_catalog."default",
    date_sai timestamp without time zone,
    CONSTRAINT an_mob_rurbain_docze_pkey PRIMARY KEY (gid)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
-- ################################################################# TABLE an_mob_rurbain_ligne ###############################################
-- Table: m_mobilite.an_mob_rurbain_ligne

-- DROP TABLE m_mobilite.an_mob_rurbain_ligne;

CREATE TABLE m_mobilite.an_mob_rurbain_ligne
(
    id_ligne character varying(30) COLLATE pg_catalog."default" NOT NULL,
    lib_res character varying(10) COLLATE pg_catalog."default",
    lib_exploi character varying(50) COLLATE pg_catalog."default",
    lib_aot character varying(20) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    nom_court character varying(40) COLLATE pg_catalog."default",
    nom_ligne character varying(255) COLLATE pg_catalog."default",
    acces_pmr boolean DEFAULT false,
    genre character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    fonct character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    op_sai character varying(50) COLLATE pg_catalog."default",
    observ character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT an_mob_rurbain_ligne_pkey PRIMARY KEY (id_ligne),
    CONSTRAINT an_mob_rurbain_ligne_fonct_fkey FOREIGN KEY (fonct)
        REFERENCES m_mobilite.lt_mob_rurbain_fonct (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_mob_rurbain_ligne_genre_fkey FOREIGN KEY (genre)
        REFERENCES m_mobilite.lt_mob_rurbain_genre (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
-- ################################################################# TABLE an_mob_rurbain_passage ###############################################
-- Table: m_mobilite.an_mob_rurbain_passage

-- DROP TABLE m_mobilite.an_mob_rurbain_passage;

CREATE TABLE m_mobilite.an_mob_rurbain_passage
(
    id_en integer NOT NULL DEFAULT nextval('m_mobilite.an_mob_rurbain_passage_iden_seq'::regclass),
    id_ze character varying(30) COLLATE pg_catalog."default" NOT NULL,
    id_ligne character varying(30) COLLATE pg_catalog."default" NOT NULL,
    date_sai timestamp without time zone DEFAULT now(),
    date_maj timestamp without time zone,
    op_sai character varying(50) COLLATE pg_catalog."default",
    t_passage character varying(2) COLLATE pg_catalog."default",
    direction character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    fonct character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    CONSTRAINT an_mob_rurbain_passage_iden_pkey PRIMARY KEY (id_en),
    CONSTRAINT an_mob_rurbain_passage_direction_fkey FOREIGN KEY (direction)
        REFERENCES m_mobilite.lt_mob_rurbain_terminus (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_mob_rurbain_passage_fonct_fkey FOREIGN KEY (fonct)
        REFERENCES m_mobilite.lt_mob_rurbain_fonct (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT an_mob_rurbain_passage_t_passage_fkey FOREIGN KEY (t_passage)
        REFERENCES m_mobilite.lt_mob_rurbain_passage (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
-- ################################################################# TABLE geo_mob_rurbain_la ###############################################
-- Table: m_mobilite.geo_mob_rurbain_la

-- DROP TABLE m_mobilite.geo_mob_rurbain_la;

CREATE TABLE m_mobilite.geo_mob_rurbain_la
(
    id_la character varying(30) COLLATE pg_catalog."default" NOT NULL,
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    op_sai character varying(50) COLLATE pg_catalog."default",
    modification character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    statut character varying(2) COLLATE pg_catalog."default" DEFAULT '10'::character varying,
    nom character varying(50) COLLATE pg_catalog."default",
    nom_court character varying(50) COLLATE pg_catalog."default",
    description character varying(255) COLLATE pg_catalog."default",
    x_l93 numeric(8,2),
    y_l93 numeric(9,2),
    date_deb timestamp without time zone,
    date_fin timestamp without time zone,
    hierarchie character varying(2) COLLATE pg_catalog."default" DEFAULT '10'::character varying,
    insee character varying(5) COLLATE pg_catalog."default",
    commune character varying(80) COLLATE pg_catalog."default",
    id_parent character varying(30) COLLATE pg_catalog."default",
    latype character varying(2) COLLATE pg_catalog."default" DEFAULT '10'::character varying,
    sens character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    angle integer DEFAULT 0,
    observ character varying(255) COLLATE pg_catalog."default",
    geom geometry(Point,2154),
    v_tampon integer,
    geom2 geometry(Polygon,2154),
    CONSTRAINT geo_mob_rurbain_la_pkey PRIMARY KEY (id_la),
    CONSTRAINT geo_mob_rurbain_la_sens_fkey FOREIGN KEY (sens)
        REFERENCES m_mobilite.lt_mob_rurbain_sens (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mon_rurbain_la_hierarchie_fkey FOREIGN KEY (hierarchie)
        REFERENCES m_mobilite.lt_mob_rurbain_hierarchie (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mon_rurbain_la_latype_fkey FOREIGN KEY (latype)
        REFERENCES m_mobilite.lt_mob_rurbain_latype (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mon_rurbain_la_modification_fkey FOREIGN KEY (modification)
        REFERENCES m_mobilite.lt_mob_rurbain_modification (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mon_rurbain_la_statut_fkey FOREIGN KEY (statut)
        REFERENCES m_mobilite.lt_mob_rurbain_statut (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
-- ################################################################# TABLE geo_mob_rurbain_ze ###############################################
-- Table: m_mobilite.geo_mob_rurbain_ze

-- DROP TABLE m_mobilite.geo_mob_rurbain_ze;

CREATE TABLE m_mobilite.geo_mob_rurbain_ze
(
    id_ze character varying(30) COLLATE pg_catalog."default" NOT NULL,
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    op_sai character varying(50) COLLATE pg_catalog."default",
    modification character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    src_geom character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    statut character varying(2) COLLATE pg_catalog."default" DEFAULT '10'::character varying,
    nom character varying(50) COLLATE pg_catalog."default",
    nom_court character varying(50) COLLATE pg_catalog."default",
    description character varying(255) COLLATE pg_catalog."default",
    x_l93 numeric(8,2),
    y_l93 numeric(9,2),
    z_ngf numeric(5,2),
    date_deb timestamp without time zone,
    date_fin timestamp without time zone,
    acces_ufr boolean DEFAULT false,
    sign_audi boolean DEFAULT false,
    sign_visu boolean DEFAULT false,
    insee character varying(5) COLLATE pg_catalog."default",
    commune character varying(80) COLLATE pg_catalog."default",
    id_la character varying(30) COLLATE pg_catalog."default",
    mtransport character varying(2) COLLATE pg_catalog."default" DEFAULT '20'::character varying,
    smtransport character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    autransport character varying(100) COLLATE pg_catalog."default",
    zetype character varying(2) COLLATE pg_catalog."default" DEFAULT '40'::character varying,
    observ character varying(255) COLLATE pg_catalog."default",
    geom geometry(Point,2154),
    ppub boolean NOT NULL DEFAULT false,
    CONSTRAINT geo_mob_rurbain_ze_idze_pkey PRIMARY KEY (id_ze),
    CONSTRAINT geo_mob_rurbain_ze FOREIGN KEY (src_geom)
        REFERENCES r_objet.lt_src_geom (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mob_rurbain_ze_modification_fkey FOREIGN KEY (modification)
        REFERENCES m_mobilite.lt_mob_rurbain_modification (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mob_rurbain_ze_mtransport_fkey FOREIGN KEY (mtransport)
        REFERENCES m_mobilite.lt_mob_rurbain_mtransport (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mob_rurbain_ze_smtransport_fkey FOREIGN KEY (smtransport)
        REFERENCES m_mobilite.lt_mob_rurbain_mtransport (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mob_rurbain_ze_statut_fkey FOREIGN KEY (statut)
        REFERENCES m_mobilite.lt_mob_rurbain_statut (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT geo_mob_rurbain_ze_zetype_fkey FOREIGN KEY (zetype)
        REFERENCES m_mobilite.lt_mob_rurbain_zetype (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;
-- ################################################################# TABLE lk_voirie_rurbain ###############################################
-- Table: m_mobilite.lk_voirie_rurbain

-- DROP TABLE m_mobilite.lk_voirie_rurbain;

CREATE TABLE m_mobilite.lk_voirie_rurbain
(
    id_tronc bigint NOT NULL,
    id_ligne character varying(30) COLLATE pg_catalog."default" NOT NULL,
    sens character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    desserte character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    statut character varying(2) COLLATE pg_catalog."default" DEFAULT '00'::character varying,
    date_sai timestamp without time zone NOT NULL DEFAULT now(),
    date_maj timestamp without time zone,
    n_car character varying(100) COLLATE pg_catalog."default",
    gid integer NOT NULL DEFAULT nextval('m_mobilite.lk_voirie_rurbain_gid_seq'::regclass),
    CONSTRAINT lk_voirie_rurbain_pkey PRIMARY KEY (gid),
    CONSTRAINT lk_voirie_rurbain_desserte_fkey FOREIGN KEY (desserte)
        REFERENCES m_mobilite.lt_mob_rurbain_desserte (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lk_voirie_rurbain_idligne_fkey FOREIGN KEY (id_ligne)
        REFERENCES m_mobilite.an_mob_rurbain_ligne (id_ligne) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lk_voirie_rurbain_sens_fkey FOREIGN KEY (sens)
        REFERENCES m_mobilite.lt_mob_rurbain_sens (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT lk_voirie_rurbain_statut_fkey FOREIGN KEY (statut)
        REFERENCES m_mobilite.lt_mob_rurbain_statut (code) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;


    
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                CLE ETRANGERE DEPENDANTE                                        		    ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                INDEX                                                                         ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- Sans objet
  





