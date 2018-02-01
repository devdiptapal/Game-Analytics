

insert into etl_temp.tmp_skb ( date, user_uid, metric)
select distinct dau_date::date, user_uid, 'bookmark'
from s_zt_dau
where game_id = 118
and source= 'bookmark'
and dau_date between '$start$' and '$end$';



insert into etl_temp.tmp_skb (date, user_uid, value, metric)
select a.date, a.user_uid, count(distinct b.date) as pre_logins, 'pre'
from etl_temp.tmp_skb a
inner join 
(select  distinct dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date - 13 and '$end$'::date) as b
on a.user_uid = b.user_uid

and a.metric= 'bookmark'
and b.date between a.date - 13 and a.date - 7
group by 1,2 ;



insert into etl_temp.tmp_skb ( date, user_uid, value, metric)
select a.date, a.user_uid, count(distinct b.date) as post_logins, 'post'
from etl_temp.tmp_skb a
inner join 
(select dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date - 13 and '$end$'::date ) as b
on a.user_uid = b.user_uid
and a.metric= 'bookmark'
and b.date between a.date - 6 and a.date
group by 1,2;

select date, type,  count(distinct user_uid) as users
from
(select a.date, a.user_uid, 
case when (a.value in (6,7) and b.value in (6,7)) then 'H constant' 
     when (a.value in (6,7) and b.value in (3,4,5)) then 'H-M' 
     when (a.value in (6,7) and b.value in (1,2)) then 'H-L' 
     when (a.value  in (3,4,5) and b.value in (6,7)) then 'M-H' 
     when (a.value in (3,4,5) and b.value in (3,4,5)) then 'M constant' 
     when (a.value in (3,4,5) and b.value in (1,2)) then 'M-L' 
     when (a.value in (1,2) and b.value in (6,7)) then 'L-H'
     when (a.value in (1,2) and b.value in (3,4,5)) then 'L-M'
     when (a.value in (1,2) and b.value in (1,2)) then 'L constant'
       when (a.value in (6,7) and b.value in (0)) then 'H-LAPSE'
       when (a.value in (3,4,5) and b.value in (0)) then 'M-LAPSE'
        when (a.value in (1,2) and b.value in (0)) then 'L-LAPSE'
         END as type


        from
    etl_temp.tmp_skb a
    inner join
    etl_temp.tmp_skb b
    on a.user_uid=b.user_uid
    and a.date=b.date
    and a.metric='pre'
    and b.metric= 'post'  )  as x
    group by 1,2 ;
        