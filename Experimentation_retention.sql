

-- Exp HVP
INSERT /*+ DIRECT */ into etl_temp.tmp_exp_3( sn_id, game_id, client_id, user_uid, test_name, variant, start_timestamp )
 select a.sn_id, a.game_id, a.client_id, a.user_uid, test_name, variant, exp_date from
(
SELECT a.sn_id, a.game_id, a.client_id, a.user_uid, test_name, variant as variant, min(exp_date) as exp_date
FROM s_zt_exp a
WHERE a.game_id=@gameid@  and test_name= @testname@
and exp_date+exp_time between @startdate@ and @enddate@
and exp_date is not null
GROUP BY 1,2,3,4,5,6
 ) a
 
 
;
-- DAU
INSERT /*+ DIRECT */ into tmp_dau(sn_id, game_id, client_id, user_uid, first_timestamp)
SELECT distinct a.sn_id, a.game_id, a.client_id, a.user_uid, dau_date
FROM s_zt_dau a
WHERE a.game_id=@gameid@ 
and dau_date between @startdate@ and @enddate@::date + 90
;
--level
INSERT /*+ DIRECT */ into tmp_skb_2(sn_id, game_id, client_id, user_uid)
select a.sn_id, a.game_id, a.client_id, a.user_uid
from a_user_day a
inner join etl_temp.tmp_exp_3 b
on a.user_uid = b.user_uid and a.game_id = b.game_id and a.stat_date::date=b.start_timestamp
where a.level >= @minlevel@
group by 1,2,3,4
;

-- Final run--

SELECT entry_date as 'Entry Date',
variant as 'Variant',
users as 'Users',
day1 *100.0 / users as "d1%",
day2 *100.0 / users as "d2%",
day3 *100.0 / users as "d3%",
day4 *100.0 / users as "d4%",
day5 *100.0 / users as "d5%",
day6 *100.0 / users as "d6%",
day7 *100.0 / users as "d7%",
day8 *100.0 / users as "d8%",
day9 *100.0 / users as "d9%",
day10 *100.0 / users as "d10%",
day11 *100.0 / users as "d11%",
day12 *100.0 / users as "d12%",
day13 *100.0 / users as "d13%",
day14 *100.0 / users as "d14%",
day15 *100.0 / users as "d15%",
day16 *100.0 / users as "d16%",
day17 *100.0 / users as "d17%",
day18 *100.0 / users as "d18%",
day19 *100.0 / users as "d19%",
day20 *100.0 / users as "d20%",
day21 *100.0 / users as "d21%",
day22 *100.0 / users as "d22%",
day23 *100.0 / users as "d23%",
day24 *100.0 / users as "d24%",
day25 *100.0 / users as "d25%",
day26 *100.0 / users as "d26%",
day27 *100.0 / users as "d27%",
day28 *100.0 / users as "d28%",
day29 *100.0 / users as "d29%",
day30 *100.0 / users as "d30%",
day45 *100.0 / users as "d45%",
day60 *100.0 / users as "d60%",
day90 *100.0 / users as "d90%"
FROM

(SELECT idate entry_date, variant,
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
    sum(case when ddiff = 30 then cnt else 0 end) day30,
	 sum(case when ddiff = 45 then cnt else 0 end) day45,
	  sum(case when ddiff = 60 then cnt else 0 end) day60,
	   sum(case when ddiff = 90 then cnt else 0 end) day90
    FROM 
    (
        SELECT start_timestamp::date idate, e.variant, first_timestamp, 
        datediff( 'day', start_timestamp::date, first_timestamp) ddiff,
        count(distinct e.user_uid) cnt
        FROM tmp_exp_3 e
        LEFT JOIN tmp_dau d on e.game_id = d.game_id  and e.user_uid = d.user_uid
        inner JOIN tmp_skb_2 c on e.game_id = c.game_id  and e.user_uid = c.user_uid
        GROUP BY 1,2,3
    ) a
    GROUP BY 1,2
) z

left join

(
        SELECT  e.variant as variant2, min(start_timestamp::date) min_date
      
        FROM tmp_exp_3 e
        LEFT JOIN tmp_dau d on e.game_id = d.game_id  and e.user_uid = d.user_uid
        inner JOIN tmp_skb_2 c on e.game_id = c.game_id  and e.user_uid = c.user_uid
        GROUP BY 1
    ) b
    
  
    on z.variant=b.variant2
    
    where entry_date between b.min_date and (b.min_date + 7)
    order by 1 desc, 2;