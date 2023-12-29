-- 1.	Show the percentage of wins of each bidder in the order of highest to lowest percentage.

SELECT BIDDER_ID,(no_of_wins/NO_OF_BIDS)*100 percentage_of_wins FROM ipl_bidder_points a INNER JOIN (SELECT BIDDER_ID,COUNT(WINNING) no_of_wins FROM 
(SELECT BIDDER_ID,CASE WHEN BID_STATUS='Won' THEN BID_STATUS END AS WINNING FROM ipl_bidding_details)t GROUP BY BIDDER_ID)b
USING (BIDDER_ID)
ORDER BY percentage_of_wins DESC;
#OR
select bidder_id, sum(total_points)/sum(no_of_matches)*100 as Winning_Percentage
	from IPL_Bidder_Points
	group by bidder_id
	order by Winning_Percentage desc;
#OR


-- 2.	Display the number of matches conducted at each stadium with the stadium name and city.es

SELECT STADIUM_NAME,CITY,COUNT(MATCH_ID) no_of_matches FROM ipl_stadium JOIN ipl_match_schedule USING (STADIUM_ID) GROUP BY STADIUM_ID;
#OR
select a.stadium_id,b.STADIUM_NAME,b.city,count(*) as Number_of_Matches from ipl_match_schedule a inner join ipl_stadium b
on a.STADIUM_ID=b.stadium_id group by STADIUM_ID order by Number_of_matches;
#OR
select s.stadium_name, s.city, count(*) as "Number of matches"
	from IPL_Match_Schedule ms join IPL_stadium s
    on ms.stadium_id = s.stadium_id
    group by s.stadium_name, s.city;

-- 3.	In a given stadium, what is the percentage of wins by a team which has won the toss?


SELECT STADIUM_NAME,(MATCH_WON/No_of_Match)*100 Percentage_of_win_when_won_toss FROM (SELECT STADIUM_NAME,SUM(Num) MATCH_WON,COUNT(MATCH_ID) No_of_Match FROM 
(SELECT TOSS_WINNER,MATCH_WINNER,MATCH_ID,STADIUM_NAME,CASE WHEN TOSS_WINNER=MATCH_WINNER THEN 1 ELSE 0 END AS Num
FROM ipl_match JOIN (SELECT STADIUM_NAME,CITY,MATCH_ID FROM ipl_stadium a JOIN ipl_match_schedule b USING (STADIUM_ID))t
USING (MATCH_ID))tt
GROUP BY STADIUM_NAME)ttt;
#OR
select stadium_id 'Stadium ID', stadium_name 'Stadium Name',
(select count(*) from ipl_match m join ipl_match_schedule ms on m.match_id = ms.match_id
where ms.stadium_id = s.stadium_id and (toss_winner = match_winner)) /
(select count(*) from ipl_match_schedule ms where ms.stadium_id = s.stadium_id) * 100 
as 'Percentage of Wins by teams who won the toss (%)'
from ipl_stadium s;


-- 4.	Show the total bids along with the bid team and team name.

SELECT TEAM_NAME,a.BID_TEAM,COUNT(BID_TEAM) TOTAL_BIDS FROM ipl_bidding_details a JOIN ipl_team b ON a.BID_TEAM=b.TEAM_ID GROUP BY BID_TEAM;
#OR
SELECT DISTINCT TEAM_NAME,a.BID_TEAM,COUNT(BID_TEAM) OVER(PARTITION BY BID_TEAM ) TOTAL_BIDS FROM ipl_bidding_details a JOIN ipl_team b ON a.BID_TEAM=b.TEAM_ID ;
#OR
with z as
  (select distinct(BID_TEAM),
  count(bid_team) over(partition by bid_team order by bid_team) as totalbids
  from ipl_bidding_details)
select t.*,te.Team_name
from z t 
join ipl_team te
on t.bid_team = te.team_id;
#OR
select BID_TEAM,team_name,count(bid_team) from ipl_bidder_points a inner join ipl_bidding_details b on a.BIDDER_ID=b.BIDDER_ID
inner join ipl_team c on b.BID_TEAM=c.TEAM_ID group by BID_TEAM ;


-- 5.	Show the team id who won the match as per the win details.

SELECT MATCH_ID,WIN_DETAILS,CASE WHEN MATCH_WINNER=1 THEN TEAM_ID1 ELSE TEAM_ID2 END AS Match_winner FROM ipl_match a JOIN ipl_team b ON a.MATCH_WINNER=b.TEAM_ID; 
#WE CAN DO THIS QUESTION WITHOUT JOINING THE TABLES ALSO AS MATCH_WINNER IS ULTIMATELY THE TEAM_ID
#OR
Select case
			when team_id1 = match_winner 
				then team_id1 
				else team_id2
		   end as "Team ID as per Win Details", win_details
    from IPL_Match;
