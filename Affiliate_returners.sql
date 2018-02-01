


select affiliate, count(distinct a.user_uid) as users

from

(SELECT distinct  user_uid 
FROM v_user_day
WHERE game_id = 118 
and stat_date between '$startdate$' and '$enddate$'
and datediff('day',preceding_date,stat_date) > $days$
) a 
inner join 
(select * from
(select affiliate, user_uid, rank() over (partition by user_uid order by dau_date desc) as rank from s_zt_dau 
where game_id=118
and dau_date between '$startdate$' and '$enddate$')x
where rank=1) b

on a.user_uid=b.user_uid

group by 1
having count(distinct a.user_uid)>=200;