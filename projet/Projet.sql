CREATE TABLESPACE SQL3_TBS DATAFILE 'C:\SQL3_TBS.dat'  SIZE 100M  AUTOEXTEND ON   ONLINE;

CREATE TEMPORARY TABLESPACE SQL3_TEMPTBS TEMPFILE 'C:\SQL3_TEMPTBS.dat' SIZE 100M  AUTOEXTEND ON;

create user SQL identified by 1976 Default Tablespace SQL3_TBS Temporary Tablespace SQL3_TEMPTBS;

grant all privileges to SQL;

/* se connecter avec l'utilisateur sql3 */

/* Definissons tous les types necessaires */

create type THotel ;
/
create type TClient ;
/
create type TChambre ;
/

create type TEvaluation as object (dateEv date, note integer, evaluation_hotel ref THotel, evaluation_client ref TClient);
/
create or replace type TReservation as object (dateArr date, dateDepart date, reservation_client ref TClient, reservation_chambre ref TChambre);
/

create type ref_evaluation as table of ref TEvaluation;
/
create type ref_reservation as table of ref TReservation;
/
create type ref_chambre as table of ref TChambre;
/

create or replace type THotel as object (
    numHotel INTEGER,
    nomHotel varchar(50),
    ville varchar(50),
    etoile INTEGER,
    siteWeb varchar(50),
    hotel_evaluation ref_evaluation,
    hotel_chambre ref_chambre 
)Not final;
/

create or replace type TClient as object (
    num_client INTEGER,
    nom_client varchar(50),
    prenom_client varchar(50),
    email varchar(50),
    client_evaluation ref_evaluation,
    client_reservation ref_reservation
)Not final;
/

create or replace type TChambre as object (
    num_chambre INTEGER,
    etage INTEGER,
    typeChambre varchar(50),
    prix_nuit INTEGER,
    chambre_hotel ref THotel,
    chambre_reservation ref_reservation
)Not final;
/


/* Les methodes */

/* Calculer pour chaque client, le nombre de reservations effectuees. */
alter type TClient add member function nb_reservation return INTEGER cascade;
create or replace type body TClient
as member function nb_reservation return INTEGER
is
nbreservation integer;
Begin
select count(*)into nbreservation
from table(self.client_reservation);
return nbreservation;
END;
END;
/

/* Calculer pour chaque hotel, le nombre de chambres */
alter type THotel add member function nb_hotel return INTEGER cascade;
create or replace type body THotel
as member function nb_hotel return integer
is
nbhotel integer;
Begin
select count(*) into nbhotel
from table(self.hotel_chambre);
return nbhotel;
END;
END;
/

/* Calculer pour chaque chambre, son chiffre daffaire */
alter type TChambre add member function chiffre_affaire return numeric cascade;
create or replace type body TChambre
as member function chiffre_affaire return numeric
is
chiffreAffaire number;
Begin
select sum((value(deref(self.chambre_reservation).dateDepart) - value(deref(self.chambre_reservation).dateArr)) * self.prix_nuit) into chiffreAffaire
from table(self.chambre_reservation) ;
return chiffreAffaire;
END;
END;
/

/* Calculer pour chaque hotel, le nombre devaluations recues a une date donnee (01-01-2022) */
alter type THotel add member function nb_evaluation return INTEGER cascade;
create or replace type body THotel
as member function  nb_evaluation return INTEGER
is
nbevaluation integer;
Begin
select count(*) into nbevaluation
from table(self.hotel_evaluation) e
where deref(e.dateEv) = '01/01/2022';
END;
END;
/
/* 
create or replace type body THotel
as 
member function nb_evaluation return INTEGER
is
nbevaluation integer;
Begin
select count(*) into nbevaluation
from table(self.hotel_evaluation) e
where deref(e.value).dateEv =  '01/01/2022';
return nbevaluation;
END;
END;
/


*/


create table Hotel of thotel (PRIMARY KEY(numHotel),constraint ck_type check (etoile >= 1 and etoile <= 10 ))
nested table hotel_evaluation store as table_hotel_evaluation ,
nested table Hotel_chambre store as table_Hotel_chambre ;

create table Chambre of tchambre(foreign key(chambre_Hotel) references Hotel,constraint ck_et check (typeChambre in ( 'simple', 'double', 'triple','suite','autre')))
nested table chambre_reservation store as table_chambre_reservation ; 

