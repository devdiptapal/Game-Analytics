
select a.date, count(distinct a.user_uid)


from

(select distinct
counter_date::date as date,min(counter_date+counter_time) as ts, user_uid
from ztrack.s_zt_count
where game_id = 118
and counter = 'dialog'
and counter_date between '$startdate$' and '$enddate$'
and kingdom = 'view'
and phylum = 'out_of_farmbucks' 
group by 1,3)a

inner join

 (select distinct date_trans::date as date,date_trans as ts, user_uid
from report.v_payment
where game_id = 118
and date_trans::date between  '$startdate$' and '$enddate$' 
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
)b

on  a.date=b.date
and a.user_uid=b.user_uid
and datediff(minute, a.ts, b.ts) between 0 and 10

group by 1
;

select distinct
counter_date::date as date, count(distinct user_uid)
from ztrack.s_zt_count
where game_id = 118
and counter = 'dialog'
and counter_date between '$startdate$' and '$enddate$'
and kingdom = 'view'
and phylum = 'out_of_farmbucks' 
group by 1;