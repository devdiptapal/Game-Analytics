commit;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, metric) 
select distinct user_uid, 'chrome'
from
v_user_day
where  game_id = 118
and user_agent like '%Chrome% 53.%'
and stat_date between '$refa$' and '$refb$' ;

insert /*+ direct */ into etl_temp.tmp_skb ( date,user_uid,value, metric) 
select counter_date, user_uid, avg(value),'fps'
 from s_zt_count
 where game_id=118 
 and counter='fpsdetailed'
 and value >=5
and counter_date between '$startdate$' and '$enddate$'
group by 1,2;







insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select user_uid,counter_date, avg(value) as value, 'loadtime'
from s_zt_count
where game_id = 118
and counter = 'CIPRO-Counter-1'
and kingdom = 'Loadtime'
and counter_date between '$startdate$' and '$enddate$'
group by 1,2;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select user_uid,counter_date, count(*) as value, 'fa'
from s_zt_count
where game_id = 118
and counter='farm_action'
group by 1,2;

insert /*+ direct */ into etl_temp.tmp_skb (user_uid, date,value, metric) 
select  user_uid, economy_date::date, -1*sum(amount) as 'Spend', 'fs'
from ztrack.s_zt_economy
where game_id =118 
and sn_id in (1,104) and client_id in (1,6)
and currency_flow = 'paid_spend' and currency = 'cash' and amount <0
and economy_date between '$startdate$' and '$enddate$'
group by 1,2;

--fps loadtime



select b.date, count(distinct a.user_uid), avg(b.value) as fps, avg(c.value) as loadtime from
(select distinct user_uid from tmp_skb where metric='chrome') a
inner join
(select distinct user_uid, date,value from tmp_skb where metric='fps') b
on a.user_uid=b.user_uid
inner join
(select distinct user_uid, date,value from tmp_skb where metric='loadtime') c
on a.user_uid= c.user_uid
and b.date=c.date
group by 1
order by 1;


-- farm actions

select b.date::date, count(distinct a.user_uid), sum(value)/count(distinct a.user_uid) as fa from
(select distinct user_uid from tmp_skb where metric='chrome') a
inner join
(select distinct user_uid, date,value from tmp_skb where metric='fa') b
on a.user_uid=b.user_uid
group by 1
order by 1;

--spend

select b.date::date, count(distinct a.user_uid), sum(value)/count(distinct a.user_uid) as fs from
(select distinct user_uid from tmp_skb where metric='chrome') a
inner join
(select distinct user_uid, date,value from tmp_skb where metric='fs') b
on a.user_uid=b.user_uid
group by 1
order by 1;