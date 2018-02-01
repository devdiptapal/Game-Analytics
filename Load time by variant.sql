
select a.date, variant,  count(distinct a.user_uid) as users, avg(value)/1000 as loadtimeseconds
from
(select distinct exp_date::date as date, user_uid, variant from s_zt_exp where game_id=118 
and exp_date::date between '$startdate$' and '$enddate$'
and test_name = 'fv2_ry_preloader_ads') as a
inner join
(select user_uid,counter_date::date as date, avg(value) as value
from s_zt_count
where game_id = 118
and sn_id in (1,104)
and client_id in (1,6)
and counter = 'CIPRO-Counter-1'
and kingdom ilike 'LoadTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2) as b
on a.date=b.date
and a.user_uid=b.user_uid
group by 1,2
having count(distinct a.user_uid) > 100;