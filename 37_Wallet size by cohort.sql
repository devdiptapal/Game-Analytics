commit;


-- getting golden cohort
insert /*+ direct */ into etl_temp.tmp_skb (game_id, user_uid,date,value,/**value2,*/value3, metric)
(select distinct  game_id, x.user_uid,x.dateobj,/**p.engagement,**/x.txn,x.rev, 'gc_dated2'   from

        (select a.dateobj, b.user_uid, game_id, sum(txn) as txn, sum(amnt) as rev from
                (select dateobj from d_date where dateobj between '$cohort_dt1$' and '$cohort_dt2$' group by 1) A
                left join
                (select user_uid, game_id, count(*) as txn,sum(amount) as amnt, date_trans 
                from
                        report.v_payment
                 where game_id = 118 and date_trans >= '2015-01-01' and transaction_type = 'USERPAY'
                 group by 1,2,5) B
                on a.dateobj  >= b.date_trans and a.dateobj - 90  < b.date_trans
                group by 1,2,3) X   
        
                 /**left join
                
                 (select dateobj, user_uid, count(distinct dau_date)/60 as engagement from       
                        (select dateobj from d_date where dateobj between '$cohort_dt1$' and '$cohort_dt2$' group by 1) A
                        left join
                        (select user_uid, dau_date from s_zt_dau where game_id = 118 and dau_date >= date('$cohort_dt1$')-60 group by 1,2) B
                        on A.dateobj >= B.dau_date and a.dateobj - 60  < B.dau_date 
                 group by 1,2  ) P
                 
                 on x.dateobj = p.dateobj and x.user_uid = p.user_uid **/
         
  where x.txn >= 2 and x.rev >= 15 //and p.engagement >= 0.5
 
) ;

--select date,count(distinct user_uid) from tmp_skb where metric='gc_dated2' and value>=.5 group by 1;



--Wallet size on the day for Gc

insert into etl_temp.tmp_skb (date,user_uid,value,metric)
select distinct date ,user_uid, total_amount,'wallet' from
(Select distinct economy_date::date,b.date,b.user_uid,total_amount,row_number() over (partition by b.user_uid,b.date order by economy_date+economy_time desc) as rank
from 

(select * from tmp_skb where metric='gc_dated2')b

/**inner join

(select user_uid, dau_date from s_zt_dau where game_id = 118 and dau_date between '$cohort_dt1$' and '$cohort_dt2$') c
on b.user_uid = c.user_uid and b.date = c.dau_date **/

left join 

(select * from ztrack.s_zt_economy where game_id = 118 and sn_id = 1 and client_id = 1 and economy_date::date <='$cohort_dt2$' 
and currency = 'cash' and currency_flow like '%paid%'
and total_amount<=5000
) a
on a.user_uid=b.user_uid and b.date>=a.economy_date::date order by 1) c

where rank=1 order by 3;

--Percentile values

Select distinct a.date::date,percentile_disc(0.5) within group (order by value) over(partition by date)
from
etl_temp.tmp_skb  a

where a.metric = 'wallet'
;


-- sum(wallet
Select a.date::date,sum(a.value),count(distinct a.user_uid)
from
etl_temp.tmp_skb  a
where a.metric = 'wallet'
group by 1;
