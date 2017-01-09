
-- 175. Combine Two Tables

/*

-- Table: Person

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| PersonId    | int     |
| FirstName   | varchar |
| LastName    | varchar |
+-------------+---------+
PersonId is the primary key column for this table.

-- Table: Address

+-------------+---------+
| Column Name | Type    |
+-------------+---------+
| AddressId   | int     |
| PersonId    | int     |
| City        | varchar |
| State       | varchar |
+-------------+---------+
AddressId is the primary key column for this table.

Write a SQL query for a report that provides the following information 
for each person in the Person table, regardless if there is an address 
for each of those people:

FirstName, LastName, City, State

*/

SELECT FirstName, LastName, City, State FROM Person
LEFT JOIN Address ON Person.PersonID = Address.PersonId

-- 176. Second Highest Salary

/*

Write a SQL query to get the second highest salary from the Employee table.

+----+--------+
| Id | Salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
For example, given the above Employee table, the second highest salary is 200. 

If there is no second highest salary, then the query should return null.

*/


SELECT IFNULL((SELECT DISTINCT Salary FROM Employee ORDER BY Salary 
  DESC LIMIT 1,1),Null) SecondHighestSalary


-- 177. Nth Highest Salary

/*

Write a SQL query to get the nth highest salary from the Employee table.

+----+--------+
| Id | Salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
For example, given the above Employee table, the nth highest salary where n = 2 is 200. 

If there is no nth highest salary, then the query should return null.


*/

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
DECLARE M INT;
SET M = N-1;
  RETURN (
      SELECT DISTINCT Salary FROM Employee ORDER BY Salary DESC LIMIT M, 1
  );
END

-- 178. Rank Score

/*

Write a SQL query to rank scores. If there is a tie between two scores, 
both should have the same ranking. Note that after a tie, the next ranking 
number should be the next consecutive integer value. In other words, 
there should be no "holes" between ranks.

+----+-------+
| Id | Score |
+----+-------+
| 1  | 3.50  |
| 2  | 3.65  |
| 3  | 4.00  |
| 4  | 3.85  |
| 5  | 4.00  |
| 6  | 3.65  |
+----+-------+
For example, given the above Scores table, your query should generate 
the following report (order by highest score):

+-------+------+
| Score | Rank |
+-------+------+
| 4.00  | 1    |
| 4.00  | 1    |
| 3.85  | 2    |
| 3.65  | 3    |
| 3.65  | 3    |
| 3.50  | 4    |
+-------+------+

*/

SELECT DISTINCT Score FROM Scores
ORDER BY Score DESC

 /*

(8)SELECT (9)DISTINCT
(11)<TOP_specification> <select_list>
(1)FROM <left_table>
(3)　<join_type> JOIN <right_table>
(2)　 ON <join_condition>
(4)WHERE <where_condition>
(5)GROUP BY <group_by_list>
(6)WITH {CUBE | ROLLUP}
(7)HAVING <having_condition>
(10)ORDER BY <order_by_list>

*/

-- Method 1

SELECT Score, (SELECT COUNT(*) FROM (SELECT DISTINCT Score s FROM Scores) t 
  WHERE Score <= s) Rank 
FROM Scores ORDER BY Score DESC;

--
SELECT Score, (SELECT COUNT(DISTINCT Score) FROM Scores WHERE s.Score <= Score) Rank
FROM Scores s ORDER BY Score DESC;


-- Method 2
-- inner join

SELECT s.Score, COUNT(*) Rank
FROM Scores s INNER JOIN (SELECT DISTINCT Score FROM Scores) t 
  WHERE s.Score <= t.Score
GROUP BY s.id, s.Score
ORDER BY s.Score DESC;

--

SELECT s.Score, COUNT(DISTINCT t.Score) Rank
FROM Scores s JOIN Scores t ON s.Score <= t.Score
GROUP BY s.Id, s.Score
ORDER BY s.Score DESC;

