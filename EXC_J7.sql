
# 1. Left Join Car on Member_car Indice : quand on dit ‘join tableA on tableB’ la table principale 
# (à utiliser dans le from) est la tableB. 

select * 
from member_car
right join cars using(car_id)
# car_id, coon de cat table then column of member_id

# 2. Y’a-t’il une différence avec un right join de Member_car on Car.

select * 
from cars
right join member_car using(car_id)

# Oui, car_id, member_car, member_id,.....



# 3. Quelle est la contribution moyenne par passager demandée en fonction de la marque de la voiture ?

select maker, AVG(contribution_per_passenger) as ave_price
from rides
left join member_car using(member_car_id)
left join cars using(car_id)
group by(maker)
ORDER by(ave_price) DESC;



#Niveau intermédiaire :
# 1. Combien de messages sont envoyés par chaque membre ?
SELECT sender_id, count(*) as num_message
from messages
GROUP by(sender_id)



#2. Existe-t-il des membres qui possèdent plus d’une voiture enregistrés ? Si oui combien ?
SELECT member_id, count(*) as num_car
from member_car
GROUP by member_id
having num_car >1;




# Si oui combien ?
SELECT count(*) as nb_mb_mlt_voitures
from (
      SELECT member_id, count(*) as num_car
      from member_car
      GROUP by member_id
      having num_car >1
		) as table_car;


# 3. Qui est le conducteur le plus actif : qui fait le plus de courses ?
SELECT member_id, first_name, last_name, count(*) as nb_rider
from rides
left join member_car using(member_car_id)
left join members USING(member_id)
group by member_id
order by nb_rider DESC;


SELECT member_id, first_name, last_name,max(nb_rider) as max_rider
from(
     SELECT member_id, first_name, last_name, count(*) as nb_rider
     from rides
     left join member_car using(member_car_id)
     left join members USING(member_id)
     group by member_id
     order by nb_rider DESC
	 ) as nb_ranking_car;





# 4. Quel est le ratio entre les voitures acceptant des animaux et les voitures les refusant ?
select(
      select count(DISTINCT car_id) as nb_cars_pet
      from members
      left join member_car USING(member_id)
      left join cars using (car_id)
      where pet_preference = 'yes'
  )
  /
  (
      select count(DISTINCT car_id) as nb_cars_no_pet
      from members
      left join member_car USING(member_id)
      left join cars using (car_id)
      where pet_preference = 'no'
    )
as ratio_pet_et_noPet;





#5. Afficher en une seule requête le nombre de courses qui sont parties de chaque ville, et le nombre de courses 
# qui sont arrivées dans chaque ville ? 
select nb_str_trip.city_name, nb_des_trip.country, nb_depart, nb_arrive
from(
      select city_name,country, COUNT(*) as nb_depart
      from cities c
      right join rides r on c.city_id= r.starting_city_id
      group by(city_name)
      ORDER by nb_depart desc) as nb_str_trip
inner join 
     (select city_name,country, COUNT(*) as nb_arrive
      from cities c
      right join rides r on c.city_id = r.destination_city_id
      group by(city_name)
      ORDER by nb_arrive desc
      )as nb_des_trip
on nb_str_trip.city_name = nb_des_trip.city_name and nb_str_trip.country = nb_des_trip.country;



#6. Quelle ville avec le plus grand ratio ‘nombre de courses qui en partent’/’nombre de courses qui y arrivent’?

select nb_str_trip.city_name, 
	   nb_des_trip.country, 
       nb_depart, 
       nb_arrive,
       nb_depart / nb_arrive as ratio_dep_arr
from(
      select city_name,country, COUNT(*) as nb_depart
      from cities c
      right join rides r on c.city_id= r.starting_city_id
      group by(city_name)
      ORDER by nb_depart desc) as nb_str_trip
inner join 
     (select city_name,country, COUNT(*) as nb_arrive
      from cities c
      right join rides r on c.city_id = r.destination_city_id
      group by(city_name)
      ORDER by nb_arrive desc
      )as nb_des_trip
on nb_str_trip.city_name = nb_des_trip.city_name and nb_str_trip.country = nb_des_trip.country

ORDER by ratio_dep_arr desc;





# 7. Quelle est la contribution moyenne par passager par ville de départ ? 
# Est-ce que la ville où la contribution moyenne est la plus élevée est aussi la ville d’où partent le plus de courses ?

select city_name, contribution_per_passenger ,avg(contribution_per_passenger) as avg_cont
from rides r
left join cities c on r.starting_city_id = c.city_id
GROUP by(city_name)
ORDER by( avg_cont) desc;



select city_name,count(*) as nb_dep
from rides r
left join cities c on r.starting_city_id = c.city_id
GROUP by(city_name)
order by nb_dep DESC

# on peux fair es 2 dans le même requete

select(
      select city_name
      from (
          select city_name, avg(contribution_per_passenger) as avg_cont
          from rides r
          left join cities c on r.starting_city_id = c.city_id
          GROUP by(city_name)
          ORDER by( avg_cont) desc LIMIT 1
          )as tabe_1)
	=


      (select city_name
       from (
              select city_name,count(*) as nb_dep
              from rides r
              left join cities c on r.starting_city_id = c.city_id
              GROUP by(city_name)
              order by nb_dep DESC limit 1
            ) as table_2) 
      as test;



