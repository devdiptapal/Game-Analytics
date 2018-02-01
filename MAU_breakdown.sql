commit;

insert into tmp_skb (user_uid, metric)
select
distinct x.user_uid, 'atype' from
---- y.level, y.latest_locale, 
--y.country, count(distinct x.user_uid) from
(select distinct a.user_uid from
(select user_uid, count(distinct week(dau_date)) as wlogins from s_zt_dau where game_id=118 and dau_date between '2016-05-22' and '2016-06-18' group by 1) as a
inner join
(select user_uid, count(distinct dau_date) as dlogins from s_zt_dau where game_id=118 and dau_date between '2016-05-22' and '2016-06-18' group by 1) as b
on 
a.user_uid = b.user_uid
where a.wlogins in (1)
and b.dlogins in (1)) x
inner join

(select * from
(select distinct user_uid,coalesce(level,1) as level,  latest_locale,country, rank() over (partition by user_uid order by stat_date desc) as rank from  
v_user_day where game_id=118  and user_uid is not null and stat_date between '2016-05-22' and '2016-06-18') as x
where rank=1
and level > $levelmin$) y

on x.user_uid=y.user_uid

group by 1
order by 1;

-- session data

select  count(distinct a.user_uid) as users , (count(*)/count(distinct a.user_uid)) as sessions_per_user, (sum(datediff(minute,start_timestamp,end_timestamp))/count(distinct a.user_uid)) as session_time_per_user
 from
 (select distinct start_timestamp::date as date, user_uid, start_timestamp, end_timestamp
 from s_zt_session 
 where game_id =118
 
-- and user_uid is not null
-- and start_timestamp is not null
-- and active_time is not null
 and date(start_timestamp) between '2016-05-22' and '2016-06-18') as a
 inner join
 (select distinct user_uid from tmp_skb where metric= 'atype') b
 on a.user_uid=b.user_uid
 
 ;

-- installs overlap
select yearweek,count(distinct a.user_uid) from
(select  user_uid , min (year(install_timestamp::date)*100+month(install_timestamp::date)) as yearweek from s_zt_install where game_id=118  group by 1) as a
inner join
 (select distinct user_uid from tmp_skb where metric= 'atype') b
 on a.user_uid=b.user_uid
 group by 1;
 
 
 --
 
-- dau overlap
select ym,count(distinct a.user_uid), avg(logins) from
(select user_uid,  (year(dau_date::date)*100+month(dau_date::date)) as ym, count(distinct dau_date::date) as logins  from s_zt_dau 
where game_id=118 and dau_date between '2014-01-01' and '2016-06-22' group by 1,2) as a
inner join
 (select distinct user_uid from tmp_skb where metric= 'atype') as b
 on a.user_uid=b.user_uid
 group by 1;
 
 --map and spend
 
 insert /*+ direct */ into etl_temp.tmp_skb (metric,value2, user_uid, value)
select distinct 'spenders',year(date_trans)*100+month(date_trans), user_uid , sum(amount)
from report.v_payment
where game_id = 118
and date_trans between '2011-01-01 00:00:00' and '2016-06-18 00:04:00' 
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
group by 2,3;

--payer information
select  count(distinct a.user_uid)
from
(select distinct value2, user_uid, value from tmp_skb where metric= 'spenders') as a
inner join
(select distinct user_uid from tmp_skb where metric='atype') as b
on a.user_uid=b.user_uid;


-- performance issues

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select user_uid,counter_date, avg(value) as value, 'memory'
from s_zt_count
where game_id = 118
and sn_id in ($snid$)
and client_id in ($clientid$)
and counter = 'CIPRO-Counter-1'
and kingdom = 'PlaytimeFrameTime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2
;

select  a.date, count(distinct user_uid), avg(a.value) from
(select user_uid, date, value from tmp_skb where metric='memory') a
inner join
(select distinct user_uid from tmp_skb where metric='atype') b
on a.user_uid=b.user_uid
group by 1;