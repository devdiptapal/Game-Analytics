
commit;
insert /*+ direct */ into etl_temp.tmp_skb (metric2, user_uid, date,value, metric) 
select country, a.user_uid,counter_date, avg(value) as value, 'memory'
from s_zt_count a  inner join (select user_uid, country from v_user_day where game_id=118 and country in ('US',
'BR',
'TR',
'FR',
'DE',
'IT',
'ID',
'PH',
'ES',
'PT')) b
on a.user_uid = b.user_uid  
where game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and counter = 'CIPRO-Counter-1'
and kingdom = 'PlaytimeFrameTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2,3
;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2,value, metric) 
select b.user_uid, b.date::date, b.metric2, (1000/b.value), 'final'
from

etl_Temp.tmp_skb b
where b.metric = 'memory'
group by 1,2,3,4,5
;



select distinct a.date::date, metric2 as locale,
PERCENTILE_CONT(.2) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date, metric2) AS '20th_PERCENTILE_CONT',
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date, metric2) AS '50th_PERCENTILE_CONT',
PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date, metric2) AS '70th_PERCENTILE_CONT'
from
etl_temp.tmp_skb a
where a.metric = 'final'
;