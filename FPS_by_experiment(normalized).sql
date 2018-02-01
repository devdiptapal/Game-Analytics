commit;



-- Determine variant per sn_id / user_uid / game_id / client_id combination
INSERT /*+ direct */ INTO etl_temp.tmp_skb(user_uid, date, value , metric) 
SELECT distinct  user_uid, exp_date, variant, 'exp'
FROM s_zt_exp 
WHERE game_id = 118 and sn_id in ($snid$) and client_id IN ($clientid$)
and start_timestamp::date between '$startdate$' and '$enddate$'
and test_name =  '$testname$'
and variant is not null;



insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2, metric) 
select distinct user_uid, stat_date, 
case when user_agent ilike '%chrome%' then 'chrome'  when user_agent ilike '%firefox%' then 'firefox'  else 'unknown' end, 'browser'
from
v_user_day
where  game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and stat_date between '$startdate$' and '$enddate$'
;

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

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2, value,value2, metric) 

select a.user_uid, a.date::date, a.metric2,(1000/ b.value) as fps, c.value, 'final'
from
etl_Temp.tmp_skb a
join 
etl_Temp.tmp_skb b
on a.user_uid = b.user_uid
and a.date::date = b.date::date
and b.metric = 'memory'
and a.metric= 'browser'
join
etl_temp.tmp_skb c
on a.user_uid=c.user_uid
and c.metric='exp'
and c.value = $value$
and a.date::date=c.date::date
group by 1,2,3,4,5
;


insert /*+ direct */ into etl_temp.tmp_skb ( date,value,value2,metric) 
select  date, max(value), min(value), 'normalize'
from
etl_temp.tmp_skb a
where a.metric = 'final'
group by 1;


insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value,metric) 
select distinct a.user_uid, a.date, (a.value - b.value2)/(b.value-b.value2) as fps, 'final_list2'
from
etl_temp.tmp_skb a
join 
etl_temp.tmp_skb b
on a.date=b.date
and a.metric = 'final' and b.metric='normalize'
;

select distinct a.date::date,  

PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date) AS '70th_PERCENTILE_CONT'
from
etl_temp.tmp_skb a
where a.metric = 'final_list2'
order by 1;