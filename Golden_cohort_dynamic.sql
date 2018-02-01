select date, count(distinct user_uid) as gc_active , avg(amount)  as gc_rev from

(select a.date,  b.user_uid, sum(amount) as amount, count(*) from

(select dateobj::date as date from d_date where dateobj between '$start$' and '$end$') as a
inner join
(select date_trans::date as date, user_uid, amount from report.v_payment where game_id=118
and date_trans::date between '$start$'::date-29 and '$end$') as b

on b.date between a.date::date - 29 and a.date
group by 1,2 
having sum(amount) >= 15
and count(*) >=2 
) as n

group by 1;