create table Client of tclient (PRIMARY KEY(num_client))
nested table client_reservation store as table_client_reservation,
nested table client_evaluation store as table_client_evaluation ;

create table Evaluation of tevaluation (foreign key(evaluation_hotel) references Hotel, foreign key (evaluation_client) references Client, constraint ck_note check (note >= 1 and note <= 10 ));

create table Reservation of treservation(foreign key(reservation_client) references Client,foreign key(reservation_chambre) references Chambre,constraint ck_date check (dateDepart >= dateArr));

/**  table Hotel **/

insert into Hotel values (1,'Renaissance', 'Tlemcen', 5, '', ref_evaluation(), ref_chambre());
insert into Hotel values (2,'Seybouse', 'Annaba', 3, '', ref_evaluation(), ref_chambre());
insert into Hotel values (3,'Hôtel Novotel', 'Constantine', 4, '', ref_evaluation(), ref_chambre());
insert into Hotel values (4,'Saint George dAlger', 'Alger', 5, '', ref_evaluation(), ref_chambre());
insert into Hotel values (5,'Ibis Alger Aéroport', 'Alger', 2, '', ref_evaluation(), ref_chambre());
insert into Hotel values (6,'El Mountazah Annaba', 'Annaba', 3, '', ref_evaluation(), ref_chambre());
insert into Hotel values (7,'Hôtel Albert 1er', 'Alger', 3, '', ref_evaluation(), ref_chambre());
insert into Hotel values (8,'Chems', 'Oran', 2, '', ref_evaluation(), ref_chambre());
insert into Hotel values (9,'Colombe', 'Oran', 3, '', ref_evaluation(), ref_chambre());
insert into Hotel values (10,'Mercure', 'Alger', 4, '', ref_evaluation(), ref_chambre());
insert into Hotel values (11,'Le Méridien', 'Oran', 5, '', ref_evaluation(), ref_chambre());
insert into Hotel values (12,'Hôtel Sofitel', 'Alger', 5, '', ref_evaluation(), ref_chambre());

/**  table Client **/

