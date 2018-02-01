commit;


-- getting golden cohort
insert /*+ direct */ into etl_temp.tmp_skb (user_uid,value, metric )
select  user_uid , sum(amount) as spend, 'ltpayers'
from report.v_payment
where game_id = 118
and date_trans::date between '2011-01-01' and '$enddate$' 
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
group by 1
having sum(amount)>=50
;


insert /*+ direct */ into etl_temp.tmp_skb (user_uid, metric)
select distinct user_uid, '90_day_users_prior' from s_zt_dau where game_id=118 and dau_date between '$startdate$' and '$enddate$';


insert /*+ direct */ into etl_temp.tmp_skb (user_uid, metric)
select distinct a.user_uid , 'target' from tmp_skb a 
inner join 
tmp_skb b on a.user_uid = b.user_uid and a.metric= 'ltpayers' and b.metric='90_day_users_prior';



insert /*+ direct */ into etl_temp.tmp_skb (user_uid, metric)
select distinct user_uid, '60_day_users' 
from s_zt_dau 
where game_id=118 
and dau_date between '$enddate$'::date +1 and '$enddate$'::date +30;


insert /*+ direct */ into etl_temp.tmp_skb (user_uid, metric)
select distinct user_uid , 'target2' from tmp_skb 
where metric='target'
and user_uid not in (select  distinct user_uid from tmp_skb where metric='60_day_users');

@set maxrows 999999999;
        @export on;
        @export set filename="C:\english_locale.csv" 
        CsvColumnDelimiter = ",";
select 
distinct
zid, first_name, last_name, email_addr, latest_locale, country

from tmp_skb a
join
(select * from
(select distinct user_uid, zid, first_name, last_name, email_addr,latest_locale,country, rank() over (partition by user_uid order by stat_date desc) as rank from  
v_user_day where game_id=118 and zid is not null and user_uid is not null and stat_date between '$startdate$'  and '$enddate$') as x
where rank=1) b
on a.user_uid = b.user_uid and metric='target2'
where latest_locale ilike '%en_%'
and zid%10 in (1,2,3,4,5,6,7,8,9);
@export off;

@set maxrows 999999999;
        @export on;
        @export set filename="C:\non_english_locale.csv" 
        CsvColumnDelimiter = ",";
select 
distinct
zid, first_name, last_name, email_addr, latest_locale, country

from tmp_skb a
join
(select * from
(select distinct user_uid, zid, first_name, last_name, email_addr,latest_locale,country, rank() over (partition by user_uid order by stat_date desc) as rank from  
v_user_day where game_id=118 and zid is not null and user_uid is not null and stat_date between '$startdate$'  and '$enddate$') as x
where rank=1) b
on a.user_uid = b.user_uid and metric='target2'
where latest_locale not ilike '%en_%'
and zid%10 in (1,2,3,4,5,6,7,8,9);
@export off;




