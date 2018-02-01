--- date wise fps current period

select a.date, variant, avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Firefox')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant, 
exp_date::date as date, user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26' ) as b

on a.user_uid=b.user_uid
and a.date= b.date

group by 1,2;

--- date wise fps pre period

select a.date, variant, avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Chrome')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant,  user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26' ) as b

on a.user_uid=b.user_uid


group by 1,2;


-- check pre-post of people who received reward


select a.date, (case when c.user_uid is not null then 'installed' when c.user_uid is null then 'notinstalled' end) as variant,

avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Chrome')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant,  user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26'  and variant=2) as b

on a.user_uid=b.user_uid

inner join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='dialog' and kingdom='open'
and phylum='d_complete_motd_chrome_extension_reward_ready' and game_id=118) as c

on a.user_uid=c.user_uid


group by 1,2;


-- check pre-post of people who received reward (alternate stats)


select a.date, (case when c.user_uid is not null then 'installed' when c.user_uid is null then 'notinstalled' end) as variant,

avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Chrome')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant,  user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26'  and variant=2) as b

on a.user_uid=b.user_uid

left join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='reward' and kingdom='grant'
and phylum='fv2_chrome_extension' and class='extension_installed' and game_id=118) as c

on a.user_uid=c.user_uid


group by 1,2;

--  start motd


select a.date, (case when c.user_uid is not null then 'installed' when c.user_uid is null then 'notinstalled' end) as variant,

avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Chrome')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant,  user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26'  and variant=2) as b

on a.user_uid=b.user_uid

left join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='dialog' and kingdom='open'
and phylum='fv2_chrome_extension' and class='start_motd' and game_id=118) as c

on a.user_uid=c.user_uid


group by 1,2;

-- clicking okay motd


select a.date, (case when c.user_uid is not null then 'installed' when c.user_uid is null then 'notinstalled' end) as variant,

avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Chrome')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant,  user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26'  and variant=2) as b

on a.user_uid=b.user_uid

left join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='dialog' and kingdom='okay'
and phylum='fv2_chrome_extension' and class='start_motd' and game_id=118) as c

on a.user_uid=c.user_uid


group by 1,2;

-- got the first reward


select a.date, (case when d.user_uid is not null then 'installed' when d.user_uid is null then 'notinstalled' end) as variant,

avg(fps) from

(select counter_date::date as date, user_uid, avg(value) as fps
from ztrack.s_zt_count 
where game_id=118 and counter='fpsdetailed' and kingdom in ('Chrome')
and value >=4
and counter_date > '2017-04-01' group by 1,2) as a

inner join

(select distinct (case when variant> 1 then 2 else 1 end) as variant,  user_uid from s_zt_exp where game_id=118 and test_name='fv2_q1_opt_fb_2_fv2'
and exp_date::date >='2017-04-26'  and variant=2) as b

on a.user_uid=b.user_uid

inner join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='dialog' and kingdom='okay'
and phylum='fv2_chrome_extension' and class='start_motd' and game_id=118) as c

on a.user_uid=c.user_uid

left join

(select distinct counter_date::date as date, user_uid from s_zt_count where counter='reward' and kingdom='grant'
and phylum='fv2_chrome_extension' and class='extension_installed' and game_id=118) as d

on a.user_uid=d.user_uid
group by 1,2;


-- session length

-- By experiments 

select a.date, b.variant, count(distinct a.user_uid) as users , (count(*)/count(distinct a.user_uid)) as sessions_per_user, (sum(datediff(minute,start_timestamp,end_timestamp))/count(distinct a.user_uid)) as session_time_per_user
 from
 (select distinct start_timestamp::date as date, user_uid, start_timestamp, end_timestamp
 from s_zt_session 
 where game_id =118
 
-- and user_uid is not null
-- and start_timestamp is not null
-- and active_time is not null
 and date(start_timestamp) between '$start_date1$' and '$end_date$') as a
 inner join
 (select distinct  user_uid, variant
from s_zt_exp
where test_name='fv2_q1_opt_fb_2_fv2'
and game_id=118
and exp_date::date between '$start_date$' and '$end_date$' ) b
 on a.user_uid=b.user_uid
 group by 1,2
 ;


select distinct sn_id, client_id , count(distinct user_uid) from s_zt_count where counter='dialog' and kingdom='okay'
and phylum='fv2_chrome_extension' and class='start_motd' and game_id=118 group by 1,2;

