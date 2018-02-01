
select user_uid, avg(datediff(day,date1,date2)) from

(select a.user_uid, a.milestone_date as date1, b.milestone_date as date2, a.value as lvl1, b.value as lvl2 from s_zt_milestone a
 inner join
  s_zt_milestone b on a.user_uid=b.user_uid and a.milestone_date < b.milestone_date and cast(b.value as decimal(10,0))= cast(a.value as decimal (10,0))+1 
  where 
  a.game_id=118
and a.client_id=1
and a.sn_id=1 and
 b.game_id=118
and b.client_id=1
and b.sn_id=1
and cast(b.value as decimal(10,0)) between $level_min$  and  $level_max$
and cast(a.value as decimal(10,0)) between $level_min$  and  $level_max$
and a.milestone='level_up'
and b.milestone= 'level_up'
and a.user_uid=10153980650345802)as x
group by 1;