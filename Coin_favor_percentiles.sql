
commit;

select level,
spend_p50/7,
 spend_p75/7,
 spend_p90/7,
 credit_p50/7,
 credit_p75/7,
 credit_p90/7

from
(select 

level,


PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY favor_spend) OVER (PARTITION BY  level) as spend_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY favor_spend) OVER (PARTITION BY  level) as spend_p75,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY favor_spend) OVER (PARTITION BY level)as spend_p90,

PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY favor_credit) OVER (PARTITION BY level) as credit_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY favor_credit) OVER (PARTITION BY level) as credit_p75,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY favor_credit) OVER (PARTITION BY level)as credit_p90



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
and amount between -1000 and 1000) as p

group by 1) as q

right join

(select  user_uid, max(level) as level
from v_user_day where game_id=118 and stat_date::date 
between '$start$' and '$end$'
and user_uid is not null
and level >=25
group by 1) as n

on  q.user_uid=n.user_uid
order by 1,2) as h;


