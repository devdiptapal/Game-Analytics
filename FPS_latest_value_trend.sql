
select date, variant, avg(fps) as fps from

(select * from

(select distinct date ,user_uid, fps,variant, rank() over (partition by user_uid, date order by counter_time desc) as rank 
from
(select distinct b.date, b.counter_time, b.user_uid, b.fps,(case when c.user_uid is not null then 'installed' when c.user_uid is null then 'notinstalled' end) as variant from

(select counter_date::date as date, user_uid, count(*) , avg(value) as fps from s_zt_count
where game_id=118
and counter_date::date between '$start$' and '$end$'
and counter='fpsdetailed'
and value >=4 
group by 1,2
having count(*) >=2
) as a

inner join

(select distinct counter_date::date as date, counter_time, user_uid, value as fps from s_zt_count
where game_id=118
and counter_date::date between '$start$' and '$end$'
and counter='fpsdetailed'
and value >=4) as b

on a.user_uid= b.user_uid
and a.date=b.date



left join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='dialog' and kingdom='open'
and phylum='fv2_chrome_extension' and class='start_motd' and game_id=118) as c

on a.user_uid=c.user_uid) as x ) as y
where rank=1) as z
group by 1,2;