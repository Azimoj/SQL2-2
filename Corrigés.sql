-- NIVEAU 1
-- 1. Display a new column "Authorized in Paris" that takes the value 'y' if a car is authorized in Paris and 'n' if not from 2022
-- Indeed cars made before 2004 will be forbidden in Paris 

-- On nous demande de rajouter une information à chaque voiture sous une condition précise
-- La commande CASE... WHEN ... permet de retourner un résultat selon plusieurs conditions
-- La commande peut s'utiliser dans n'importe quelle instruction ou clause, ici on cherche à afficher le résultat dans une colonne, c'est donc dans le SELECT qu'on l'utilise
-- Rappelons - nous la syntaxe
CASE
	WHEN condition1 THEN resultat1 -- si la condition est vraie alors la valeur située après le THEN sera retourné
	WHEN condition2 THEN resultat2 
	ELSE resultat3 				-- Toujours finir un CASE WHEN par un ELSE qui renvoie la valeur située à sa suite si aucune condition n'est respectée
	END AS new_output -- il est possible d'alias le case when pour pouvoir le rappeler si besoin, ou simplement donner un nom à la colonne 

-- Ici nous n'avons qu'une condition à regarder : est-ce que l'attibut YEAR de la voiture est inférieur à 2004 auquel cas on veut attrivuer la valeur 'n' à notre nouvelle colonne

-- Final : 

SELECT maker, c.year,
	CASE 
		WHEN c.year < 2004 THEN 'Y'
		ELSE 'N'
	END AS authorized_in_Paris
FROM cars c;

-- A la différence du WHERE qui aurait pu nous permettre d'afficher toutes les voitures autorisées par exemple (WHERE c.Year >= 2004)
-- on a ici affiché une nouvelle colonne qui nous permet de comprendre clairement les informations en regardant uniquement notre output.

-- 2. Show car makers that have more than 3 cars registered in the database 

-- Ici on ne nous demande pas de nouvelles colonnes, on ne veut garder que les fabricants ayant un certain nombre de voitures enregistrés dans la base
-- Donc pas besoin de Case When , un bon vieux GROUP BY avec une fonction d'agrégation fera l'affaire (on compte le nombre de voitures par groupe de fabricants)

-- Final : 

SELECT maker, COUNT(*) AS nb_maker
FROM cars
GROUP BY maker
HAVING nb_maker >= 3; -- On se souvient qu'on a besoin de la commande HAVING pour filtrer des agrégats

-- 3. Compute the number of ride for each car and the total contribution
-- received. Get only the top 10 results.

-- HERE I CONSIDERED THAT ALL SEATS IN THE RIDE TABLE HAVE BEEN BOUGHT

-- Toutes les informations sont contenues dans la table rides (contribution, nombre de sièges, par agrégat nombre de voyages) sauf l'id de la voiture qui est dans member_car
-- Pour avoir le résultat par voiture on doit grouper nos données par voiture unique.

-- La première chose que l'on peut faire est donc d'afficher le nombre de voyages par voiture et de préparer notre jointure
-- On sait calculer le nombre de voyages en comptant chaque Ride unique par groupe de voiture unique, et l'ordonner pour ne garder que les 10 premiers résultats
-- (à l'aide d'ORDER BY et de LIMIT)

SELECT  mc.car_ID, COUNT(r.ride_id) AS nb_trips
FROM rides AS r
INNER JOIN member_car AS mc
	ON r.member_car_id = mc.member_car_id
GROUP BY mc.car_ID
ORDER BY nb_trips DESC
LIMIT 10;

-- Il reste à faire le calcul de la contribution totale l'idée est de multiplier la contribution par passager par le nombre de sièges utilisés
-- on a donc la contribution par course, il faut ensuite sommer toutes ces contributions par groupe de voiture unique.
-- On peut faire ça dans la même requête car notre GROUP BY ci-dessus (mc.car_ID) sépare déjà notre table par voiture unique
-- il ne reste donc plus qu'à écrire le calcul décrit dans le SELECT

-- Final :

SELECT  mc.car_id, COUNT(r.ride_id) AS nb_trips, SUM(contribution_per_passenger*number_seats) AS total_contrib
FROM rides AS r
INNER JOIN member_car AS mc
	ON r.member_car_id = mc.member_car_id
GROUP BY mc.car_id
ORDER BY nb_trips DESC
LIMIT 10;

