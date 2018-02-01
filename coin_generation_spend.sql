
select 
distinct date1 as date, level1 as level,

PERCENTILE_CONT(.50) WITHIN GROUP(ORDER BY coin_earn) OVER (PARTITION BY date1,level1) as coin_earn_p50,
PERCENTILE_CONT(.70) WITHIN GROUP(ORDER BY coin_spend) OVER (PARTITION BY date1, level1) as coin_spend_p70,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY coin_spend) OVER (PARTITION BY date1, level1) as coin_spend_p90
from

(Select a.date1, a.level as level1, a.user_uid as user,

sum(b.coin_credit) as coin_earn,
sum(b.coin_spend) as coin_spend

from


(Select distinct stat_Date as date1,user_uid, level
from
v_user_day where game_id = 118
and stat_date::date between '$start$' and '$end$'
and user_uid is not null) as a 

left join

(Select economy_Date::Date as date2,user_uid,

sum(case when  amount > 0 then amount end) as 'coin_credit',
sum(case when amount < 0 then (-1)*amount end) as 'coin_spend'
from
(select distinct economy_date, economy_time, user_uid, amount
from
ztrack.s_zt_economy where game_id = 118 and currency = 'favor' 
 and currency_flow in ('paid_spend','paid_credit','free_credit') 
 and economy_date::Date between '$start$' and '$end$'
 and amount is not null) as x
group by 1,2) as b
on a.user_uid = b.user_uid 
and a.date1 = b.date2
where a.user_uid is not null
 group by 1,2,3
 
order by level) as x
where level1 >=25
order by 1,2 
;