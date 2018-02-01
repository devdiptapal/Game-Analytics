commit;
INSERT /*+ direct */ INTO etl_temp.tmp_skb (sn_id, game_id, client_id, user_uid, metric)
SELECT sn_id, game_id, client_id, user_uid, 'payers'
FROM report.v_payment
WHERE game_id=118 and sn_id in ($snid$) and client_id in ($clientid$)
and user_uid%10=1
GROUP BY 1,2,3,4
;

-- High Value Payers
INSERT /*+ direct */ INTO etl_temp.tmp_skb (sn_id, game_id, client_id, user_uid, date, metric)
SELECT sn_id, game_id, client_id, user_uid, a.dateobj, 'high value payers'
FROM d_date a
JOIN report.v_payment b on b.date_trans::date between a.dateobj-29 and a.dateobj
WHERE dateobj between '$startdate$' and '$enddate$'

and game_id=118 and sn_id in ($snid$) and client_id in ($clientid$)
GROUP BY 1,2,3,4,5
having sum(amount) >= 20
;
--Pulls coop information
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric,value,date,metric5)
Select sn_id, user_uid, game_id, client_id,milestone,value,milestone_date,'coop'
from s_zt_milestone
where game_id=118
and user_uid%10=1
and milestone ilike '%coop'
;
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric5)
select sn_id,user_uid,game_id,client_id,'exclude'
from tmp_skb
where metric='leave_coop'
and metric5='coop'
and date between '$startdate$' and '$enddate$'
group by 1,2,3,4
;
--pulls coop information by coop ID to later join with experiment by coop ID.
INSERT /*+ direct*/ INTO etl_temp.tmp_skb_2(sn_id, user_uid, game_id, client_id,metric,value,date,value2,value3,value4,metric5,value5)
Select 1,value::int,118,1,case when milestone='leave_coop' then milestone else 'join_coop' end,value,milestone_date,sn_id,client_id,user_uid,'coop_alt',row_number() over(partition by sn_id,client_id,user_uid order by milestone_date)
from s_zt_milestone
where game_id=118
 and user_uid%10=1
and milestone ilike '%coop'
group by 1,2,3,4,5,6,7,8,9,10,11
;
-- pulls experiment information
INSERT /*+ direct */ INTO etl_temp.tmp_exp_3 
SELECT  sn_id, game_id, client_id, user_uid, 0 as test_name, variant, start_timestamp
FROM s_zt_exp 
WHERE game_id =118 
and test_name in ('$testname$')
and user_uid%10=1
and start_timestamp::date between '$startdate$' and '$enddate$'
and variant is not null;

--Pulls experiment information by the person who created to coop to show which variant a coop member will see.
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric,value,metric5)
Select  1,a.value::int,a.game_id,1,a.metric,b.variant,'exp_c'
from etl_temp.tmp_skb a
left join etl_temp.tmp_exp_3 b
on a.sn_id=b.sn_id and a.client_id=b.client_id and a.game_id=b.game_id and a.user_uid=b.user_uid
where a.metric5='coop'
and a.metric='create_coop'
group by 1,2,3,4,5,6,7
;
--Joins experiment information with Coop Status to give users the correct variant per the coop they were a part of at the time.
INSERT /*+ direct*/ INTO etl_temp.tmp_skb(sn_id, user_uid, game_id, client_id,metric,value,date,metric5,value3)
Select a.value2,a.value4,a.game_id,a.value3,a.metric,b.value,a.date,'combine',a.value5
from etl_temp.tmp_skb_2 a
left join  etl_temp.tmp_skb b
on a.sn_id=b.sn_id and a.client_id=b.client_id and a.game_id=b.game_id and a.user_uid=b.user_uid and b.metric5='exp_c'
left join etl_temp.tmp_skb ex
on a.sn_id=ex.sn_id and a.client_id=ex.client_id and a.game_id=ex.game_id and a.user_uid=ex.user_uid and ex.metric5='exclude'
where a.metric5='coop_alt'
and a.value2 in ($snid$) and a.value3 in ($clientid$)
and ex.user_uid is null
group by 1,2,3,4,5,6,7,8,9
;
--level
INSERT /*+ DIRECT */ into tmp_skb_2(metric,sn_id, game_id, client_id, user_uid,date,value)
select 'a_user',a.sn_id, a.game_id, a.client_id, a.user_uid,a.stat_date,max(isnull(level,1))
from a_user_day a
where a.game_id=118 and a.sn_id in ($snid$) and a.client_id in ($clientid$)
and stat_date between '$startdate$' and '$enddate$'
group by 1,2,3,4,5,6
;
-- DAU
--contains joins to limit to payer ot High value payers
--adds coop status information to dau data.  Causes duplicate records.  Row_number used to filter our duplicates
INSERT /*+ DIRECT */ into tmp_skb(metric5,sn_id, game_id, client_id, user_uid, date,date2,metric,value2,value)
SELECT  'dau2',a.sn_id, a.game_id, a.client_id, a.user_uid, dau_date,d.date,d.metric,d.value,row_number() over (partition by a.sn_id, a.game_id, a.client_id, a.user_uid, dau_date order by d.date desc)
FROM s_zt_dau a
 JOIN tmp_skb b on a.client_id = b.client_id and a.user_uid = b.user_uid and a.sn_id = b.sn_id and a.game_id = b.game_id and b.metric = 'payers'
