
select distinct logins, count(distinct a.user_uid)  from
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
group by 1;