select x.economy_date, y.user_uid, x.total_amount

from

(SELECT distinct user_uid
from s_zt_economy
where game_id = 118 --and sn_id = 1 and client_id = 1
and economy_date = '2016-02-10'
and currency = 'cash' and currency_flow = 'paid_spend' and amount < 0
and (phylum like 'e_bank_bottle_v2' )
and kingdom ='consumable'
) as y

inner join 
(select * from 
(select distinct user_uid, economy_date, economy_time, rank() over (partition by  economy_date, user_uid order by economy_time desc) as rank, total_amount
from s_zt_economy
where game_id=118
and currency='cash' and currency_flow='paid_spend' and amount < 0
and user_uid is not null
and economy_date in ('2016-02-03','2016-02-10','2016-02-17')
order by 1,2,3) as b
where rank=1) as x

on y.user_uid=x.user_uid
 ;