select wk1 as install_date, wk2 as dau_presence, count(distinct x.user_uid)
from

(select distinct (year(dau_date)*100 + week(dau_date)) as wk2,user_uid
from s_zt_dau
where game_id=118
and user_uid is not null
and dau_date >='2015-09-01') as x

right join

(select distinct min((year(milestone_date)*100 + week(milestone_date))) as wk1, user_uid
from ztrack.s_zt_milestone
where game_id = 118
        and milestone_date >= '2015-09-01'
        and milestone = 'extension_installed'
group by 2)as a

on x.user_uid=a.user_uid

where 
wk2 >= wk1

group by 1,2;