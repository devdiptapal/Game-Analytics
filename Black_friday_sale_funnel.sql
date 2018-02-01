
--users in variant
select variant, count(distinct user_uid)  from s_zt_exp 
        where game_id=118 and test_name='fv2_blackfriday_q4sale_16' and exp_date::date between '$start$' and '$end$' group by 1;
        
--overall views
        
select variant, count(distinct a.user_uid) from

(select user_uid, max(variant) as variant from s_zt_exp 
        where game_id=118 and test_name='fv2_blackfriday_q4sale_16' and exp_date::date between '$start$' and '$end$' group by 1) a
       inner join 
(select distinct user_uid from s_zt_count
where game_id=118
and counter='dialog'
and kingdom in ('open')
and phylum = 'black_friday_sale'
and counter_date::date between '$start$' and '$end$' ) b
on a.user_uid=b.user_uid
group by 1;


-- payer views
        
  select variant, count(distinct a.user_uid) from

(select user_uid, max(variant) as variant from s_zt_exp 
        where game_id=118 and test_name='fv2_blackfriday_q4sale_16' and exp_date::date between '$start$' and '$end$' group by 1) a
       inner join 
(select distinct user_uid from s_zt_count
where game_id=118
and counter='dialog'
and kingdom in ('open')
and phylum = 'black_friday_sale'
and counter_date::date between '$start$' and '$end$') b
on a.user_uid=b.user_uid
inner join
 (select distinct  user_uid
from report.v_payment
where game_id = 118
and date_trans::date between  '2011-04-01' and '2016-11-24'
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date > '2011-04-01') ) as c
    on a.user_uid=c.user_uid
        
 group by 1;      
        
        
        
        
        
    
        
  -- item buys      
        
        
        select variant, count(distinct a.user_uid), sum(purchases) from

(select user_uid, max(variant) as variant from s_zt_exp 
        where game_id=118 and test_name='fv2_blackfriday_q4sale_16' and exp_date::date between '$start$' and '$end$' group by 1) a
       inner join 
(select distinct user_uid, count(*) as purchases from s_zt_count
where game_id=118
and counter='dialog'
and kingdom in ('click')
and class like '%slot%'
and phylum = 'black_friday_sale'
and counter_date::date between '$start$' and '$end$' group by 1) b
on a.user_uid=b.user_uid
group by 1;
        
        
    -- final reward    
              select variant, count(distinct a.user_uid) from

(select user_uid, max(variant) as variant from s_zt_exp 
        where game_id=118 and test_name='fv2_blackfriday_q4sale_16' and exp_date::date between '$start$' and '$end$' group by 1) a
       inner join 
(select distinct user_uid from s_zt_count
where game_id=118
and counter='dialog'
and kingdom in ('buy')
and family= 'cow_granted'
and counter_date::date between '$start$' and '$end$' ) b
on a.user_uid=b.user_uid
group by 1;
        