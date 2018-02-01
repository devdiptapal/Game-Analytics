
-- Overall farm actions

select
distinct val1 as week,

 PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY val1) as  p50,
PERCENTILE_CONT(0.7) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY val1) as  p70,

PERCENTILE_CONT(0.9) WITHIN GROUP(ORDER BY actions) OVER (PARTITION BY val1) as  p90


from
(select distinct a.val1, a.user_uid, actions
from

(select week(b.date::date) as val1,  b.user_uid , sum(actions) as actions from

(select counter_date::date as date,
        user_uid,

        count(*) as actions 
        from s_zt_count where
        game_id=118
        and counter_date between  '$startdate$' and '$enddate$' 
        and counter = 'farm_action'
        and kingdom in ('harvest','water','fertilizer','instagrow')
        and kingdom is not null
        group by 1,2) b
group by 1,2
order by 1) as a 

inner join

(select distinct  val1, user_uid, (case when stu > 40 then 'H' else 'L' end) as type from
        (select distinct week(date_trans::date)  as val1, user_uid, sum(amount) as stu
        from report.v_payment
        where game_id = 118
        and date_trans::date between  '$startdate$' and '$enddate$' 
        and status = 0
        and db_source = 's_receipts'
        and amount > 0
        and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
        and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
        and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
        group by 1,2) as x
        -- filtering high value payers only
where (case when stu > 40 then 'H' else 'L' end)='H') b

on 
a.user_uid = b.user_uid
 and a.val1=b.val1
 
) as y
 
 order by 1;
