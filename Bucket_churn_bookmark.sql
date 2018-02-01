

insert into etl_temp.tmp_skb ( date, user_uid, metric)
select dau_date::date, user_uid, 'bookmark'
from s_zt_dau
where game_id = 118
and source= 'bookmark'
and dau_date between '$start$' and '$end$';



insert into etl_temp.tmp_skb (date, user_uid, metric2, metric)
select distinct date, user_uid, 
case when pre_logins = 0 then 'LAPSE' when pre_logins in (1,2) then 'L' when pre_logins in (3,4,5) then 'M' when pre_logins in (6,7) then 'H' end, 'pre'
from
(select a.date, a.user_uid, count(distinct b.date) as pre_logins, 'pre'
from etl_temp.tmp_skb a
inner join 
(select dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date - 8 and '$end$'::date) as b
on a.user_uid = b.user_uid
and metric= 'bookmark'
and b.date between a.date - 6 and a.date
group by 1,2) as x;



insert into etl_temp.tmp_skb ( date, user_uid, metric2, metric)
select distinct date, user_uid, 
(case when post_logins = 0 then 'LAPSE' when post_logins in (1,2) then 'L' when post_logins in (3,4,5) then 'M' when post_logins in (6,7) then 'H'  end), 'post'
from
(select a.date, a.user_uid, count(distinct b.date) as post_logins
from etl_temp.tmp_skb a
inner join 
(select dau_date::date as date, user_uid from s_zt_dau where game_id = 118 and dau_date::date between '$start$'::date and '$end$'::date + 8 ) as b
on a.user_uid = b.user_uid
and metric= 'bookmark'
and b.date between a.date + 1 and a.date + 7
group by 1,2) as x;

select date, type,  count(distinct user_uid) as users
from
(select a.date, a.user_uid, 

case when (a.metric2 = 'H' and b.metric2 = 'H') then 'H constant' 
     when (a.metric2 = 'H' and b.metric2 = 'M') then 'H-M' 
     when (a.metric2 = 'H' and b.metric2 = 'L') then 'H-L' 
     when (a.metric2 = 'M' and b.metric2 = 'H') then 'M-H' 
     when (a.metric2 = 'M' and b.metric2 = 'M') then 'M constant' 
     when (a.metric2 = 'M' and b.metric2 = 'L') then 'M-L' 
     when (a.metric2 = 'L' and b.metric2 = 'H') then 'L-H'
     when (a.metric2 = 'L' and b.metric2 = 'M') then 'L-M'
     when (a.metric2 = 'L' and b.metric2 = 'L') then 'L-L'
       when (a.metric2 = 'H' and b.metric2 = 'LAPSE') then 'H-LAPSE'
       when (a.metric2 = 'M' and b.metric2 = 'LAPSE') then 'M-LAPSE'
        when (a.metric2 = 'L' and b.metric2 = 'LAPSE') then 'L-LAPSE'
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
        