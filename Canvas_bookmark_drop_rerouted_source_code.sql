select source, 
 count(distinct a.user_uid) from

(select distinct a.user_uid  from
(select distinct user_uid from
 s_zt_dau 
where game_id=118
and dau_date between '2016-11-01' and '2016-11-30'
and source like '%canvas_bookmark%'
) a
left join
(select 
user_uid from s_zt_dau 
where game_id=118
and dau_date between '2016-12-01' and '2016-12-31'
and source like '%canvas_bookmark%'
--and affiliate like '%favorite%'
)b
on a.user_uid=b.user_uid
where b.user_uid is null) as a
inner join

(select  distinct
source, user_uid from s_zt_dau 
where game_id=118
and dau_date between '2016-12-01' and '2016-12-31') as b
on a.user_uid=b.user_uid

group by 1;



