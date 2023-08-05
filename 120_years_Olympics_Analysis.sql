select * from olympics_history;
select * from olympics_history_noc_regions;

-- Query 1
select COUNT(DISTINCT(games)) as total_olympics_games
from olympics_history;

-- Query 2
select DISTINCT year, season, city 
from olympics_history
ORDER BY year;

--Query 3
with cte as (
SELECT games, ohr.region
from olympics_history oh
JOIN olympics_history_noc_regions as ohr
ON oh.noc = ohr.noc
GROUP BY games, ohr.region)
	SELECT games, COUNT (DISTINCT region) as total_countries
	FROM cte 
	GROUP BY games;
	
-- Query 4
with t1 as (
SELECT games, ohr.region
from olympics_history oh
JOIN olympics_history_noc_regions as ohr
ON oh.noc = ohr.noc
GROUP BY games, ohr.region),
t2 as(
	SELECT  games, COUNT(region) as nations_participated
	FROM t1
	group by games
	ORDER By games)
		SELECT min(t2.nations_participated) as lowest,
		max(t2.nations_participated) as highest
		from t2;
	
--QUERY 5
 with cte as (
 select count(distinct games) as uniq
from olympics_history),
 countries as (
	 SELECT games, ohr.region as country
	from olympics_history oh
	JOIN olympics_history_noc_regions as ohr
	ON oh.noc = ohr.noc
	GROUP BY games, ohr.region),
countries_participated as (
			select country, count(*) as total_participated_games
			from countries
			GROUP BY country)
			select * from countries_participated
			JOIN cte ON countries_participated.total_participated_games =
						cte.uniq

-- QUERY 6
with cte as (
 select count(distinct games) as uniq
from olympics_history
WHERE season = 'Summer'),
t2 as (

	select distinct sport, games
	FROM olympics_history
	WHERE season = 'Summer'
	order by games),
t3 as (
	select sport, count(games) as total
	from t2
	group by sport)
select *
from t3 join cte on t3.total = cte.uniq

--QUERY 7
with t1 as (Select distinct games, sport
from olympics_history
order by games),
t2 as (
	select sport, count(*) as no_of_games
	from t1 
	group by sport)
	select t2.*, t1.games from t2
	join t1 on t2.sport = t1.sport
	where t2.no_of_games = 1
	order by t1.games
	
-- Query 8
with t1 as (select distinct games, sport
from olympics_history),
t2 as (select games, count(*) as no_sports
	  from t1 group by games)
select * from t2 order by no_sports desc; 

--Query 9
with t1 as (select * from 
olympics_history
WHERE medal = 'Gold' and age IS NOT Null
ORDER BY age desc),
t2 as (select * from t1 where age NOT LIKE 'NA'),
t3 as (select max(age) as max_age from t2)
select * from t2 where age = (select max_age from t3)

--Query 10
SELECT 
    SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS female_count,
    SUM(CASE WHEN sex IN ('M', 'F') THEN 1 ELSE 0 END) AS total_participants,
    ROUND(CAST(SUM(CASE WHEN sex = 'M' THEN 1 ELSE 0 END) AS NUMERIC) / CAST(SUM(CASE WHEN sex = 'F' THEN 1 ELSE 0 END) AS NUMERIC), 2) AS male_to_female_ratio
FROM olympics_history;

--Query 11
with t1 as 
	(select name, team, medal from olympics_history
	WHERE medal = 'Gold'),
t2 as 
	(select name, team, count(1) as gold_count
	from t1
	GROUP BY t1.team, name, t1.team
	ORDER BY gold_count desc),
t3 as 
	(select t2.*,
	 dense_rank() over (order by gold_count desc) as R
	 from t2)
select * from t3 
where r<=5;

--Query 12
with t1 as 
	(select name, team, medal from olympics_history
	WHERE medal = 'Gold' or medal ='Silver' or
	      medal = 'Bronze'),
t2 as 
	(select name, team, count(1) as medal_count
	from t1
	GROUP BY t1.team, name, t1.team
	ORDER BY medal_count desc),
