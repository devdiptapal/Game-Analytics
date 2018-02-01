select user_uid,
sum(case when phylum like '%e_building_storage_animalpen_l%' then 1 else 0 end) as 'animal_barn'
sum(case when phylum like '%e_building_watertower_craftsman_l%' then 1 else 0 end) as 'water_tower'
sum(case when phylum like '%e_building_barn_craftsman_l%' then 1 else 0 end) as 'barn'
sum(case when phylum like '%e_building_windmill_craftsman_l%' then 1 else 0 end) as 'windmill'

from
s_zt_goods
where good_date between = '2016-03-13'
and game_id=118
and phylum in ('%e_building_storage_animalpen_l%' , '%e_building_watertower_craftsman_l%' , '%e_building_barn_craftsman_l%' ,
 '%e_building_windmill_craftsman_l%')
and user_uid is not null
group by 1
having 
((sum(case when phylum like '%e_building_storage_animalpen_l%' then 1 else 0 end) > 1) or
(sum(case when phylum like '%e_building_watertower_craftsman_l%' then 1 else 0 end) > 1) or
(sum(case when phylum like '%e_building_barn_craftsman_l%' then 1 else 0 end)  > 1)
(sum(case when phylum like '%e_building_windmill_craftsman_l%' then 1 else 0 end) > 1));