select counter_date, count(*), count(distinct user_uid)
from
s_zt_count
where game_id=118
and counter = 'xp_grants'
and kingdom = 'finished_visit'
and genus = 'visit_friend'
and counter_date between '$startdate$' and '$enddate$'
group by 1
;