SELECT s.Score, COUNT(*) Rank
FROM Scores s JOIN (SELECT DISTINCT Score FROM Scores) t ON s.Score <= t.Score
GROUP BY s.Id, s.Score
ORDER BY s.Score DESC;

-- Method 3
-- User-Defined Variables (UDF)

SELECT Score, (@rank := @rank + IF(@pre = (@pre := Score), 0, 1)) Rank
FROM Scores, (SELECT @pre := -1, @rank := 0) INIT
ORDER BY Score DESC;

-- 
SELECT Score, Rank FROM(
  SELECT    Score,
            @curRank := @curRank + IF(@prevScore = Score, 0, 1) AS Rank,
            @prevScore := Score
  FROM      Scores s, (SELECT @curRank := 0) r, (SELECT @prevScore := NULL) p
  ORDER BY  Score DESC
) t;


-- 182. Dupicate Emails

/*

Write a SQL query to find all duplicate emails in a table named Person.

+----+---------+
| Id | Email   |
+----+---------+
| 1  | a@b.com |
| 2  | c@d.com |
| 3  | a@b.com |
+----+---------+
For example, your query should return the following for the above table:

+---------+
| Email   |
+---------+
| a@b.com |
+---------+
Note: All emails are in lowercase.

*/

SELECT Email FROM Person Group BY Email HAVING COUNT(*) > 1

-- 181. Employees Earning More Than Their Managers  

/*

The Employee table holds all employees including their managers. 
Every employee has an Id, and there is also a column for the manager Id.

+----+-------+--------+-----------+
| Id | Name  | Salary | ManagerId |
+----+-------+--------+-----------+
| 1  | Joe   | 70000  | 3         |
| 2  | Henry | 80000  | 4         |
| 3  | Sam   | 60000  | NULL      |
| 4  | Max   | 90000  | NULL      |
+----+-------+--------+-----------+

Given the Employee table, write a SQL query that finds out employees who earn more 
than their managers. For the above table, Joe is the only employee 
who earns more than his manager.

+----------+
| Employee |
+----------+
| Joe      |
+----------+

*/

SELECT a.Name AS Employee FROM Employee a
JOIN Employee b ON a.ManagerID = b.Id
WHERE a.Salary > b.Salary



-- 183. Customers Who Never Order  

/* 

Suppose that a website contains two tables, the Customers table and 
the Orders table. Write a SQL query to find all customers who never order anything.

Table: Customers.

+----+-------+
| Id | Name  |
+----+-------+
| 1  | Joe   |
| 2  | Henry |
| 3  | Sam   |
| 4  | Max   |
+----+-------+

Table: Orders.

+----+------------+
| Id | CustomerId |
+----+------------+
| 1  | 3          |
| 2  | 1          |
+----+------------+
Using the above tables as example, return the following:

+-----------+
| Customers |
+-----------+
| Henry     |
| Max       |
+-----------+

*/

SELECT Customers.Name AS Customers FROM Customers
LEFT JOIN Orders ON Customers.Id = Orders.CustomerId 
WHERE Orders.CustomerId IS NULL


-- 197. Rising Temperature  

/*

Given a Weather table, write a SQL query to find all dates' Ids with higher 
temperature compared to its previous (yesterday's) dates.

+---------+------------+------------------+
| Id(INT) | Date(DATE) | Temperature(INT) |
+---------+------------+------------------+
|       1 | 2015-01-01 |               10 |
|       2 | 2015-01-02 |               25 |
|       3 | 2015-01-03 |               20 |
|       4 | 2015-01-04 |               30 |
+---------+------------+------------------+
For example, return the following Ids for the above Weather table:
+----+
| Id |
+----+
|  2 |
|  4 |
+----+

*/

