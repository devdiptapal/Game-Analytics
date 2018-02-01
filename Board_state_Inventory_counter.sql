
-- enter all for others avg(value) for calc

commit;

INSERT /*+ direct */ INTO tmp_skb (sn_id, game_id, client_id, user_uid, date, metric)
SELECT sn_id, game_id, client_id, user_uid, firstdate, 'installs'
FROM v_user
WHERE game_id = 118 and sn_id in ($snid$) and client_id in ($clientid$) 
and firstdate between '$startdate$' and '$enddate$'
GROUP BY 1,2,3,4,5;

INSERT /*+ direct */ INTO tmp_skb (sn_id, game_id, client_id, user_uid, date, metric
  -- ,metric2, value
)
SELECT 
  sn_id, game_id, client_id, user_uid, stat_date, 'reacts'
  -- , level, ROW_NUMBER() OVER(PARTITION BY sn_id, game_id, client_id, user_uid ORDER BY level DESC) 
FROM v_user_day
WHERE game_id = 118 and sn_id in ($snid$) and client_id in ($clientid$) 
and stat_date between '$startdate$' and '$enddate$'
and preceding_date < date(stat_date)-30
GROUP BY 1,2,3,4,5;

insert /*+ direct */ into tmp_count_sl  
  select sn_id, game_id, client_id, user_uid, counter_date, 
    counter
    , case when $depth$ >= 1 then kingdom else ' ' end
    , case when $depth$ >= 2 then phylum else ' ' end
    , case when $depth$ >= 3 then class else ' ' end
    , case when $depth$ >= 4 then family else ' ' end
    , case when $depth$ >= 5 then genus else ' ' end
    , round($calc$) 
 from 
    s_zt_count where game_id = 118 and sn_id in ($snid$) and client_id in ($clientid$) 
 and counter_date between '$startdate$' and '$enddate$'
 and counter = 'board_state'
 and kingdom in ('animal', 'animal_storage')
 and (class ilike '%adult_duck%' or class ilike '%adult_pheasant%' or class ilike '%adult_turkey%'
  or class ilike '%adult_peacock%' or class ilike '%adult_swan%' or class ilike '%adult_ostrich%'  )
 and class not like '%building%'
group by 1,2,3,4,5,6,7,8,9,10,11
;

-- anyone with a farm_action gets a 0
INSERT /*+ direct */ INTO tmp_count_sl (sn_id, user_uid, game_id, client_id, 
  stat_date, value
  )
SELECT  
    sn_id, user_uid, game_id, client_id,
    counter_date, 0

FROM
    s_zt_count
WHERE
    game_id = 118
    and sn_id in ($snid$) and client_id in ($clientid$) 
    AND counter_date BETWEEN  '$startdate$' and '$enddate$' 
    AND counter = 'farm_action'
GROUP BY 1,2,3,4,5,6
;

insert /*+ direct */ into tmp_skb(sn_id,user_uid,game_id,client_id,date,value,metric)
select a.sn_id,a.user_uid,a.game_id,a.client_id,a.stat_date,sum(a.value),'temp'
from
tmp_count_sl a
group by 1,2,3,4,5
;




insert /*+ direct */ into tmp_skb (sn_id, client_id, game_id, user_uid, value, metric)
select sn_id, client_id, game_id, user_uid, max(value::int), 'level'
from s_zt_milestone
where game_id = 118 and sn_id in ($snid$) and client_id in ($clientid$) 
 and milestone_date::date <= '$enddate$'
 and milestone = 'level_up'
group by 1,2,3,4
;

insert /*+ direct */ into tmp_skb (sn_id, client_id, game_id, user_uid, date, metric)
select sn_id, client_id, game_id, user_uid, min(date_trans), 'payer'
from f_payment
where game_id = 118 and sn_id in ($snid$) and client_id in ($clientid$) 
and status = 0
and date_trans::date <= '$enddate$'
group by 1,2,3,4
;


