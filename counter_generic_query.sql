

select kingdom, count(distinct user_uid) as users, count(*) as actions
from s_zt_count 
where game_id=118
and counter like '$ctr$'
and kingdom like '$kdm$'
and phylum like '$plm$'
and class like '$clss$'
and counter_date between '2016-12-12' and '2016-12-18' group by 1;
