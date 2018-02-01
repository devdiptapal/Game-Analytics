
select date,
(case when logins between 0 and 10 then 'low'
      when logins between 11 and 20 then 'mid'
      when logins between 21 and 30 then 'high'
      else end) as 'engagement',
      (case when stu > 5 then '10 min'
      when stu between 5 and 20 then '5-20 min'
      when stu > 20 then '20+ min'
      else 'disengaged' end) as sessiontime,
      count(distinct user_uid) from



(select a.date, a.user_uid, stu, count(distinct b.date) as logins from

(select date::date as date, 
 user_uid, stu
from
(select  date(start_timestamp) as date, user_uid,
max(datediff(minute,start_timestamp,end_timestamp)) as stu

        from s_zt_session 
        where game_id =118
        and sn_id in (1,104)
	and client_id in (1,6)
        and date(start_timestamp) between '$start$' and '$end$'
        group by 1,2
       ) as x

order by 1) as a

inner join 

(select distinct dau_date::date as date, user_uid
from s_zt_dau
where game_id=118
and dau_date between '$start$'::date-30 and '$end$') as b

on a.user_uid=b.user_uid
and b.date between a.date::date-30 and a.date::date-1

group by 1,2,3) as n

group by 1,2,3;