-- 4. Create a new category in cities that tells whether a city is in the
-- south or in the north
-- HERE ONLY LYON AND MARSEILLE ARE IN THE SOUTH

-- Dans la table nous ne disposons pas de données géographiques précises pour faire notre filtre, nous nous contenterons donc de séparer Lyon et Mareille des autres villes
-- plus au nord

-- Il s'agit à nouveau de créer une nouvelle catégorie, cela se fait donc grâce à un case when
-- dans le when on peut retrouver la même syntaxe que dans un filtre WHERE, les opérateurs OR AND sont valables de même que les commandes LIKE etc..

SELECT city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS position
FROM cities

-- 5. Join cities on rides with a Left Join and an Inner Join for both starting_city and Destination_city

SELECT * 
FROM rides AS r
LEFT JOIN cities AS c 
	ON r.starting_city_id = c.city_id
LEFT JOIN cities AS ct
	ON r.destination_city_id = ct.city_id ;

SELECT * 
FROM rides AS r
INNER JOIN cities AS c 
	ON r.starting_city_id = c.city_id
INNER JOIN cities AS ct 
	ON r.destination_city_id = ct.city_id;

-- NIVEAU 2 
-- 1. Taking results from question 4, compute whether the number of rides is higher in the north or in the south
-- You can display the number of rides from North to South , N to N, S to N, S to S


-- Reprenons la question 4, nous pouvons utiliser cette requête pour catégoriser chaque ville en regardant la valeur de la colonne Position
-- Notre objectif est d'arriver à montrer une table avec les colonnes localisation_Ville_depart, localisation_ville_d'arrivee et le nombre_de_courses associé

-- la requête : 
SELECT city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS position
FROM cities
-- donne une table avec la localisation des villes, on peut donc joindre cette table d'une part avec la table rides sur starting_city_id 
-- et grouper par position (NORD,SUD) pour effectuer des opérations sur les villes de départ selon leur localisation
-- On peut faire le même procédé par jointure sur destination_city_id
-- On va donc joindre deux fois la table position (la question 4) Avec la table rides, précisons bien l'alias de position selon la jointure (position_depart / _arrivee)


SELECT c.city_name ,`position_depart`,c2.city_name, `position_arrivee`
FROM rides AS r
JOIN (SELECT city_id, city_name,        -- Lorsque JOIN est renseigné sans préfixe, c'est un INNER JOIN qui est opéré, lorsque plusieurs types de jointures sont effectuées dans
	CASE 							-- une requête, préférons l'écriture complète INNER JOIN par souci de clarté
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS `position_depart`
FROM cities AS cp) AS c         -- Bien penser à faire des Alias reconnaissables et distincts comme la requête est utilisée deux fois 
	ON r.starting_city_id = c.city_id

JOIN (SELECT city_id, city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS `position_arrivee`
FROM cities AS cp2) AS c2
	ON r.destination_city_id = c2.city_id;



-- En éxécutant cette requête, vous pouvez comprendre comment a fonctionné la jointure, on peut désormais classer les villes par position de départ et d'arrivée
-- et donc effectuer des opérations d'agrégation 
-- Il faut penser au GROUP BY judicieux, on veut à la fois grouper par rapport aux positions de départ et aux positions d'arrivée pour avoir notre fameux tableau :
-- avec les informations : N - N , N - S, S - N , S-S
-- Avec le bon GROUP BY il suffit d'utiliser COUNT sur les différentes courses pour afficher le nombre de courses par localisation : 

--Final : 


SELECT `position_depart`,`position_arrivee`, COUNT(r.ride_id) AS total_ride
FROM rides AS r
JOIN (SELECT city_id, city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS `position_depart`
FROM cities AS cp) AS c
	ON r.starting_city_id = c.city_id

JOIN (SELECT city_id, city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS `position_arrivee`
FROM cities AS cp2) AS c2
	ON r.destination_city_id = c2.city_id
GROUP BY `position_depart`,`position_arrivee`;

-- Il est aussi possible de passer par un With : 

WITH table_city_position AS
      (
      SELECT city_id, city_name,
              CASE
                  WHEN city_name in ('Lyon', 'Marseille') THEN 'South'
                  ELSE 'North'
              END AS city_position
      FROm cities
      )
SELECT tcp_dep.city_position AS position_dep, tcp_arr.city_position AS position_arr, COUNT(*) AS nb_trips 
FROM rides r
JOIN table_city_position AS tcp_dep
	ON r.starting_city_id = tcp_dep.city_id