insert into Client values (1 ,  'BOUROUBI', 'Taous', '', ref_evaluation(), ref_reservation());
insert into Client values (2 ,'BOUZIDI', 'AMEL', '', ref_evaluation(), ref_reservation());
insert into Client values (3 ,'LACHEMI' ,'Bouzid', '', ref_evaluation(), ref_reservation());
insert into Client values (4 ,'BOUCHEMLA' ,  'Elias', '', ref_evaluation(), ref_reservation());
insert into Client values (5 ,'HADJ', 'Zouhir', '', ref_evaluation(), ref_reservation());
insert into Client values (6 ,'OUSSEDIK', 'Hakim', '', ref_evaluation(), ref_reservation());
insert into Client values (7 ,'AAKOUB', 'Fatiha', '', ref_evaluation(), ref_reservation());
insert into Client values (8 ,'ABAD', 'Abdelhamid', '', ref_evaluation(), ref_reservation());
insert into Client values (9 ,'ABADA', 'Mohamed', '', ref_evaluation(), ref_reservation());
insert into Client values (10 ,'ABAYAHIA' ,'Abdelkader', '', ref_evaluation(), ref_reservation());
insert into Client values (11 ,'ABBACI' ,'Abdelmadjid', '', ref_evaluation(), ref_reservation());
insert into Client values (12 ,'ABBAS', 'Samira', '', ref_evaluation(), ref_reservation());
insert into Client values (13 ,'ABBOUm', 'Mohamed', '', ref_evaluation(), ref_reservation());
insert into Client values (14 ,'ABDELAZIZ', 'Ahmed', '', ref_evaluation(), ref_reservation());
insert into Client values (15 ,'ABDELMOUMEN' ,'Nassima', '', ref_evaluation(), ref_reservation());
insert into Client values (16 ,'ABDELOUAHAB', 'OUAHIBA', '', ref_evaluation(), ref_reservation());
insert into Client values (17 ,'ABDEMEZIANE' ,'Madjid', '', ref_evaluation(), ref_reservation());
insert into Client values (18 ,'ABERKANE' ,'Aicha', '', ref_evaluation(), ref_reservation());
insert into Client values (19 ,'AZOUG' ,'Dalila', '', ref_evaluation(), ref_reservation());
insert into Client values (20 ,'BENOUADAH', 'Mohammed', '', ref_evaluation(), ref_reservation());
insert into Client values (21 ,'ACHAIBOU' ,'Rachid', '', ref_evaluation(), ref_reservation());
insert into Client values (22 ,'ADDAD' ,'Fadila', '', ref_evaluation(), ref_reservation());
insert into Client values (23 ,'AGGOUN' ,'Khadidja', '', ref_evaluation(), ref_reservation());
insert into Client values (24 ,'AISSAT' ,'Salima', '', ref_evaluation(), ref_reservation());
insert into Client values (25 ,'AMARA' ,'Dahbia', '', ref_evaluation(), ref_reservation());
insert into Client values (26 ,'AROUEL' ,'Leila', '', ref_evaluation(), ref_reservation());
insert into Client values (27 ,'BAALI' ,'Souad', '', ref_evaluation(), ref_reservation());
insert into Client values (28 ,'BABACI' ,'Mourad', '', ref_evaluation(), ref_reservation());
insert into Client values (29 ,'BACHA' ,'Nadia', '', ref_evaluation(), ref_reservation());
insert into Client values (30 ,'BAHBOUH', 'Naima', '', ref_evaluation(), ref_reservation());
insert into Client values (31 ,'BADI' ,'Hatem', '', ref_evaluation(), ref_reservation());
insert into Client values (32 ,'BAKIR', 'ADEL', '', ref_evaluation(), ref_reservation());
insert into Client values (33 ,'BALI' ,'Malika', '', ref_evaluation(), ref_reservation());
insert into Client values (34 ,'BASSI' ,'Fatima', '', ref_evaluation(), ref_reservation());
insert into Client values (35 ,'BEHADI', 'Youcef', '', ref_evaluation(), ref_reservation());
insert into Client values (36 ,'BEKKAT' ,'Hadia', '', ref_evaluation(), ref_reservation());
insert into Client values (37 ,'BELABES' ,'Abdelkader', '', ref_evaluation(), ref_reservation());
insert into Client values (38 ,'BELAKERMI', 'Mohammed', '', ref_evaluation(), ref_reservation());
insert into Client values (39 ,'BELGHALI' ,'Mohammed', '', ref_evaluation(), ref_reservation());
insert into Client values (40 ,'BELHAMIDI' ,'Mustapha', '', ref_evaluation(), ref_reservation());
insert into Client values (41 ,'BELKACEMI' ,'Hocine', '', ref_evaluation(), ref_reservation());
insert into Client values (42 ,'BELKOUT' ,'Tayeb', '', ref_evaluation(), ref_reservation());
insert into Client values (43 ,'RAHALI' ,'Ahcene', '', ref_evaluation(), ref_reservation());
insert into Client values (44 ,'FERAOUN' ,'Houria', '', ref_evaluation(), ref_reservation());
insert into Client values (45 ,'TERKI' ,'Amina', '', ref_evaluation(), ref_reservation());
insert into Client values (46 ,'CHAOUI' ,'Farid', '', ref_evaluation(), ref_reservation());
insert into Client values (47 ,'BENDALI', 'Hacine', '', ref_evaluation(), ref_reservation());
insert into Client values (48 ,'CHAKER' ,'Nadia', '', ref_evaluation(), ref_reservation());
insert into Client values (49 ,'BELHAMIDI', 'Mustapha', '', ref_evaluation(), ref_reservation());
insert into Client values (50 ,'BELKACEMI', 'Hocine', '', ref_evaluation(), ref_reservation());
insert into Client values (51 ,'BELKOUT', 'Tayeb', '', ref_evaluation(), ref_reservation());
insert into Client values (52 ,'RAHALI', 'Ahcene', '', ref_evaluation(), ref_reservation());
insert into Client values (53 ,'FERAOUN', 'Houria', '', ref_evaluation(), ref_reservation());
insert into Client values (54 ,'TERKI', 'Amina', '', ref_evaluation(), ref_reservation());
insert into Client values (55 ,'CHAOUI', 'Farid', '', ref_evaluation(), ref_reservation());
insert into Client values (56 ,'BENDALI', 'Hacine', '', ref_evaluation(), ref_reservation());
insert into Client values (57 ,'CHAKER' ,'Nadia', '', ref_evaluation(), ref_reservation());
insert into Client values (58 ,'BOULARAS','Fatima', '', ref_evaluation(), ref_reservation());
insert into Client values (59 ,'IGOUDJIL', 'Redouane', '', ref_evaluation(), ref_reservation());
insert into Client values (60 ,'GHEZALI', 'Lakhdar', '', ref_evaluation(), ref_reservation());
insert into Client values (61 ,'KOULA', 'Brahim', '', ref_evaluation(), ref_reservation());
insert into Client values (62 ,'BELAID', 'Layachi', '', ref_evaluation(), ref_reservation());
insert into Client values (63 ,'CHALABI' ,'Mourad', '', ref_evaluation(), ref_reservation());
insert into Client values (64 ,'MOHAMMEDI' ,'Mustapha', '', ref_evaluation(), ref_reservation());
insert into Client values (65 ,'FEKAR', 'Abdelaziz', '', ref_evaluation(), ref_reservation());
insert into Client values (66 ,'SAIDOUNI', 'Wafa', '', ref_evaluation(), ref_reservation());
insert into Client values (67 ,'Yalaoui', 'Lamia', '', ref_evaluation(), ref_reservation());
insert into Client values (68 ,'AYATA', 'Samia', '', ref_evaluation(), ref_reservation());
insert into Client values (69 ,'TEBIBEL', 'Nabila', '', ref_evaluation(), ref_reservation());