t3 as 
	(select t2.*,
	 dense_rank() over (order by medal_count desc) as R
	 from t2)
select * from t3 
where r<=5;


--Query 13
with t1 as (SELECT ohr.region,
		SUM(CASE WHEN medal = 'Gold' or medal = 'Silver'
		or medal = 'Bronze' THEN 1 ELSE 0 END) AS 
			total_medal
from olympics_history oh
JOIN olympics_history_noc_regions as ohr
ON oh.noc = ohr.noc
GROUP BY ohr.region)
	select *,
	rank () over (order by total_medal desc) as R
	from t1;
	
-- Query 14


--Query 15
with t1 as 
	(SELECT games, medal ,ohr.region
	from olympics_history oh
	JOIN olympics_history_noc_regions as ohr
	ON oh.noc = ohr.noc
	WHERE medal IS NOT NULL and medal NOT LIKE 'NA'
	GROUP BY games,medal, ohr.region
	ORDER BY games),
t2 as 
		(select t1.games, t1.region,
	   (CASE WHEN t1.medal = 'Gold' THEN 1 ELSE 0 END)
	   AS gold_count,
	   (CASE WHEN t1.medal = 'Silver' THEN 1 ELSE 0 END)
	   AS silver_count,
	   (CASE WHEN t1.medal = 'Bronze' THEN 1 ELSE 0 END)
	   AS bronze_count
		from t1)
select t2.games,
t2.region as country,
sum(t2.gold_count) as gold, sum(t2.silver_count) as silver, sum(t2.bronze_count) as bronze
from t2
group by country, t2.games
ORDER by gold_count desc;
	
	
-- Query 15 part 2
with medals as 
	(select nr.region as country,
		(case when medal = 'Gold' then 1 else 0 end) as Gold,
		(case when medal = 'Silver' then 1 else 0 end) as Silver,
		(case when medal = 'Bronze' then 1 else 0 end) as Bronze
		from olympics_history oh
	 	join olympics_history_noc_regions nr on nr.noc = oh.noc
	 	where medal <> 'NA')
select  country, sum(medals.Gold) as gold, sum(medals.Silver) as silver, sum(medals.Bronze) as bronze
from medals
group by country
order by gold desc, silver desc, bronze desc;

--QUery 16
with medals as 
	(select oh.games, nr.region as country,
		(case when medal = 'Gold' then 1 else 0 end) as Gold,
		(case when medal = 'Silver' then 1 else 0 end) as Silver,
		(case when medal = 'Bronze' then 1 else 0 end) as Bronze
		from olympics_history oh
	 	join olympics_history_noc_regions nr on nr.noc = oh.noc
	 	where medal <> 'NA')
select medals.games, country, sum(medals.Gold) as gold, sum(medals.Silver) as silver, sum(medals.Bronze) as bronze
from medals
group by medals.games, country
order by games;

-- Query 17

with medals as 
	(select nr.region as country,
		(case when medal = 'Gold' then 1 else 0 end) as Gold,
		(case when medal = 'Silver' then 1 else 0 end) as Silver,
		(case when medal = 'Bronze' then 1 else 0 end) as Bronze
		from olympics_history oh
	 	join olympics_history_noc_regions nr on nr.noc = oh.noc
	 	where medal <> 'NA'),
t2 as (select  country, sum(medals.Gold) as gold, sum(medals.Silver) as silver, sum(medals.Bronze) as bronze
	from medals
	group by country
	order by gold desc, silver desc, bronze desc),
t3 as (select * 
from t2 
where gold = 0)
select * from 
t3 where Silver > 0 or Bronze > 0

-- Query 18
with t1 as (select sport, medal, ohr.region
from olympics_history oh
JOIN olympics_history_noc_regions as ohr
ON oh.noc = ohr.noc
WHERE 
ohr.region = 'India' and medal <> 'NA'),
t2 as (select sport, count(*) as total_medals
FROM t1 
GROUP BY sport),
t3 as (select max(total_medals) as max_medals from t2)
select * from t2 where total_medals = (select max_medals from t3)










