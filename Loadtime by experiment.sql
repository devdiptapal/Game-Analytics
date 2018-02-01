commit;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, value, date, metric) 
select distinct user_uid, variant, exp_date::date, 'exp' from s_zt_exp 
where game_id=118 and test_name like '$test_name$'  
and exp_date between '$startdate$' and '$enddate$'
;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select user_uid,counter_date, avg(value) as value, 'memory'
from s_zt_count
where game_id = 118

and counter = 'CIPRO-Counter-1'
and kingdom = 'PlaytimeFrameTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2;

select a.date, a.value as variant , count(distinct a.user_uid), sum(b.value)/count(distinct a.user_uid) as users from

(select user_uid, date, value from tmp_skb where metric='exp')a
inner join
(select user_uid, date, value from tmp_skb where metric='memory')b
on a.date=b.date
and a.user_uid=b.user_uid
group by 1,2
order by 1,2;

