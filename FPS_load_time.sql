commit;
insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2, metric) 
select distinct user_uid, stat_date, 
case when user_agent ilike '%chrome%' then 'chrome'  when user_agent ilike '%firefox%' then 'firefox'  else 'unknown' end,
 'browser'
from
v_user_day
where  game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and stat_date between '$startdate$' and '$enddate$'
;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select user_uid,counter_date, avg(value) as value, 'memory'
from s_zt_count
where game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and counter = 'CIPRO-Counter-1'
and kingdom = 'PlaytimeFrameTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2
;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2, value, metric) 
select a.user_uid, a.date::date, a.metric2, (1000/b.value), 'final'
from
etl_Temp.tmp_skb a
join 
etl_Temp.tmp_skb b
on a.user_uid = b.user_uid
and a.date::date = b.date::date
and b.metric = 'memory'
where a.metric= 'browser'
group by 1,2,3,4
;



select distinct a.date::date, a.metric2, 
PERCENTILE_CONT(.2) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date, a.metric2) AS '20th_PERCENTILE_CONT',
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date, a.metric2) AS '50th_PERCENTILE_CONT',
PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date, a.metric2) AS '70th_PERCENTILE_CONT'
from
etl_temp.tmp_skb a
where a.metric = 'final'
;