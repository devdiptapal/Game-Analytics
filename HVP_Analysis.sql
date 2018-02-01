
commit;

-- get high value payers who have paid in the last 90 days
-- High Value Payers

INSERT /*+ direct */ INTO etl_temp.tmp_skb (user_uid, date, metric)

select  distinct user_uid , date, 'high value payers' from
(SELECT  a.user_uid, a.dau_date::date as date, sum(b.amount) 
FROM 
(select distinct user_uid, dau_date::date from s_zt_dau where game_id=118 and dau_date::date  between  '$start$' and '$end$') a
JOIN 
(select distinct user_uid, date_trans, amount from report.v_payment where game_id=118 and date_trans::date  between  '$start$'::date - 30 and '$end$' ) b 
on 
b.user_uid=a.user_uid and
b.date_trans::date between a.dau_date::date-29 and a.dau_date::date
GROUP BY 1,2
having sum(amount) >= 20) as x
;




select date, count(distinct user_uid) from tmp_skb where metric= 'high value payers' group by 1;