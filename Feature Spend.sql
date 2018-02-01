select kingdom,phylum,class, -1*sum(amount) as 'Spend', count(distinct(user_uid)) as 'Spenders' 
from ztrack.s_zt_economy
where game_id =118 and sn_id=1 and client_id=1
and currency_flow = 'paid_spend' and currency = 'cash' and amount <0
and (kingdom like '%$featurename$%' or phylum like '%$featurename$%' or class like '%$featurename$%')
and economy_date between '$startdate$' and '$enddate$'
group by 1,2,3;

---for animal---
select kingdom,phylum,class, -1*sum(amount) as 'Spend', count(distinct(user_uid)) as 'Spenders' 
from ztrack.s_zt_economy
where game_id =118 and sn_id=1 and client_id=1
and currency_flow = 'paid_spend' and currency = 'cash' and amount <0
and kingdom like 'animal'
and class like '%$animalname$%'
and economy_date between '$startdate$' and '$enddate$'
group by 1,2,3;

---for animal by date---
select economy_date, kingdom, -1*sum(amount) as 'Spend', count(distinct(user_uid)) as 'Spenders' 
from ztrack.s_zt_economy
where game_id =118 and sn_id=1 and client_id=1
and currency_flow = 'paid_spend' and currency = 'cash' and amount <0
and kingdom like 'animal'
and class like '%$animalname$%'
and economy_date between '$startdate$'::date-30 and '$enddate$'
group by 1,2;