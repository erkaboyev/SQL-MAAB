/* ================================================
		Lesson-14: Date and time Functions,Practice
   ================================================ */

/* -------------------- EASY -------------------- */

--1)
SELECT 
    LTRIM(RTRIM(LEFT(Name, CHARINDEX(',', Name) - 1))) AS Surname,
    LTRIM(RTRIM(SUBSTRING(Name, CHARINDEX(',', Name) + 1, LEN(Name)))) AS Name
FROM TestMultipleColumns;

--2)
SELECT *
FROM TestPercent
WHERE CHARINDEX('%', Strs) > 0;
--or
SELECT *
FROM TestPercent
WHERE Strs LIKE '%[%]%'

--3)
SELECT Id, Vals, LEFT(Vals, CHARINDEX('.', Vals) - 1) AS Part1,
    CASE 
        WHEN CHARINDEX('.', Vals, CHARINDEX('.', Vals) + 1) > 0 
        THEN SUBSTRING(Vals, 
                      CHARINDEX('.', Vals) + 1, 
                      CHARINDEX('.', Vals, CHARINDEX('.', Vals) + 1) - CHARINDEX('.', Vals) - 1)
        ELSE SUBSTRING(Vals, CHARINDEX('.', Vals) + 1, LEN(Vals))
    END AS Part2,
    CASE 
        WHEN CHARINDEX('.', Vals, CHARINDEX('.', Vals) + 1) > 0 
        THEN SUBSTRING(Vals, CHARINDEX('.', Vals, CHARINDEX('.', Vals) + 1) + 1, LEN(Vals))
        ELSE NULL
    END AS Part3
FROM Splitter

--4) 
SELECT *
FROM testDots
WHERE LEN(Vals) - LEN(REPLACE(Vals, '.', '')) > 2;

--5) 
SELECT texts, LEN(texts + 'x') -1 - LEN(REPLACE(texts, ' ', '')) AS count_spaces
FROM CountSpaces

--6)
SELECT a.name
FROM Employee a
JOIN Employee b ON a.Managerid = b.id 
WHERE a.Salary>b.Salary

--7)
SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, HIRE_DATE, DATEDIFF(YEAR, HIRE_DATE, GETDATE()) - CASE
      WHEN DATEADD(YEAR, DATEDIFF(YEAR, HIRE_DATE, GETDATE()), HIRE_DATE) > GETDATE()
           THEN 1 ELSE 0
    END AS [YEARS OF SERVICE]
FROM Employees 
WHERE HIRE_DATE > DATEADD(YEAR, -15, CAST(GETDATE() AS date))
  AND HIRE_DATE < DATEADD(YEAR, -10, CAST(GETDATE() AS date))
ORDER BY HIRE_DATE;


/* -------------------- MEDIUM -------------------- */

--8)
SELECT a.Id
FROM weather a
JOIN weather b ON DATEDIFF(DAY, b.RecordDate, a.RecordDate)=1
WHERE a.temperature > b.temperature

--9) 
SELECT
  player_id,
  MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id;

--10)
SELECT s.value AS third_item
FROM fruits f
CROSS APPLY STRING_SPLIT(f.fruit_list, ',', 1) AS s
WHERE s.ordinal = 3;

--11)
;WITH svc AS (
  SELECT
      e.EMPLOYEE_ID,
      e.FIRST_NAME,
      e.LAST_NAME,
      e.HIRE_DATE,
      YearsOfService = DATEDIFF(YEAR, e.HIRE_DATE, GETDATE())
        - CASE
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, e.HIRE_DATE, GETDATE()), e.HIRE_DATE) > GETDATE()
            THEN 1 ELSE 0
          END
  FROM Employees AS e
)
SELECT
  EMPLOYEE_ID,
  FIRST_NAME,
  LAST_NAME,
  HIRE_DATE,
  YearsOfService,
  CASE
    WHEN YearsOfService < 1  THEN 'New Hire'
    WHEN YearsOfService < 5  THEN 'Junior'
    WHEN YearsOfService < 10 THEN 'Mid-Level'
    WHEN YearsOfService < 20 THEN 'Senior'
    ELSE 'Veteran'
  END AS EmploymentStage
FROM svc
ORDER BY YearsOfService DESC;

--12)
SELECT
    g.Id,
    g.VALS,
    TRY_CONVERT(int,
        CASE 
            WHEN g.VALS LIKE '[0-9]%' THEN 
                 LEFT(g.VALS, COALESCE(NULLIF(p.pos, 0) - 1, LEN(g.VALS)))
        END
    ) AS LeadingInt
FROM GetIntegers AS g
CROSS APPLY (SELECT PATINDEX('%[^0-9]%', g.VALS) AS pos) AS p
ORDER BY g.Id;

/* -------------------- HARD -------------------- */
--13)
SELECT
  m.Id,
  m.Vals,
  CASE 
    WHEN p1 = 0 THEN m.Vals 
    ELSE CONCAT(
           SUBSTRING(m.Vals, p1 + 1, COALESCE(NULLIF(p2,0), LEN(m.Vals)+1) - (p1 + 1)),
           ',',
           LEFT(m.Vals, p1 - 1),
           CASE WHEN p2 = 0 THEN '' ELSE SUBSTRING(m.Vals, p2, LEN(m.Vals) - p2 + 1) END
         )
  END AS Vals_Swapped
FROM MultipleVals AS m
CROSS APPLY (VALUES (CHARINDEX(',', m.Vals))) AS a(p1)
CROSS APPLY (VALUES (CHARINDEX(',', m.Vals, a.p1 + 1))) AS b(p2);

--14)
DECLARE @s varchar(100) = 'sdgfhsdgfhs@121313131';

CREATE TABLE dbo.StringChars (pos int NOT NULL, ch char(1) NOT NULL);

INSERT dbo.StringChars(pos, ch)
SELECT n,
       SUBSTRING(@s, n, 1)
FROM (
  SELECT TOP (LEN(@s))
         ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
  FROM sys.all_objects
) AS T;

SELECT * FROM dbo.StringChars ORDER BY pos;

--15)
SELECT a.player_id, a.device_id
FROM Activity AS a
JOIN (
  SELECT player_id, MIN(event_date) AS first_login
  FROM Activity
  GROUP BY player_id
) AS m
  ON a.player_id = m.player_id
 AND a.event_date = m.first_login;

 --16)
DECLARE @s varchar(100) = 'rtcfvty34redt';

WITH seq(n) AS (
  SELECT 1
  UNION ALL
  SELECT n + 1 FROM seq WHERE n < LEN(@s)      -- рекурсивная CTE
),
chars AS (
  SELECT n, SUBSTRING(@s, n, 1) AS ch
  FROM seq
)
SELECT
  STRING_AGG(CASE WHEN ch LIKE '[0-9]' THEN ch END, '') WITHIN GROUP (ORDER BY n) AS digits_text,
  STRING_AGG(CASE WHEN ch LIKE '[0-9]' THEN NULL ELSE ch END, '') WITHIN GROUP (ORDER BY n) AS letters_text
FROM chars
OPTION (MAXRECURSION 0);