#OR
select WIN_DETAILS,
case
when MATCH_WINNER=1 then TEAM_ID1
else TEAM_ID2
end as teamid_won_match
 from ipl_match;


-- 6.	Display total matches played, total matches won and total matches lost by the team along with its team name.
select distinct team_id,
sum(matches_played) over(partition by team_id) as total_matches_played,
sum(matches_won) over(partition by team_id) as total_matches_won,
sum(matches_lost) over(partition by team_id) as total_matches_lost
 from ipl_team_standings;
#OR
select a.team_id,sum(MATCHES_PLAYED) as Total_matches_play,sum(MATCHES_WON) as  Total_matches_won
,sum(MATCHES_LOST)  Total_matches_lost,sum(NO_RESULT) as Tied_Matches ,TEAM_NAME from ipl_team_standings a inner join ipl_team b on a.TEAM_ID=b.TEAM_ID
group by a.TEAM_ID;

-- 7.	Display the bowlers for the Mumbai Indians team.

SELECT PLAYER_ID,PLAYER_NAME,TEAM_NAME,PLAYER_ROLE FROM 
(SELECT TEAM_NAME,PLAYER_ID,PLAYER_ROLE FROM ipl_team JOIN ipl_team_players USING (TEAM_ID) WHERE TEAM_NAME='Mumbai Indians' AND PLAYER_ROLE='Bowler')t JOIN 
ipl_player USING(PLAYER_ID);
#OR
select a.team_name ,b.player_role,b.player_id,c.player_name from ipl_team a inner join ipl_team_players b on
 a.TEAM_ID=b.TEAM_ID
inner join ipl_player c on b.PLAYER_ID=c.PLAYER_ID
where a.TEAM_name='mumbai indians'and PLAYER_ROLE='bowler';
#OR
with z as
   (select * from ipl_team_players
    where player_role = 'bowler' and team_id = (select team_id from ipl_team where team_name = 'Mumbai Indians'))
 select t.*,  te.player_name
 from z t
 join ipl_player te
 on t.player_id = te.player_id;

-- 8.	How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.

SELECT TEAM_ID,TEAM_NAME,NO_OF_AR FROM 
(SELECT TEAM_ID,COUNT(PLAYER_ID) NO_OF_AR FROM ipl_team_players WHERE PLAYER_ROLE='All-Rounder' GROUP BY TEAM_ID)t JOIN ipl_team USING (TEAM_ID)
WHERE NO_OF_AR>4 ORDER BY NO_OF_AR DESC;
#OR
select a.TEAM_ID,count(PLAYER_ROLE),PLAYER_ROLE,TEAM_NAME from ipl_team_players a inner join ipl_team b on a.TEAM_ID=b.TEAM_ID
where PLAYER_ROLE='All-Rounder' group by TEAM_ID having count(PLAYER_ROLE)>4 order  by count(PLAYER_ROLE) desc;

-- 9.	 Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
-- Note the total bidders’ points in descending order and the year is bidding year.
-- Display columns: bidding status, bid date as year, total bidder’s points

SELECT BID_STATUS,bid_year,TOTAL_POINTS FROM
(SELECT BID_STATUS,YEAR(bid_date) bid_year,TOTAL_POINTS,SCHEDULE_ID FROM ipl_bidder_points JOIN ipl_bidding_details USING (BIDDER_ID)
WHERE BID_TEAM = 1)t JOIN ipl_match_schedule USING (SCHEDULE_ID)
WHERE STADIUM_ID=7 AND BID_STATUS='Won' ORDER BY TOTAL_POINTS DESC;



-- 10.	Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
-- Note 
-- 1. use the performance_dtls column from ipl_player to get the total number of wickets
-- 2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
-- 3.	Do not use joins in any cases.
-- 4.	Display the following columns teamn_name, player_name, and player_role.

SELECT player_name,PERFORMANCE_DTLS FROM ipl_player WHERE PERFORMANCE_DTLS NOT LIKE '%Wkt-0%';
SELECT player_name,PERFORMANCE_DTLS FROM ipl_player;
select *, substring(performance_dtls,16,8) from ipl_player ;


-- 11.	show the percentage of toss wins of each bidder and display the results in descending order based on the percentage.

SELECT BIDDER_ID,BIDDER_NAME,perc_toss_wins FROM (SELECT BIDDER_ID,(total_toss_wins/total_bids)*100 perc_toss_wins FROM 
(SELECT BIDDER_ID,COUNT(BID_TEAM) total_bids,SUM(TOSS) total_toss_wins FROM (SELECT BIDDER_ID,BID_TEAM,CASE WHEN BID_TEAM=TOSS_WINNER THEN 1 ELSE 0 END AS TOSS FROM 
(SELECT SCHEDULE_ID,MATCH_ID,TOSS_WINNER,TEAM_NAME FROM (SELECT SCHEDULE_ID,MATCH_ID,TOSS_WINNER FROM ipl_match a JOIN ipl_match_schedule USING (MATCH_ID))t 
JOIN ipl_team b ON t.TOSS_WINNER=b.team_id)tt JOIN ipl_bidding_details c ON tt.SCHEDULE_ID=c.SCHEDULE_ID)ttt
GROUP BY BIDDER_ID)tttt
ORDER BY perc_toss_wins DESC)ttttt JOIN ipl_bidder_details USING (BIDDER_ID);


