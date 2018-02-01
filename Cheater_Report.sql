
commit;


-- classifying building cheaters

insert into etl_Temp.tmp_skb (metric,user_uid)
select distinct 'building_fraud', user_uid from (
select user_uid, max(case when kingdom like ('wind_mill') then value end) as wind_max,
max(case when kingdom like ('water_tower') then value end) as water_max
 from s_zt_count  where game_id = 118
and counter like '%start_session%'
and counter_date between '$start_date$' and '$end_date$'
and (kingdom like ('wind_mill') or kingdom like ('water_tower'))
group by 1
having
max(case when kingdom like ('wind_mill') then value end) > 1
or max(case when kingdom like ('water_tower') then value end)>1
) as x
;


-- revenue behavior

insert into etl_Temp.tmp_skb (metric, date, user_uid, value )
Select distinct 'rev',date_trans::date, user_uid,sum(amount) as spend 
from report.v_payment where 
   status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
    and game_id = 118 and date_trans::date between '$start_date$' and '$end_date$' 
group by 1,2,3;


-- rev behavior

select b.date::date, count(distinct b.user_uid) as users, sum(value) as revenue,  (sum(value)/count(distinct b.user_uid)) as arpac from
(select user_uid, date, value from tmp_skb where metric= 'rev') as a
right join

(select distinct b.date, a.user_uid from
(select distinct user_uid from tmp_skb where metric='building_fraud') a
inner join
(select distinct user_uid, dau_date::date as date from s_zt_dau where game_id=118 and dau_date between '$start_date$' and '$end_date$')b
on a.user_uid=b.user_uid) b
on a.user_uid=b.user_uid 
and a.date=b.date
group by 1;




-- wallet behavior

select
distinct economy_date::date,

PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date) as wallet_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date) as wallet_p75,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date)as wallet_p90
from

 ( select distinct economy_date, a.user_uid, coalesce(wallet,0) as wallet from


(select distinct economy_date, user_uid,total_amount as wallet
from 
(select distinct user_uid, economy_date, economy_time, rank() over (partition by  economy_date, user_uid order by economy_time desc) as rank, total_amount
from s_zt_economy
where game_id=118
and currency='favor' and currency_flow in ('paid_spend','paid_credit','free_credit') 
and user_uid is not null
and economy_date between '$start_date$' and '$end_date$'
order by 1,2,3) as b
where rank=1
and user_uid is not null) as a

right join

(select distinct b.date, a.user_uid from
(select distinct user_uid from tmp_skb where metric='building_fraud') a
inner join
(select distinct user_uid, dau_date::date as date from s_zt_dau where game_id=118 and dau_date between '$start_date$' and '$end_date$')b
on a.user_uid=b.user_uid) b


on 
a.economy_date::date = b.date and
a.user_uid = b.user_uid) as n
where economy_date is not null
order by 1
 ;
 

 
 -- state fair cheaters
 commit;
 
insert into etl_temp.tmp_skb (metric,user_uid)
Select distinct 'sfcheater', user_uid
from
ztrack.s_zt_count where game_id = 118 and counter_date between '$start_date$' and '$end_date$'
and counter = 'state_fair' and kingdom = 'start'
and family in (
'AaC_v0',
'AaC_v1',
'AaC_v2',
'AaC_v3',
'AbC_v0',
'AbC_v1',
'AbC_v2',
'AbC_v3',
'AcC_v0',
'AcC_v1',
'AcC_v2',
'AcC_v3',
'DC_v0',
'DC_v1',
'RaC_v0',
'RaC_v1',
'RaC_v2',
'RaC_v3',
'RbC_v0',
'RbC_v1',
'RbC_v2',
'RcC_v0',
'RcC_v1',
'SaC_v0',
'SaC_v1',
'SbC_v0',
'ScC_v0'

);



-- revenue behavior

insert into etl_Temp.tmp_skb (metric, date, user_uid, value )
Select distinct 'rev',date_trans::date, user_uid,sum(amount) as spend 
from report.v_payment where 
   status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
    and game_id = 118 and date_trans::date between '$start_date$' and '$end_date$' 
group by 1,2,3;


-- rev behavior

select b.date::date, count(distinct b.user_uid) as users, sum(value) as revenue,  (sum(value)/count(distinct b.user_uid)) as arpac from
(select user_uid, date, value from tmp_skb where metric= 'rev') as a
right join

(select distinct b.date, a.user_uid from
(select distinct user_uid from tmp_skb where metric='sfcheater') a
inner join
(select distinct user_uid, dau_date::date as date from s_zt_dau where game_id=118 and dau_date between '$start_date$' and '$end_date$')b
on a.user_uid=b.user_uid) b
on a.user_uid=b.user_uid 
and a.date=b.date
group by 1;




-- wallet behavior

select
distinct economy_date::date,

PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date) as wallet_p50,
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date) as wallet_p75,
PERCENTILE_CONT(.90) WITHIN GROUP(ORDER BY wallet) OVER (PARTITION BY economy_date)as wallet_p90
from

 ( select distinct economy_date, a.user_uid, coalesce(wallet,0) as wallet from


(select distinct economy_date, user_uid,total_amount as wallet
from 
(select distinct user_uid, economy_date, economy_time, rank() over (partition by  economy_date, user_uid order by economy_time desc) as rank, total_amount
from s_zt_economy
where game_id=118
and currency='favor' and currency_flow in ('paid_spend','paid_credit','free_credit') 
and user_uid is not null
and economy_date between '$start_date$' and '$end_date$'
order by 1,2,3) as b
where rank=1
and user_uid is not null) as a

right join

(select distinct b.date, a.user_uid from
(select distinct user_uid from tmp_skb where metric='sfcheater') a
inner join
(select distinct user_uid, dau_date::date as date from s_zt_dau where game_id=118 and dau_date between '$start_date$' and '$end_date$')b
on a.user_uid=b.user_uid) b


on 
a.economy_date::date = b.date and
a.user_uid = b.user_uid) as n
where economy_date is not null
order by 1
 ;
 
