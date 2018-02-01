select a.date,  count(distinct a.user_uid) from
(select distinct install_date::date as date, user_uid 
from (select sn_id, game_id, client_id, user_uid, min(install_date) 
"install_date" from ztrack.s_zt_install where game_id = 118 group by 1,2,3,4) A 
where install_date >= '2016-07-01' order by 1,2
 ) a
inner join
(select distinct message_date::date as date, user_uid from s_zt_message where subcategory like '%bookmark%' and game_id=118
and date(message_date) between '$start$'::date+$days$ and '$end$'::date+$days$) b

on b.date= a.date+$days$
and a.user_uid=b.user_uid

group by 1;
