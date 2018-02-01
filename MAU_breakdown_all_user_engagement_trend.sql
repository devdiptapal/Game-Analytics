
select
distinct ym, wlogins, count(distinct x.user_uid) , 'atype' from
---- y.level, y.latest_locale, 
--y.country, count(distinct x.user_uid) from
(select distinct a.ym, a.wlogins, a.user_uid from
(select (year(dau_date)*100+month(dau_date)) as ym,user_uid, count(distinct week(dau_date)) as wlogins from s_zt_dau where game_id=118 and dau_date between '2014-01-01' and '2016-06-30' group by 1,2) as a
inner join
(select (year(dau_date)*100+month(dau_date)) as ym,user_uid, count(distinct dau_date) as dlogins from s_zt_dau where game_id=118 and dau_date between '2014-01-01' and '2016-06-30'group by 1,2) as b
on 
a.user_uid = b.user_uid
and a.ym=b.ym
--where a.wlogins in (1)
--and b.dlogins in (1)
) x
inner join

(select * from
(select distinct user_uid,coalesce(level,1) as level,  latest_locale,country, rank() over (partition by user_uid order by stat_date desc) as rank from  
v_user_day where game_id=118  and user_uid is not null and stat_date between '2016-05-22' and '2016-06-18') as x
where rank=1
and level > $levelmin$) y

on x.user_uid=y.user_uid
group by 1,2
;
