select a.date, country, count(distinct a.user_uid), sum(clicks) from

(select country, stat_date::date as date, user_uid from v_user_day where game_id=118 and stat_date::date between '$start$' and '$end$') a
inner join

(select counter_date as date,user_uid , count (*) as clicks from s_zt_count
where game_id=118 and kingdom='bookmark' and counter='click_tracking'
and counter_date between '$start$' and '$end$'
group by 1,2) b

on a.date=b.date
and a.user_uid=b.user_uid
group by 1,2;