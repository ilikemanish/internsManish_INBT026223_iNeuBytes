CREATE DATABASE European_Football_Analysis;

USE European_Football_Analysis;

---Verify all seven tables

SELECT
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

--- Check the number of records

SELECT 'Country' AS Table_Name,
       COUNT(*) AS Total_Records
FROM dbo.Country

UNION ALL

SELECT 'League', COUNT(*)
FROM dbo.League

UNION ALL

SELECT 'Match', COUNT(*)
FROM dbo.[Match]

UNION ALL

SELECT 'Player', COUNT(*)
FROM dbo.Player

UNION ALL

SELECT 'Player_Attributes', COUNT(*)
FROM dbo.Player_Attributes

UNION ALL

SELECT 'Team', COUNT(*)
FROM dbo.Team

UNION ALL

SELECT 'Team_Attributes', COUNT(*)
FROM dbo.Team_Attributes;

---Display your first 10 matches

SELECT TOP 10 *
FROM dbo.[Match];

---Check missing values

SELECT
    COUNT(*) AS Total_Matches,

    SUM(
        CASE
            WHEN home_team_goal IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_Home_Goals,

    SUM(
        CASE
            WHEN away_team_goal IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_Away_Goals,

    SUM(
        CASE
            WHEN date IS NULL
            THEN 1 ELSE 0
        END
    ) AS Missing_Dates

FROM dbo.[Match];

---Check duplicate match IDs

SELECT
    id,
    COUNT(*) AS Duplicate_Count
FROM dbo.[Match]
GROUP BY id
HAVING COUNT(*) > 1;

---first analytical query

SELECT
    l.name AS League_Name,
    COUNT(m.id) AS Total_Matches
FROM dbo.[Match] AS m
INNER JOIN dbo.League AS l
    ON m.league_id = l.id
GROUP BY l.name
ORDER BY Total_Matches DESC;

---Explore the dataset

SELECT TOP 10 *
FROM dbo.[Match];

---Check for missing values

SELECT
    COUNT(*) AS Total_Matches,

    SUM(CASE
        WHEN date IS NULL THEN 1
        ELSE 0
    END) AS Missing_Dates,

    SUM(CASE
        WHEN home_team_api_id IS NULL THEN 1
        ELSE 0
    END) AS Missing_Home_Teams,

    SUM(CASE
        WHEN away_team_api_id IS NULL THEN 1
        ELSE 0
    END) AS Missing_Away_Teams,

    SUM(CASE
        WHEN home_team_goal IS NULL THEN 1
        ELSE 0
    END) AS Missing_Home_Goals,

    SUM(CASE
        WHEN away_team_goal IS NULL THEN 1
        ELSE 0
    END) AS Missing_Away_Goals

FROM dbo.[Match];

---Check duplicate records

SELECT
    id,
    COUNT(*) AS Duplicate_Count
FROM dbo.[Match]
GROUP BY id
HAVING COUNT(*) > 1;

---Check the date range

SELECT
    MIN(TRY_CONVERT(datetime2, [date]))
        AS First_Match_Date,

    MAX(TRY_CONVERT(datetime2, [date]))
        AS Last_Match_Date

FROM dbo.[Match];

---Check invalid goal values

SELECT
    id,
    home_team_goal,
    away_team_goal
FROM dbo.[Match]
WHERE home_team_goal < 0
   OR away_team_goal < 0;

---Check table relationships

SELECT
    COUNT(*) AS Unmatched_Home_Teams
FROM dbo.[Match] AS m
LEFT JOIN dbo.Team AS t
    ON m.home_team_api_id = t.team_api_id
WHERE t.team_api_id IS NULL;SELECT
    COUNT(*) AS Unmatched_Home_Teams
FROM dbo.[Match] AS m
LEFT JOIN dbo.Team AS t
    ON m.home_team_api_id = t.team_api_id
WHERE t.team_api_id IS NULL;

---Basic descriptive analysis
--Query 1: Find total matches
--Business question: How many football matches are recorded?

SELECT
    COUNT(*) AS Total_Matches
FROM dbo.[Match];

---Calculate total goals scored

SELECT
    SUM(home_team_goal + away_team_goal)
        AS Total_Goals
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

---Calculate average goals per match

SELECT
    ROUND(
        AVG(
            CAST(home_team_goal + away_team_goal
                AS FLOAT)
        ), 2
    ) AS Average_Goals_Per_Match
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

--- Analyze league performance using JOIN
--- Query 4: Total matches by league
--- Business question: Which league has the most matches?

SELECT
    l.name AS League_Name,
    COUNT(m.id) AS Total_Matches
FROM dbo.[Match] AS m
INNER JOIN dbo.League AS l
    ON m.league_id = l.id
GROUP BY l.name
ORDER BY Total_Matches DESC;

--- Average goals by league
--- Business question: Which league has the highest average number of goals per match?

SELECT
    l.name AS League_Name,
    COUNT(*) AS Total_Matches,
    ROUND(
        AVG(
            CAST(m.home_team_goal +
                 m.away_team_goal AS FLOAT)
        ), 2
    ) AS Average_Goals
FROM dbo.[Match] AS m
INNER JOIN dbo.League AS l
    ON m.league_id = l.id
WHERE m.home_team_goal IS NOT NULL
  AND m.away_team_goal IS NOT NULL
GROUP BY l.name
ORDER BY Average_Goals DESC;

--- Analyze team performance
--- Query 6: Top 10 teams by home goals

SELECT TOP 10
    t.team_long_name AS Team_Name,
    SUM(m.home_team_goal) AS Total_Home_Goals
FROM dbo.[Match] AS m
INNER JOIN dbo.Team AS t
    ON m.home_team_api_id = t.team_api_id
WHERE m.home_team_goal IS NOT NULL
GROUP BY t.team_api_id, t.team_long_name
ORDER BY Total_Home_Goals DESC;

---Top 10 teams by away goals

SELECT TOP 10
    t.team_long_name AS Team_Name,
    SUM(m.away_team_goal) AS Total_Away_Goals
FROM dbo.[Match] AS m
INNER JOIN dbo.Team AS t
    ON m.away_team_api_id = t.team_api_id
WHERE m.away_team_goal IS NOT NULL
GROUP BY t.team_api_id, t.team_long_name
ORDER BY Total_Away_Goals DESC;

--- Analyze match results
--- Query 8: Home wins, away wins and draws

SELECT
    SUM(CASE
        WHEN home_team_goal > away_team_goal
        THEN 1 ELSE 0
    END) AS Home_Wins,

    SUM(CASE
        WHEN home_team_goal < away_team_goal
        THEN 1 ELSE 0
    END) AS Away_Wins,

    SUM(CASE
        WHEN home_team_goal = away_team_goal
        THEN 1 ELSE 0
    END) AS Draws

FROM dbo.[Match]

WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

---Calculate home win percentage

SELECT
    ROUND(
        100.0 * SUM(CASE
            WHEN home_team_goal > away_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0),
        2
    ) AS Home_Win_Percentage
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

--- Analyze seasonal trends
--- Query 10: Total goals by season

SELECT
    season AS Season,
    COUNT(*) AS Total_Matches,
    SUM(home_team_goal + away_team_goal)
        AS Total_Goals
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL
GROUP BY season
ORDER BY season;

--- Query 11: Average goals by season

SELECT
    season,
    ROUND(
        AVG(CAST(
            home_team_goal + away_team_goal
            AS FLOAT
        )), 2
    ) AS Average_Goals
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL
GROUP BY season
ORDER BY season;

--- Rank teams using window functions
--- Query 12: Rank teams by total goals scored

WITH Team_Goals AS (
    SELECT
        home_team_api_id AS Team_ID,
        home_team_goal AS Goals
    FROM dbo.[Match]
    WHERE home_team_goal IS NOT NULL

    UNION ALL

    SELECT
        away_team_api_id AS Team_ID,
        away_team_goal AS Goals
    FROM dbo.[Match]
    WHERE away_team_goal IS NOT NULL
),
Total_Team_Goals AS (
    SELECT
        Team_ID,
        SUM(Goals) AS Total_Goals
    FROM Team_Goals
    GROUP BY Team_ID
)
SELECT
    t.team_long_name AS Team_Name,
    g.Total_Goals,
    RANK() OVER (
        ORDER BY g.Total_Goals DESC
    ) AS Team_Rank
FROM Total_Team_Goals AS g
INNER JOIN dbo.Team AS t
    ON g.Team_ID = t.team_api_id
ORDER BY Team_Rank;

--- KPI 1 – Total Matches
--- Business question: How many completed football matches are available?

SELECT
    COUNT(*) AS Total_Matches
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

--- KPI 2 – Total Goals
--- Business question: How many goals were scored across all matches?

SELECT
    SUM(home_team_goal + away_team_goal)
        AS Total_Goals
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

---KPI 3 – Average Goals per Match

SELECT
    ROUND(
        AVG(
            CAST(home_team_goal + away_team_goal
            AS FLOAT)
        ), 2
    ) AS Average_Goals_Per_Match
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

--- KPI 4 – Home Win Rate
--- Business question: What percentage of matches were won by the home team?

SELECT
    ROUND(
        100.0 *
        SUM(CASE
            WHEN home_team_goal > away_team_goal
            THEN 1 ELSE 0
        END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS Home_Win_Rate
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL

--- KPI 5 – Away Win Rate

SELECT
    ROUND(
        100.0 *
        SUM(CASE
            WHEN away_team_goal > home_team_goal
            THEN 1 ELSE 0
        END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS Away_Win_Rate
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

--- KPI 6 – Draw Rate

SELECT
    ROUND(
        100.0 *
        SUM(CASE
            WHEN home_team_goal = away_team_goal
            THEN 1 ELSE 0
        END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS Draw_Rate
FROM dbo.[Match]
WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL;

--- all six KPIs in one query

WITH Valid_Matches AS (
    SELECT
        home_team_goal,
        away_team_goal
    FROM dbo.[Match]
    WHERE home_team_goal IS NOT NULL
      AND away_team_goal IS NOT NULL
      AND home_team_goal >= 0
      AND away_team_goal >= 0
)

SELECT
    COUNT(*) AS Total_Matches,

    SUM(home_team_goal + away_team_goal)
        AS Total_Goals,

    ROUND(
        AVG(CAST(
            home_team_goal + away_team_goal
            AS FLOAT
        )), 2
    ) AS Average_Goals_Per_Match,

    ROUND(
        100.0 * SUM(CASE
            WHEN home_team_goal > away_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS Home_Win_Rate,

    ROUND(
        100.0 * SUM(CASE
            WHEN away_team_goal > home_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS Away_Win_Rate,

    ROUND(
        100.0 * SUM(CASE
            WHEN home_team_goal = away_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS Draw_Rate

FROM Valid_Matches;

AND away_team_goal IS NOT NULL;

--- Analyze KPIs by league

SELECT
    l.name AS League_Name,

    COUNT(*) AS Total_Matches,

    ROUND(
        100.0 * SUM(CASE
            WHEN m.home_team_goal > m.away_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS Home_Win_Rate,

    ROUND(
        100.0 * SUM(CASE
            WHEN m.away_team_goal > m.home_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS Away_Win_Rate,

    ROUND(
        AVG(CAST(
            m.home_team_goal + m.away_team_goal
            AS FLOAT
        )), 2
    ) AS Average_Goals

FROM dbo.[Match] AS m

INNER JOIN dbo.League AS l
    ON m.league_id = l.id

WHERE m.home_team_goal IS NOT NULL
  AND m.away_team_goal IS NOT NULL
  AND m.home_team_goal >= 0
  AND m.away_team_goal >= 0

GROUP BY l.id, l.name

ORDER BY Home_Win_Rate DESC;

--- Analyze seasonal KPI trends

SELECT
    season,

    COUNT(*) AS Total_Matches,

    ROUND(
        AVG(CAST(
            home_team_goal + away_team_goal
            AS FLOAT
        )), 2
    ) AS Average_Goals,

    ROUND(
        100.0 * SUM(CASE
            WHEN home_team_goal > away_team_goal
            THEN 1 ELSE 0
        END) / NULLIF(COUNT(*), 0), 2
    ) AS Home_Win_Rate

FROM dbo.[Match]

WHERE home_team_goal IS NOT NULL
  AND away_team_goal IS NOT NULL
  AND home_team_goal >= 0
  AND away_team_goal >= 0

GROUP BY season
ORDER BY season;

--- COHORT ANALYSIS
--- 1 - Identify each team's participation seasons

SELECT
    home_team_api_id AS Team_ID,
    season AS Season
FROM dbo.[Match]

UNION

SELECT
    away_team_api_id AS Team_ID,
    season AS Season
FROM dbo.[Match];

--- Find the first season of each team
--- Business question: In which season did each football team first appear?

WITH Team_Seasons AS (
    SELECT
        home_team_api_id AS Team_ID,
        season
    FROM dbo.[Match]

    UNION

    SELECT
        away_team_api_id AS Team_ID,
        season
    FROM dbo.[Match]
)

SELECT
    Team_ID,
    MIN(season) AS First_Season
FROM Team_Seasons
WHERE Team_ID IS NOT NULL
  AND season IS NOT NULL
GROUP BY Team_ID
ORDER BY First_Season;

--- Calculate cohort size
--- Business question: How many teams first appeared in each season?

WITH Team_Seasons AS (
    SELECT home_team_api_id AS Team_ID, season
    FROM dbo.[Match]

    UNION

    SELECT away_team_api_id AS Team_ID, season
    FROM dbo.[Match]
),

First_Season AS (
    SELECT
        Team_ID,
        MIN(season) AS Cohort_Season
    FROM Team_Seasons
    WHERE Team_ID IS NOT NULL
      AND season IS NOT NULL
    GROUP BY Team_ID
)

SELECT
    Cohort_Season,
    COUNT(*) AS Cohort_Size
FROM First_Season
GROUP BY Cohort_Season
ORDER BY Cohort_Season;

--- Calculate cohort retention

USE European_Football_Analysis;
GO

-- Step 1: Find unique team-season pairs
WITH Team_Seasons AS (
    SELECT
        home_team_api_id AS Team_ID,
        season
    FROM dbo.[Match]
    WHERE home_team_api_id IS NOT NULL
      AND season IS NOT NULL

    UNION

    SELECT
        away_team_api_id AS Team_ID,
        season
    FROM dbo.[Match]
    WHERE away_team_api_id IS NOT NULL
      AND season IS NOT NULL
),

-- Step 2: Identify each team's first season
First_Season AS (
    SELECT
        Team_ID,
        MIN(season) AS Cohort_Season
    FROM Team_Seasons
    GROUP BY Team_ID
),

-- Step 3: Calculate cohort sizes
Cohort_Size AS (
    SELECT
        Cohort_Season,
        COUNT(*) AS Total_Teams
    FROM First_Season
    GROUP BY Cohort_Season
),

-- Step 4: Track participation
Cohort_Activity AS (
    SELECT
        f.Cohort_Season,
        t.season AS Activity_Season,
        COUNT(DISTINCT t.Team_ID)
            AS Active_Teams
    FROM Team_Seasons t
    INNER JOIN First_Season f
        ON t.Team_ID = f.Team_ID
    WHERE t.season >= f.Cohort_Season
    GROUP BY
        f.Cohort_Season,
        t.season
)

-- Step 5: Calculate retention percentages
SELECT
    a.Cohort_Season,
    a.Activity_Season,
    c.Total_Teams AS Cohort_Size,
    a.Active_Teams,

    ROUND(
        100.0 * a.Active_Teams
        / NULLIF(c.Total_Teams, 0),
        2
    ) AS Retention_Rate

FROM Cohort_Activity a

INNER JOIN Cohort_Size c
    ON a.Cohort_Season = c.Cohort_Season

ORDER BY
    a.Cohort_Season,
    a.Activity_Season;

--- Create a cohort retention matrix


WITH Team_Seasons AS (
    SELECT home_team_api_id AS Team_ID, season
    FROM dbo.[Match]
    WHERE home_team_api_id IS NOT NULL
      AND season IS NOT NULL

    UNION

    SELECT away_team_api_id AS Team_ID, season
    FROM dbo.[Match]
    WHERE away_team_api_id IS NOT NULL
      AND season IS NOT NULL
),

First_Season AS (
    SELECT
        Team_ID,
        MIN(season) AS Cohort_Season
    FROM Team_Seasons
    GROUP BY Team_ID
),

Cohort_Data AS (
    SELECT
        f.Cohort_Season,
        CAST(LEFT(t.season, 4) AS INT)
        - CAST(LEFT(f.Cohort_Season, 4) AS INT)
            AS Season_Number,
        t.Team_ID
    FROM Team_Seasons t
    INNER JOIN First_Season f
        ON t.Team_ID = f.Team_ID
)

SELECT
    Cohort_Season,
    COUNT(DISTINCT CASE
        WHEN Season_Number = 0 THEN Team_ID
    END) AS Season_0,

    COUNT(DISTINCT CASE
        WHEN Season_Number = 1 THEN Team_ID
    END) AS Season_1,

    COUNT(DISTINCT CASE
        WHEN Season_Number = 2 THEN Team_ID
    END) AS Season_2,

    COUNT(DISTINCT CASE
        WHEN Season_Number = 3 THEN Team_ID
    END) AS Season_3

FROM Cohort_Data
GROUP BY Cohort_Season
ORDER BY Cohort_Season;

---- END 
