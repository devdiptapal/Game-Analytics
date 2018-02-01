
commit;


insert into etl_temp.tmp_skb (metric,metric2,user_uid)
Select distinct 'abc', family,user_uid
from
ztrack.s_zt_count where game_id = 118 and counter_date between '$start_date$' and '$end_date$'
and counter = 'state_fair' and kingdom = 'start'
and family in (
'AaC_v0',
'AaC_v1',
'AaC_v2',
'AaC_v3',
'AbC_v0',
'AbC_v1',
'AbC_v2',
'AbC_v3',
'AcC_v0',
'AcC_v1',
'AcC_v2',
'AcC_v3',
'DC_v0',
'DC_v1',
'RaC_v0',
'RaC_v1',
'RaC_v2',
'RaC_v3',
'RbC_v0',
'RbC_v1',
'RbC_v2',
'RcC_v0',
'RcC_v1',
'SaC_v0',
'SaC_v1',
'SbC_v0',
'ScC_v0'

);




insert into etl_Temp.tmp_skb (metric,user_uid)
Select distinct 'rev',user_uid
from report.v_payment where game_id = 118;

insert into etl_Temp.tmp_skb (metric,user_uid)
select distinct 'building_fraud', user_uid from (
select user_uid, max(case when kingdom like ('wind_mill') then value end) as wind_max,
max(case when kingdom like ('water_tower') then value end) as water_max
 from s_zt_count  where game_id = 118
and counter like '%start_session%'
and counter_date between '$start_date$' and '$end_date$'
and (kingdom like ('wind_mill') or kingdom like ('water_tower'))
group by 1
having
max(case when kingdom like ('wind_mill') then value end) > 1
or max(case when kingdom like ('water_tower') then value end)>1
) as x
;

Select a.metric2,count(distinct a.user_uid),count(distinct b.user_uid), count(distinct c.user_uid)
from etl_Temp.tmp_skb a left join etl_temp.tmp_skb b on a.user_uid = b.user_uid  and  b.metric = 'rev' left join etl_temp.tmp_skb c on b.user_uid = c.user_uid  and  c.metric = 'building_fraud'
where a.metric = 'abc' group by 1;
