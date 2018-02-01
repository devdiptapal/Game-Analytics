
commit;

insert into etl_temp.tmp_skb ( date,  metric)
select distinct dau_date::date, 'bookmark'
from s_zt_dau
where game_id = 118
and dau_date between '$start$' and '$end$';

insert into etl_temp.tmp_skb (date, user_uid, metric)
select a.date, b.user_uid, 'week'
from etl_temp.tmp_skb a
inner join 

(select  distinct dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and  dau_date::date  between '$start$'::date - 6 and '$end$'::date) as b

on b.date between a.date - 6 and a.date
and a.metric= 'bookmark'
and b.user_uid is not null
group by 1,2 ;

insert into etl_temp.tmp_skb (date, user_uid, metric2, metric)
select distinct date, user_uid, (case when logins between 1 and 2 then 'l' when logins between 3 and 5 then 'm' when logins between 6 and 7 then 'h' end), 'week1'
from
(select a.date, b.user_uid, count(distinct b.date) as logins
from etl_temp.tmp_skb a
inner join 

(select  distinct dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date - 13 and '$end$'::date and user_uid%10=1) as b

on b.date between a.date - 13 and a.date - 7
and a.metric= 'bookmark'
and b.user_uid is not null

group by 1,2) as x
 ;



insert into etl_temp.tmp_skb ( date, user_uid, metric)
select a.date, b.user_uid,  'week2'
from etl_temp.tmp_skb a
inner join 
(select dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date -20 and '$end$'::date ) as b
on b.date between a.date - 20 and a.date - 14
and a.metric= 'bookmark'
and b.user_uid is not null

group by 1,2;

insert into etl_temp.tmp_skb ( date, user_uid,metric2, metric)
select 

distinct a.date, a.user_uid,a.metric2,

 'weekcomb'
from
etl_temp.tmp_skb a
inner join
etl_temp.tmp_skb b
on a.user_uid= b.user_uid
and a.date = b.date
and a.metric='week1'
and b.metric='week2';


insert into etl_temp.tmp_skb ( date,metric2, value, metric)
select a.date, a.metric2, count(distinct a.user_uid) as overall , 'S1'
from
etl_temp.tmp_skb a
inner join
etl_temp.tmp_skb b
on a.date=b.date
and a.user_uid=b.user_uid
where a.metric='weekcomb'
and b.metric='week'
group by 1,2;

insert into etl_temp.tmp_skb ( date,metric2, value, metric)
select a.date, a.metric2, count(distinct a.user_uid) as overall , 'S2'
from
etl_temp.tmp_skb a
where a.metric='weekcomb'
group by 1,2;

Select distinct a.date::date , a.metric2, a.value, b.value
from
etl_temp.tmp_skb a
inner join
etl_temp.tmp_skb b
on a.date=b.date
and a.metric2=b.metric2
and  a.metric = 'S1'
and b.metric = 'S2'
order by 1;