insert /*+ direct */ into tmp_skb (user_uid, value,value2, metric)
    SELECT 
      a.user_uid, case when '$calc$' = 'avg(value)' then avg(ZEROIFNULL(a.value))
                       when '$calc$' = 'sum(value)' then sum(ZEROIFNULL(a.value))
                       when '$calc$' = 'max(value)' then max(ZEROIFNULL(a.value))
                       when '$calc$' = 'min(value)' then min(ZEROIFNULL(a.value))
                       when '$calc$' = 'count(value)' then sum(ZEROIFNULL(a.value)) end as val, coalesce(b.value, 1) as level,'final'

 FROM
      tmp_skb   a
     
    LEFT JOIN
      tmp_skb d 
      on d.sn_id = a.sn_id and d.client_id = a.client_id and d.game_id = a.game_id and d.user_uid = a.user_uid 
      AND d.metric = '$usertype$'
      AND d.date::date = a.date::date
    left join 
      tmp_skb b 
      on b.sn_id = a.sn_id and b.client_id = a.client_id and b.game_id = a.game_id and b.user_uid = a.user_uid 
      and b.metric = 'level'
   left join 
      tmp_skb c on c.sn_id = a.sn_id and c.client_id = a.client_id and c.game_id = a.game_id and c.user_uid = a.user_uid 
      and c.metric = 'payer'
  where (case when '$payer$' = 'payer' then c.user_uid is not null else 1 = 1 end)
  and (('$usertype$' = 'all') OR ('$usertype$' != 'all' AND  d.user_uid IS NOT NULL))
    and a.metric ='temp'
    GROUP BY 1,3
;
select distinct b.'Users' * 100 as Users,
a.'P30' as 'P30',
a.'P40' as 'P40',
a.'Median' as 'Median', 
a.'P60' as 'P60',
a.'P65' as 'P65',
a.'P70' as 'P70',
a.'P75' as 'P75',
a.'P80' as 'P80',
a.'P85' as 'P85',
a.'P90' as 'P90'
from
(
select distinct PERCENTILE_CONT(.3) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P30',
PERCENTILE_CONT(.4) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P40',
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'Median',
PERCENTILE_CONT(.6) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P60',
PERCENTILE_CONT(.65) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P65',
PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P70',
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P75',
PERCENTILE_CONT(.8) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P80',
PERCENTILE_CONT(.85) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P85',
PERCENTILE_CONT(.9) WITHIN GROUP(ORDER BY value) OVER ( ) AS 'P90' from
tmp_skb a
where a.metric = 'final'
and a.value2 >= $level$ AND a.value2 <= $maxlevel$
)a
left join 
(
select count(distinct a.user_uid) as 'Users'
from
tmp_skb a
where a.metric = 'final'
and a.value2 >= $level$ AND a.value2 <= $maxlevel$
)b
on 1=1
;

select distinct a.Level,b.'Users' * 100 as Users,
a.'P30' as 'P30',
a.'P40' as 'P40',
a.'Median' as 'Median', 
a.'P60' as 'P60',
a.'P65' as 'P65',
a.'P70' as 'P70',
a.'P75' as 'P75',
a.'P80' as 'P80',
a.'P85' as 'P85',
a.'P90' as 'P90'
from
(
select distinct a.value2 as Level,
PERCENTILE_CONT(.3) WITHIN GROUP(ORDER BY value) OVER ( partition by a.value2) AS 'P30',
PERCENTILE_CONT(.4) WITHIN GROUP(ORDER BY value) OVER ( partition by a.value2) AS 'P40',
PERCENTILE_CONT(.5) WITHIN GROUP(ORDER BY value) OVER (partition by a.value2 ) AS 'Median',
PERCENTILE_CONT(.6) WITHIN GROUP(ORDER BY value) OVER ( partition by a.value2) AS 'P60',
PERCENTILE_CONT(.65) WITHIN GROUP(ORDER BY value) OVER ( partition by a.value2) AS 'P65',
PERCENTILE_CONT(.7) WITHIN GROUP(ORDER BY value) OVER (partition by a.value2 ) AS 'P70',
PERCENTILE_CONT(.75) WITHIN GROUP(ORDER BY value) OVER ( partition by a.value2) AS 'P75',
PERCENTILE_CONT(.8) WITHIN GROUP(ORDER BY value) OVER (partition by a.value2 ) AS 'P80',
PERCENTILE_CONT(.85) WITHIN GROUP(ORDER BY value) OVER ( partition by a.value2) AS 'P85',
PERCENTILE_CONT(.9) WITHIN GROUP(ORDER BY value) OVER (partition by a.value2 ) AS 'P90'
from
tmp_skb a
where a.metric = 'final'
and a.value2 >= $level$ AND a.value2 <= $maxlevel$
)a
left join 
(
select a.value2 as Level, count(distinct a.user_uid) as 'Users'
from
tmp_skb a
where a.metric = 'final'
and a.value2 >= $level$ AND a.value2 <= $maxlevel$
group by 1
)b
on a.Level = b.Level
order by 1
---
;
