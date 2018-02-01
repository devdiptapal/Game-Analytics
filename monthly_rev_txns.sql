
select a.week, (case when a.bucket= 'l' and b.bucket='l' then 'l-constant'
                when a.bucket= 'm' and b.bucket='m' then 'm-constant'
                when a.bucket= 'h' and b.bucket='h' then 'h-constant'
                when a.bucket= 'l' and b.bucket='h' then 'h-to-l'
                 when a.bucket= 'l' and b.bucket='m' then 'm-to-l'
                     when a.bucket= 'm' and b.bucket='h' then 'h-to-m'
                 when a.bucket= 'm' and b.bucket='l' then 'l-to-m'
                  when a.bucket= 'h' and b.bucket='m' then 'm-to-h'
                 when a.bucket= 'h' and b.bucket='l' then 'l-to-h'
                 when b.bucket is null then 'new payers' end) as bucket, count(distinct a.user_uid)
                 from
(select week,

(case when txn between 1 and 3 then 'l'
when txn between 4 and 8 then 'm'
else 'h' end) as bucket, user_uid
from
(select (year(date_trans::date)*100+week(date_trans::date))  as week, user_uid, count(*) as txn
from report.v_payment
where game_id = 118
and date_trans::date between  '$startdate$' and '$enddate$' 
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date > '2011-04-01')
group by 1,2) x
group by 1,2,3)a

left join

(select week,

(case when txn between 1 and 3 then 'l'
when txn between 4 and 8 then 'm'
else 'h' end) as bucket, user_uid
from
(select (year(date_trans::date)*100+week(date_trans::date))  as week, user_uid, count(*) as txn
from report.v_payment
where game_id = 118
and date_trans::date between  '$startdate$'::date-7 and '$enddate$'::date-7
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date > '2011-04-01')
group by 1,2) x
group by 1,2,3)b

on a.week=b.week+1
and a.user_uid=b.user_uid

group by 1,2;