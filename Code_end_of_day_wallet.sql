
select b.economy_date, count(distinct y.user_uid), sum(total_amount) as tot_rev, avg(total_amount) as avg_amt

from

(select distinct user_uid
from s_zt_economy
where game_id=118
and user_uid is not null
and currency='cash'
and economy_date in ('2016-02-10')
) as y

inner join 



(select user_uid, economy_date, total_amount, rank from 
(select distinct user_uid, economy_date, rank() over (partition by user_uid, economy_date order by economy_time desc) as rank, total_amount
from s_zt_economy
where game_id=118
and user_uid is not null
and economy_date in ('2016-02-03','2016-02-10','2016-02-17')
order by 2,1)as x
where rank=1) as b

on y.user_uid=b.user_uid

group by 1;