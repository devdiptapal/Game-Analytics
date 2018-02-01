commit;

--golden cohort definition

insert /*+ direct */ into etl_temp.tmp_skb (game_id, user_uid, metric, value)
select game_id, user_uid, 'golden_cohort', sum(amount)
from report.v_payment
where game_id = 118
and date_trans::date between '2016-10-01' and '2016-12-31' 

and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
group by 1,2,3
having
sum(amount) >= 15 and count(amount) >=2
;
insert into tmp_skb(metric,date,user_uid,value)
select distinct 'econ', date, user_uid, total_amount from
(Select distinct economy_date::date as date, user_uid,total_amount, 
rank() over (partition by user_uid, economy_date order by economy_time desc) as rank
from ztrack.s_zt_economy
where game_id = 118  and 

economy_date::date between '$start_dt$'::date-7 and '$end_dt$' and currency = 'cash' and currency_flow like '%paid%'
and total_amount<=5000) as n
where rank=1;


insert into tmp_skb(metric,date,user_uid)
select distinct 'dau',a.date, a.user_uid from
(select distinct dau_date::date as date, user_uid from s_zt_dau
where  dau_date::date  between '$start_dt$' and '$end_dt$') as a
inner join
(select distinct user_uid from tmp_skb where metric='golden_cohort') as b
on a.user_uid=b.user_uid;


insert into etl_temp.tmp_skb (metric,date,user_uid,value)
select distinct 'def', date, user_uid, total_amount from
(Select distinct  a.date,a.user_uid,total_amount,row_number() over 
(partition by a.user_uid,a.date order by b.date desc) as rank from
(select distinct date, user_uid from tmp_skb where  metric='dau') as a
full join
(select distinct date,user_uid, value as total_amount from tmp_skb where metric='econ') as b
on a.user_uid=b.user_uid
and b.date between a.date::date-7 and a.date) as n
where rank=1;




-- get golden cohort


select distinct date1, 

percentile_cont(0.75) within group(order by wallet) over (partition by date1) as p75,
percentile_cont(0.90) within group(order by wallet) over (partition by  date1) as p90,
percentile_cont(0.99) within group(order by wallet) over (partition by  date1) as p99

from

(Select a.date::date as date1,a.user_uid, sum(a.value) as wallet
from
etl_temp.tmp_skb  a

where a.metric = 'def'
and a.user_uid is not null
group by 1,2) as a
;