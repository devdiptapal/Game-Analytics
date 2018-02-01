commit;

-- Payers
insert /*+direct*/ into tmp_skb (sn_id, client_id, game_id, user_uid, metric, value, date)
select sn_id, client_id, game_id, user_uid, 'payers'
    , sum(amount), max(date_trans::date)
from report.v_payment
Where game_id = 118
and sn_id =1 
and client_id =1
--and user_uid%100 = 1
group by 1,2,3,4
;

-- Payments
insert /*+direct*/ into tmp_skb (sn_id, client_id, game_id, user_uid, metric, value, date)
select sn_id, client_id, game_id, user_uid, 'payments', amount, date_trans::date
from report.v_payment
Where game_id = 118
and sn_id =1 
and client_id =1
--and user_uid%100 = 1
;

--exclusions
insert /*+direct*/ into tmp_skb (sn_id, client_id, game_id, user_uid, metric)
select sn_id, client_id, game_id, user_uid, 'exclusions'
from s_zt_economy
Where game_id = 118
and sn_id =1 
and client_id =1
and kingdom in ('console_grant', 'cheat_grant', 'admin_grant')
and amount > 1000
--and user_uid%100 = 1
group by 1,2,3,4
;

--get current wallet sizes
insert /*+direct*/ into tmp_skb (sn_id, client_id, game_id, user_uid, metric, date, value)
select a.sn_id, a.client_id, a.game_id, a.user_uid, 'payer balance', economy_date, total_amount
from (
    select sn_id, 1 as client_id, game_id, user_uid, total_amount, economy_date
        , row_number() over (partition by sn_id, game_id, user_uid, economy_date order by economy_time desc) as row_num
    from s_zt_economy
    where game_id = 118
    and sn_id = 1
    and client_id = 1
    and currency = '$currency$'
    --and user_uid%100 = 1
    and economy_date >= '$mintransdate$'
) a
join tmp_skb b on b.sn_id = a.sn_id and b.client_id = a.client_id and b.game_id = a.game_id and b.user_uid = a.user_uid and b.metric = 'payers'
left join tmp_skb c on c.sn_id = a.sn_id and c.client_id = a.client_Id and c.game_id = a.game_id and c.user_Uid = a.user_Uid and c.metric = 'exclusions'
where row_num = 1
and c.user_uid is null
;

insert /*+direct*/ into tmp_skb (sn_id, client_id, game_id, user_uid, date, metric, value)
select a.sn_id, a.client_id, a.game_id, a.user_uid, stat_date, 'payer wallet', value
from (
    select sn_id, client_id, game_id, user_uid, stat_date, value
        , row_number() over (partition by sn_id, client_id, game_id, user_uid, stat_date order by date::date desc) as row_num
    from (
        select distinct dateobj::date as stat_date
        from star.d_date 
        where dateobj between '$startdate$'::date and '$enddate$'::date
        and dateobj <= current_date - 1
    ) a
    join tmp_skb b on b.date::Date <= stat_date and b.metric = 'payer balance' and b.sn_id = 1 and b.client_id = 1 and b.game_id = 118
) a
where row_num = 1
;


insert /*+direct*/ into tmp_skb (sn_id, client_id, game_id, user_uid, date, metric, value, value2)
select a.sn_id, a.client_id, a.game_id, a.user_uid, a.date, 'payer wallet active payers', a.value, sum(b.value)
from tmp_skb a
    join tmp_skb b
    on  a.client_id = b.client_id
    and a.sn_id = b.sn_id
    and a.game_id = b.game_id
    and a.user_uid = b.user_uid
    and b.metric = 'payments'
    and b.sn_id = 1
    and b.client_id = 1
    and b.game_id = 118
    and b.date between a.date::date-29 and a.date
where a.metric = 'payer wallet'
and a.sn_id = 1
and a.client_id = 1
and a.game_id = 118
group by 1,2,3,4,5,6,7
having sum(b.value) >= $minamount$ 
;


select count(*) as 'Payers in Period'
from tmp_skb a
join a_user b on b.sn_id = a.sn_id and b.client_id = a.client_id and b.game_id = a.game_id and b.user_uid = a.user_uid
        and case when $activeplayers$ > 0 then lastdate >= current_date - $activeplayers$ else 1 = 1 end
where metric = 'payers'
$active$ and date > '$startdate$'::date-90
;

select date, percentile25, median, percentile75, percentile90,percentile99, average
from (
    SELECT a.sn_id, a.game_id, a.client_id, a.date::date as date,
        percentile_cont(.25) within group (order by value) over(partition by a.sn_id, a.game_id, a.client_id, a.date::date) as percentile25,
        percentile_cont(.50) within group (order by value) over(partition by a.sn_id, a.game_id, a.client_id, a.date::date) as median,
        percentile_cont(.75) within group (order by value) over(partition by a.sn_id, a.game_id, a.client_id, a.date::date) as percentile75,
        percentile_cont(.90) within group (order by value) over(partition by a.sn_id, a.game_id, a.client_id, a.date::date) as percentile90,
        percentile_cont(.99) within group (order by value) over(partition by a.sn_id, a.game_id, a.client_id, a.date::date) as percentile99,
        avg(value) over(partition by a.sn_id, a.game_id, a.client_id, a.date::date) as average
    from tmp_skb a 
    join a_user b on b.sn_id = a.sn_id and b.client_id = a.client_id and b.game_id = a.game_id and b.user_uid = a.user_uid
        and case when $activeplayers$ > 0 then lastdate >= current_date - $activeplayers$ else 1 = 1 end
    where metric = case when '$active$' = '--' then 'payer wallet' else 'payer wallet active payers' end
) a
group by 1,2,3,4,5,6,7
order by 1 desc
;



SELECT a.date::date as 'Cumulative Date'
        , sum(a.value) as 'Sum of Wallets'
    from tmp_skb a 
    join a_user b on b.sn_id = a.sn_id and b.client_id = a.client_id and b.game_id = a.game_id and b.user_uid = a.user_uid
        and case when $activeplayers$ > 0 then lastdate >= current_date - $activeplayers$ else 1 = 1 end
    where metric = case when '$active$' = '--' then 'payer wallet' else 'payer wallet active payers' end
group by 1
order by 1 desc
;