/*
CREATE TABLE Weather(Id INTEGER, Date DATE, Temperature INTEGER);

INSERT INTO Weather 
  VALUES(1,'2015-01-01',10), 
  (2,'2015-01-02',25),
   (3,'2015-01-03',20), 
   (4,'2015-01-04',30);
*/

SELECT a.Id 
FROM Weather a JOIN Weather b 
WHERE datediff(a.Date,b.Date) = 1 AND a.Temperature > b. Temperature;

--
SELECT a.Id 
FROM Weather a JOIN Weather b ON a.Temperature > b.Temperature
WHERE datediff(a.Date, b.Date) = 1;

SELECT a.Id 
FROM Weather a, Weather b
WHERE a.Temperature > b.Temperature AND datediff(a.Date, b.Date) = 1;


-- 196. Delete Duplicate Emails  

/*

Write a SQL query to delete all duplicate email entries in a table named Person, 
keeping only unique emails based on its smallest Id.

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+

Id is the primary key column for this table.
For example, after running your query, the above Person table should have the 
following rows:

+----+------------------+
| Id | Email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
+----+------------------+

*/

DELETE a FROM Person a JOIN Person b ON a.Email = b.Email Where a.Id > b.Id

DELETE FROM Person WHERE Id NOT IN 
(SELECT minID FROM (SELECT MIN(Id) AS minID FROM Person GROUP BY Email) t)


-- 180 Consecutive Numbers  

/*

Write a SQL query to find all numbers that appear at least three times consecutively.

+----+-----+
| Id | Num |
+----+-----+
| 1  |  1  |
| 2  |  1  |
| 3  |  1  |
| 4  |  2  |
| 5  |  1  |
| 6  |  2  |
| 7  |  2  |
+----+-----+
For example, given the above Logs table, 1 is the only number that appears 
consecutively for at least three times.

*/

/*
CREATE TABLE ConNum(ID INTEGER, num INTEGER);
INSERT INTO ConNum VALUES (1,1), (2,1), (3,1), (4,2), (5,1),(6,2),(7,2);
*/

SELECT DISTINCT a.Num AS ConsecutiveNums FROM Logs a, Logs b, Logs c
WHERE a.num = b.num AND b.num = c.num AND a.Id = b.Id + 1 AND b.Id = c.Id + 1;


-- 184. Department Highest Salary  

/*

The Employee table holds all employees. Every employee has an Id, a salary, 
and there is also a column for the department Id.

+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
+----+-------+--------+--------------+

CREATE TABLE Employee(Id INTEGER, Name CHAR(20), Salary Integer, DepartmentId Integer);
INSERT INTO Employee VALUES (1, 'Joe', 70000, 1), (2, 'Henry', 80000, 2), (3, 'Sam', 60000, 2)
, (4, 'Max', 90000, 1);


The Department table holds all departments of the company.

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+

CREATE TABLE Department(Id INTEGER, Name CHAR(20));
INSERT INTO Department VALUES (1, 'IT'),(2, 'Sales');

Write a SQL query to find employees who have the highest salary in each of the departments. 
For the above tables, Max has the highest salary in the IT department and 
Henry has the highest salary in the Sales department.

+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT         | Max      | 90000  |
| Sales      | Henry    | 80000  |
+------------+----------+--------+

*/

SELECT t.Department, b.name AS Employee, t.Salary FROM
(SELECT Department.Name AS Department, MAX(a.Salary) AS Salary, a.DepartmentId AS DepartmentId
FROM Employee a JOIN Department ON a.DepartmentId = Department.Id
GROUP BY a.DepartmentId, Department.Name) t
JOIN Employee b WHERE b.Salary = t.Salary AND b.DepartmentId = t.DepartmentId;


-- 262. Trips and Users  

