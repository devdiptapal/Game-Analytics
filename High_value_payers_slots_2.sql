

commit;
-- High Value Payers
INSERT /*+ direct */ INTO etl_temp.tmp_skb (user_uid, date, metric)
SELECT  user_uid, a.dateobj, 'high value payers'
FROM d_date a
JOIN report.v_payment b on b.date_trans::date between a.dateobj-29 and a.dateobj
WHERE dateobj  = '2016-02-13'
and game_id=$gameid$
GROUP BY 1,2
having sum(amount) >= 20
;


select distinct flag, 
percentile_cont(0.25) within group(order by logins) over (partition by flag) as p75,
percentile_cont(0.5) within group(order by logins) over (partition by flag) as p75,
percentile_cont(0.75) within group(order by logins) over (partition by flag) as p75,
percentile_cont(0.90) within group(order by logins) over (partition by flag) as p90,
percentile_cont(0.99) within group(order by logins) over (partition by flag) as p99



from

(select  a.user_uid, (case when spin_flag>0 then 'tried' else 'not-tried' end) as flag, logins
from

(select  b.user_uid, sum(case when kingdom like 'free_bonus' then 1 else 0 end) as spin_flag
from
s_zt_count a
inner join
etl_temp.tmp_skb b

on a.user_uid=b.user_uid
and a.counter_date=b.date
where
a.game_id=5002366
and counter_date = '2016-02-13'
and counter_date is not null
and b.user_uid is not null
and a.user_uid is not null
group by 1) as a

inner join

(select user_uid, count(distinct counter_date) as logins
from
s_zt_count a 

where
a.game_id=5002366
and counter_date between  '$startdate$' and '$enddate$'
and class is not null
and counter_date is not null
and a.user_uid is not null
group by 1)as c

on a.user_uid=c.user_uid
) as x
order by 1;