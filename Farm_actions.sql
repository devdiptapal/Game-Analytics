select week(counter_date::date),kingdom,count(distinct user_uid) as users, count(*) as actions
from s_zt_count
where game_id=118
and counter='farm_action'
and kingdom in ('fertilizer','speedfeed','feed')
and sample_rate=100
and counter_date between '2016-01-03' and '2016-10-09'
group by 1,2;