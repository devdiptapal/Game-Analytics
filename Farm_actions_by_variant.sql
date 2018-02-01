

select a.date, variant , sum(actions) as actions, count(distinct a.user_uid) as users from
(select counter_date::date as date, user_uid, count(*) as actions
from s_zt_count
where game_id=118
and counter='farm_action'
and sample_rate=100
and counter_date between '$startdate$' and '$enddate$'
group by 1,2) as a 
inner join
(select distinct exp_date::date as date, user_uid, variant from s_zt_exp where game_id=118 
and exp_date::date between '$startdate$' and '$enddate$'
and test_name = 'fv2_ry_preloader_ads') as b
on a.date=b.date
and a.user_uid=b.user_uid
group by 1,2;