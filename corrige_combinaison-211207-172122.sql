
-- 1. Left Join Car on member_car

SELECT *
FROM member_car AS mc
LEFT JOIN cars AS c
	ON c.car_id = mc.car_id;

-- 2. Right Join member_car on cars. Do you spot any difference?

SELECT *
FROM cars c
RIGHT JOIN member_car mc
	ON mc.car_id = c.car_id;
-- The column order is different.

-- 3. What is the mean contribution of each car maker?


-- 

SELECT AVG(r.contribution_per_passenger) AS mean_contrib, c.maker
FROM rides r
LEFT JOIN member_car mc
	ON r.member_car_id = mc.member_car_id
LEFT JOIN cars c
	ON mc.car_id = c.car_id
GROUP BY c.maker;

-- ----------------------------------
-- Niveau 2
-- ----------------------------------

-- 1. How many messages does each member send?

-- On demande le nombre de messages envoyé par chaque membre, cette information est disponible dans la table message
-- l'attribut sender_id permet à chaque message d'identifier l'émetteur, il faut donc regrouper les messages de chaque émetteur, puis les compter
-- la fonction d'agrégation COUNT() et la commande GROUP BY le permet :

-- Final : 

SELECT COUNT(sender_id) AS nb_messages, sender_id
FROM messages m
GROUP BY sender_id;

-- 2. Are there members that have more than 1 car? If yes, how many?

-- on peut commencer par attribuer à chaque membre son nombre de voitures
-- La table member_car relie chaque voiture à son propriétaire, le propriétaire est reconnu par l'attribut member_id
-- Le nombre d'occurences d'un même member_id correspond donc au nombre de voitures, il suffit donc de compter le nombre de member_id identiques : 

SELECT COUNT(member_id) as nb_voitures , member_id
FROM member_car
GROUP BY member_id;

-- Plutôt que de regarder manuellement les valeurs supérieures à 1, la commande HAVING qui permet comme WHERE de filtrer mais en utilisant des fonctions d'agrégation
-- On pense aussi à ordonner les valeurs par ordre décroissant à l'aide d' ORDER BY

-- Final : 

SELECT COUNT(member_id) as nb_voitures , member_id
FROM member_car 
GROUP BY member_id
HAVING nb_voitures > 1 -- notez bien que having filtre sur un count (fonction agrégation) (on a renommé la colonne mais il est écrit HAVING COUNT(member_id) > 1)
ORDER BY nb_voitures DESC;

-- On voit chaque conducteur qui a plus d'1 voiture, sur cette table le résultat est lisible, mais s'il y avait plus de lignes
-- Il est possible d'écrire une requête pour compter le nombre de membres concernés :

SELECT COUNT(nb_voitures) as nb_conducteurs_multi_voiture
	FROM (SELECT COUNT(c.member_id) as nb_voitures ,c.member_id
		FROM member_car c
		GROUP BY c.member_id
		HAVING nb_voitures > 1 
		ORDER BY nb_voitures DESC) AS table1;

-- 3. Who is the most active driver / Doing the most trips ?

-- Essayons de classer les différents membres par nombre de voyages :
-- on peut arriver à un premier résultat en utilisant uniquement la table rides, en comptant les occurences de chaque member_car_id distinct, et en les ordonnant : 

SELECT COUNT(member_car_id) AS nb_rides, member_car_id
FROM rides r 
GROUP BY member_car_id
ORDER BY nb_rides;

-- Le problème de cette requête est qu'elle nous donne le member_car_id qui ne permet pas directement d'identifier le conducteur, ce n'est pas son ID mais l'ID de l'ensemble 
-- Voiture + conducteur (certains conducteurs pouvant avoir plusieurs voitures et inversement)
-- Pour l'identifier on fait une jointure avec la table member_car qui permet d'afficher l'attribut member_id :

SELECT COUNT(mc.member_id) AS nb_rides, mc.member_id
FROM rides r
INNER JOIN member_car mc
	ON r.member_car_id = mc.member_car_id
