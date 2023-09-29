/*1.	Ajouter une colonne à la table rides qui affiche le nombre de total courses effectuées par le conducteur de la course en cours.
(Indice : il faut joindre la table member_car a rides pour pouvoir y répondre, puis, faire une Window Fonction)
*/
SELECT *, count(*) over(PARTITION by mc.member_id)
from rides r
inner join member_car mc
	on mc.member_car_id = r.member_car_id ;


/* 2	Créer un classement des conducteurs en fonction du nombre de courses.
(Tu peux créer une VIEW pour te faciliter la tâche).*/

CREATE view tab as (
SELECT mc.member_id ,count(*) as nb_rides
from rides r
join member_car mc
	on mc.member_car_id = r.member_car_id 
group by mc.member_id
  )
SELECT *, rank() over(order by nb_rides desc) as rank_
from tab


/*3.	Sans créer de VIEW, affichez le % des recettes des rides par conducteur.
(Indice : Tu peux utiliser la fonction WITH).
Lorsque vous aurez réussi, stockez le résultat dans une VIEW, tu en auras besoin pour la question suivante.
*/


with t as (
SELECT mc.member_id, sum(r.contribution_per_passenger*r.number_seats) as total
from rides r 
inner join member_car mc
	on mc.member_car_id = r.member_car_id
group by mc.member_id
)
SELECT * , (t.total/sum(t.total) over())*100
from t
order by 3 desc


create view t
as
with t as (
SELECT mc.member_id, sum(r.contribution_per_passenger*r.number_seats) as total
from rides r 
inner join member_car mc
	on mc.member_car_id = r.member_car_id
group by mc.member_id
)
SELECT * , (t.total/sum(t.total) over())*100
from t
order by 3 desc


/*4.	Reprenez la table créée dans la question précédente et faites un classement des conducteurs 
en fonction du % de recettes, puis n’affichez que top 10% des conducteurs en fonction de leurs participations aux recettes. 
(Indice : le classement est une des étapes qui vous permet d’extraire les 10% des conducteurs en fonction de leurs participations aux recettes).
*/
with tt as(
SELECT*, rank()over(order by t.total desc) as rak_
from t)
SELECT *,  tt.rak_/(SELECT count(*) from t) as pe
from tt
where tt.rak_/(SELECT count(*) from t) <=0.5


/* 5.	Créer une nouvelle colonne dans la table rides qui combine la date de départ et l’horaire de départ de chaque course, stockez les résultats dans une VIEW 
Puis, ajoutez une colonne à cette table qui renseigne le temps écoulé entre chaque course.
*/

CREATE view rides_time as(
SELECT *,(timestamp(timestamp(r.departure_date)+time(replace(r.departure_time, 'h', ':')))) as time_st
from rides r)


with tabl1 as(
SELECT *,  lag(rt.time_st, 1) over(order by rt.time_st) as time_st1 
from rides_time rt)
SELECT *, (timediff(t.time_st, t.time_st1)) as tt
from tabl1 t





    
