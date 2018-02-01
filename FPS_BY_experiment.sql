commit;



-- Determine variant per sn_id / user_uid / game_id / client_id combination
INSERT /*+ direct */ INTO etl_temp.tmp_skb(user_uid, date, value , metric) 
SELECT distinct  user_uid, exp_date, variant, 'exp'
FROM s_zt_exp 
WHERE game_id = 118 and sn_id in ($snid$) and client_id IN ($clientid$)
and start_timestamp::date between '$startdate$' and '$enddate$'
and test_name =  '$testname$'
and variant is not null;





insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select 
user_uid,counter_date,avg(value) as value, 'memory'
from s_zt_count
where game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and counter = 'CIPRO-Counter-1'
and kingdom = 'PlaytimeFrameTime'
--and kingdom = 'PlaytimeFrameTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2
;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date, value, metric) 

select  b.user_uid, b.date::date, (1000/ b.value) as fps, 'final'
from
etl_Temp.tmp_skb b
join
etl_temp.tmp_skb c
on b.user_uid=c.user_uid
and c.metric='exp'
and c.value = $value$
and b.date::date=c.date::date
and b.metric = 'memory'
group by 1,2,3,4 ;



select distinct a.date::date,  

PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date) AS '70th_PERCENTILE_CONT'
from
etl_temp.tmp_skb a
where a.metric = 'final'
order by 1;