/*

The Trips table holds all taxi trips. Each trip has a unique Id, while Client_Id and Driver_Id 
are both foreign keys to the Users_Id at the Users table. Status is an ENUM type of (‘completed’, 
‘cancelled_by_driver’, ‘cancelled_by_client’).

+----+-----------+-----------+---------+--------------------+----------+
| Id | Client_Id | Driver_Id | City_Id |        Status      |Request_at|
+----+-----------+-----------+---------+--------------------+----------+
| 1  |     1     |    10     |    1    |     completed      |2013-10-01|
| 2  |     2     |    11     |    1    | cancelled_by_driver|2013-10-01|
| 3  |     3     |    12     |    6    |     completed      |2013-10-01|
| 4  |     4     |    13     |    6    | cancelled_by_client|2013-10-01|
| 5  |     1     |    10     |    1    |     completed      |2013-10-02|
| 6  |     2     |    11     |    6    |     completed      |2013-10-02|
| 7  |     3     |    12     |    6    |     completed      |2013-10-02|
| 8  |     2     |    12     |    12   |     completed      |2013-10-03|
| 9  |     3     |    10     |    12   |     completed      |2013-10-03| 
| 10 |     4     |    13     |    12   | cancelled_by_driver|2013-10-03|
+----+-----------+-----------+---------+--------------------+----------+

The Users table holds all users. Each user has an unique Users_Id, and Role is an 
ENUM type of (‘client’, ‘driver’, ‘partner’).

+----------+--------+--------+
| Users_Id | Banned |  Role  |
+----------+--------+--------+
|    1     |   No   | client |
|    2     |   Yes  | client |
|    3     |   No   | client |
|    4     |   No   | client |
|    10    |   No   | driver |
|    11    |   No   | driver |
|    12    |   No   | driver |
|    13    |   No   | driver |
+----------+--------+--------+

Write a SQL query to find the cancellation rate of requests made by unbanned 
clients between Oct 1, 2013 and Oct 3, 2013. For the above tables, your SQL query 
should return the following rows with the cancellation rate being rounded to two decimal places.

+------------+-------------------+
|     Day    | Cancellation Rate |
+------------+-------------------+
| 2013-10-01 |       0.33        |
| 2013-10-02 |       0.00        |
| 2013-10-03 |       0.50        |
+------------+-------------------+

Credits:

Special thanks to @cak1erlizhou for contributing this question, writing the problem 
description and adding part of the test cases.

*/

-- find unbanned clients

SELECT Trips.Request_at AS Day, 
	ROUND(SUM(IF(Trips.Status = 'completed',0,1))/COUNT(Trips.Id),2) AS 'Cancellation Rate'
  FROM Trips JOIN Users ON Client_Id = Users_Id
  WHERE Trips.Request_at BETWEEN '2013-10-01' AND '2013-10-03' AND Users.Banned = 'NO'
  GROUP BY Trips.Request_at;

-- 185. Department Top Three Salaries

/*

The Employee table holds all employees. Every employee has an Id, 
and there is also a column for the department Id.

+----+-------+--------+--------------+
| Id | Name  | Salary | DepartmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 70000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
+----+-------+--------+--------------+

The Department table holds all departments of the company.

+----+----------+
| Id | Name     |
+----+----------+
| 1  | IT       |
| 2  | Sales    |
+----+----------+

Write a SQL query to find employees who earn the top three salaries 
in each of the department. For the above tables, your SQL query should return the following rows.

+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT         | Max      | 90000  |
| IT         | Randy    | 85000  |
| IT         | Joe      | 70000  |
| Sales      | Henry    | 80000  |
| Sales      | Sam      | 60000  |
+------------+----------+--------+

*/

SELECT d.Name AS Department, e.Name AS Employee, e.Salary AS Salary
FROM Employee e JOIN Department d ON e.DepartmentId = d.Id
WHERE 3 > ( SELECT COUNT(DISTINCT e1.Salary) 
            FROM Employee e1 WHERE e1.DepartmentId = e.DepartmentId 
            AND e1.Salary > e.Salary)
ORDER BY d.Name, e.Salary;