JOIN table_city_position AS tcp_arr
	ON r.destination_city_id = tcp_arr.city_id
GROUP BY position_dep, position_arr;

-- 2. Find out how many trips starting in the North was taken by each member 

-- Il va à nouveau falloir utiliser la requête en 4. pour déterminer la position des courses
-- Cela commence à être redondant d'appeler la requête 4 en sous requête à de multiples reprises pour pouvoir utiliser les informations de localisation des villes
-- Commençons donc par créer une table éphémère dans notre base de données qui stocke les informations de notre requête préférée : 

DROP TABLE IF EXISTS city_position;  -- Afin de s'assurer de ne pas utiliser de tables déjà existantes, assurons nous de repartir d'une table vierge
CREATE TEMPORARY TABLE city_position
(SELECT city_id, city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS position
 FROM cities);

-- Nous avons maintenant à disposition notre table City_Position, n'hésitez pas à afficher ses éléments pour être sur de comprendre
SELECT *
FROM city_position;

-- Utilisons maintenant cette table comme une autre, nous devons relier les voyages commençant au nord, les membres concernés, et le nombre de voyages en question
-- Les informations sont donc dans les tablees City_position , Ride, et Member_Car que nous allons joindre
-- Il nous suffira ensuite de grouper notre table par membre, et de compter le nombre de courses par membre, en s'assurant de filtrer les courses commençant au nord

-- Final : 

SELECT member_id, count(r.ride_id) AS nb_trips
FROM rides AS r
JOIN city_position AS cp 
	ON r.starting_city_id = cp.city_id
JOIN member_car AS mc 
	ON r.member_car_id = mc.member_car_id
WHERE position = 'North'
GROUP BY member_id ;

-- 3. Create new columns in ride printing the day of the week, the month number and the year of the ride.

-- Ici nous allons manipuler les fonctions de date pour affichier le résultat désiré, l'information de base que nous détenons dans la table est l'attribut departure_date
Select departure_date
From rides r;

-- L'information est donc condensé sous un certain format, le format classique des dates en SQL, nous allons donc pouvoir utiliser des fonctions nous facilitant la vie
-- https://sql.sh/fonctions/date-heure : la documentation SQL nous permet de connaître toutes les fonctions aidant à travailler avec des dates
-- Ici les fonctions MONTH(), YEAR() nous serons directement utiles : elles extraient le numéro du mois et l'année d'une date complète
-- Pour le jour de la semaine, la fonction DAYOFWEEK est notre amie, elle renvoie une valeur de 1 à 7 pour indiquer le jour de la semaine selon la data qu'on lui fournit
-- Attention : lisez avec précaution la documentation, la fonction renvoie 1 quand le jour est dimanche (et non lundi) jusqu'à 7 pour samedi

-- Nous pouvons donc utiliser ces fonctions dans notre SELECT pour avoir accès aux informations désirées
SELECT rides.ride_id, DAYOFWEEK(departure_date), MONTH(departure_date), YEAR(departure_date)
From rides;

-- Le résultat est presque satisfaisant, mais avoir un numéro pour le jour de la semaine n'est pas très parlant, surtout quand on sait que 1 tient pour Dimanche
-- Pour finir la requête préférons à DAYOFWEEK(departure_date) l'affichage du jour en lettres, pour cela nous pouvons créer une colonne qui prend la valeur du jour de la seamine
-- avec un CASE WHEN en se basant sur le résultat de DAYOFWEEK(), dès lors notre requête sera parfaitement lisible

-- Final :


SELECT rides.ride_id, DAYOFWEEK(departure_date), MONTH(departure_date), YEAR(departure_date), 
	CASE 
		WHEN DAYOFWEEK(departure_date) = 1 THEN 'Sunday'
		WHEN DAYOFWEEK(departure_date) = 2 THEN 'Monday'
		WHEN DAYOFWEEK(departure_date) = 3 THEN 'Tuesday'
		WHEN DAYOFWEEK(departure_date) = 4 THEN 'Wednesday'
		WHEN DAYOFWEEK(departure_date) = 5 THEN 'Thursday'
		WHEN DAYOFWEEK(departure_date) = 6 THEN 'Friday'
		WHEN DAYOFWEEK(departure_date) = 7 THEN 'Saturday'
	END AS day_week
FROM rides;

-- 4. Retrieve rides that happened on a monday

-- Utilisons la requête précédente, nous avons accès à l'information du jour de la semaine, il nous suffit de filtrer notre SELECT pour qu'il affiche uniquement les lundi

