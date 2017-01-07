
---------------------------------

-- I. SELECT Basics & II. SELECT FROM world

---------------------------------

-- 12. Show the name and the continent - but substitute Eurasia for Europe and Asia; 
-- substitute America - for each country in North America or South America or 
-- Caribbean. S how countries beginning with A or B

SELECT name, 
 CASE WHEN continent IN ('Europe', 'Asia') THEN 'Eurasia'
      WHEN continent IN ('North America', 'South America', 'Caribbean') THEN 'America'  
 ELSE continent END
FROM world
WHERE name LIKE 'A%' OR name LIKE 'B%'


-- 13. Put the continents right... 
-- Oceania becomes Australasia Countries in Eurasia and Turkey 
-- go to Europe/Asia Caribbean islands starting with 'B' go to North America, 
-- other Caribbean islands go to South America Order by country name in 
-- ascending order Test your query using the WHERE clause with the following:
-- WHERE tld IN ('.ag','.ba','.bb','.ca','.cn','.nz','.ru','.tr','.uk')
-- Show the name, the original continent and the new continent of all countries.


SELECT name, continent, 
  CASE WHEN continent = 'Oceania' THEN 'Australasia'
    WHEN name IN ('Eurasia','Turkey') OR continent IN ('Eurasia','Turkey')
      THEN 'Europe/Asia'
    WHEN continent = 'Caribbean' AND name LIKE 'B%' THEN 'North America'
    WHEN continent = 'Caribbean' THEN 'South America'
    ELSE continent END
FROM world
WHERE tld IN ('.ag','.ba','.bb','.ca','.cn','.nz','.ru','.tr','.uk')
ORDER BY name



---------------------------------

-- III. SELECT from Nobel Tutorial

---------------------------------

-- 11.  Find all details of the prize won by PETER GRÜNBERG; Non-ASCII characters

SELECT * from nobel
WHERE winner = 'PETER GRÜNBERG'

-- 12. Find all details of the prize won by EUGENE O 'NEILL; Escaping single quotes

SELECT * FROM nobel
WHERE winner = 'EUGENE O''NEILL'

-- 13.  List the winners, year and subject where the winner starts with Sir. 
-- Show the the most recent first, then by name order.

SELECT winner, yr, subject FROM nobel
WHERE winner LIKE 'Sir%'
ORDER by yr DESC, winner

-- 14. The expression subject IN ('Chemistry','Physics') can be used as a 
-- value - it will be 0 or 1. Show the 1984 winners and subject ordered by 
-- subject and winner name; but list Chemistry and Physics last.

SELECT winner, subject
  FROM nobel
 WHERE yr=1984
 ORDER BY subject IN ('Physics','Chemistry'), subject, winner


-- Quiz 2. Select the code that shows how many Chemistry awards were given 
-- between 1950 and 1960

SELECT COUNT(subject) FROM nobel
 WHERE subject = 'Chemistry'
   AND yr BETWEEN 1950 AND 1960


-- Quiz 3. Pick the code that shows the amount of years where no Medicine 
-- awards were given

SELECT COUNT(DISTINCT yr) FROM nobel
 WHERE yr NOT IN (SELECT DISTINCT yr FROM nobel WHERE subject = 'Medicine')


-- Quiz 6. Select the code, which shows the years when a Medicine award was 
-- given but no Peace or Literature award was

SELECT DISTINCT yr FROM nobel 
 WHERE yr NOT IN (SELECT yr FROM nobel WHERE subject IN ('Peace', 'Literature'))
AND subject = 'Medicine'



---------------------------------

-- IV. SELECT within SELECT Tutorial

---------------------------------

-- 3. List the name and continent of countries in the continents containing 
-- either Argentina or Australia. Order by name of the country.

SELECT name, continent FROM world
WHERE continent IN 
(SELECT continent FROM world 
WHERE name IN ('Argentina', 'Australia'))
ORDER BY name


-- 4. Which country has a population that is more than Canada but less than Poland? 
-- Show the name and the population.

