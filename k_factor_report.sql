commit;
  --cohort dau
  
insert /*+direct*/ into tmp_skb
( game_id, sn_id, client_id, user_uid, date, metric2, metric)
select distinct game_id, sn_id, client_id, user_uid, dau_date::date, source, 'dau_cohort'
from ztrack.s_zt_dau
where game_id in  ($gameid$)
and sn_id in  ($snid$)
and client_id in ($clientid$)
and source is not null
and dau_date::date between '$startdate$' and '$enddate$'
;


--alternate dau
insert /*+direct*/ into tmp_skb
(game_id, sn_id, client_id, user_uid, date,value, metric)
select distinct game_id, sn_id, client_id,from_uid as user_uid,  dau_date as date,user_uid, 'dau'
from s_zt_dau
where game_id in  ($gameid$)
and sn_id in  ($snid$)
and client_id in ($clientid$)
and dau_date::date >= '$startdate$'
and from_uid is not null
and from_uid <> 0
and from_uid > 0
and user_uid is not null;
-- getting retention


select 
a.date::date as 'dau Date',
a.metric2 as 'dau Source',
count(distinct a.user_uid) as 'dau',
100.00*sum(case when b.user_uid is not null then 1 else 0 end)/count(distinct a.user_uid) as 'Total%',
100.00*sum(case when b.date::date - a.date::date = 0 then 1 else 0 end)/count(distinct a.user_uid) as 'd0%',
100.00*sum(case when b.date::date - a.date::date = 1 then 1 else 0 end)/count(distinct a.user_uid) as 'd1%',
100.00*sum(case when b.date::date - a.date::date = 2 then 1 else 0 end)/count(distinct a.user_uid) as 'd2%',
100.00*sum(case when b.date::date - a.date::date = 3 then 1 else 0 end)/count(distinct a.user_uid) as 'd3%',
100.00*sum(case when b.date::date - a.date::date = 4 then 1 else 0 end)/count(distinct a.user_uid) as 'd4%',
100.00*sum(case when b.date::date - a.date::date = 5 then 1 else 0 end)/count(distinct a.user_uid) as 'd5%',
100.00*sum(case when b.date::date - a.date::date = 6 then 1 else 0 end)/count(distinct a.user_uid) as 'd6%',
100.00*sum(case when b.date::date - a.date::date = 7 then 1 else 0 end)/count(distinct a.user_uid) as 'd7%',
100.00*sum(case when b.date::date - a.date::date = 8 then 1 else 0 end)/count(distinct a.user_uid) as 'd8%',
100.00*sum(case when b.date::date - a.date::date = 9 then 1 else 0 end)/count(distinct a.user_uid) as 'd9%',
100.00*sum(case when b.date::date - a.date::date = 10 then 1 else 0 end)/count(distinct a.user_uid) as 'd10%',
100.00*sum(case when b.date::date - a.date::date = 11 then 1 else 0 end)/count(distinct a.user_uid) as 'd11%',
100.00*sum(case when b.date::date - a.date::date = 12 then 1 else 0 end)/count(distinct a.user_uid) as 'd12%',
100.00*sum(case when b.date::date - a.date::date = 13 then 1 else 0 end)/count(distinct a.user_uid) as 'd13%',
100.00*sum(case when b.date::date - a.date::date = 14 then 1 else 0 end)/count(distinct a.user_uid) as 'd14%',
100.00*sum(case when b.date::date - a.date::date = 15 then 1 else 0 end)/count(distinct a.user_uid) as 'd15%',
100.00*sum(case when b.date::date - a.date::date = 16 then 1 else 0 end)/count(distinct a.user_uid) as 'd16%',
100.00*sum(case when b.date::date - a.date::date = 17 then 1 else 0 end)/count(distinct a.user_uid) as 'd17%',
100.00*sum(case when b.date::date - a.date::date = 18 then 1 else 0 end)/count(distinct a.user_uid) as 'd18%',
100.00*sum(case when b.date::date - a.date::date = 19 then 1 else 0 end)/count(distinct a.user_uid) as 'd19%',
100.00*sum(case when b.date::date - a.date::date = 20 then 1 else 0 end)/count(distinct a.user_uid) as 'd20%',
100.00*sum(case when b.date::date - a.date::date = 21 then 1 else 0 end)/count(distinct a.user_uid) as 'd21%',
100.00*sum(case when b.date::date - a.date::date = 22 then 1 else 0 end)/count(distinct a.user_uid) as 'd22%',
100.00*sum(case when b.date::date - a.date::date = 23 then 1 else 0 end)/count(distinct a.user_uid) as 'd23%',
100.00*sum(case when b.date::date - a.date::date = 24 then 1 else 0 end)/count(distinct a.user_uid) as 'd24%',
100.00*sum(case when b.date::date - a.date::date = 25 then 1 else 0 end)/count(distinct a.user_uid) as 'd25%',
100.00*sum(case when b.date::date - a.date::date = 26 then 1 else 0 end)/count(distinct a.user_uid) as 'd26%',
100.00*sum(case when b.date::date - a.date::date = 27 then 1 else 0 end)/count(distinct a.user_uid) as 'd27%',
100.00*sum(case when b.date::date - a.date::date = 28 then 1 else 0 end)/count(distinct a.user_uid) as 'd28%',
100.00*sum(case when b.date::date - a.date::date = 29 then 1 else 0 end)/count(distinct a.user_uid) as 'd29%',
100.00*sum(case when b.date::date - a.date::date = 30 then 1 else 0 end)/count(distinct a.user_uid) as 'd30%',
sum(case when b.user_uid is not null then 1 else 0 end) as total,
sum(case when b.date::date - a.date::date = 0 then 1 else 0 end) as d0,
sum(case when b.date::date - a.date::date = 1 then 1 else 0 end) as d1,
sum(case when b.date::date - a.date::date = 2 then 1 else 0 end) as d2,
sum(case when b.date::date - a.date::date = 3 then 1 else 0 end) as d3,
sum(case when b.date::date - a.date::date = 4 then 1 else 0 end) as d4,
sum(case when b.date::date - a.date::date = 5 then 1 else 0 end) as d5,
sum(case when b.date::date - a.date::date = 6 then 1 else 0 end) as d6,
sum(case when b.date::date - a.date::date = 7 then 1 else 0 end) as d7,
sum(case when b.date::date - a.date::date = 8 then 1 else 0 end) as d8,
sum(case when b.date::date - a.date::date = 9 then 1 else 0 end) as d9,
sum(case when b.date::date - a.date::date = 10 then 1 else 0 end) as d10,
sum(case when b.date::date - a.date::date = 11 then 1 else 0 end) as d11,
sum(case when b.date::date - a.date::date = 12 then 1 else 0 end) as d12,
sum(case when b.date::date - a.date::date = 13 then 1 else 0 end) as d13,
sum(case when b.date::date - a.date::date = 14 then 1 else 0 end) as d14,
sum(case when b.date::date - a.date::date = 15 then 1 else 0 end) as d15,
sum(case when b.date::date - a.date::date = 16 then 1 else 0 end) as d16,
sum(case when b.date::date - a.date::date = 17 then 1 else 0 end) as d17,
sum(case when b.date::date - a.date::date = 18 then 1 else 0 end) as d18,
sum(case when b.date::date - a.date::date = 19 then 1 else 0 end) as d19,
sum(case when b.date::date - a.date::date = 20 then 1 else 0 end) as d20,
sum(case when b.date::date - a.date::date = 21 then 1 else 0 end) as d21,
sum(case when b.date::date - a.date::date = 22 then 1 else 0 end) as d22,
sum(case when b.date::date - a.date::date = 23 then 1 else 0 end) as d23,
sum(case when b.date::date - a.date::date = 24 then 1 else 0 end) as d24,
sum(case when b.date::date - a.date::date = 25 then 1 else 0 end) as d25,
sum(case when b.date::date - a.date::date = 26 then 1 else 0 end) as d26,
sum(case when b.date::date - a.date::date = 27 then 1 else 0 end) as d27,
sum(case when b.date::date - a.date::date = 28 then 1 else 0 end) as d28,
sum(case when b.date::date - a.date::date = 29 then 1 else 0 end) as d29,
sum(case when b.date::date - a.date::date = 30 then 1 else 0 end) as d30

from etl_temp.tmp_skb a
left outer join
etl_temp.tmp_skb b
on a.user_uid = b.user_uid 
and a.game_id = b.game_id
and a.sn_id = b.sn_id
and a.client_id = b.client_id
and a.user_uid = b.user_uid
and a.metric='dau_cohort' and b.metric='dau'
group by 1,2
order by 1,3 desc
;
