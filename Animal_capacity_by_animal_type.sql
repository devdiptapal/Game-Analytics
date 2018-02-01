
select distinct
a.date,level,

PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY count_animals) OVER (PARTITION BY  a.date,level) as animal_ct_p50,
PERCENTILE_CONT(.70) WITHIN GROUP(ORDER BY count_animals) OVER (PARTITION BY  a.date,level) as animal_ct_p70,
PERCENTILE_CONT(.9) WITHIN GROUP(ORDER BY count_animals) OVER (PARTITION BY  a.date,level) as animal_ct_p90
from
(select date, user_uid, count_a as count_animals
from
(select date, user_uid, sum(value) as count_a from
(select date, user_uid, class, value from
(select distinct
 counter_date::date as date,
user_uid,  
class, value , rank() over (partition by counter_date , user_uid order by counter_date+counter_time desc) as rank
 from s_zt_count where game_id=118 and counter='board_state' 
and kingdom like ('%animal%') 
and class ilike ('%animal%')
and (class ilike ('%adult_cowsmall%') or class ilike ('%adult_yak%'))
and counter_date::date between '$start$' and '$end$'
  ) as x
  where rank=1) as a
  group by 1,2) as a )as a
  inner join 
  (select distinct user_uid, level, stat_date::date as date from v_user_day where game_id=118 and 
  stat_date::date between '$start$' and '$end$' and level >=2) b
  on a.user_uid=b.user_uid
  and a.date=b.date
  
  order by 1,2;