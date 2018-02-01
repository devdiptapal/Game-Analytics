commit;
insert into tmp_skb(user_uid,sn_id,client_id,metric)
select distinct useR_uid,sn_id,client_id,'payer' from 
report.v_payment where game_id=118 and sn_id=1 and client_id=1 and date_trans::date between date(current_date)-59 and current_date;

insert into tmp_skb (user_uid,sn_id,client_id,value,metric)
select distinct user_uid,sn_id,client_id, count(distinct date(dau_date)),'W-1' from 
s_Zt_dau where game_id =118 and date(dau_Date) between date(current_date)-7 and date(current_date)-1 and sn_id=1 and client_id=1 group by 1,2,3;

insert into tmp_skb (user_uid,sn_id,client_id,value,metric)
select distinct user_uid,sn_id,client_id, count(distinct date(dau_date)),'W-2' from 
s_Zt_dau where game_id =118 and date(dau_Date) between date(current_date)-14 and date(current_date)-8 and sn_id=1 and client_id=1 group by 1,2,3;

insert into tmp_skb(user_uid,sn_id,client_id,value,value2,metric)
select case when a.user_uid is null then b.user_uid else a.user_uid end, 
case when a.sn_id is null then b.sn_id else a.sn_id end,case when a.client_id is null then b.client_id else a.client_id end,
case when a.value is null then 0 else a.value end as 'W-1 days',
case when b.value is null then 0 else b.value end as 'W-2 days','dau'
from
(select * from tmp_skb where metric='W-1') a
full outer join
(select * from tmp_skb where metric='W-2') b
on a.user_uid=b.user_uid and a.client_id=b.client_id and a.sn_id=b.sn_id;

insert into tmp_skb(user_uid,sn_id,client_id,value,value2,metric2,metric)
select case when a.user_uid is null then b.user_uid else a.user_uid end, 
case when a.sn_id is null then b.sn_id else a.sn_id end,case when a.client_id is null then b.client_id else a.client_id end,
case when a.value is null then 0 else a.value end as 'W-1 days',
case when a.value2 is null then 0 else a.value2 end as 'W-2 days',
case when b.user_uid is null then 'non-payer' else 'payer' end as Payer,'dau2'
from
(select * from tmp_skb where metric='dau') a
full outer join
(select * from tmp_skb where metric='payer') b
on a.user_uid=b.user_uid and a.client_id=b.client_id and a.sn_id=b.sn_id;

insert into tmp_skb (user_uid, value,metric)
select to_uid, count(*),'exclude' from s_Zt_message where channel='$channel$' and status='d:provider success' and
        game_id=118 and to_uid not in 
                (select distinct user_uid from s_Zt_dau where game_id=118 and
                date(dau_Date) between date(current_date)-7 and date(current_date)-1  ) group by 1 having count(*)>5;

insert into tmp_skb (user_uid,sn_id,client_id,value,value2,metric2,metric)
select user_uid,sn_id,client_id,value as 'W1 days',value2 as 'W2 days',metric2,'dau4'
from tmp_skb where metric='dau2' and useR_uid not in 
        (Select distinct to_uid 
        from s_Zt_message where channel='$channel$' and status='d:provider success' and
        game_id=118 and message_date::date between date(current_date)-14 and date(current_date) ) and user_uid not in 
        (select distinct user_uid from tmp_skb where metric='exclude');

insert into tmp_skb(user_uid,value,value2,value3,metric2,metric3,metric4,metric)
select a.user_uid,a.zid,b.value as 'W1',b.value2 as 'W2',b.metric2 as 'payer', a.latest_locale,a.first_name,'final_list' from 
(select distinct user_uid,zid,latest_locale,first_name,'zid' from v_user where game_id=118 and sn_id=1 and client_id=1 ) a
inner join 
(select distinct user_uid,sn_id,client_id,value,value2,metric2 from tmp_skb where metric='dau4')b
on a.user_uid=b.user_uid;


 insert into etl_temp.tmp_skb (user_uid, value,metric)
 select a.user_uid, type, 'segment'
 
 from
 
 (select user_uid,type,
 count(*) as cnt
 
 from
 (select user_uid,
   (case when hour(dau_time) between 0 and 5 then 1
   when hour(dau_time) between 6 and 11 then 2
    when hour(dau_time) between 12 and 17 then 3
    when hour(dau_time) between 18 and 23 then 4 end) as type
   from s_zt_dau
   where game_id=118
   and client_id in (1,6)
and sn_id in (1,104)
and dau_date between '$start$' and '$end$') as x
  group by 1,2) as a
 
 inner join 
  
 ( select user_uid, max(cnt) as cnt
  from
   (select user_uid,type,
 count(*) as cnt
 
 from
 (select user_uid,
   (case when hour(dau_time) between 0 and 5 then 1
   when hour(dau_time) between 6 and 11 then 2
    when hour(dau_time) between 12 and 17 then 3
    when hour(dau_time) between 18 and 23 then 4 end) as type
   from s_zt_dau
   where game_id=118
   and client_id in (1,6)
and sn_id in (1,104)
and dau_date between '$start$' and '$end$') as x
  group by 1,2) as y
  group by 1) as b
  
  on a.user_uid=b.user_uid
  and a.cnt=b.cnt;


select zid, value as type, first_name from
(select distinct user_uid, x.zid,x.locale,x.first_name from
(select distinct  user_uid,value as zid,metric3 as 'locale',metric4 as 'first_name' 
from tmp_skb
where metric='final_list' and
      value3 >0 and
      value2 =0 and      
      metric2='payer') as x ) as a
left join
tmp_skb b
on a.user_uid = b.user_uid and b.metric='segment'
where value =4
 ;
 
 