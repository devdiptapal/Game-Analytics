
insert into tmp_skb (date, user_uid, value, metric)
select a.date,  b.user_uid, count(distinct b.date) ,'abc' 
from 
(select dateobj as date from d_date where dateobj between '$start$' and '$end$' ) as a
inner join
(select distinct dau_date::date as date , user_uid
from s_zt_dau
where game_id = 118
and dau_date between '$start$'::date-7 and '$end$') b
on b.date between a.date - 6 and a.date 
inner join

--Insert the required user_uid here

(select  user_uid from s_zt_count
where game_id=118
and (phylum like '%d_browser_support%' or kingdom like '%d_browser_support%' or class like '%d_browser_support%')
and counter_date between '2016-12-05' and '2016-12-25')   c
on b.user_uid=c.user_uid
group by 1,2 ;



select  eng, count(distinct a.user_uid) from

(select distinct
  user_uid
  from s_zt_count
where game_id=118
and kingdom in ('open','view')
and (phylum like '%d_browser_support%' or kingdom like '%d_browser_support%' or class like '%d_browser_support%')
and counter_date between '2016-12-05'  and '2016-12-25'
) a

inner join

(select user_uid, (case when (value in (1,2,3,4,5,6,7)) then 'Low' 
     when (value  in (8,9,10,11,12,13,14,15,16,17)) then 'Mid' 
     when (value  in (18,19,20,21)) then 'High'  end) as ENG from
(select user_uid, count(distinct dau_date) as value from s_zt_dau where game_id=118 and
dau_date between '2016-12-05' and '2016-12-25' group by 1
) c
) as c
on a.user_uid=c.user_uid

group by 1;

--open the game

select eng,
--a.date,
 count(distinct a.user_uid) from
(select dau_date::date+dau_time as date,  user_uid from s_zt_dau
where game_id=118
--and counter in ('loadtimetimedetailed','fpsdetailed')
and dau_date >= '2016-12-05' ) a
inner join

(select user_uid,counter_date::date+counter_time as date  from s_zt_count
where game_id=118
and phylum like '%d_browser_support%'  
and counter_date >= '2016-12-05' ) b

on a.date > b.date
and a.user_uid=b.user_uid

inner join
(select user_uid, (case when (value in (1,2,3,4,5,6,7)) then 'Low' 
     when (value  in (8,9,10,11,12,13,14,15,16,17)) then 'Mid' 
     when (value  in (18,19,20,21)) then 'High'  end) as ENG from
(select user_uid, count(distinct dau_date) as value from s_zt_dau where game_id=118 and
dau_date between '2016-12-05' and '2016-12-25' group by 1
) as x) c
on a.user_uid=c.user_uid
 group by 1 ;

--browser details

select  class as browser ,family as version, count(distinct user_uid) as players from s_zt_count
where game_id=118
and counter_date between '2016-12-05' and '2016-12-25'
and phylum like '%d_browser_support%'  
and kingdom = 'open'


group by 1,2;
--Here is the query fo finding the engagement:
--distributing players in engagement buckets

insert into tmp_skb (date, user_uid, value, metric)
select a.date,  b.user_uid, count(distinct b.date) ,'ENG' 
from 
(select dateobj as date from d_date where dateobj between '$start$' and '$end$' ) as a
inner join
(select distinct dau_date::date as date , user_uid
from s_zt_dau
where game_id = 118
and dau_date between '$start$'::date-7 and '$end$') b
on b.date between a.date - 6 and a.date 
inner join

--Insert the required user_uid here

(select  user_uid from s_zt_count
where game_id=118
and (phylum like '%d_browser_support%' or kingdom like '%d_browser_support%' or class like '%d_browser_support%')
and counter_date between '2016-12-05' and '2016-12-25')   c
on b.user_uid=c.user_uid
group by 1,2 ;


--output

select date::date, 
case when (value in (1,2)) then 'Low' 
     when (value  in (3,4,5)) then 'Mid' 
     when (value  in (6,7)) then 'High'  end as ENG, 
      user_uid
from tmp_skb where metric = 'ENG'
group by 1,2;

select a.date, eng, count(distinct a.user_uid) from
(select dau_date::date as date,  user_uid from s_zt_dau
where game_id=118

and dau_date >= '2016-12-01' ) a
inner join
(select user_uid,counter_date::date as date  from s_zt_count
where game_id=118
and phylum like '%d_browser_support%'  
and counter_date >= '2016-12-01' ) b
on a.date=b.date
and a.user_uid=b.user_uid
inner join
(select date::date, 
case when (value in (1,2)) then 'Low' 
     when (value  in (3,4,5)) then 'Mid' 
     when (value  in (6,7)) then 'High'  end as ENG, 
      user_uid
from tmp_skb where metric = 'ENG'
group by 1,2,3) c
on a.date=c.date
and a.user_uid=b.user_uid
 group by 1,2;


select date::date, 
case when (value in (1,2)) then 'Low' 
     when (value  in (3,4,5)) then 'Mid' 
     when (value  in (6,7)) then 'High'  end as ENG, 
      count(distinct user_uid)
from tmp_skb where metric = 'ENG'
group by 1,2;


--browser for high engaged
select  class as browser ,family as version, count(distinct user_uid) as players from s_zt_count
where game_id=118
and counter_date >= '2016-12-10'
and phylum like '%d_browser_support%'  
and kingdom = 'open'
and user_uid in (
select  user_uid
from tmp_skb where metric = 'ENG'
and value in (6,7))
group by 1,2;