SELECT name, population FROM world
WHERE population > (SELECT population FROM world WHERE name = 'Canada') AND 
population < (SELECT population FROM world WHERE name = 'Poland')


-- 5. Show the name and the population of each country in Europe. 
-- Show the population as a percentage of the population of Germany

SELECT name, CONCAT(ROUND(population/(SELECT population FROM world 
	WHERE name = 'Germany')*100, 0), '%') FROM world
WHERE continent = 'Europe'


-- 6. Which countries have a GDP greater than every country in Europe? 
-- [Give the name only.] (Some countries may have NULL gdp values)

SELECT name FROM world
WHERE gdp > ALL (SELECT gdp FROM world WHERE continent = 'Europe' AND gdp > 0)


-- 7. Find the largest country (by area) in each continent, 
-- show the continent, the name and the area; Pay attention to the equal sign (“=”)

SELECT continent, name, area FROM world x
  WHERE area >= ALL
    (SELECT area FROM world y
        WHERE y.continent=x.continent
          AND area >0)

-- 8. List each continent and the name of the country that comes first alphabetically.

SELECT continent, name FROM world x
WHERE x.name <= ALL (
SELECT name FROM world y WHERE x.continent = y.continent)


-- 9. Find the continents where all countries have a population <= 25000000. 
-- Then find the names of the countries associated with these continents. 
-- Show name, continent and population.

 SELECT name, continent, population FROM world
 WHERE continent IN (
  SELECT continent FROM world x
   WHERE 25000000 >= (SELECT MAX(population) FROM world y 
    WHERE x.continent = y.continent))


 SELECT name, continent, population FROM world
 WHERE continent IN (
  SELECT continent FROM world x
   WHERE 25000000 >= ALL(SELECT population FROM world y 
    WHERE x.continent = y.continent))


-- 10. Some countries have populations more than three times that of any of 
-- their neighbors (in the same continent). Give the countries and continents.

SELECT name, continent FROM world
 WHERE name IN (
  SELECT name FROM world x
   WHERE x.population/3 >= ALL(SELECT population FROM world y 
   	WHERE x. continent = y. continent AND x.name != y.name) )


SELECT name, continent FROM world
 WHERE name IN (
  SELECT name FROM world x
   WHERE x.population/3 >=(SELECT MAX(population) FROM world y 
   	WHERE x. continent = y. continent AND x.name != y.name) )


SELECT name, continent FROM world
 WHERE name IN (
  SELECT name FROM world x
   WHERE x.population >=(SELECT MAX(population)*3 FROM world y 
   	WHERE x. continent = y. continent AND x.name != y.name) )



-- Quiz 1. Select the code that shows the name, region and population of 
-- the smallest country in each region

SELECT name, region, population FROM bbc
WHERE region IN (
	SELECT region FROM world x
	WHERE x.population <= ALL(SELECT population FROM bbc y 
		WHERE x.region = y.reigon AND population > 0))


-- Quiz 2. Select the code that shows the countries belonging to regions 
-- with all populations over 50000

SELECT name, region, population FROM bbc
WHERE region IN (
	SELECT region FROM world x
	WHERE 50000 <= ALL(SELECT population FROM bbc y WHERE x.region = y.reigon 
    AND population > 0))

-- Quiz 3. Select the code that shows the countries with a less than a third of 
-- the population of the countries around it

SELECT name, region, population FROM bbc x
WHERE populuatin < ALL(SELECT populuatin / 3 FROM bbc y 
  WHERE x.region = y.region AND x.name ! = y.name)

-- Quiz 5. Select the code that would show the countries with a greater GDP 
-- than any country in Africa (some countries may have NULL gdp values).

SELECT name FROM bbc x
WHERE gdp > (SELECT MAX(gdp) FROM bbc y WHERE region = 'Africa')

-- Quiz 6. Select the code that shows the countries with population 
-- smaller than Russia but bigger than Denmark

