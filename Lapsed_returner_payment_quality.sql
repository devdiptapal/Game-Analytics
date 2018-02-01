commit;

--  getting returning 7 day lapsers for each date

insert into etl_temp.tmp_skb (metric,date,user_uid)
select distinct 'returnlapser', a.date,  a.user_uid from

(select dau_date as date, user_uid
from s_zt_dau 
where game_id= $gameid$
and client_id=1
and dau_date between '$start$' and '$end$') as a

left join
(select dau_date as date, user_uid
from s_zt_dau 
where game_id= $gameid$
and client_id=1
and dau_date between '$start$'::date - $days$ and '$end$') as b

on b.date between a.date::date-$days$ and a.date::date-1
and a.user_uid=b.user_uid

where b.user_uid is null
;

-- Getting payer duu on each date

insert into tmp_skb (date, user_uid, value,metric)
select a.date,  b.user_uid, sum(amount) as amount, 'payerduu' from


(select dau_date::date as date, user_uid from s_zt_dau
where game_id= $gameid$
and client_id=1
and dau_date::date between '$start$' and '$end$' ) a

inner join

(select  date_trans::date as date, user_uid, amount
from report.v_payment
where game_id= $gameid$
and client_id=1
and date_trans::date between '2011-01-01' and '$end$' 

and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')) b
on a.user_uid=b.user_uid
and b.date <= a.date
group by 1,2
order by 1 desc;

-- Getting count of 7-day lapsed returners and payer DUU 7-day lapsed returners for each day

select a.date::date as date, count(a.user_uid) as 'All users', count(case when b.user_uid is not null then  a.user_uid end) as 'PayerDuu', sum(value)/count(case when b.user_uid is not null then  a.user_uid end) as 'lT$ Per Payer DUU'  
from
(select user_uid, date from tmp_skb where metric='returnlapser') as a
left join
(select user_uid, date, value from tmp_skb where metric='payerduu') as b
on a.user_uid=b.user_uid
and a.date=b.date
group by 1;


-- For lapsed returners the total $ output in the next 30 days to be given here

select a.date, count(distinct a.user_uid), count(case when c.user_uid is not null then a.user_uid end),
sum(amount)/count(case when c.user_uid is not null then a.user_uid end) as ltv from

(select user_uid, date from tmp_skb where metric='returnlapser') as a
inner join
(select user_uid, date, value from tmp_skb where metric='payerduu') as b
on a.user_uid=b.user_uid
and a.date=b.date
left join
(select distinct date_trans::date as date, user_uid,sum(amount) as amount from report.v_payment
where game_id= $gameid$
and client_id=1
and date_trans::date between  '$start$'::date  and '$end$'::date + $ltvdays$
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
    group by 1,2) as c
    on c.date between a.date and a.date + $ltvdays$
    and c.user_uid=a.user_uid
    
    group by 1;


--- MONTHLY ANALYSIS-----

-- cohort of such 7 day lapsed users in a month


insert into tmp_skb(date,metric, user_uid)
select distinct a.date, '7daylapse', a.user_uid from

(select user_uid, date from tmp_skb where metric='returnlapser') as a
inner join
(select user_uid, date, value from tmp_skb where metric='payerduu') as b
on a.user_uid=b.user_uid
and a.date=b.date
inner join
(select   date_trans::date as date, user_uid,sum(amount) as amount from report.v_payment
where game_id= $gameid$
and client_id=1
and date_trans::date between  '$start$'::date  and '$end$'::date + $ltvdays$
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
    group by 1,2) as c
    on c.date between a.date and a.date + $ltvdays$
    and c.user_uid=a.user_uid
  ;
    
    
    -- N day LTV
    
    
select count(distinct b.user_uid), sum(amount) from

(select distinct user_uid from tmp_skb where metric='returnlapser' and date between '$date1$' and '$date2$') as a
inner join
(select distinct min(dau_date) as date, user_uid
from s_zt_dau 
where game_id= $gameid$
and client_id=1
and dau_date between '$date1$' and '$date2$' group by 2) as b
on a.user_uid=b.user_uid
inner join
(select distinct date_trans::date as date, user_uid,sum(amount) as amount from report.v_payment
where game_id= $gameid$
and client_id=1
and date_trans::date between  '$start$'::date  and '$end$'::date + $ltvdays$
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
    group by 1,2) as c
    on c.date between b.date and b.date + $ltvdays$
    and c.user_uid=a.user_uid
   ;
   
   
   
-- Returners source

select (year(date)*100+month(date)), source, avg(users) from
(select  a.date, source, count(distinct a.user_uid) as users from

(select distinct dau_date as date,  source, user_uid
from s_zt_dau 
where game_id= $gameid$
and client_id=1
and dau_date between '$start$' and '$end$') as a

left join
(select dau_date as date, user_uid
from s_zt_dau 
where game_id= $gameid$
and client_id=1
and dau_date between '$start$'::date - $days$ and '$end$') as b

on b.date between a.date::date-$days$ and a.date::date-1
and a.user_uid=b.user_uid

where b.user_uid is null
group by 1,2) as a
group by 1,2
having avg(users)>10000
;


