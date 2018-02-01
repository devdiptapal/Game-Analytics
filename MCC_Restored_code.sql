commit;


--Pulls coop information
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric,value,date,metric5)
Select sn_id, user_uid, game_id, client_id,milestone,value,milestone_date,'coop'
from s_zt_milestone
where game_id=118
and milestone ilike '%coop'
;
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric5)
select sn_id,user_uid,game_id,client_id,'exclude'
from tmp_skb
where metric='leave_coop'
and metric5='coop'
and date between '$startdate$' and '$enddate$'
group by 1,2,3,4
;
--pulls coop information by coop ID to later join with experiment by coop ID.
INSERT /*+ direct*/ INTO etl_temp.tmp_skb_2(sn_id, user_uid, game_id, client_id,metric,value,date,value2,value3,value4,metric5,value5)
Select 1,value::int,118,1,case when milestone='leave_coop' then milestone else 'join_coop' end,value,milestone_date,sn_id,client_id,user_uid,'coop_alt',row_number() over(partition by sn_id,client_id,user_uid order by milestone_date)
from s_zt_milestone
where game_id=118
and milestone ilike '%coop'
group by 1,2,3,4,5,6,7,8,9,10,11
;
-- pulls experiment information
INSERT /*+ direct */ INTO etl_temp.tmp_exp_3 
SELECT  sn_id, game_id, client_id, user_uid, 0 as test_name, variant, start_timestamp
FROM s_zt_exp 
WHERE game_id =118 
and test_name in ('$testname$')
and start_timestamp::date between '$startdate$' and '$enddate$'
and variant is not null;

--Pulls experiment information by the person who created to coop to show which variant a coop member will see.
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric,value,metric5)
Select  1,a.value::int,a.game_id,1,a.metric,b.variant,'exp_c'
from etl_temp.tmp_skb a
left join etl_temp.tmp_exp_3 b
on a.sn_id=b.sn_id and a.client_id=b.client_id and a.game_id=b.game_id and a.user_uid=b.user_uid
where a.metric5='coop'
and a.metric='create_coop'
group by 1,2,3,4,5,6,7
;
--Joins experiment information with Coop Status to give users the correct variant per the coop they were a part of at the time.
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric,value,date,metric5,value3)
Select a.value2,a.value4,a.game_id,a.value3,a.metric,b.value,a.date,'combine',a.value5
from etl_temp.tmp_skb_2 a
left join  etl_temp.tmp_skb b
on a.sn_id=b.sn_id and a.client_id=b.client_id and a.game_id=b.game_id and a.user_uid=b.user_uid and b.metric5='exp_c'
left join etl_temp.tmp_skb ex
on a.sn_id=ex.sn_id and a.client_id=ex.client_id and a.game_id=ex.game_id and a.user_uid=ex.user_uid and ex.metric5='exclude'
where a.metric5='coop_alt'
and a.value2 in ($snid$) and a.value3 in ($clientid$)
and ex.user_uid is null
group by 1,2,3,4,5,6,7,8,9
;


--getting final list of users by variant at that time
select dau_date, value, count(distinct user_uid) from
(select distinct dau_date, user_uid, value from
(select dau_date::date,  a.user_uid, b.value, rank() over (partition by dau_date, a.user_uid order by b.date desc) as rank
from 
(select dau_date, user_uid from s_zt_dau  where game_id=118 and dau_date between '$startdate$' and '$enddate$' ) as a inner join
tmp_skb b
on a.user_uid=b.user_uid and b.metric5='combine' and b.date<=a.dau_date
order by 1,2) as x
where rank =1) as y
group by 1,2;