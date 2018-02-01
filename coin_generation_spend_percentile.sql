
commit;

select level,
spend_p50/7 as spend_p50,
 spend_p70/7 as spend_p70,
 spend_p90/7 as spend_p90,
 credit_p50/7 as credit_p50,
 credit_p70/7 as credit_p70,
 credit_p90/7 as credit_p90

from
(select distinct

level,


PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY favor_spend) OVER (PARTITION BY  level) as spend_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY favor_spend) OVER (PARTITION BY  level) as spend_p70,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY favor_spend) OVER (PARTITION BY level)as spend_p90,

PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY favor_credit) OVER (PARTITION BY level) as credit_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY favor_credit) OVER (PARTITION BY level) as credit_p70,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY favor_credit) OVER (PARTITION BY level)as credit_p90

from
(select n.user_uid, level, favor_credit, favor_spend



from


(select
user_uid,
sum(case when amount > 0  then amount end) as 'favor_credit',
sum(case when amount < 0 then ((-1)*amount) end) as 'favor_spend'

from

(Select distinct economy_Date::Date as date,economy_time as time, user_uid, amount
from
ztrack.s_zt_economy 
where game_id = 118 
and currency in ('$favor$') and economy_date::Date between '$start$' and '$end$'
and currency_flow in ('free_spend', 'free_credit') 
and user_uid is not null 
and economy_date is not null
and amount is not null
and amount between $min$ and $max$) as p

group by 1) as q

right join

(select  user_uid, max(level) as level
from v_user_day where game_id=118 and stat_date::date 
between '$start$' and '$end$'
and user_uid is not null
and level >= $minlevel$
group by 1) as n

on  q.user_uid=n.user_uid) as j


order by 1) as h;