SELECT name FROM bbc
WHERE population < (SELECT populuation FROM bbc WHERE name = 'Russia') 
AND populuation > (SELECT populuation FROM bbc WHERE name = 'Denmark') 


---------------------------------

-- V. SUM and COUNT

---------------------------------

-- 7. For each continent show the continent and number of countries 
-- with populations of at least 10 million.

SELECT continent, COUNT(*) FROM world
WHERE population >= 10000000
GROUP BY continent

-- 8. List the continents that have a total population of at least 100 million.

SELECT continent FROM world
GROUP BY continent
HAVING SUM(population) > 100000000

---------------------------------

-- VI. JOIN operation, GROPU BY

---------------------------------

-- dataset : UEFA EURO 2012 Football Championship in Poland and Ukraine.

-- 3. Modify it to show the player, teamid, stadium and mdate and for 
-- every German goal.

SELECT player, teamid, stadium, mdate
FROM game 
JOIN goal ON (game.id = goal.matchid)
WHERE teamid = 'GER' 

-- 4. Show the team1, team2 and player for every goal scored by a player 
-- called Mario player LIKE 'Mario%'

SELECT team1, team2, player FROM game
JOIN goal ON game.id = goal.matchid
WHERE player LIKE 'Mario%'

-- 5. Show player, teamid, coach, gtime for all goals scored in the 
-- first 10 minutes gtime<=10

SELECT player, teamid, coach, gtime
  FROM goal JOIN eteam ON goal.teamid = eteam.id
 WHERE gtime<=10

-- 6. List the the dates of the matches and the name of the team in which 
-- 'Fernando Santos' was the team1 coach.

SELECT mdate, teamname FROM game
JOIN eteam ON game.team1 = eteam.id
WHERE coach = 'Fernando Santos'

-- 7. List the player for every goal scored in a game where the stadium 
-- was 'National Stadium, Warsaw'

SELECT player FROM game
JOIN goal ON game.id = goal.matchid
WHERE stadium = 'National Stadium, Warsaw'

-- 8. The example query shows all goals scored in the Germany-Greece quarterfinal.
-- Instead show the name of all players who scored a goal against Germany.

SELECT DISTINCT player
  FROM game JOIN goal ON matchid = id 
    WHERE teamid != 'GER' AND (team1 ='GER' OR team2 ='GER')


-- 9. Show teamname and the total number of goals scored.

SELECT teamname, COUNT(gtime)
  FROM eteam JOIN goal ON id=teamid
 GROUP BY teamname

-- 10. Show the stadium and the number of goals scored in each stadium.

SELECT stadium, COUNT(gtime)
FROM game JOIN goal ON goal.matchid = game.id
GROUP BY stadium

-- 11. For every match involving 'POL', show the matchid, 
-- date and the number of goals scored.

SELECT matchid, mdate, COUNT(gtime) 
  FROM game JOIN goal ON goal.matchid = game.id
  WHERE team1 = 'POL' OR team2 = 'POL'
  GROUP BY matchid, mdate

-- 12. For every match where 'GER' scored, show matchid, match date and the 
-- number of goals scored by 'GER'

SELECT matchid, mdate, COUNT(gtime)
  FROM game JOIN goal ON game.id = goal.matchid
  WHERE teamid = 'GER'
  GROUP BY matchid, mdate


-- 13. List every match with the goals scored by each team as shown. 
-- This will use "CASE WHEN" which has not been explained in any previous exercises.

SELECT mdate,
  team1, SUM(CASE WHEN teamid=team1 THEN 1 ELSE 0 END) AS score1,
  team2, SUM(CASE WHEN teamid=team2 THEN 1 ELSE 0 END) AS score2
  FROM game LEFT JOIN goal ON matchid = id
  GROUP BY mdate, team1, team2
  ORDER BY mdate, matchid


-- Quize 5. Select the code which would show the player and their team for 
-- those who have scored against Poland(POL) in National Stadium, Warsaw.

