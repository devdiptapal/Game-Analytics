
commit;

select distinct level,
 feed_p30/21 as feed_30,
 feed_p50/21 as feed_p50,
 feed_p70/21 as feed_p70,
 feed_p80/21 as feed_p80,
feed_p90/21 as feed_p90,

speedfeed_p30/21 as speedfeed_30,
 speedfeed_p50/21 as speedfeed_p50,
 speedfeed_p70/21 as speedfeed_p70,
 speedfeed_p80/21 as speedfeed_p80,
speedfeed_p90/21 as speedfeed_p90


from
(select 

 distinct level,


PERCENTILE_CONT(.3) WITHIN GROUP(ORDER BY feed) OVER (PARTITION BY  level) as feed_p30,
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY feed) OVER (PARTITION BY  level) as feed_p50,
PERCENTILE_CONT(.70) WITHIN GROUP(ORDER BY feed) OVER (PARTITION BY  level) as feed_p70,
PERCENTILE_CONT(.80) WITHIN GROUP(ORDER BY feed) OVER (PARTITION BY  level) as feed_p80,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY feed) OVER (PARTITION BY level)as feed_p90,

PERCENTILE_CONT(.3) WITHIN GROUP(ORDER BY speedfeed) OVER (PARTITION BY level) as speedfeed_p30,
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY speedfeed) OVER (PARTITION BY level) as speedfeed_p50,
PERCENTILE_CONT(.70) WITHIN GROUP(ORDER BY speedfeed) OVER (PARTITION BY level) as speedfeed_p70,
PERCENTILE_CONT(.80) WITHIN GROUP(ORDER BY speedfeed) OVER (PARTITION BY level) as speedfeed_p80,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY speedfeed) OVER (PARTITION BY level)as speedfeed_p90



from


(select
user_uid,
sum(feed) as feed,
sum(speedfeed) as speedfeed -- br 1


from

 (select counter_date::date as date, user_uid, 
 
 sum(case when kingdom ilike 'feed' then 1 else 0 end) as feed,
 sum(case when kingdom ilike 'speedfeed' then 1 else 0 end) as speedfeed

 
        from s_zt_count where
        game_id=118
        and counter_date between '$startdate$' and '$enddate$'
    
        and counter = 'farm_action'
        and kingdom in ('feed','speedfeed')
group by 1,2) as p

group by 1) as q

right join



(select  user_uid, max(level) as level
from v_user_day where game_id=118 and stat_date::date   -- br 2
between '$startdate$' and '$enddate$'
and user_uid is not null
and level >=25
group by 1) as n

on  q.user_uid=n.user_uid
order by 1,2) as h;


