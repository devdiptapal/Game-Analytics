
insert into tmp_skb (date, user_uid, metric)
select distinct date(click_date), user_uid , 'a2u'
from s_zt_message_click
where game_id=118 --and family=385 --
--and genus like ('%1403898942%')--
and client_id =1 and sn_id =1 
and click_dt between '2016-01-01' and '2016-05-31'
and family in ('1763', '1764','1765','1766','1767','1768','1769','1770', '2210','2211','2315','2316') 
and channel in ('a2u');


select date::date, count(distinct user_uid) from tmp_skb where metric='a2u' group by 1;


select b.date::date, count(distinct b.user_uid) from
(select stat_date::date as date, user_uid from v_user_day where game_id=118 and stat_date::date between '2016-01-01' and '2016-06-30') as a
inner join
(select date, user_uid from tmp_skb where metric='a2u') as b
on a.date = b.date+ $days$
and a.user_uid=b.user_uid

group by 1;

