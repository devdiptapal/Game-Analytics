

select distinct a.user_uid, keys_earned
, level_1 
from 
( select distinct user_uid from s_zt_count
where 
game_id=118 and
counter='christmas_book'
and kingdom='complete_tradition'
and phylum='christmas_book'
and class like '12_%')a
inner join


( select  user_uid, sum(class) as keys_earned from s_zt_count
where 
game_id=118 and
counter='christmas_book'
and kingdom='earn_keys'
and phylum='christmas_book'
group by 1) b
on a.user_uid=b.user_uid

inner join
( select  user_uid, max(class) as level_1 from s_zt_count
where 
game_id=118 and
counter='christmas_book'
and kingdom='level_up_kf'
and phylum='christmas_book'
group by 1) c
on a.user_uid=c.user_uid
group by 1,2,3
;