GROUP BY mc.member_id
ORDER BY nb_rides; 


-- enfin on ne cherche pas à classer les valeurs, simplement prendre la valeur maximale, cherchons à afficher la valeur maximale de courses faites : 
						
SELECT MAX(nb_rides)
FROM (SELECT COUNT(mc.member_id) AS nb_rides, mc.member_id
	FROM rides r 
	INNER JOIN member_car mc
		ON r.member_car_id = mc.member_car_id
	GROUP BY mc.member_id) AS count_rides;

-- En utilisant notre première requête en sous requête il nous est donc possible d'afficher le maximum de courses effectuées par un conducteur
-- Il ne nous manque plus qu'à afficher l'ID du conducteur correspondant
-- Attention il y a une difficulté, on ne pouvait se contenter d'écrire : 
SELECT MAX(nb_rides), member_id
FROM (SELECT COUNT(mc.member_id) AS nb_rides, mc.member_id
	FROM rides r 
	INNER JOIN member_car mc
		ON r.member_car_id = mc.member_car_id
	GROUP BY mc.member_id) AS count_rides;
-- Le member_id sélectionné par la requête n'est pas celui correspondant au MAX, c'est simplement la première valeur de la table
-- C'est le cas car le MAX n'est guidé par aucun group BY, il prend simplement la valeur maximale de la table généré dans le FROM

-- Il suffit d'utiliser ORDER BY pour obtenir le résultat souhaité : 


-- Final 

SELECT member_id, first_name, last_name, MAX(nb_rides) 
FROM (SELECT COUNT(mc.member_id) AS nb_rides, mc.member_id
	FROM rides r 
	INNER JOIN member_car mc
		ON r.member_car_id = mc.member_car_id
	INNER JOIN members m 						-- on fait une jointure avec members pour avoir nom et prénom en + de l'ID 
		ON mc.member_id = m.member_id
	GROUP BY mc.member_id
	ORDER BY nb_rides DESC) AS count_rides		

-- 4. What is the ratio of car accepting pets over those which do not?

-- Commençons par compter les voitures acceptant les animaux d'un côté, et ceux les refusant de l'autre
-- Pour cela il va falloir réunir les voitures avec la préférence de leur conducteur 
-- Il faut donc joindre les tables members et member_car et filtrer les voitures selon les préférences des conducteurs
SELECT COUNT(DISTINCT mc.car_id) AS nb_cars -- Les voitures peuvent apparaître plusieurs fois si plusieurs conducteurs ont la même voiture et préférence donc DISTINCT
FROM member_car mc
INNER JOIN `members` AS m
	ON mc.member_id = m.member_id
WHERE m.pet_preference = 'yes'

SELECT COUNT(DISTINCT mc.car_ID) AS nb_cars
FROM member_car mc
INNER JOIN `members` AS m
	ON mc.member_ID = m.member_id
WHERE m.pet_preference = 'no'

-- Ensuite on fait le calcul en divisant le résultat d'une requête par le résultat de l'autre 


SELECT
	(SELECT COUNT(DISTINCT mc.car_ID) AS nb_car
	FROM member_car mc
	INNER JOIN `members` AS m
		ON mc.member_ID = m.member_id
	WHERE m.pet_preference = 'yes')
	/
	(SELECT COUNT(DISTINCT mc.car_ID) AS nb_car
	FROM member_car mc
	INNER JOIN `members` AS m
		ON mc.member_ID = m.member_id
	WHERE m.pet_preference = 'no') AS accepts_pets;

-- 5. Can you print with one request the number of trips beginning in each town and the number of trips ending in each town ?

-- Comment avoir le nombre de voyages pour chaque ville de départ d'un côté, puis celui par ville d'arrivée de l'autre ?
-- On l'a déjà fait, La fonction d'agrégation COUNT revient à nouveau, en groupant les lignes par ville de départ ou d'arrivée 
-- et on doit réaliser une jointure entre les table rides et cities pour obtenir les noms des villes au lieu des IDs