SELECT rides.ride_id, DAYOFWEEK(departure_date), 
	CASE 
		WHEN DAYOFWEEK(departure_date) = 1 THEN 'Sunday'
		WHEN DAYOFWEEK(departure_date) = 2 THEN 'Monday'
		WHEN DAYOFWEEK(departure_date) = 3 THEN 'Tuesday'
		WHEN DAYOFWEEK(departure_date) = 4 THEN 'Wednesday'
		WHEN DAYOFWEEK(departure_date) = 5 THEN 'Thursday'
		WHEN DAYOFWEEK(departure_date) = 6 THEN 'Friday'
		WHEN DAYOFWEEK(departure_date) = 7 THEN 'Saturday'
	END AS day_week, MONTH(departure_date), YEAR(departure_date)
FROM rides
HAVING day_week = 'Monday'; -- ATTENTION : lorsqu'on veut filtrer le résultat d'un CASE WHEN , c'est bien un HAVING et non un WHERE qu'il s'agit d'utiliser


-- Si nous n'avions pas déjà écrit la requête 3, il aurait été très chronophage d'écrire celle-ci, comme nous sommes de compétents requéteurs SQL qui connaissons 
-- la subtilité des fonctions appliquées au date, nous n'avons pas besoin de passer par ce CASE WHEN
-- il est possible de filtrer directement sur le résultat de DAYOFWEEK(departure_date) en renseignant la bonne valeur ( = 2 pour Lundi)
-- C'est peut être un détail pour le lecteur qui ne remarquera rien, mais pour nous, ça veut dire beaucoup

SELECT rides.ride_id, DAYOFWEEK(departure_date), MONTH(departure_date), YEAR(departure_date)
FROM rides
WHERE DAYOFWEEK(departure_date) = 2;

-- 5. What share of rides have been done by drivers older than 25 ?

-- Nous avons accès à l'attribut birthdate des membres de la plateforme, utilisons des fonctions sur les dates pour trouver les membres de plus de 25ans
-- La fonction NOW() permet d'obtenir la date du jour, en utilisant la fonction YEAR() pour obtenir simplement les années, on peut réaliser des opérations usuelles :
SELECT YEAR(NOW())-YEAR(m.birthdate) as age , m.member_id
FROM members m 
-- et voilà , nous avons l'age de chacun de nos membres (grossièrement certes, nous n'avons comparé que les années, l'utilisation de DATE_SUB()) peut vous apporter précision
m.birthdate < DATE_SUB(NOW(), INTERVAL 25 YEAR) -- est un exemple de condition permettant de filtrer les membres ayant moins de 25ans précisément, je vous renvoie à la documentation


-- fermons la parenthèse, et comptons le nombre de courses faites par des conducteurs de plus de 25ans
-- il nous faut joindre les tables rides et members pour avoir accès en même temps aux courses et à l'age des membres, la jointure se fait par l'intermédiaire de member_car
-- Filtrons déjà les courses faites par des conducteurs de plus de 25ans à l'aide d'un HAVING portant sur l'age : (un WHERE ne fonctionne pas car il y a eu opération)


Select r.ride_id , m.member_id, (YEAR(NOW()) - YEAR(m.birthdate)) AS DIF, YEAR(m.birthdate), YEAR(NOW())
		FROM rides r
		LEFT JOIN member_car mc ON r.member_car_id = mc.member_car_id 
		LEFT JOIN `members` m on mc.member_id = m.member_id
		HAVING DIF>25;

-- il faut maintneant effectuer le calcul de proportion il nous suffit de compter ces fameuses courses que nous avons trouver et de les diviser par le total de courses
-- nous avons déjà fait un calcul similaire 

Select 
	(SELECT COUNT(over_25.ride_id)
		from (Select r2.ride_id  , m.member_id, (YEAR(NOW()) - YEAR(m.birthdate)) AS DIF, YEAR(m.birthdate), YEAR(NOW())
			FROM rides r2 
			LEFT JOIN member_car mc ON r2.member_car_id = mc.member_car_id 
			LEFT JOIN `members` m on mc.member_ID = m.member_id
			HAVING DIF>25) as over_25)
		/
		(SELECT count(r.ride_id)  
		FROM rides r)
		*100

