select category, zid from 
(select distinct (case when logins <10 then 'low engaged' when logins between 10 and 20 then 'medium engaged'
when logins between 21 and 30 then 'high engaged' end) as category,  a.user_uid  from
(select distinct a.user_uid from
(select 
user_uid from s_zt_dau 
where game_id=118
and dau_date between '2016-11-01' and '2016-11-30'
and source like '%bookmark%'
and affiliate like '%favorite%'
) a
left join
(select 
user_uid from s_zt_dau 
where game_id=118
and dau_date between '2016-12-01' and '2016-12-14'
--and source like '%bookmark%'
--and affiliate like '%favorite%'
)b
on a.user_uid=b.user_uid
where b.user_uid is null) as a

inner join
( select user_uid,count(distinct dau_date) as logins 
from s_zt_dau 
where game_id=118 and dau_date between '2016-11-01' and '2016-11-30'
and source like '%bookmark%'
and affiliate like '%favorite%'
group by 1)b
on a.user_uid=b.user_uid
)a 
inner join
(select * from(select user_uid, zid , rank() over (partition by user_uid order by stat_date desc ) as rank 
from v_user_day
where game_id=118)as p where rank=1)b
on a.user_uid=b.user_uid
;