SELECT c.city_name, COUNT(r.starting_city_id) as nb_trips_per_starting_city
FROM rides r
INNER JOIN cities c
	ON c.city_id = r.starting_city_id
GROUP BY r.starting_city_id;

SELECT c.city_name, COUNT(r.destination_city_id) as nb_trips_per_destination_city
FROM rides r
INNER JOIN cities c
	ON c.city_id = r.destination_city_id
GROUP BY r.destination_city_id;

-- Pour avoir les résultat dans une même table, joignons les deux tables ci-dessus, et sélectionnons les colonnes qui nous intéresse dans le bon ordre : 


-- Final :

SELECT nb_arriving_trips.city_name, nb_arriving_trips.country, nb_starting_trips, nb_arriving_trips
FROM 
      (SELECT city_name, country, COUNT(*) AS nb_starting_trips
      FROM rides r
      LEFT JOIN cities c
          ON r.starting_city_id = c.city_id
      GROUP BY city_name) AS nb_starting_trips
INNER JOIN 
      (SELECT city_name, country, COUNT(*) AS nb_arriving_trips
      FROM rides r
      LEFT JOIN cities c
          ON r.destination_city_id = c.city_id
      GROUP BY city_name) AS nb_arriving_trips
ON nb_starting_trips.city_name = nb_arriving_trips.city_name AND nb_starting_trips.country = nb_arriving_trips.country;

