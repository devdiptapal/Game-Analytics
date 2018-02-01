


select distinct a.user_uid, milestone
from
tmp_skb as a
left join
(select distinct user_uid, milestone from
(select user_uid,milestone, rank() over (partition by user_uid order by (milestone_date+milestone_time) desc) as rank1
from s_zt_milestone
where milestone_date between '2016-02-01' and '2016-03-24'
and milestone like 'e_rare_buildable_racing_chinchilla_part%'
and game_id = 118) as x
where rank1=1) as b
on a.user_uid=b.user_uid
where a.metric='red';


insert into tmp_skb (user_uid,metric)
(select distinct(user_uid), 'red'
from s_zt_count
where game_id = 118
and counter = 'start_session'
and counter_date = '2016-03-24'
and counter_time between '12:00:00' and '15:30:00')



