commit;






insert /*+ direct */ into etl_temp.tmp_skb (metric2, user_uid, date,value, metric) 
select country,
a.user_uid,counter_date,avg(value) as value, 'memory'
from s_zt_count a join (select user_uid, country from v_user_day where game_id=118 and country in ('US',
'BR',
'TR',
'FR',
'DE',
'IT',
'ID',
'PH',
'ES',
'PT')) as b
on a.user_uid = b.user_uid
where game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and counter = 'CIPRO-Counter-1'
and kingdom = 'PlaytimeFrameTime'
--and kingdom = 'PlaytimeFrameTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2,3
;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2, value, metric) 

select b.user_uid, b.date::date, b.metric2,(1000/ b.value) as fps, 'final'
from
etl_Temp.tmp_skb b


where  b.metric = 'memory'

group by 1,2,3,4,5
;


insert /*+ direct */ into etl_temp.tmp_skb ( date,metric2, value,value2,metric) 
select  a.date, a.metric2, max(value), min(value), 'normalize'
from
etl_temp.tmp_skb a
inner join
(select stat_date as date,user_uid, country from v_user_day where game_id=118 and country in ('US',
'BR',
'TR',
'FR',
'DE',
'IT',
'ID',
'PH',
'ES',
'PT')) b
on 
a.date=b.date and
a.user_uid=b.user_uid
and a.metric2=b.country
where a.metric = 'final'
group by 1,2;


insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,metric2, value,metric) 
select distinct a.user_uid, a.date,a.metric2, (a.value - b.value2)/(b.value- b.value2) as fps, 'final_list2'
from
etl_temp.tmp_skb a
join 
etl_temp.tmp_skb b
on a.date=b.date

and a.metric2= b.metric2
and a.metric = 'final' and b.metric='normalize'
;

select distinct a.date::date,  
a.metric2,
PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value asc) OVER (PARTITION BY a.date::date,a.metric2) AS '70th_PERCENTILE_CONT'
from
etl_temp.tmp_skb a
where a.metric = 'final_list2'
order by 1,2;