-- Pouvez vous-trouver le nombre total de courses par ville (que la ville soit point de départ ou point d'arrivée) ? 
-- Une requête par fonction SUM() sur la table que l'on vient de générer permet de trouver rapidement le résultat. (groupé par nom de ville)


SELECT SUM(nb_trips), city_name
	FROM(
		SELECT  COUNT(r.starting_city_id) as nb_trips, c.city_name 
			FROM rides r
			INNER JOIN cities c
				ON c.city_id = r.starting_city_id
			GROUP BY r.starting_city_id
		UNION
		SELECT  COUNT(r.destination_city_id) , c.city_name 
			FROM rides r
			INNER JOIN cities c
				ON c.city_id = r.destination_city_id
			GROUP BY r.destination_city_id) AS table_1  -- ATTENTION : la requête que nous avions écrit précédemment est désormais une table utilisé dans un FROM
GROUP BY city_name;							      	  -- Il faut donc lui attribuer un alias

-- 6. Which city has the highest ratio of starting trip over destination trip?

-- Pour calculer le ratio, on doit d'abord trouver les deux membres de la division
-- Trouvons le nombre de départs par ville dans une table et le nombre d'arrivée par ville dans une autre, nous l'avons déjà fait ci-dessus
SELECT c.city_id, c.city_name, COUNT(r.starting_city_id) as nb_start
		FROM rides r
		INNER JOIN cities c
			ON c.city_id = r.starting_city_id
		GROUP BY r.starting_city_id;

SELECT c.city_id, c.city_name, COUNT(r.destination_city_id ) as nb_dest
			FROM rides r
			INNER JOIN cities c
				ON c.city_id = r.destination_city_id
			GROUP BY r.destination_city_id;

-- On peut maintenant calculer le ratio de chaque ville, (avant de trouver le plus grand ratio)
-- Pour calculer le ratio ville par ville, on ne peut pas faire comme en 4. En 4 chaque requête renvoyait une valeur numérique unique, on pouvait donc "diviser les requêtes"
-- Ici chaque requête renvoie une liste de ville, on ne peut donc pas simplement diviser notre premier select par le deuxième, ce n'est pas possible en SQL
-- L'idée est donc d'abord de joindre les tables, il est possible ensuite de réaliser des calculs sur différentes colonnes d'une table dans le SELECT
-- Un ORDER BY à la fin permet de conserver uniquement la plus grande valeur.

-- FINAL : 

SELECT depart.city_name, depart.nb_start / dest.nb_dest as ratio 		-- ratio (nb departs)/(nb arrivees) par ville, on peut diviser les valeurs d'une colonne par l'autre
FROM (SELECT c.city_id, c.city_name, COUNT(r.starting_city_id) as nb_start
		FROM rides r
		INNER JOIN cities c
			ON c.city_id = r.starting_city_id
		GROUP BY r.starting_city_id) as depart
LEFT JOIN (SELECT c.city_id, c.city_name, COUNT(r.destination_city_id ) as nb_dest
			FROM rides r
			INNER JOIN cities c
				ON c.city_id = r.destination_city_id
			GROUP BY r.destination_city_id) as dest
	ON depart.city_id = dest.city_id
ORDER BY ratio DESC LIMIT 1; -- on peut tester la requête en retirant cette ligne pour bien comprendre le résultat de la requête qui fait un calcul entre deux colonnes.


-- 7. What is the mean contribution of trip per starting city? Does the city with highest average contribution have the highest number of trips (as a starting city)?

-- The mean contribution of trip per starting city

-- Commençons par par la contribution moyenne par ville de départ, pour cela réalisons une jointure entre rides et cities
-- Utilisons la fonction d'agrégation AVG en regroupant la table par ville de départ pour trouver le résultat : 
SELECT c.city_name, AVG(contribution_per_passenger) AS prix_moy_depart
	FROM rides AS r
	INNER JOIN cities AS c
		ON r.starting_city_id = c.city_id
	GROUP BY r.starting_city_id;


-- On peut ensuite faire une requête pour classer les villes de départ selon le nombre de voyages
SELECT c.city_name, COUNT(r.starting_city_id) AS nb_trips
FROM rides r
INNER JOIN cities c 
	on c.city_id = r.starting_city_id
GROUP BY r.starting_city_id
ORDER BY nb_trips DESC;

-- On veut maintenant comparer la valeur maximale de chaque table pour pouvoir les comparer, on peut le trouver grâce aux commandes ORDER BY et LIMIT
ORDER BY prix_moy_depart DESC LIMIT 1
ORDER BY nb_trips DESC LIMIT 1

-- Nous avons donc maintenant les deux valeurs maximales, nous pouvons regarder 'à la main' si la ville est la même, mais il est possible de tout trouver en une requête
-- l'opérateur logique '=' permet de tester l'égalité entre deux tables, on peut l'utiliser à l'image de la division '/' réalisée pour calculer les ratios
-- ATTENTION : en l'état même si la ville qui propose le plus de voyage et la ville la plus chère en moyenne sont les mêmes, le test '=' ne pourra pas nous le dire 
-- En effet : la première requête renvoie le nom de la ville mais aussi la fameuse valeur moyenne
-- La deuxième requête renvoie le nom de la ville mais aussi le nombre de voyages proposés
-- Ainsi même si le nom de la ville est le même, les deux tables ne sont pas égales car la deuxième colonne est différente
-- On doit donc modifier nos sous requêtes pour obtenir uniquement le nom de la ville à la fin

SELECT city_name 
	FROM(SELECT c.city_name, COUNT(r.starting_city_id) AS nb_trips
		FROM rides r
		INNER JOIN cities c 
			on c.city_id = r.starting_city_id
		GROUP BY r.starting_city_id
		ORDER BY nb_trips DESC LIMIT 1) AS Table1;

-- On peut maintenant utiliser l'opérateur '=' pour effectuer notre test :

							
SELECT 							
	(SELECT city_name
		FROM (SELECT c.city_name, AVG(contribution_per_passenger) AS prix_moy_depart
			FROM rides AS r
			INNER JOIN cities AS c
				ON r.starting_city_id = c.city_id
			GROUP BY r.starting_city_id
			ORDER BY prix_moy_depart DESC LIMIT 1) AS table1)
	
=
	(SELECT city_name 
		FROM(SELECT c.city_name, COUNT(r.starting_city_id) AS nb_trips
			FROM rides r
			INNER JOIN cities c 
				on c.city_id = r.starting_city_id
			GROUP BY r.starting_city_id
			ORDER BY nb_trips DESC LIMIT 1) AS table2)
		as test;


-- Le test donne 0, notre test est donc faux, les villes ne sont pas identiques

