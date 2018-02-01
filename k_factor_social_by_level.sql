commit;
  --cohort dau
  
insert /*+direct*/ into tmp_skb
(  user_uid, date, value, metric)
select user_uid, min(stat_date::date), max(level), 'dau_cohort'
from v_user_day
where game_id in  ($gameid$)
and sn_id in  ($snid$)
and client_id in ($clientid$)
and stat_date::date between '$startdate$' and '$enddate$'
group by 1
having max(level) between $minlevel$ and $maxlevel$
;



insert /*+direct*/ into tmp_skb
(user_uid, date, metric2, metric)
select distinct from_uid, dau_date::date, user_uid, 'dau_referrals'
from ztrack.s_zt_dau
where game_id in  ($gameid$)
and sn_id in  ($snid$)
and client_id in ($clientid$)
and source is not null
and dau_date::date  between '$startdate$' and '$enddate$'::date+90
and from_uid is not null
and from_uid <> 0
and user_uid is not null
;


insert into tmp_skb(user_uid, metric)
select distinct a.user_uid, 'referrers'
from tmp_skb a
inner join
tmp_skb b
on a.user_uid= b.user_uid
and b.date between a.date and a.date+$days$
and a.metric='dau_cohort' and b.metric='dau_referrals'
;

insert into tmp_skb_3(metric2, metric)
select distinct b.metric2, 'referrees+'
from tmp_skb a
inner join
tmp_skb b
on a.user_uid= b.user_uid
and b.date between a.date and a.date+$days$
and a.metric='dau_cohort' and b.metric='dau_referrals';

insert into tmp_skb_3 (metric2,metric)
select distinct metric2, 'referees-' from tmp_skb_3 where metric = 'referrees+' 
and metric2 not in (select user_uid from tmp_skb where metric='referrers');

select count(distinct user_uid) from tmp_skb where metric='dau_cohort';


select count(distinct user_uid) from tmp_skb where metric='referrers';

select count(distinct metric2) from tmp_skb_3 where metric='referees-';
