-- Illuminati Database Management System -- analytical queries
--
-- Run against a seeded database:  mysql Illuminati < sql/analytics.sql
--
-- Standalone reporting queries built on window functions. They are kept apart
-- from the application so each one can be read, run and explained on its own.
-- Every query notes the result it produces against the seed data, so a wrong
-- answer is visible rather than merely plausible.


-- ---------------------------------------------------------------------------
-- 1. Faction leaderboard: RANK vs DENSE_RANK, and a share-of-total
--
-- Shows why the two ranking functions differ. Factions 1 and 2 tie on 4 members
-- each: RANK leaves a gap after the tie (1,2,2,4,4,4), DENSE_RANK does not
-- (1,2,2,3,3,3).
--
-- SUM(COUNT(*)) OVER () is the point of interest -- the window runs *after*
-- GROUP BY, so it totals the grouped rows and yields each faction's share
-- without a second pass or a self-join.
--
-- Expect: faction 3 first with 5 members (38.5%), factions 1 and 2 tied on
-- 4 (30.8%), factions 4-6 on 0.
-- ---------------------------------------------------------------------------
SELECT
    f.Faction_Id,
    f.Aim,
    COUNT(fm.Member_Id)                                    AS Member_Count,
    -- Aliased Rank_No_Gaps rather than Dense_Rank: DENSE_RANK is a reserved
    -- word in MySQL 8 and is rejected as a bare identifier.
    RANK()       OVER (ORDER BY COUNT(fm.Member_Id) DESC)  AS Rank_With_Gaps,
    DENSE_RANK() OVER (ORDER BY COUNT(fm.Member_Id) DESC)  AS Rank_No_Gaps,
    ROUND(100.0 * COUNT(fm.Member_Id)
          / NULLIF(SUM(COUNT(fm.Member_Id)) OVER (), 0), 1) AS Pct_Of_All_Members
FROM Factions f
LEFT JOIN Faction_Members fm ON f.Faction_Id = fm.Faction_Id
GROUP BY f.Faction_Id, f.Aim
ORDER BY Member_Count DESC, f.Faction_Id;


-- ---------------------------------------------------------------------------
-- 2. Surveillance programme growth: a running total over time
--
-- COUNT(*) OVER (ORDER BY ...) with an explicit frame accumulates operations
-- chronologically. FIRST_VALUE gives every row a fixed anchor to measure from,
-- so elapsed days come out without a self-join to the earliest record.
--
-- The frame clause is spelled out rather than left to the default. With
-- ORDER BY present the default is RANGE UNBOUNDED PRECEDING, which lumps
-- together rows sharing an ORDER BY value; ROWS counts each row individually.
-- Identical here (all dates distinct) but not in general.
--
-- Expect: cumulative 1..5, elapsed days 0, 45, 89, 105, 121.
-- ---------------------------------------------------------------------------
SELECT
    Surveillance_Id,
    Start_Date_Of_Survey,
    Target_Type,
    COUNT(*) OVER (ORDER BY Start_Date_Of_Survey
                   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Cumulative_Ops,
    DATEDIFF(
        Start_Date_Of_Survey,
        FIRST_VALUE(Start_Date_Of_Survey) OVER (ORDER BY Start_Date_Of_Survey)
    ) AS Days_Since_First_Op
FROM v_surveillance_targets
ORDER BY Start_Date_Of_Survey;


-- ---------------------------------------------------------------------------
-- 3. Timeline cadence: gaps between consecutive events via LAG and LEAD
--
-- Answers "how long between events" without a self-join. The first row's
-- Days_Since_Prev is NULL by definition -- there is no previous event -- and
-- that NULL is left visible rather than coerced to 0, which would misreport
-- the gap as instantaneous.
--
-- Expect, in date order (EVT002, EVT003, EVT001, EVT005, EVT004):
-- gaps NULL, 15, 36, 4, 7.
-- ---------------------------------------------------------------------------
SELECT
    Event_Id,
    Date,
    Status,
    Description,
    LAG(Date)  OVER (ORDER BY Date) AS Prev_Event_Date,
    DATEDIFF(Date, LAG(Date) OVER (ORDER BY Date)) AS Days_Since_Prev,
    LEAD(Date) OVER (ORDER BY Date) AS Next_Event_Date
FROM Sacred_Timeline_Events
ORDER BY Date;


-- ---------------------------------------------------------------------------
-- 4. Membership age distribution: NTILE quartiles
--
-- NTILE splits the ordered set into four buckets as evenly as it can. With
-- 13 members the split is 4/3/3/3 -- the remainder lands in the earliest
-- buckets, which is NTILE's defined behaviour, not a rounding accident.
--
-- Quartiles are computed over Dob so they stay stable; Age is derived for
-- display only and moves with the calendar.
-- ---------------------------------------------------------------------------
SELECT
    Member_Id,
    CONCAT_WS(' ', Fname, Lname)              AS Member,
    Dob,
    TIMESTAMPDIFF(YEAR, Dob, CURDATE())       AS Age,
    NTILE(4) OVER (ORDER BY Dob)              AS Age_Quartile,
    CASE NTILE(4) OVER (ORDER BY Dob)
        WHEN 1 THEN 'Eldest'
        WHEN 4 THEN 'Youngest'
        ELSE 'Middle'
    END                                       AS Cohort
FROM Faction_Members
ORDER BY Dob;


-- ---------------------------------------------------------------------------
-- 5. Seniority within each faction: PARTITION BY
--
-- Restarts the ranking at every faction rather than ranking globally, so each
-- member is placed against their own faction. Faction_Size rides along from a
-- second window over the same partition -- one scan, two results.
-- ---------------------------------------------------------------------------
SELECT
    fm.Faction_Id,
    f.Aim,
    CONCAT_WS(' ', fm.Fname, fm.Lname)                                 AS Member,
    fm.Dob,
    RANK()   OVER (PARTITION BY fm.Faction_Id ORDER BY fm.Dob)         AS Seniority,
    COUNT(*) OVER (PARTITION BY fm.Faction_Id)                         AS Faction_Size,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, fm.Dob, CURDATE()))
          OVER (PARTITION BY fm.Faction_Id), 1)                        AS Faction_Avg_Age