SELECT DISTINCT player, teamid 
   FROM game JOIN goal ON matchid = id 
  WHERE stadium = 'National Stadium, Warsaw' 
 AND (team1 = 'POL' OR team2 = 'POL')
   AND teamid != 'POL'


-- Quize 6. 6. Select the code which shows the player, their team and the time 
-- they scored, for players who have played in Stadion Miejski (Wroclaw) 
-- but not against Italy(ITA).

SELECT DISTINCT player, teamid, gtime
  FROM game JOIN goal ON matchid = id
 WHERE stadium = 'Stadion Miejski (Wroclaw)'
   AND (( teamid = team2 AND team1 != 'ITA') OR ( teamid = team1 AND team2 != 'ITA'))



---------------------------------

-- VII. More JOIN operation: Movie Database

---------------------------------

-- 7. Obtain the cast list for 'Casablanca'. 
-- Use movieid=11768, this is the value that you obtained in the previous question.

SELECT name FROM actor
WHERE id IN (SELECT actorid FROM casting WHERE movieid = 11768)


-- 8. Obtain the cast list for the film 'Alien'

SELECT actor.name FROM actor
  JOIN casting ON casting.actorid = actor.id
  JOIN movie ON casting.movieid = movie.id
  WHERE movie.title = 'Alien'

-- 9. List the films in which 'Harrison Ford' has appeared


SELECT title FROM movie
JOIN casting ON movie.id = casting.movieid
JOIN actor ON actor.id = casting.actorid
WHERE actor.name = 'Harrison Ford'

-- 10. List the films where 'Harrison Ford' has appeared - but not in the 
-- starring role. [Note: the ord field of casting gives the position of the actor. 
-- If ord=1 then this actor is in the starring role]


SELECT title FROM movie
JOIN casting ON movie.id = casting.movieid
JOIN actor ON actor.id = casting.actorid
WHERE actor.name = 'Harrison Ford' AND casting.ord !=1


-- 11. List the films together with the leading star for all 1962 films.

SELECT title, actor.name FROM movie
JOIN casting ON casting.movieid = movie.id
JOIN actor ON actor.id = casting.actorid
WHERE yr = 1962 AND casting.ord = 1

-- 12. Which were the busiest years for 'John Travolta', show the year 
-- and the number of movies he made each year for any year in which he 
-- made more than 2 movies.

SELECT movie.yr, COUNT(*) AS x FROM movie
JOIN casting ON movie.id = casting.movieid
JOIN actor ON actor.id = casting.actorid
WHERE actor.name = 'John Travolta'
GROUP BY yr
HAVING COUNT(*)  > 2


-- 13. List the film title and the leading actor for all of the films 
-- 'Julie Andrews' played in.

SELECT movie.title, actor.name FROM movie
 JOIN casting ON casting.movieid = movie.id
 JOIN actor ON casting.actorid = actor.id
WHERE casting.ord = 1 AND movie.id IN 
(SELECT movie.id FROM movie
  JOIN casting ON casting.movieid = movie.id 
  JOIN actor ON casting.actorid = actor.id
  WHERE actor.name = 'Julie Andrews'
)

-- 14. Obtain a list, in alphabetical order, of actors who've had at 
-- least 30 starring roles.

SELECT actor.name FROM actor
  JOIN casting ON casting.actorid = actor.id
  WHERE casting.ord = 1
  GROUP BY actor.name
  HAVING COUNT(*) >= 30
  ORDER BY actor.name

-- 15. List the films released in the year 1978 ordered by the number 
-- of actors in the cast, then by title.

SELECT movie.title, COUNT(*) FROM movie
  JOIN casting ON movie.id = casting.movieid
  WHERE yr = 1978
  GROUP BY movie.title
  ORDER BY COUNT(*) DESC, movie.title

-- List all the people who have worked with 'Art Garfunkel'.

