
commit;

insert into tmp_skb (date,user_uid,metric)
select distinct a.date, b.user_uid, 'cohort' from
(select distinct stat_date::date as date
   from v_user_day 
  where game_id=118
  and stat_date::date between '$startdate$' and '$enddate$' )a
  inner join
  
  (select stat_date::date as date, user_uid, level 
  from v_user_day 
  where game_id=118
  and stat_date::date between '$startdate$'::date-31 and '$enddate$')b
  on b.date::date= a.date::date - 31
;
  
  insert into tmp_skb (date,user_uid,metric)
  select a.date, a.user_uid,'payercohort' from
 (select date, user_uid from tmp_skb where metric='cohort') a
  
  inner join
  
  (select distinct date_trans::date as date,  user_uid
        from report.v_payment
        where game_id = 118
        and date_trans::date between  '2011-01-01' and '$enddate$' 
        and status = 0
            and db_source = 's_receipts'
            and amount > 0
            and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
            and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
            and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
      ) b
      
   on a.user_uid =  b.user_uid
   and b.date::date= a.date::date-31
  inner join
   
   (select distinct user_uid
from report.v_payment
where game_id=118 
and transaction_type not like '%SUBSCRIPTION%'
and date_trans::date between  '2015-06-01' and '2016-10-11') d
on a.user_uid=d.user_uid
; 
   
   
   insert into tmp_skb (date, user_uid, metric)
   select a.date, a.user_uid, 'dead' from
   (select date, user_uid from tmp_skb where metric='payercohort' ) a
  
  left join
  
  (select stat_date::date as date, user_uid, level 
  from v_user_day 
  where game_id=118
  and stat_date::date between '$startdate$'::date -30 and '$enddate$' )c
  on a.user_uid=c.user_uid
  and c.date between a.date::date - 30 and a.date::date - 1
  where c.user_uid  is null;
  
  
  select date, count(distinct user_uid) from tmp_skb where metric='dead' group by 1;

select a.date, count(distinct a.user_uid) as users, sum(amount) as amount from
(select date, user_uid from tmp_skb where metric='dead') a
inner join
(select distinct date_trans::date as date,  user_uid, sum(amount) as amount
        from report.v_payment
        where game_id = 118
        and date_trans::date between  '2011-01-01' and '$enddate$' 
        and status = 0
            and db_source = 's_receipts'
            and amount > 0
            and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
            and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
            and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01') group by 1,2) b
            on a.user_uid=b.user_uid
            and b.date between a.date::date-29 and a.date
            group by 1;




