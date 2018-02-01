
commit;


insert into etl_temp.tmp_skb(metric,user_uid,value)
Select distinct 'dedup',a.user_uid,a.fbid
from
star.v_user a
inner join 
( select  distinct user_uid from s_zt_exp where game_id=118 and test_name='fv2_mcc_shared_orders_enabled' and variant=$var$)b
on a.user_uid=b.user_uid
where a.game_id = 118 and a.user_uid > 0 and a.fbid > 0 and a.user_uid is not null
and a.fbid is not null;

insert into etl_temp.tmp_skb(metric,user_uid,date)
Select distinct 'rev',a.user_uid,min(a.date_Trans::Date)
from
report.v_payment a
inner join 
( select  distinct user_uid from s_zt_exp where game_id=118 and test_name='fv2_mcc_shared_orders_enabled' and variant=$var$)b
on a.user_uid=b.user_uid
where a.game_id =118 
group by 1,2;

insert into etl_temp.tmp_skb(metric,user_uid,date)
Select distinct 'rev1', coalesce(b.value,a.user_uid),min(a.date::date)
from
etl_temp.tmp_skb a
left join
etl_temp.tmp_skb b
on a.user_uid = b.user_uid and b.metric = 'dedup'
where a.metric = 'rev'
group by 1,2;

insert into etl_temp.tmp_skb(metric,date,user_uid,value)
Select  'order_completion',a.counter_date,a.user_uid,count(*)
from
ztrack.s_zt_count a
inner join 
( select  distinct user_uid from s_zt_exp where game_id=118 and test_name='fv2_mcc_shared_orders_enabled' and variant=$var$)b
on a.user_uid=b.user_uid
where game_id = 118
and counter_date::Date between '$startdate$' and '$enddate$' and counter = 'marketstall_action'
and kingdom ='complete_order' group by 1,2,3
;

insert into etl_temp.tmp_skb(metric,date,user_uid,value)
Select distinct 'order_completion1',a.date::Date,coalesce(b.value,a.user_uid),sum(a.value)
from
etl_temp.tmp_skb a
left join
etl_temp.tmp_skb b
on a.user_uid = b.user_uid and b.metric = 'dedup'
where a.metric = 'order_completion'
group by 1,2,3;

Select a.date::Date as OrdersDate,count(distinct case when b.user_uid is not null then a.user_uid end) as 'Payer Completers',sum(case when b.user_uid is not null then a.value end) as 'Payer orders completed',
count(distinct case when b.user_uid is null then a.user_uid end) as 'NonPayer Completers',sum(case when b.user_uid is  null then a.value end) as 'NonPayer orders completed',
sum(case when b.user_uid is not null then a.value end)/count(distinct case when b.user_uid is not null then a.user_uid end) as 'Payers orders completed per completer'
,sum(case when b.user_uid is  null then a.value end)/count(distinct case when b.user_uid is null then a.user_uid end)as 'Non Payers orders completed per completer'
from
etl_temp.tmp_skb a
left join
etl_temp.tmp_skb b
on a.user_uid = b.user_uid and b.metric = 'rev1' and a.date::Date >= b.date
where a.metric = 'order_completion1'
group by 1 order by 1;

