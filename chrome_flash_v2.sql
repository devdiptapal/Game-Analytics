

--view
select phylum, count(distinct a.user_uid) from

(select distinct
  phylum,counter_date+counter_time as date,  user_uid
  from s_zt_count
where game_id=118
and kingdom in ('open','view')
and (phylum like '%d_browser_support%' or kingdom like '%d_browser_support%' or class like '%d_browser_support%')
and counter_date+counter_time between '2017-01-04 02:10'  and '2017-01-09 23:59:59' 
group by 1,2,3) a
inner join
(select distinct
  user_uid
  from s_zt_count
where game_id=118
and kingdom in ('open','view')
and (phylum not like '%d_browser_support_incent%')
and counter_date+counter_time < '2017-01-04 02:10'
) c
on a.user_uid=c.user_uid
group by 1;



-- came back into the game



select phylum, count(distinct a.user_uid) from

(select distinct
  phylum,counter_date+counter_time as date,  user_uid
  from s_zt_count
where game_id=118
and kingdom in ('open','view')
and (phylum like '%d_browser_support%' or kingdom like '%d_browser_support%' or class like '%d_browser_support%')
and counter_date+counter_time between '2017-01-04 02:10'  and '2017-01-09 23:59:59' 
group by 1,2,3) a
inner join
(select dau_date+dau_time as date, user_uid from s_zt_dau where game_id=118
and dau_date+dau_time between '2017-01-04 02:10'  and '2017-01-09 23:59:59' ) b

on a.user_uid=b.user_uid
and a.date <  b.date

inner join

(select distinct
  user_uid
  from s_zt_count
where game_id=118
and kingdom in ('open','view')
and (phylum not like '%d_browser_support_incent%')
and counter_date+counter_time < '2017-01-04 02:10'
) c
on a.user_uid=c.user_uid

group by 1
;