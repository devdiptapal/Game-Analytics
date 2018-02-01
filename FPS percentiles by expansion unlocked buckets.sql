 commit;
 
 
insert into tmp_skb (user_uid, metric2, metric)
select distinct user_uid, (case when class like 'expansion_11%' then 'L3' when class like 'expansion_10%' then 'L2' else 'L1' end) , 'segments' from

(select user_uid, class, rank() over (partition by user_uid order by economy_date+economy_time desc) as rank
ztrack.s_zt_economy 
where game_id = 118 
and economy_date >= '2016-02-04'
and currency = 'cash'
and currency_flow = 'paid_spend'
and kingdom = 'expansion'
and amount < 0
and (class like ('expansion_90%') or class like ('expansion_91%') or class like ('expansion_92%') or 
class like ('expansion_93%') or class like ('expansion_94%') or class like ('expansion_95%') or 
class like ('expansion_96%') or class like ('expansion_97%') or class like ('expansion_98%') or 
class like ('expansion_99%') or class like ('expansion_100%') or class like ('expansion_101%') or 
class like ('expansion_102%') or class like ('expansion_103%') or class like ('expansion_104%') or
 class like ('expansion_105%') or class like ('expansion_106%') or class like ('expansion_107%') or 
 class like ('expansion_108%') or class like ('expansion_109%') or class like ('expansion_110%') or 
 class like ('expansion_111%') or class like ('expansion_112%') or class like ('expansion_113%') or 
 class like ('expansion_114%') or class like ('expansion_115%') or class like ('expansion_116%') or 
 class like ('expansion_117%') or class like ('expansion_118%') or class like ('expansion_119%') 
 or class like ('expansion_120%')))
where rank=1;   


select distinct segment, date,
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY fps) OVER (PARTITION BY  segment,date) as p50,
PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY fps) OVER (PARTITION BY  segment,date) as p70,
PERCENTILE_CONT(.9) WITHIN GROUP(ORDER BY fps) OVER (PARTITION BY  segment,date) as p90
from
(select distinct counter_date::date as date, 
user_uid, avg(value) as fps, from s_zt_count where game_id=118 counter='fpsdetailed' and counter_date > '2017-03-01'
group by 1,2) as a
inner join

(select distinct user_uid, metric2 as segment from tmp_skb where metric='segments') as b 
on a.user_uid=b.user_uid

order by 1,2;