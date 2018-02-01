

insert into etl_temp.tmp_skb ( date, user_uid, metric)
select distinct dau_date::date, user_uid, 'bookmark'
from s_zt_dau
where game_id = 118
and dau_date between '$start$' and '$end$';

insert into etl_temp.tmp_skb (date, user_uid, metric)
select a.date, a.user_uid, 'week'
from etl_temp.tmp_skb a
inner join 

(select  distinct dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date - 21 and '$end$'::date) as b

on a.user_uid = b.user_uid

and a.metric= 'bookmark'
and b.date between a.date - 6 and a.date
group by 1,2 ;

insert into etl_temp.tmp_skb (date, user_uid, metric)
select a.date, a.user_uid, 'week-1'
from etl_temp.tmp_skb a
inner join 

(select  distinct dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date - 21 and '$end$'::date) as b

on a.user_uid = b.user_uid

and a.metric= 'bookmark'
and b.date between a.date - 13 and a.date - 7


group by 1,2 ;



insert into etl_temp.tmp_skb ( date, user_uid, vmetric)
select a.date, a.user_uid, 'week-2'
from etl_temp.tmp_skb a
inner join 
(select dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date -21 and '$end$'::date ) as b
on a.user_uid = b.user_uid
and a.metric= 'bookmark'
and b.date between a.date - 20 and a.date - 14
group by 1,2;

insert into etl_temp.tmp_skb ( date, user_uid, vmetric)
select distinct a.date, a.user_uid, 'week-12'
from
etl_temp.tmp_skb a
inner join
etl_temp.tmp_skb b
on a.user_uid= b.user_uid
and a.date = b.date
and a.metric='week-1'
and b.metric='week-2';


select distinct a.date, count( distinct a.user_uid),sum(case when b.user_uid is not null then 1 else 0)
from
etl_temp.tmp_skb a
left join
etl_temp.tmp_skb b
on a.user_uid= b.user_uid
and a.date = b.date
and a.metric='week-12'
and b.metric='week'
group by 1;


