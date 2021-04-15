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





-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                SEQUENCE                                                                      ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################



    
 -- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                REINITIALISATION DU MODELE                                                    ###
-- ###                                                                                                                                              ###
-- #################################################################################################################################################### 



-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                DOMAINE DE VALEURS                                                            ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################

-- ################################################################# lt_ev_doma ###############################################
    


INSERT INTO m_espace_vert_v2.lt_ev_position(
            code, valeur)
    VALUES
('10','Sol'),
('20','Hors-sol (non précisé)'),
('21','Pot'),
('22','Bac'),
('23','Jardinière'),
('24','Suspension'),
('29','Autre');
  
-- ####################################################################################################################################################
-- ###                                                                                                                                              ###
-- ###                                                                TABLE                                                           		    ###
-- ###                                                                                                                                              ###
-- ####################################################################################################################################################


-- ################################################################# TABLE an_ev_objet ###############################################




    
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
  




