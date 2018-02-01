
-- High Value Payers
INSERT /*+ direct */ INTO etl_temp.tmp_skb (user_uid, date, metric)
SELECT  user_uid, a.dateobj, 'high value payers'
FROM d_date a
JOIN report.v_payment b on b.date_trans::date between a.dateobj-29 and a.dateobj
WHERE dateobj between '$startdate$' and '$enddate$'
and game_id=$gameid$
GROUP BY 1,2
having sum(amount) >= 20
;

select counter_date,class, count(distinct     user_uid) as distinct_users
from

(select distinct counter_date, class, b.user_uid
from
s_zt_count a
inner join
etl_temp.tmp_skb b

on a.user_uid=b.user_uid
and a.counter_date=b.date
where
a.game_id=5002366
and counter_date between  '$startdate$' and '$enddate$'
and class is not null
and counter_date is not null
and b.user_uid is not null
and a.user_uid is not null) as A

group by 1,2;