commit;



-- Determine variant per sn_id / user_uid / game_id / client_id combination
INSERT /*+ direct */ INTO etl_temp.tmp_skb(user_uid, date, value , metric) 
SELECT distinct  user_uid, exp_date, variant, 'exp'
FROM s_zt_exp 
WHERE game_id = 118 and sn_id in ($snid$) and client_id IN ($clientid$)
and start_timestamp::date between '$startdate$' and '$enddate$'
and test_name =  '$testname$'
and variant is not null;

-- Get coop activity (create_coop / join_coop / leave_coop)  coop number tracked in value field
INSERT /*+ direct*/ INTO etl_temp.tmp_skb( user_uid,  metric, value, date, metric5)
Select user_uid, milestone, value, milestone_date, 'coop'
from s_zt_milestone
where game_id=118
and milestone ilike '%coop' 
; 

-- logging coops as user_uid for mapping
INSERT /*+ direct*/ INTO etl_temp.tmp_skb_2( user_uid, date, metric5)
Select user_uid, milestone_date,  'coop_alt'
from s_zt_milestone
where game_id=118
and milestone ilike '%coop'
;

-- logging coop as experiment variant for coop founder
INSERT /*+ direct*/ INTO etl_temp.tmp_skb( date, user_uid,  metric, value, metric5)
Select  distinct b.date, a.user_uid, a.metric, b.value, 'exp_c'
from etl_temp.tmp_skb a
inner join etl_temp.tmp_skb b
on a.user_uid=b.user_uid
and b.metric='exp'
where a.metric5='coop'
and a.metric='create_coop'
;

-- logging members of coops under variant of coop
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(user_uid,  value, date,metric)
Select  distinct a.user_uid,  b.value,  b.date::date, 'final_list'
from etl_temp.tmp_skb_2 a
inner join  etl_temp.tmp_skb b
on
a.user_uid=b.user_uid and b.metric5='exp_c'
where a.metric5='coop_alt'

and a.date between '$startdate$' and '$enddate$'
;


-- users in variant





Select count(distinct  a.value4),  b.value, a.date::date, 'final_list'
from etl_temp.tmp_skb_2 a
left join  etl_temp.tmp_skb b
on
a.user_uid=b.user_uid and b.metric5='exp_c'
where a.metric5='coop_alt'
and b.value is not null
and a.value4 is not null
and a.date is not null
and a.date between '$startdate$' and '$enddate$'
group by 2,3
order by 3,2
;


-- counter slicer


select a.date::date, a.value, count(distinct a.user_uid) as users, sum(actions) as actions

from tmp_skb a
inner join
(select  counter_date, user_uid, count(*) as actions from
s_zt_count
where
game_id=118 
 --counter = 'big_ha' 
and kingdom = 'big_harvest' 
and phylum = 'coop_goal'
and class = 'completed'
and counter_date between '$startdate$' and '$enddate$' group by 1,2) b
on a.date=b.counter_date
and a.user_uid = b.user_uid
and a.metric='final_list'
group by 1, 2 ;



-- spend slicer


select a.date::date, a.value, count(distinct a.user_uid) as users, sum(spend) as spend

from tmp_skb a
inner join
(select economy_date, user_uid, -1*sum(amount) as spend from ztrack.s_zt_economy where game_id = 118 and sn_id = 1 and client_id = 1 and economy_date::date between '$startdate$' and '$enddate$'
and currency = 'cash' and currency_flow like '%paid_spend%' and amount < 0
and total_amount<=5000
group by 1,2) b
on a.date=b.counter_date
and a.user_uid = b.user_uid
and a.metric='final_list'
group by 1, 2 ;

