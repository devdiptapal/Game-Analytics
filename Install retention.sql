-- install day cohort
select date, count(distinct n.user_uid) as users from
(select  min(install_date) as date,  user_uid from s_zt_install where game_id=118
 group by 2) as n where date  between '$start$' and '$end$' group by 1;


select date::date,count(distinct user_uid)
from (
  select sn_id, game_id,client_id,user_uid, install_timestamp
    ,min(install_timestamp) over (partition by sn_id, game_id,client_id,user_uid) as date
  from s_zt_install
  where game_id=118
) x
where date between '$start$' and '$end$'
group by 1
order by 1 desc;

-- d1 retention

select a.date, source,  count(distinct a.user_uid) from
(select distinct date::date as date, user_uid
from (
  select sn_id, game_id,client_id,user_uid, install_timestamp
    ,min(install_timestamp) over (partition by sn_id, game_id,client_id,user_uid) as date
  from s_zt_install
  where game_id=118
) x
where date between '$start$' and '$end$'
group by 1,2) a
inner join
(select  distinct source, date(stat_date), user_uid from s_zt_dau where
game_id=118
and date(dau_date) between '$start$'::date+$days$ and '$end$'::date+$days$) b

on b.date= a.date+$days$
and a.user_uid=b.user_uid

group by 1,2;
