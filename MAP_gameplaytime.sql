
-- payers only


commit;

 insert into tmp_skb (date, user_uid, metric2, metric)
 
 select distinct a.date, a.user_uid,'exp' from
(select distinct stat_date::date as date, user_uid
from v_user_day where 
game_id=118 
and stat_date::date between '$startdate$' and '$enddate$'

) a
inner join
(select date_trans::date  as date, user_uid
from report.v_payment
where game_id = 118
and date_trans::date between  '$startdate$'::date-$days$ and '$enddate$' 
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')

)b
on 
 a.user_uid=b.user_uid
 and b.date between a.date-$days$ and a.date;
 
 
insert into tmp_skb (date, user_uid, metric) 
 select distinct a.date, a.user_uid, 'actual' from
 (select date, user_uid from tmp_skb where metric='exp') as a
inner join
 (select distinct stat_date::date as date, user_uid from v_user_day where game_id=118 and level >=29 
  and stat_date::date between '$startdate$' and '$enddate$') as b
  on a.date=b.date
  and a.user_uid = b.user_uid
;

-- 5 minute users
 
 insert into tmp_skb (date, user_uid, metric)
 select distinct a.date , a.user_uid, '5min'
 from
  (select date, user_uid from tmp_skb where metric='actual') as a
 inner join
  (select date(start_timestamp::date) as date, user_uid
        from s_zt_session 
        where game_id =118
        --and datediff(minute,start_timestamp,end_timestamp) between 5 and 360
        and date(start_timestamp)  between '$startdate$' and '$enddate$'
        group by 1,2
        having sum(datediff(minute,start_timestamp,end_timestamp)) between 5 and 360 )b
    on a.date=b.date
    and a.user_uid = b.user_uid;
    
  -- get count by each type
    
   select date, metric, count(distinct user_uid) AS USERS from tmp_skb where metric in ('actual','5min') group by 1,2;
  
