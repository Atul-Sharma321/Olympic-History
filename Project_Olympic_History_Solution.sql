

--1 which team has won the maximum gold medals over the years.

select top 1 l.team,
count(distinct event) medalmax from athletes l  join  athlete_events a on l.Id=a.athlete_Id
where a.medal='gold'
group by l.team order by medalmax desc




select  * from athletes
select  * from athlete_events where athlete_Id=9495
--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

;with ctee as(
select a.team,e.year,count(distinct e.event) medalc,rank() 
over(partition by a.team order by count(distinct e.event) desc) rn from athletes a join  athlete_events e on a.Id=e.athlete_Id 
 where e.medal='silver'
group by a.team,e.year)
select team,SUM(medalc) silvermedl,max(case when rn=1 then year end) yearsilver from ctee
group by team



--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years

-----solution first
select top 1 a.name,count(athlete_Id) countf from athlete_events t
join athletes a on a.Id=t.athlete_Id
where  not athlete_Id in( select athlete_Id from athlete_events where medal  in('silver','bronze')) and medal='gold' 
group by a.name order by countf desc 


------solution second 
with cte as(
select name,medal from athletes a join athlete_events e on a.Id=e.athlete_Id
)
select top 1 name,COUNT(1) noof from cte where not name in(select distinct name from cte where medal in('silver','bronze'))
and medal='gold'
group by name 
order by noof desc 
--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

select year,noof,STRING_AGG(name,',') from (
select name,year,noof,rank() over (partition by year order by noof desc) rn from (
select name,e.year,count(*) noof from athletes a join athlete_events e on a.Id=e.athlete_Id
where e.medal='gold'
group by name,e.year) A 
group by name,year,noof) B
where rn=1
group by year,noof


--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

;with cte as (
select   team,medal,year,event from athletes a join athlete_events e on a.Id=e.athlete_Id
where a.team='india' ),cte2 as (
select medal,year,event,rank() over(partition by medal order by year ) ran from cte  )

select distinct * from cte2 where ran=1

--6 find players who won gold medal in summer and winter olympics both.

select  a.name,count(distinct season) from athletes a join athlete_events r on a.Id=r.athlete_Id
where medal='gold' 
group by a.name having count(distinct season)=2


--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

select  a.name,year,count(distinct medal) from athletes a join athlete_events r on a.Id=r.athlete_Id
where medal in('silver','gold','bronze') and medal !=''
group by a.name,year having count(distinct medal)=3

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

with cte as (
select name,year,event from athletes a join athlete_events r on a.Id=r.athlete_Id
where medal='gold' and season='summer' and year>=2000 group by name,year,event ), cte2 as (
select *,lag(year,1) over(partition by name,event order by year) prevyear, 
lead(year,1) over(partition by name,event order by year) nextyear from cte )
select * from cte2 where year=prevyear+4 and year=nextyear-4