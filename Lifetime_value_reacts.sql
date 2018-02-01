commit;

insert into tmp_skb (date,user_uid, metric)
select distinct a.date, a.user_uid, 'reacts' from
(select distinct dau_date::date as date, user_uid from s_zt_dau where game_id=118 and dau_date::date between '$start$' and '$end$') a
left join
(select distinct dau_date::date as date, user_uid from s_zt_dau where game_id=118 and dau_date::date between '$start$'::date-7 and '$end$') b
on a.user_uid=b.user_uid
and b.date between a.date-7 and a.date-1
where b.user_uid is null;

select a.date, count(distinct a.user_uid), sum(spend) as 'buy' from
(select date, user_uid from tmp_skb where metric='reacts') a
inner join
(select  date_trans::date as date, user_uid , sum(amount) as spend, 'ltpayers'
from report.v_payment
where game_id = 118
and date_trans::date between '$start$'::date+$ndays$ and '$end$'::date+ $ndays$
and status = 0
    and db_source = 's_receipts'
    and amount > 0
    and left(provider_key,3) <> '23:'                                                                   -- omit social vibe
    and not (left(provider_key,3) = '15:' and provider_acct_id = 1)                                   -- omit CPA
    and not (left(provider_key,3) = '15:' and amount < 2.5 and date_trans::date < '2011-04-01')
group by 1,2) b
on a.user_uid=b.user_uid
and b.date between a.date and a.date+$ndays$
group by 1
order by 1 desc;