/**  table Chambre **/

insert into Chambre values (1, 1, 'simple', 4500, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (1, 0, 'autre', 13000, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (1, 0, 'triple', 7000, (select ref(h) from Hotel h where h.numHotel=5), ref_reservation());
insert into Chambre values (1, 1, 'double', 6000, (select ref(h) from Hotel h where h.numHotel=6), ref_reservation());
insert into Chambre values (1, 0, 'autre', 13000, (select ref(h) from Hotel h where h.numHotel=9), ref_reservation());
insert into Chambre values (1, 1, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (1, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (2, 1, 'simple', 4800, (select ref(h) from Hotel h where h.numHotel=5), ref_reservation());
insert into Chambre values (2, 1, 'simple', 4000, (select ref(h) from Hotel h where h.numHotel=6), ref_reservation());
insert into Chambre values (2, 1, 'double', 6000, (select ref(h) from Hotel h where h.numHotel=9), ref_reservation());
insert into Chambre values (2, 1, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (2, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (3, 1, 'double', 7100, (select ref(h) from Hotel h where h.numHotel=5), ref_reservation());
insert into Chambre values (3, 1, 'double', 5500, (select ref(h) from Hotel h where h.numHotel=6), ref_reservation());
insert into Chambre values (3, 1, 'double', 6000, (select ref(h) from Hotel h where h.numHotel=9), ref_reservation());
insert into Chambre values (3, 1, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (3, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (4, 1, 'simple', 5400, (select ref(h) from Hotel h where h.numHotel=6), ref_reservation());
insert into Chambre values (4, 2, 'double', 6200, (select ref(h) from Hotel h where h.numHotel=9), ref_reservation());
insert into Chambre values (4, 2, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (5, 2, 'double', 8600, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (4, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=6), ref_reservation());
insert into Chambre values (5, 2, 'double', 6200, (select ref(h) from Hotel h where h.numHotel=9), ref_reservation());
insert into Chambre values (5, 2, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (5, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (6, 2, 'simple', 5800, (select ref(h) from Hotel h where h.numHotel=6), ref_reservation());
insert into Chambre values (6, 2, 'double', 6200, (select ref(h) from Hotel h where h.numHotel=9), ref_reservation());
insert into Chambre values (6, 2, 'double', 4800, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (6  0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (7, 2, 'simple', 5800, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (7, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (8, 2, 'double', 8600, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (8, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (9, 3, 'suite', 16000, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (9, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (10, 1, 'simple', 7100, (select ref(h) from Hotel h where h.numHotel=2), ref_reservation());
insert into Chambre values (10, 3, 'suite', 16500, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (10, 1, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (10, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (11, 1, 'simple', 7100, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (11, 1, 'simple', 8400, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (11, 1, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (11, 0, 'simple', 7800, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (12, 1, 'double', 8800, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (12, 1, 'simple', 8400, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (12, 1, 'double', 4200, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (12, 0, 'double', 9100, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (13, 1, 'simple', 6200, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (13, 1, 'simple', 8600, (select ref(h) from Hotel h where h.numHotel=11, ref_reservation());
insert into Chambre values (13, 0, 'double', 9100, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (14, 1, 'simple', 9000, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (14, 1, 'double', 9100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (15, 1, 'double', 9100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (16, 1, 'simple', 7700, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (17, 1, 'simple', 7700, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (18, 1, 'simple', 7700, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (19, 1, 'simple', 7700, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (20, 2, 'double', 9000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (20, 2, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (20, 1, 'simple', 7700, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (21, 2, 'simple', 6800, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (21, 2, 'double', 12000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (21, 2, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (21, 1, 'simple', 7500, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (22, 2, 'simple', 6800, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (22, 2, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (22, 2, 'double', 4200, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (22, 1, 'simple', 7500, (select ref(h) from Hotel h where h.numHotel=1), ref_reservation());
insert into Chambre values (23, 2, 'double', 8900, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (23, 1, 'simple', 7500, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (24, 1, 'double', 8000, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (25, 1, 'double', 8000, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation()); 
insert into Chambre values (26, 1, 'double', 8000, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (27, 2, 'triple', 10900, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (28, 2, 'triple', 10900, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (29, 2, 'simple', 7200, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (30, 3, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (30, 2, 'simple', 7200, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (31, 3, 'triple', 14500, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (31, 3, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (31, 2, 'simple', 7200, (select ref(h) from Hotel h where h.numHotel=4), ref_reservation());
insert into Chambre values (32, 3, 'simple', 9000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (32, 3, 'double', 4200, (select ref(h) from Hotel h where h.numHotel=11), ref_reservation());
insert into Chambre values (32, 2, 'simple', 7200, (select ref(h) from Hotel h where h.numHotel=13), ref_reservation());
insert into Chambre values (33, 3, 'simple', 5000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (40, 4, 'simple', 2000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (41, 4, 'simple', 2000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (42, 4, 'simple', 2000, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (43, 4, 'simple', 1800, (select ref(h) from Hotel h where h.numHotel=7), ref_reservation());
insert into Chambre values (44, 4, 'simple', 1800, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (100, 1, 'simple', 2900, (select ref(h) from Hotel h where h.numHotel=10), ref_reservation());
insert into Chambre values (100, 1, 'double', 9700, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (101, 1, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (101, 1, 'simple', 2900, (select ref(h) from Hotel h where h.numHotel=10), ref_reservation());
insert into Chambre values (101, 1, 'double', 11000, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (101, 1, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (102, 1, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (102, 1, 'simple', 2800, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (102, 1, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (103, 1, 'simple', 3300, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (103, 1, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (104, 1, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (105, 1, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (106, 1, 'double', 14500, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (107, 1, 'double', 14500, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (200, 2, 'simple', 2800, (select ref(h) from Hotel h where h.numHotel=10), ref_reservation());
insert into Chambre values (200, 2, 'double', 9700, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (201, 2, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (201, 2, 'simple', 2900, (select ref(h) from Hotel h where h.numHotel=10), ref_reservation());
insert into Chambre values (201, 2, 'double', 9700, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (201, 2, 'double', 14500, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (202, 2, 'simple', 3200, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (202, 2, 'simple', 2900, (select ref(h) from Hotel h where h.numHotel=10), ref_reservation());
insert into Chambre values (202, 2, 'triple', 14100, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (202, 2, 'double', 14500, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (203, 2, 'simple', 3300, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (203, 2, 'double', 11800, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (204, 2, 'double', 11800, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (205, 2, 'double', 13000, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (206, 2, 'double', 14500, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (207, 2, 'double', 14500, (select ref(h) from Hotel h where h.numHotel=14), ref_reservation());
insert into Chambre values (208, 1, 'simple', 4500, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (300, 3, 'simple', 3000, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (301, 3, 'simple', 3400, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (301, 3, 'simple', 3100, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (301, 3, 'suite', 19500, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (302, 3, 'simple', 3400, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (302, 3, 'double', 3700, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (302, 3, 'suite', 19500, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (303, 3, 'simple', 3400, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (303, 3, 'suite', 19500, (select ref(h) from Hotel h where h.numHotel=12), ref_reservation());
insert into Chambre values (401, 4, 'double', 4200, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (401, 4, 'double', 3700, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());
insert into Chambre values (402, 4, 'double', 4200, (select ref(h) from Hotel h where h.numHotel=3), ref_reservation());
insert into Chambre values (402, 4, 'simple', 2000, (select ref(h) from Hotel h where h.numHotel=8), ref_reservation());

/**  table Reservation **/

insert into Reservation values ('11/05/2022', '15/05/2022', (select ref(cl) from Client cl where cl.num_client=1), (select ref(c) from Chambre c where c.num_chambre=1 AND c.chambre_hotel.numHotel=5));
insert into Reservation values ('11/04/2022', '18/04/2022', (select ref(cl) from Client cl where cl.num_client=2), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=5));
insert into Reservation values ('05/04/2022', '06/04/2022', (select ref(cl) from Client cl where cl.num_client=6), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=5));
insert into Reservation values ('27/04/2022', '01/05/2022', (select ref(cl) from Client cl where cl.num_client=6), (select ref(c) from Chambre c where c.num_chambre=30 AND c.chambre_hotel.numHotel=7));
insert into Reservation values ('11/06/2022', '14/06/2022', (select ref(cl) from Client cl where cl.num_client=6), (select ref(c) from Chambre c where c.num_chambre=100 AND c.chambre_hotel.numHotel=10));
insert into Reservation values ('02/05/2022', '10/05/2022', (select ref(cl) from Client cl where cl.num_client=13), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=6));
insert into Reservation values ('28/04/2022', '01/05/2022', (select ref(cl) from Client cl where cl.num_client=14), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=6));
insert into Reservation values ('12/05/2022', '13/05/2022', (select ref(cl) from Client cl where cl.num_client=14), (select ref(c) from Chambre c where c.num_chambre=21 AND c.chambre_hotel.numHotel=4));
insert into Reservation values ('04/05/2022', '09/05/2022', (select ref(cl) from Client cl where cl.num_client=23), (select ref(c) from Chambre c where c.num_chambre=1 AND c.chambre_hotel.numHotel=6));
insert into Reservation values ('30/04/2022', '03/05/2022', (select ref(cl) from Client cl where cl.num_client=28), (select ref(c) from Chambre c where c.num_chambre=100 AND c.chambre_hotel.numHotel=8));
insert into Reservation values ('13/04/2022', '14/04/2022', (select ref(cl) from Client cl where cl.num_client=28), (select ref(c) from Chambre c where c.num_chambre=3 AND c.chambre_hotel.numHotel=9));
insert into Reservation values ('01/05/2022', '03/05/2022', (select ref(cl) from Client cl where cl.num_client=16), (select ref(c) from Chambre c where c.num_chambre=301 AND c.chambre_hotel.numHotel=8));
insert into Reservation values ('03/05/2022', '20/05/2022', (select ref(cl) from Client cl where cl.num_client=20), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=9));
insert into Reservation values ('15/04/2022', '20/04/2022', (select ref(cl) from Client cl where cl.num_client=15), (select ref(c) from Chambre c where c.num_chambre=3 AND c.chambre_hotel.numHotel=9));
insert into Reservation values ('09/05/2022', '10/05/2022', (select ref(cl) from Client cl where cl.num_client=12), (select ref(c) from Chambre c where c.num_chambre=8 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('06/04/2022', '08/04/2022', (select ref(cl) from Client cl where cl.num_client=3), (select ref(c) from Chambre c where c.num_chambre=9 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('07/05/2022', '12/05/2006', (select ref(cl) from Client cl where cl.num_client=7), (select ref(c) from Chambre c where c.num_chambre=7 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('04/04/2022', '08/04/2022', (select ref(cl) from Client cl where cl.num_client=47), (select ref(c) from Chambre c where c.num_chambre=20 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('07/04/2022', '07/05/2022', (select ref(cl) from Client cl where cl.num_client=44), (select ref(c) from Chambre c where c.num_chambre=5 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('07/05/2022', '12/05/2022', (select ref(cl) from Client cl where cl.num_client=80), (select ref(c) from Chambre c where c.num_chambre=302 AND c.chambre_hotel.numHotel=13));
insert into Reservation values ('11/04/2022', '14/04/2022', (select ref(cl) from Client cl where cl.num_client=40), (select ref(c) from Chambre c where c.num_chambre=9 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('01/05/2022', '05/05/2022', (select ref(cl) from Client cl where cl.num_client=40), (select ref(c) from Chambre c where c.num_chambre=8 AND c.chambre_hotel.numHotel=2));
insert into Reservation values ('09/05/2022', '13/05/2022', (select ref(cl) from Client cl where cl.num_client=40), (select ref(c) from Chambre c where c.num_chambre=23 AND c.chambre_hotel.numHotel=1));
insert into Reservation values ('04/04/2022', '05/04/2022', (select ref(cl) from Client cl where cl.num_client=22), (select ref(c) from Chambre c where c.num_chambre=25 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('07/06/2022', '10/06/2022', (select ref(cl) from Client cl where cl.num_client=112), (select ref(c) from Chambre c where c.num_chambre=1 AND c.chambre_hotel.numHotel=5));
insert into Reservation values ('22/04/2022', '26/04/2022', (select ref(cl) from Client cl where cl.num_client=26), (select ref(c) from Chambre c where c.num_chambre=25 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('04/04/2022', '08/04/2022', (select ref(cl) from Client cl where cl.num_client=29), (select ref(c) from Chambre c where c.num_chambre=1 AND c.chambre_hotel.numHotel=11));
insert into Reservation values ('12/05/2022', '10/05/2022', (select ref(cl) from Client cl where cl.num_client=37), (select ref(c) from Chambre c where c.num_chambre=302 AND c.chambre_hotel.numHotel=8));
insert into Reservation values ('04/05/2022', '09/05/2022', (select ref(cl) from Client cl where cl.num_client=29), (select ref(c) from Chambre c where c.num_chambre=205 AND c.chambre_hotel.numHotel=12));
insert into Reservation values ('04/04/2022', '06/05/2022', (select ref(cl) from Client cl where cl.num_client=35), (select ref(c) from Chambre c where c.num_chambre=101 AND c.chambre_hotel.numHotel=12));
insert into Reservation values ('17/05/2022', '23/05/2022', (select ref(cl) from Client cl where cl.num_client=35), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=5));
insert into Reservation values ('27/05/2022', '02/06/2022', (select ref(cl) from Client cl where cl.num_client=35), (select ref(c) from Chambre c where c.num_chambre=2 AND c.chambre_hotel.numHotel=6));
insert into Reservation values ('11/05/2022', '18/05/2022', (select ref(cl) from Client cl where cl.num_client=37), (select ref(c) from Chambre c where c.num_chambre=202 AND c.chambre_hotel.numHotel=12));

/**  table Evaluation **/

INSERT INTO Evaluation VALUES ('11/05/2022', 3, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =8), (SELECT REF(c) FROM Client c WHERE c.num_Client =26));
INSERT INTO Evaluation VALUES ('25/05/2022', 4, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =8), (SELECT REF(c) FROM Client c WHERE c.num_Client =29));
INSERT INTO Evaluation VALUES ('04/05/2022', 7, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =7), (SELECT REF(c) FROM Client c WHERE c.num_Client =35));
INSERT INTO Evaluation VALUES ('02/05/2022', 1, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_Client =37));
INSERT INTO Evaluation VALUES ('18/05/2022', 9, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =4), (SELECT REF(c) FROM Client c WHERE c.num_client =40));
INSERT INTO Evaluation VALUES ('01/05/2022', 10, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =1), (SELECT REF(c) FROM Client c WHERE c.num_client =22));
INSERT INTO Evaluation VALUES ('03/06/2022', 5, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_client =3));
INSERT INTO Evaluation VALUES ('04/05/2022', 5, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_client =7));
INSERT INTO Evaluation VALUES ('17/06/2022', 5, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =8), (SELECT REF(c) FROM Client c WHERE c.num_client =13));
INSERT INTO Evaluation VALUES ('19/06/2022', 7, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =2), (SELECT REF(c) FROM Client c WHERE c.num_client =6));
INSERT INTO Evaluation VALUES ('18/05/2022', 8, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_client =1));
INSERT INTO Evaluation VALUES ('22/05/2022', 4, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =2), (SELECT REF(c) FROM Client c WHERE c.num_client =2));
INSERT INTO Evaluation VALUES ('26/05/2022', 2, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =5), (SELECT REF(c) FROM Client c WHERE c.num_client =15));
INSERT INTO Evaluation VALUES ('29/05/2022', 2, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_client =20));
INSERT INTO Evaluation VALUES ('02/06/2022', 6, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =4), (SELECT REF(c) FROM Client c WHERE c.num_client =40));
INSERT INTO Evaluation VALUES ('03/05/2022', 8, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =12), (SELECT REF(c) FROM Client c WHERE c.num_client =26));
INSERT INTO Evaluation VALUES ('18/04/2022', 9, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =12), (SELECT REF(c) FROM Client c WHERE c.num_client =112));
INSERT INTO Evaluation VALUES ('19/04/2022', 4, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =5), (SELECT REF(c) FROM Client c WHERE c.num_client =22));
INSERT INTO Evaluation VALUES ('03/06/2022', 4, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =4), (SELECT REF(c) FROM Client c WHERE c.num_client =22));
INSERT INTO Evaluation VALUES ('09/05/2022', 3, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =8), (SELECT REF(c) FROM Client c WHERE c.num_client =3));
INSERT INTO Evaluation VALUES ('09/05/2022', 2, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =5), (SELECT REF(c) FROM Client c WHERE c.num_client =7));
INSERT INTO Evaluation VALUES ('10/06/2022', 8, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =4), (SELECT REF(c) FROM Client c WHERE c.num_client =15));
INSERT INTO Evaluation VALUES ('26/10/2022', 3, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_client =12));
INSERT INTO Evaluation VALUES ('07/03/2022', 7, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =6), (SELECT REF(c) FROM Client c WHERE c.num_client =37));
INSERT INTO Evaluation VALUES ('27/06/2022', 8, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =1), (SELECT REF(c) FROM Client c WHERE c.num_client =80));
INSERT INTO Evaluation VALUES ('09/11/2022', 5, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =3), (SELECT REF(c) FROM Client c WHERE c.num_client =29));
INSERT INTO Evaluation VALUES ('27/08/2022', 6, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =2), (SELECT REF(c) FROM Client c WHERE c.num_client =6));
INSERT INTO Evaluation VALUES ('20/04/2022', 9, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =7), (SELECT REF(c) FROM Client c WHERE c.num_client =2));
INSERT INTO Evaluation VALUES ('29/03/2022', 10, (SELECT REF(h) FROM Hotel h WHERE h.numHotel =12), (SELECT REF(c) FROM Client c WHERE c.num_client =14));


/* Language d'intérrogation */

/* Lister les noms d’hôtels et leurs villes respectives */
select nomHotel, ville from Hotel order by nomHotel;

/* Lister les hôtels sur lesquels porte au moins une réservation. */
select distinct H.numHotel, H.nomHotel, H.ville  from Hotel H, Reservation R 
where deref(deref(R.reservation_chambre).chambre_hotel).numHotel = H.numHotel;

/* Quels sont les clients qui ont toujours séjourné au premier étage ? */
select C.num_client,C.nom_client,C.prenom_client from Chambre Ch, Client C, table(CH.chambre_reservation) R 
where deref(value(R).reservation_client).num_client = C.num_client and CH.etage = 1;

/*  Quels sont les hôtels (nom, ville) qui offrent des suites ? et donner le prix pour chaque suite */
select distinct H.numHotel, H.nomHotel, H.ville, value(CH).num_chambre, value(CH).prix_nuit, value(CH).typeChambre from Hotel H, table(H.hotel_chambre) CH
where value(CH).typeChambre = 'suite';

/*  Quel est le type de chambre le plus réservé habituellement, pour chaque hôtel d’Alger ? */

SELECT deref(R.reservation_chambre).TYPECHAMBRE, COUNT(*) AS nb_reservation
FROM Reservation R
WHERE deref(deref(R.reservation_chambre).chambre_hotel).VILLE = 'Alger'
GROUP BY deref(R.reservation_chambre).TYPECHAMBRE
ORDER BY nb_reservation ;

/*  Quels sont les hôtels (nom, ville) ayant obtenu une moyenne de notes >=6, durant l’année 2022*/

SELECT H.numHotel, H.nomHotel, H.ville ,AVG(E.note) as moyennNote
FROM Hotel H, Evaluation E 
WHERE  H.numHotel = deref(E.evaluation_hotel).numHotel AND EXTRACT(YEAR FROM dateE) = 2022
GROUP BY H.numHotel
HAVING AVG(E.note) >= 6;

/*  Quel est l’hôtel ayant réalisé le meilleur chiffre d’affaire durant l’été 2022  */

select deref(deref(R.RESERVATION_CHAMBRE).CHAMBRE_HOTEL).numHotel, sum(deref(R.RESERVATION_CHAMBRE).prix_nuit) as chiffre_aff
from reservation R 
where EXTRACT(MONTH FROM DATEA) IN (6, 7, 8)
group by deref(deref(R.RESERVATION_CHAMBRE).CHAMBRE_HOTEL).numHotel 
ORDER BY chiffre_aff;