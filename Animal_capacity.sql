
select distinct
a.date,level,
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY capacity) OVER (PARTITION BY  a.date,level) as cap_p50,
PERCENTILE_CONT(.70) WITHIN GROUP(ORDER BY capacity) OVER (PARTITION BY  a.date,level) as cap_p70,
PERCENTILE_CONT(.9) WITHIN GROUP(ORDER BY capacity) OVER (PARTITION BY  a.date,level) as cap_p90,
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY count_animals) OVER (PARTITION BY  a.date,level) as animal_ct_p50,
PERCENTILE_CONT(.70) WITHIN GROUP(ORDER BY count_animals) OVER (PARTITION BY  a.date,level) as animal_ct_p70,
PERCENTILE_CONT(.9) WITHIN GROUP(ORDER BY count_animals) OVER (PARTITION BY  a.date,level) as animal_ct_p90
from
(select date, user_uid, count_a as animal_count, cap as capacity
from
(select 
 counter_date::date as date,
user_uid,  
max(case when kingdom='animals_max_cap' then value end) as cap,
max(case when kingdom='animal_total' then value end) as count_animals
 from s_zt_count where game_id=118 and counter='board_state' and kingdom in ('animals_max_cap', 'animal_total') 
and counter_date::date between '$start$' and '$end$'
  group by 1,2) as x) as a
  inner join 
  (select distinct user_uid, level, stat_date::date as date from v_user_day where game_id=118 and 
  stat_date::date between '$start$' and '$end$' and level >=2) b
  on a.user_uid=b.user_uid
  and a.date=b.date
  
  order by 1,2;