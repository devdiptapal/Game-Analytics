commit;
  --cohort dau
  
insert /*+direct*/ into tmp_skb
(  user_uid, date, metric)
select user_uid, min(dau_date::date),  'dau_cohort'
from ztrack.s_zt_dau
where game_id in  ($gameid$)
and sn_id in  ($snid$)
and client_id in ($clientid$)
and source is not null
and dau_date::date between '$startdate$' and '$enddate$'
group by 1
;

insert /*+direct*/ into tmp_skb
(user_uid, date, metric2, metric)
select distinct from_uid, dau_date::date, user_uid, 'dau_referrals'
from ztrack.s_zt_dau
where game_id in  ($gameid$)
and sn_id in  ($snid$)
and client_id in ($clientid$)
and source is not null
and dau_date::date >= '$startdate$'
and from_uid is not null
and from_uid <> 0
and user_uid is not null
;

select percentile_cont(0.50) within group(order by nodes) as p75,
from
(select 
a.user_uid, count(distinct b.metric2) as nodes
from tmp_skb a
inner join
tmp_skb b
on a.user_uid= b.user_uid
and b.date between a.date and a.date+$days$
and a.metric='dau_cohort' and b.metric='dau_referrals'
group by 1) as x;