-- 12.	find the IPL season which has min duration and max duration.
-- Output columns should be like the below:
-- Tournment_ID, Tourment_name, Duration column, Duration

SELECT TOURNMT_ID,TOURNMT_NAME,DURATION FROM (SELECT TOURNMT_ID,TOURNMT_NAME,DURATION,DENSE_RANK() OVER(ORDER BY DURATION DESC) RANK_
FROM 
(SELECT Tournmt_id,tournmt_name,DATEDIFF(TO_DATE,FROM_DATE) DURATION FROM ipl_tournament)t
ORDER BY DURATION DESC)tt
WHERE RANK_ IN (1,5);


-- 13.	Write a query to display to calculate the total points month-wise for the 2017 bid year. 
-- sort the results based on total points in descending order and month-wise in ascending order.
-- Note: Display the following columns:
-- 1.	Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
-- Only use joins for the above query queries.

SELECT DISTINCT a.BIDDER_ID,BIDDER_NAME,YEAR(BID_DATE) bid_date_as_year,MONTH(BID_DATE) bid_date_as_month,TOTAL_POINTS FROM ipl_bidding_details a JOIN 
ipl_bidder_details b USING(BIDDER_ID) JOIN ipl_bidder_points c ON b.BIDDER_ID=c.BIDDER_ID
WHERE YEAR(BID_DATE)=2017
ORDER BY MONTH(BID_DATE) ASC,TOTAL_POINTS DESC;
#OR
select a.BIDDER_ID,BIDDER_NAME, year(bid_date) ,month(bid_date),total_points from ipl_bidder_details a join ipl_bidding_details b 
on a.BIDDER_ID=b.BIDDER_ID
join ipl_bidder_points c on b.BIDDER_ID=c.BIDDER_ID
 where year(bid_date)=2017 group by a.BIDDER_ID,month(bid_date) order by TOTAL_POINTS desc,month(bid_date) asc;

-- 14.	Write a query for the above question using sub queries by having the same constraints as the above question.

SELECT DISTINCT BIDDER_ID,BIDDER_NAME,YEAR(BID_DATE) bid_date_as_year,MONTH(BID_DATE) bid_date_as_month,TOTAL_POINTS 
FROM ipl_bidding_details a JOIN (SELECT BIDDER_ID,BIDDER_NAME FROM ipl_bidder_details) b USING(BIDDER_ID)
JOIN (SELECT BIDDER_ID,TOTAL_POINTS FROM ipl_bidder_points) c USING (BIDDER_ID)
WHERE YEAR(BID_DATE)=2017
ORDER BY MONTH(BID_DATE) ASC,TOTAL_POINTS DESC;

-- 15.	Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
-- Output columns should be:
-- like:
-- Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder, Lowest_3_Bidders  --> columns contains name of bidder;

SELECT BIDDER_ID,R,CASE WHEN R IN (1,2,3) THEN BIDDER_NAME END AS HIGHEST_3_BIDDERS,
CASE WHEN R IN (14,15,16) THEN  BIDDER_NAME END AS LOWEST_3_BIDDERS,TOTAL_POINTS FROM
(SELECT DISTINCT BIDDER_ID,BIDDER_NAME,YEAR(BID_DATE) bid_date_as_year,TOTAL_POINTS,DENSE_RANK() OVER(ORDER BY TOTAL_POINTS DESC) R
FROM ipl_bidding_details a JOIN (SELECT BIDDER_ID,BIDDER_NAME FROM ipl_bidder_details) b USING(BIDDER_ID) 
JOIN (SELECT BIDDER_ID,TOTAL_POINTS FROM ipl_bidder_points) c USING (BIDDER_ID) 
WHERE YEAR(BID_DATE)=2018
ORDER BY TOTAL_POINTS DESC)t;

-- 16.	Create two tables called Student_details and Student_details_backup.

-- Table 1: Attributes 		Table 2: Attributes
-- Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

-- Feel free to add more columns the above one is just an example schema.
-- Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the students in the Student details table.
-- Every time the students changed their details like mobile number,
-- You need to update their details in the student details table.  Here is one thing you should ensure whenever the new students' details come , you should also store them in
-- the Student backup table so that if you modify the details in the student details table, you will be having the old details safely.
-- You need not insert the records separately into both tables rather Create a trigger in such a way that It should insert the details into the Student back table when you 
-- inserted the student details into the student table automatically.

-- AND NOW IT'S TO REVISE DBMS-2 (UGHHHHHHHHHHHHHHHHHHH)........













