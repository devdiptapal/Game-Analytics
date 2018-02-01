commit;

insert into tmp_skb(user_uid,metric2, metric)
    select distinct user_uid , 
(case when diff between 7 and 14 then '7-14'
   when diff between 15 and 30 then '15-30'
   when diff between 31 and 60 then '31-60'
   when diff between 61 and 90 then '61-90'
      when diff >  90 then '90+'
 end) as category, 'cat'
    
   from 
   ( select distinct a.user_uid, b.date-a.date as diff from
 
    (select  user_uid, max(dau_date::date) as date
    from s_zt_dau
    where game_id=118
    and dau_date between '2011-01-01' and '2016-08-31' group by 1
    ) as a 
    inner join
    (select user_uid, stat_date::date as date from v_user_day
    where game_id=118
    and stat_date = '2016-09-01'
    and level>=10) as b
    on a.user_uid=b.user_uid ) as a
    where diff >=7 ;
    
    select cat, count(distinct a.user_uid), sum(amount), sum(amount)/count(distinct a.user_uid) as avg from
  (select user_uid, metric2 as cat from tmp_skb where metric='cat') as a
  left join
  (select  user_uid,sum(amount) as amount from report.v_payment
where game_id= 118
and client_id=1
and date_trans::date between  '2016-09-01'::date  and '2016-09-01'::date + $ltvdays$
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
    group by 1) as b
    on a.user_uid =b.user_uid
    group by 1;
    
    
    -- n day LTV
    
    
        select count(distinct user_uid ), 
(case when diff between 7 and 14 then '7-14'
   when diff between 15 and 30 then '15-30'
   when diff between 31 and 60 then '31-60'
   when diff between 61 and 90 then '61-90'
      when diff >  90 then '61-90'
 end) as category, 'cat'
    
   from 
   ( select distinct a.user_uid, b.date-a.date as diff from
 
    (select  user_uid, max(stat_date::date) as date
    from v_user_day
    where game_id=118
    and stat_date between '2011-01-01' and '2016-08-31' group by 1 having max(level)>=10
    ) as a 
    inner join
    (select distinct stat_date::date as date from v_user_day
    where game_id=118
    and stat_date = '2016-09-01'
    and level>=10) as b
    on a.date < b.date ) as a
    
    where diff >=7
    group by 2 ;