SELECT DISTINCT actor.name FROM actor
  JOIN casting ON casting.actorid = actor.id
  JOIN movie ON casting.movieid = movie.id
  WHERE movie.id IN 
  (SELECT movie.id FROM movie
    JOIN casting ON casting.movieid = movie.id 
    JOIN actor ON casting.actorid = actor.id
    WHERE actor.name = 'Art Garfunkel'
  ) AND actor.name != 'Art Garfunkel'

-- Quiz 1

--1. Select the statement which lists the unfortunate directors of the movies 
-- which have caused financial loses (gross < budget)

SELECT name
  FROM actor INNER JOIN movie ON actor.id = director
 WHERE gross < budget


---------------------------------

-- VIII. Using Null - Dataset Teachers and Departments

---------------------------------


-- 5. Use COALESCE to print the mobile number. Use the number '07986 444 2266' 
-- if there is no number given. Show teacher name and mobile number or '07986 444 2266'

SELECT name, COALESCE(mobile,'07986 444 2266') AS mobile 

FROM teacher

-- 6. Use the COALESCE function and a LEFT JOIN to print the teacher name and 
-- department name. Use the string 'None' where there is no department.

SELECT teacher.name, COALESCE(dept.name, 'None') as dept
 FROM teacher LEFT JOIN dept
           ON (teacher.dept=dept.id)


-- 7. Use COUNT to show the number of teachers and the number of mobile phones.

SELECT COUNT(name), COUNT(mobile) FROM teacher


-- 8. Use COUNT and GROUP BY dept.name to show each department and the number of staff. 
-- Use a RIGHT JOIN to ensure that the Engineering department is listed.

SELECT dept.name, COUNT(teacher.name) FROM teacher
RIGHT JOIN dept ON teacher.dept = dept.id
GROUP BY dept.name

-- 9. Use CASE to show the name of each teacher followed by 'Sci' if the teacher 
-- is in dept 1 or 2 and 'Art' otherwise.

SELECT name,
CASE WHEN dept = 1 OR dept = 2 THEN 'Sci' 
          ELSE 'Art' END as Type
FROM teacher


-- 10. Use CASE to show the name of each teacher followed by 'Sci' if the teacher 
-- is in dept 1 or 2, show 'Art' if the teacher's dept is 3 and 'None' otherwise.

SELECT name,
CASE WHEN dept = 1 OR dept = 2 THEN 'Sci' 
          WHEN dept = 3 THEN 'Art' 
          ELSE 'None' END as Type
FROM teacher


-- Quiz 3. Select out of following the code which uses a JOIN to show a list of 
-- all the departments and number of employed teachers
 
 SELECT dept.name, COUNT(teacher.name) FROM teacher RIGHT JOIN 
 dept ON dept.id = teacher.dept GROUP BY dept.name

---------------------------------

-- IX. Self Join - Edinburgh Buses Dataset

---------------------------------

-- 3. Give the id and the name for the stops on the '4' 'LRT' service.

SELECT id, name FROM stops
JOIN route ON route.stop = stops.id
WHERE route.company = 'LRT' AND num = 4


-- 4. The query shown gives the number of routes that visit either London Road (149)
-- or Craiglockhart (53). Run the query and notice the two services that link these 
-- stops have a count of 2. Add a HAVING clause to restrict the output to these two routes.

SELECT company, num, COUNT(*)
FROM route WHERE stop=149 OR stop=53
GROUP BY company, num
HAVING COUNT(*) = 2

-- 5. Execute the self join shown and observe that b.stop gives all the places 
-- you can get to from Craiglockhart, without changing routes. 
-- Change the query so that it shows the services from Craiglockhart to London Road.

SELECT a.company, a.num, a.stop, b.stop
FROM route a JOIN route b ON
  (a.company = b.company AND a.num = b.num)
WHERE a.stop = 53 AND b.stop = 149

-- 6. The query shown is similar to the previous one, however by joining two copies 
-- of the stops table we can refer to stops by name rather than by number. 
-- Change the query so that the services between 'Craiglockhart' and 
-- 'London Road' are shown. If you are tired of these places try 'Fairmilehead' 
-- against 'Tollcross'

