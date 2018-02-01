commit;

insert /*+ direct */ into tmp_skb (date,user_uid,value, metric)
select distinct stat_date as date, user_uid, max(coalesce(level,1)),'user_level3'
from v_user_day
where game_id=118
and client_id in (1,6)
and sn_id in (1,104)
and stat_date between '$startdate$' and '$enddate$'
group by 1,2;

select  
cast(avg(actions_p30) as decimal (4,1)) as p30,
cast(avg(actions_p40)as decimal (4,1)) as p40,
cast(avg(actions_p50)as decimal (4,1)) as mean,
cast(avg(actions_p60)as decimal (4,1)) as p60,
cast(avg(actions_p65)as decimal (4,1)) as p65,
cast(avg(actions_p70)as decimal (4,1)) as p70,
cast(avg(actions_p75)as decimal (4,1)) as p75,
cast(avg(actions_p80)as decimal (4,1)) as p80,
cast(avg(actions_p85)as decimal (4,1)) as p85,
cast(avg(actions_p90)as decimal (4,1)) as p90

from

(select date,

PERCENTILE_CONT(0.3) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p30,
PERCENTILE_CONT(0.4) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p40,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p50,
PERCENTILE_CONT(0.6) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p60,
PERCENTILE_CONT(0.65) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p65,
PERCENTILE_CONT(0.7) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p70,
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p75,
PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p80,
PERCENTILE_CONT(0.85) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p85,
PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date) as actions_p90


from

(select a.date::date, a.user_uid,
count(*) as actions 
from 
tmp_skb a
inner join
s_zt_count b
on a.date=b.counter_date
and a.user_uid=b.user_uid
and a.metric= 'user_level3'
where 
b.game_id=118 
and b.client_id in (1,6)
and b.sn_id in (1,104) and
b.counter like '%$counter$%' and
b.kingdom like '%$counter2$%'
and b.class like '$counter4$%'
and a.value between 30 and 9999
and b.counter_date between '$startdate$' and '$enddate$'
group by 1,2) as x
order by 1) as y
where date between date::date-$days$ and '$enddate$';

select  cast(level1 as decimal(3,0)),
round(avg(actions_p30),1) as p30,
round(avg(actions_p40),1) as p40,
round(avg(actions_p50),1) as mean,
round(avg(actions_p60),1) as p60,
round(avg(actions_p65),1) as p65,
round(avg(actions_p70),1) as p70,
round(avg(actions_p75),1) as p75,
round(avg(actions_p80),1) as p80,
round(avg(actions_p85),1) as p85,
round(avg(actions_p90),1) as p90

from

(select date, level1,

PERCENTILE_CONT(0.3) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p30,
PERCENTILE_CONT(0.4) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p40,
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p50,
PERCENTILE_CONT(0.6) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p60,
PERCENTILE_CONT(0.65) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p65,
PERCENTILE_CONT(0.7) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p70,
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p75,
PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p80,
PERCENTILE_CONT(0.85) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p85,
PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY date, level1) as actions_p90


from

(select a.date::date, a.user_uid,a.value as level1,
count(*) as actions 
from 
tmp_skb a
inner join
s_zt_count b
on a.date=b.counter_date
and a.user_uid=b.user_uid
and a.metric= 'user_level3'
where 
b.game_id=118 
and b.client_id in (1,6)
and b.sn_id in (1,104) and
b.counter like '%$counter$%' and
b.kingdom like '%$counter2$%'
and b.class like '$counter4$%'
and a.value between 30 and 9999
and b.counter_date between '$startdate$' and '$enddate$'
group by 1,2,3) as x
order by 1,2) as y
where date between date::date-$days$ and '$enddate$'
group by 1
order by 1;


