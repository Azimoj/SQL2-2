

SELECT now();

SELECT date(now())



-- EXO: créer des tranches d'âge 18-24, 25-39, 40-60, 60+ puis compter le nb de membres par catégorie, 



select 
        case 
        when DATEDIFF(NOW(), birthdate) / 365 < 25 then '18-24'
        when DATEDIFF(NOW(), birthdate) / 365 BETWEEN 25 and 39 then '25-38'
        when DATEDIFF(NOW(), birthdate) / 365 BETWEEN 40 and 60 THEN '40-60'
        ELSE '60+'
        end as age_category,
        count(*) as nb_members
from members
group by age_category;

# et afficher le pourcentage du total

select 
        case 
        when DATEDIFF(NOW(), birthdate) / 365 < 25 then '18-24'
        when DATEDIFF(NOW(), birthdate) / 365 BETWEEN 25 and 39 then '25-38'
        when DATEDIFF(NOW(), birthdate) / 365 BETWEEN 40 and 60 THEN '40-60'
        ELSE '60+'
        end as age_category,
        count(*) as nb_members,
        round (COUNT(*)*100 / (SELECT COUNT(*) from members),2) as percentage
from members
group by age_category;
