
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
  on b.date::date= a.date::date - 31;
  
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
   and b.date::date between '2011-01-01'  and a.date::date-31; 
   
   
   insert into tmp_skb (date, user_uid, metric)
   select a.date, a.user_uid, 'LTdead' from
   (select date, user_uid from tmp_skb where metric='payercohort' ) a
  
  left join
  
  (select stat_date::date as date, user_uid, level 
  from v_user_day 
  where game_id=118
  and stat_date::date between '$startdate$'::date -30 and '$enddate$' )c
  on a.user_uid=c.user_uid
  and c.date between a.date::date - 30 and a.date::date - 1
  where c.user_uid  is null;
  
  
  select date::date, count(distinct user_uid) from tmp_skb where metric='LTdead' group by 1 order by 1 desc;