SELECT a.company, a.num, stopa.name, stopb.name
FROM route a JOIN route b ON
  (a.company=b.company AND a.num=b.num)
  JOIN stops stopa ON (a.stop=stopa.id)
  JOIN stops stopb ON (b.stop=stopb.id)
WHERE stopa.name='Craiglockhart' and stopb.name = 'London Road'

-- 7. Give a list of all the services which connect stops 115 and 137 
-- ('Haymarket' and 'Leith')

SELECT DISTINCT a.company, a.num
  FROM route a JOIN route b ON (a.num = b.num AND a.company = b.company)
  JOIN stops stopa ON a.stop = stopa.id
  JOIN stops stopb ON b.stop = stopb.id
  WHERE stopa.name = 'Haymarket' AND stopb.name = 'Leith'

-- 8. Give a list of the services which connect the stops 'Craiglockhart' and 'Tollcross'

SELECT DISTINCT a.company, a.num
  FROM route a JOIN route b ON (a.num = b.num AND a.company = b.company)
  JOIN stops stopa ON a.stop = stopa.id
  JOIN stops stopb ON b.stop = stopb.id
  WHERE stopa.name = 'Craiglockhart' AND stopb.name = 'Tollcross'

-- 9. Give a distinct list of the stops which may be reached from 'Craiglockhart'
--  by taking one bus, including 'Craiglockhart' itself, offered by the LRT company. 
-- Include the company and bus no. of the relevant services.

SELECT DISTINCT stopb.name, a.company, a.num
  FROM route a JOIN route b ON (a.num = b.num AND a.company = b.company AND a.company = 'LRT')
  JOIN stops stopa ON a.stop = stopa.id
  JOIN stops stopb ON b.stop = stopb.id
  WHERE stopa.name = 'Craiglockhart' OR stopb.name = 'Craiglockhart' 

-- 10. Find the routes involving two buses that can go from Craiglockhart to Sighthill.
-- Show the bus no. and company for the first bus, the name of the stop for the transfer,
-- and the bus no. and company for the second bus.

SELECT c1.num, c1.company, c1.astop, c2.num, c2.company FROM
(SELECT DISTINCT a.company, a.num, stopa.name AS astop, stopb.name AS bstop, b.num AS bnum
  FROM route a JOIN route b ON (a.num = b.num AND a.company = b.company )
  JOIN stops stopa ON a.stop = stopa.id
  JOIN stops stopb ON b.stop = stopb.id
  WHERE stopa.name = 'Craiglockhart' OR stopb.name = 'Craiglockhart') c1
JOIN
(SELECT DISTINCT a.company, a.num, stopa.name AS astop, stopb.name AS bstop, b.num AS bnum
  FROM route a JOIN route b ON (a.num = b.num AND a.company = b.company)
  JOIN stops stopa ON a.stop = stopa.id
  JOIN stops stopb ON b.stop = stopb.id
  WHERE stopa.name = 'Sighthill' OR stopb.name = 'Sighthill') c2
ON c1.astop = c2.astop
ORDER BY LENGTH(c1.num), c1.bnum, c1.astop, LENGTH(c2.num), c2.bnum


SELECT DISTINCT a.num, a.company, stopb.name ,  c.num,  c.company
FROM route a JOIN route b
ON (a.company = b.company AND a.num = b.num)
JOIN ( route c JOIN route d ON (c.company = d.company AND c.num= d.num))
JOIN stops stopa ON (a.stop = stopa.id)
JOIN stops stopb ON (b.stop = stopb.id)
JOIN stops stopc ON (c.stop = stopc.id)
JOIN stops stopd ON (d.stop = stopd.id)
WHERE  stopa.name = 'Craiglockhart' AND stopd.name = 'Sighthill'
            AND  stopb.name = stopc.name
ORDER BY LENGTH(a.num), b.num, stopb.id, LENGTH(c.num), d.num






















