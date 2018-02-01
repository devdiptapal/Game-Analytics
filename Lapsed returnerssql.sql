-- Payers 30 days before march
commit;
insert into tmp_skb (user_uid,metric)
select distinct user_uid, 't1' from s_zt_dau
where game_id=118  and 
dau_date::date between '2016-12-21' and '2016-12-27' group by 1;

-- Users who played in march
insert into tmp_skb (user_uid,metric)
select distinct user_uid, 't2' from s_zt_dau
where game_id=118  and 
dau_date::date between '2016-12-14' and '2016-12-20' group by 1;

--Getting Lapsed payers in march
insert into tmp_skb (user_uid,metric)
select distinct a.user_uid, 't3' from
(select user_uid from tmp_skb where metric='t2') a
left join
(select user_uid from tmp_skb where metric='t1') b
on a.user_uid = b.user_uid
where b.user_uid is null;

insert into tmp_skb (value, user_uid,metric)
select distinct variant, a.user_uid, 'var' from
(select distinct user_uid from tmp_skb where metric='t3') as a
inner join 
(select user_uid, max(variant) as variant from s_zt_exp where game_id=118 and
exp_date+exp_time between '2016-12-28 03:17:00' and '2017-01-07 23:59:59' and test_name='fv2_xpday_viral_master' group by 1) as b
on a.user_uid=b.user_uid;



select value, count(distinct user_uid) from tmp_skb where metric='var' group by 1;

select value as var, count(distinct a.user_uid), sum(logins)/count(distinct a.user_uid) from
(select distinct user_uid, count(distinct dau_date::date) as logins from s_zt_dau
where game_id=118  and 
dau_date::date between '2016-12-28' and '2016-01-07' group by 1) a
inner join
(select distinct user_uid, value from tmp_skb where metric='var') b
on a.user_uid=b.user_uid
group by 1;



