

commit;

insert into tmp_skb (user_uid,value,value2,metric)
select distinct user_uid,date_part('week',date(counter_date)),count(distinct date(counter_Date)),'spin_week' from s_zt_count where  kingdom='free_bonus' 
and game_id=5002366 and counter_date>='2015-11-01' group by 1,2 ;
 
 
 --engagnement bucket wheel
 insert into tmp_skb (user_uid,value,value2,metric2, metric)
  select user_uid,value as week,value2,case when value2 <=2 then 'Low' 
                    when value2>2 and value2<=5 then 'Med'
                    when value2>5 then 'High' end as engagement_game,'engage_buck_wheel' from tmp_skb where metric='spin_week' ;
 
 
 -- Game dau for spinners
insert into tmp_skb (user_uid,value,value2,metric)
select distinct user_uid, date_part('week',date(dau_Date)),count(distinct date(dau_Date)),'spinners_dau_Game' from s_zt_dau where game_id=5002366 and user_uid in
 (select distinct user_uid from tmp_skb where metric='spin_week') and dau_date>='2015-11-01' group by 1,2;
 
 --engagement bucket game
 insert into tmp_skb (user_uid,value,value2,metric2, metric)
  select user_uid,value as week,value2,case when value2 <=2 then 'Low' 
                    when value2>2 and value2<=5 then 'Med'
                    when value2>5 then 'High' end as engagement_game,'engage_buck_game' as players from tmp_skb where metric='spinners_dau_Game' ;
 
 
 @set maxrows 999999999;
@export on;
@export set filename="C:\Work\Krishnan KT\Adhoc\15. Daily wheel\user_level_Weekly_engagement_hititrich.csv" 
CsvColumnDelimiter = ",";

 select a.value as week ,a.metric2 as game_engagement,b.metric2 as wheel_engagement, count(distinct a.user_uid) from
        (select * from tmp_skb where metric='engage_buck_game') as a
        left join
        (select * from tmp_skb where metric='engage_buck_wheel') as b
        on a.user_uid=b.user_uid and a.value=b.value
        group by 1,2,3;
@export off;
 