-- On peut prendre un peu de temps sur le calcul, la première sous requête donne le nombre de courses faites par des plus de 25 ans
-- la deuxième sous-requête compte le nombre total de courses
-- on divise le résultat d'une sous requête par l'autre * 100 pour obtenir un pourcentage
-- Ici : la deuxième sous-requête est assez courte, il est possible de réarranger la syntaxe de la requête comme ci-dessous pour une meilleure compréhension de la requête: 

-- Final  :


Select COUNT(over_25.ride_id)/ (SELECT count(r3.ride_id) FROM rides r3)*100 -- Notez que la deuxième sous-requête est intégrée calcul, SQL commence par trouver le résultat de cette
	from (Select r2.ride_id , m.member_id, (YEAR(NOW()) - YEAR(m.birthdate)) AS DIF, YEAR(m.birthdate), YEAR(NOW()) -- requête avant de tenter de réaliser le calcul de la requête mère
		FROM rides r2 
		LEFT JOIN member_car mc ON r2.member_car_id = mc.member_car_id 
		LEFT JOIN `members` m on mc.member_ID = m.member_id
		HAVING DIF>25) as over_25;


-- On peut aussi utiliser la fonction date_sub pour éviter de requêter dans le FROM une table complexe :

SELECT 
    (
    select count(*) *100 / (select count(*) FROM rides)
    FROM rides r
    JOIN member_car mc
        ON r.member_car_id = mc.member_car_id
    JOIN members m
        ON mc.member_id = m.member_id
    where m.birthdate < date_sub(now(), INTERVAL 25 year)
    ) AS over_25;



-- 6. Create a view from one of the questions above

-- Souvenez-vous une view, à la différence d'une table, n'existe pas dans la mémoire de l'ordinateur, à la place, la requête est réeffectuée à chaque fois qu'on l'appelle 
-- (au sein d'une autre requête)
-- reprenons l'exemple position_city que nous avions créé en tant que table temporaire : 

-- Final : 

CREATE VIEW position_city AS -- Notez la différence de syntaxe entre CREATE TABLE et CREATE VIEW 
SELECT city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS position
FROM cities;



-- 7. Re-do question 1 from level 2 by creating an intermediary temp table or using a WITH

-- Et oui, en question 2 du niveau 2 nous en avions marre de réécrire la même requête à des multiples reprises, nous avions donc créé un table temporaire
DROP TABLE IF EXISTS city_position;
With city_position as
(SELECT c.city_id, city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS position
FROM cities c);

-- Dans le cadre de la question 1 cela nous simplifierait bien la vie, il suffit de l'appeler par son nom, la requête devient beaucoup plus légère à lire 
-- mais la requête ci-dessous, identique à la 1. mais avec l'appel de la table temporaire comporte un problème : 

SELECT cp1.position ,cp2.position, COUNT(r.ride_id) AS total_rides
FROM rides AS r
JOIN city_position AS cp1
	ON r.starting_city_id = cp1.city_id

JOIN city_position as cp2
	ON r.destination_city_id = cp2.city_id
GROUP BY cp1.position, cp2.position;

-- Essayons d'éxécuter la requête, c'est une erreur can't reopen table cp1 qui nous attend
-- En effet les tables temporaires ont le mauvais goût de ne pouvoir être appelé plusieurs fois avec des alias différents
-- Or nous en avons besoin pour identifier et aliasser nos colonnes
-- Il n'y a en fait qu'une méthode pour parvenir au résultat entre les deux proposées, la commande WITH, la commande WITH a la même syntaxe qu'une view
-- Mais un WITH doit être suivi d'un SELECT, le WITH nous permet d'écrire une seule fois notre CASE WHEN puis de l'utiliser deux fois pour simplifier la lecture

-- FINAL : 

With city_position as
(SELECT city_id, city_name,
	CASE 
		WHEN city_name LIKE 'Lyon' OR city_name LIKE 'Marseille' THEN 'South'
		ELSE 'North'
	END AS position
FROM cities)

SELECT cp1.position as starting_point ,cp2.position destination_point, COUNT(r.ride_id) AS total_rides
FROM rides AS r
JOIN city_position AS cp1
	ON r.starting_city_id = cp1.city_id

JOIN city_position as cp2
	ON r.destination_city_id = cp2.city_id
GROUP BY cp1.position, cp2.position;

-- Notez que WITH ne garde rien en mémoire, il faut donc exécuter notre requête en même temps que le WITH pour que tout fonctionne correctement
-- On peut utilsier ce WITH dès qu'on a besoin d'une requête qui utilise les données de position des villes.

