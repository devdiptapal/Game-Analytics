

insert into etl_temp.tmp_skb (metric,user_uid)
select distinct 'x3', user_uid from s_zt_dau
where dau_date between '2016-03-01' and '2016-03-27'
and game_id > 0
and game_id=118;

select count(distinct a.user_uid), count (distinct b.user_uid)
from etl_temp.tmp_skb a
inner join
(select user_uid from (
select user_uid, count(distinct game_id) from s_zt_dau
where dau_date between '2016-03-01' and '2016-03-27'
and game_id > 0
group by 1
having count(distinct game_id) > 1) as x)as b
on a.user_uid=b.user_uid
and a.metric='x2'
where a.user_uid is not null
and b.user_uid is not null;