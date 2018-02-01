
commit;


insert into etl_temp.tmp_skb (metric,metric2,user_uid)
Select distinct 'abc', family,user_uid
from
ztrack.s_zt_count where game_id = 118 and counter_date between '2015-06-11' and '2015-06-17'
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
from report.v_farm2_payment where game_id = 118;

insert into etl_Temp.tmp_skb (metric,user_uid)
select distinct 'building_fraud', user_uid
from
(
select user_uid,
sum(case when good_name like 'e_building_storage_animalpen_construction' then 1 else 0 end) as 'animal_barn',
sum(case when good_name like 'e_building_watertower_craftsman_construction' then 1 else 0 end) as 'water_tower',
sum(case when good_name like 'e_building_barn_craftsman_construction' then 1 else 0 end) as 'barn',
sum(case when good_name like 'e_building_windmill_craftsman_construction' then 1 else 0 end) as 'windmill'

from
s_zt_goods
where good_date between '2016-03-06' and '2016-03-13'
and game_id=118

and good_name like ('e_building_storage_animalpen%') 
or  good_name like ('e_building_watertower_craftsman%') 
or  good_name like ('e_building_barn_craftsman%') 
or  good_name like ('e_building_windmill_craftsman%') 
and user_uid is not null
group by 1
having 
(sum(case when good_name like 'e_building_storage_animalpen_construction' then 1 else 0 end) > 1) or
(sum(case when good_name like 'e_building_watertower_craftsman_construction' then 1 else 0 end) > 1) or
(sum(case when good_name like 'e_building_barn_craftsman_construction' then 1 else 0 end)  > 1) or
(sum(case when good_name like 'e_building_windmill_craftsman_construction' then 1 else 0 end) > 1) ) as x;


Select a.metric2,count(distinct a.user_uid),count(distinct b.user_uid), count(distinct c.user_uid)
from etl_Temp.tmp_skb a left join etl_temp.tmp_skb b on a.user_uid = b.user_uid  and  b.metric = 'rev' left join etl_temp.tmp_skb c on b.user_uid = c.user_uid  and  c.metric = 'building_fraud'
where a.metric = 'abc' group by 1;
