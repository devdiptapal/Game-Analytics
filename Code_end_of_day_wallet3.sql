select
distinct economy_date,

PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date) as wallet_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date) as wallet_p75,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date)as wallet_p90
from



(select distinct economy_date, user_uid,total_amount as wallet
from 
(select distinct user_uid, economy_date, economy_time, rank() over (partition by  economy_date, user_uid order by economy_time desc) as rank, total_amount
from s_zt_economy
where game_id=118
and currency='favor' and currency_flow in ('paid_spend','paid_credit','free_credit') 
and user_uid is not null
and economy_date between '$start$' and '$end$'
order by 1,2,3) as b
where rank=1
and user_uid is not null) as x
order by 1
 ;