JOIN tmp_skb c on a.client_id = c.client_id and a.user_uid = c.user_uid and a.sn_id = c.sn_id and a.game_id = c.game_id and a.dau_date = c.date::date and c.metric = 'high value payers'
left join tmp_skb d on a.client_id = d.client_id and a.user_uid = d.user_uid and a.sn_id = d.sn_id and a.game_id = d.game_id and d.date<=dau_date and d.metric5='combine'
inner JOIN tmp_skb_2 e on e.game_id = a.game_id and e.sn_id = a.sn_id and e.client_id = a.client_id and e.user_uid = a.user_uid and e.date=a.dau_date
left join etl_temp.tmp_skb ex
on a.sn_id=ex.sn_id and a.client_id=ex.client_id and a.game_id=ex.game_id and a.user_uid=ex.user_uid and ex.metric5='exclude'
WHERE a.game_id=118 and a.sn_id in ($snid$) and a.client_id in ($clientid$)
and dau_date between '$startdate$' and '$enddate$'::date + 30
and ex.user_uid is null
group by 1,2,3,4,5,6,7,8,9
;
--Removes duplication from joining coop status data to DAu, also determines first DAU during experiment time
INSERT /*+ DIRECT */ into tmp_skb(metric5,sn_id, game_id, client_id, user_uid, date,metric,value2,value)
Select 'dau' ,sn_id, game_id, client_id, user_uid, date,metric,value2,row_number() over (partition by sn_id, game_id, client_id, user_uid order by date)
from tmp_skb
where metric5='dau2'
and value=1

;



    SELECT idate entry_date, variant,case when actions ilike '%leave%' then 'Left Variant' else case when variant = checks then 'Variant population' else 'Joined other variant' end end,
    sum(case when ddiff = 0 or ddiff is null then cnt else 0 end) users,
    sum(case when ddiff = 1 then cnt else 0 end) day1,
    sum(case when ddiff = 2 then cnt else 0 end) day2,
    sum(case when ddiff = 3 then cnt else 0 end) day3,
    sum(case when ddiff = 4 then cnt else 0 end) day4,
    sum(case when ddiff = 5 then cnt else 0 end) day5,
    sum(case when ddiff = 6 then cnt else 0 end) day6,
    sum(case when ddiff = 7 then cnt else 0 end) day7,
  sum(case when ddiff = 8 then cnt else 0 end) day8,
    sum(case when ddiff = 9 then cnt else 0 end) day9,
    sum(case when ddiff = 10 then cnt else 0 end) day10,
    sum(case when ddiff = 11 then cnt else 0 end) day11,
    sum(case when ddiff = 12 then cnt else 0 end) day12,
    sum(case when ddiff = 13 then cnt else 0 end) day13,
    sum(case when ddiff = 14 then cnt else 0 end) day14,
  sum(case when ddiff = 15 then cnt else 0 end) day15,
    sum(case when ddiff = 16 then cnt else 0 end) day16,
    sum(case when ddiff = 17 then cnt else 0 end) day17,
  sum(case when ddiff = 18 then cnt else 0 end) day18,
    sum(case when ddiff = 19 then cnt else 0 end) day19,
    sum(case when ddiff = 20 then cnt else 0 end) day20,
    sum(case when ddiff = 21 then cnt else 0 end) day21,
  sum(case when ddiff = 22 then cnt else 0 end) day22,
    sum(case when ddiff = 23 then cnt else 0 end) day23,
    sum(case when ddiff = 24 then cnt else 0 end) day24,
    sum(case when ddiff = 25 then cnt else 0 end) day25,
    sum(case when ddiff = 26 then cnt else 0 end) day26,
    sum(case when ddiff = 27 then cnt else 0 end) day27,
    sum(case when ddiff = 28 then cnt else 0 end) day28,
    sum(case when ddiff = 29 then cnt else 0 end) day29,  
    sum(case when ddiff = 30 then cnt else 0 end) day30
    FROM 
    (
        SELECT  case when f.date::date <e.date::date then e.date::date else f.date::date end  idate, e.value as variant,d.value2 as checks,d.metric as actions,
        datediff( 'day', case when f.date::date <e.date::date then e.date::date else f.date::date end, d.date) ddiff,
        count(distinct d.user_uid) cnt
        FROM tmp_skb e
        inner JOIN tmp_skb d on e.game_id = d.game_id and e.sn_id = d.sn_id and e.client_id = d.client_id and e.user_uid = d.user_uid and d.metric5='dau'  
        LEFT JOIN tmp_skb f on e.game_id = f.game_id and e.sn_id = f.sn_id and e.client_id = f.client_id and e.user_uid = f.user_uid and f.metric5='dau'  and f.value=1
--        inner JOIN tmp_skb_2 c on d.game_id = c.game_id and d.sn_id = c.sn_id and d.client_id = c.client_id and d.user_uid = c.user_uid and d.date::date=c.date::date and c.value >=$minlevel$ and c.metric='a_user'
        where e.metric5='combine'
        and e.value3=1
        and case when f.date::date <e.date::date then e.date::date else f.date::date end<=current_date-$day$
        
        GROUP BY 1,2,3,4,5
    ) a
    where variant is not null
    and idate is not null
    and idate between '$startdate$' and '$enddate$'
    and variant = checks
    and actions ilike '%join%'
    GROUP BY 1,2,3
    order by 1 desc,2,3
limit 2000 
;