FROM Faction_Members fm
JOIN Factions f ON fm.Faction_Id = f.Faction_Id
ORDER BY fm.Faction_Id, Seniority;


-- ---------------------------------------------------------------------------
-- 6. Widest span of control per faction: the top-N-per-group pattern
--
-- MySQL has no QUALIFY, so the window function is computed in a derived table
-- and filtered outside it -- a window function cannot appear in WHERE, because
-- WHERE is evaluated before the window is.
--
-- Member_Id breaks ties in the ORDER BY to keep the result deterministic;
-- without it, tied rows could surface in any order between runs.
-- ---------------------------------------------------------------------------
SELECT Faction_Id, Aim, Member, Subordinates
FROM (
    SELECT
        h.Faction_Id,
        h.Faction_Name                         AS Aim,
        CONCAT_WS(' ', h.Fname, h.Lname)       AS Member,
        h.Subordinates,
        ROW_NUMBER() OVER (PARTITION BY h.Faction_Id
                           ORDER BY h.Subordinates DESC, h.Member_Id) AS rn
    FROM v_member_hierarchy h
) ranked
WHERE rn = 1
ORDER BY Subordinates DESC, Faction_Id;


-- ---------------------------------------------------------------------------
-- 7. Artifact power coverage
--
-- Aggregates the 1NF child table back into a readable row per artifact, and
-- ranks by how many powers each holds.
-- ---------------------------------------------------------------------------
SELECT
    a.Artifact_Id,
    a.Origin,
    f.Aim                                             AS Controlling_Faction,
    COUNT(p.Power)                                    AS Power_Count,
    GROUP_CONCAT(p.Power ORDER BY p.Power SEPARATOR ', ') AS Powers,
    RANK() OVER (ORDER BY COUNT(p.Power) DESC)        AS Power_Rank
FROM Artifacts_And_Treasures a
LEFT JOIN Powers   p ON a.Artifact_Id = p.Artifact_Id
LEFT JOIN Factions f ON a.Faction_Id  = f.Faction_Id
GROUP BY a.Artifact_Id, a.Origin, f.Aim
ORDER BY Power_Count DESC, a.Artifact_Id;
