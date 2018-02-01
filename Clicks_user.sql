-- message clicks 

INSERT /*+ direct */ INTO etl_temp.tmp_skb(user_uid,value, metric)
select user_uid, count(*) as clicks  , 'true_2'
from s_zt_message_click where channel='feed' and click_date between '$start$' and '$end$' 
and game_id=118
group by 1;


		


-- By user logins
        
        
        select logins,  count(distinct a.user_uid), sum(value) as clicks
        
        from etl_temp.tmp_skb as a
        

        
        inner join
        
        
        (select   user_uid, logins
        from (
        select user_uid , count(distinct dau_date) as logins
        from s_zt_dau 
        where 
        game_id=118
        and sn_id =104
        and dau_date between '$start$' and '$end$'
        group by  1 
        ) as x) as y
        
        on a.user_uid = y.user_uid
        and a.metric='true_2'
        
--        inner join
--        
--       ( select 'InstalledExtension', user_uid
--from ztrack.s_zt_milestone
--where game_id = 118
--        and milestone_date >= '2015-09-01'
--        and milestone_date < '$start$'
--        and milestone = 'extension_installed'
--group by 1,2) as b

--on y.user_uid = b.user_uid      

   

        
        group by 1;
        
        
     
       
        
