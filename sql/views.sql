-- Illuminati Database Management System -- views
--
-- Load after sql/schema.sql and sql/seed.sql:  mysql <dbname> < sql/views.sql
--
-- These exist so the application selects from a named relation instead of
-- embedding long SQL in Python. Ordering is deliberately left to the caller:
-- a view that imposes ORDER BY forces a sort the caller may not want.

DROP VIEW IF EXISTS v_surveillance_targets;
DROP VIEW IF EXISTS v_member_hierarchy;
DROP VIEW IF EXISTS v_faction_membership;

-- Every faction with its head and current headcount.
-- LEFT JOIN, so factions with no members appear with a count of 0 rather than
-- vanishing -- the distinction the membership statistics depend on.
CREATE VIEW v_faction_membership AS
SELECT
    f.Faction_Id,
    f.Aim,
    f.Symbol,
    f.HeadTitle,
    kim.Name             AS Head_Name,
    COUNT(fm.Member_Id)  AS Member_Count
FROM Factions f
LEFT JOIN Faction_Members fm        ON f.Faction_Id = fm.Faction_Id
LEFT JOIN Key_Illuminati_Members kim ON f.HeadTitle = kim.Title
GROUP BY f.Faction_Id, f.Aim, f.Symbol, f.HeadTitle, kim.Name;

-- The full command chain of every faction, flattened with depth levels.
-- Descent is constrained to a single faction: Leader_Id has no same-faction
-- constraint in the schema, so without it a cross-faction leader would splice
-- one faction's members into another's tree.
CREATE VIEW v_member_hierarchy AS
WITH RECURSIVE MemberHierarchy AS (
    -- Roots: members answering to nobody.
    SELECT Member_Id, Fname, Lname, Faction_Id, Leader_Id, 0 AS Level
    FROM Faction_Members
    WHERE Leader_Id IS NULL

    UNION ALL

    SELECT fm.Member_Id, fm.Fname, fm.Lname, fm.Faction_Id, fm.Leader_Id, mh.Level + 1
    FROM Faction_Members fm
    JOIN MemberHierarchy mh
      ON fm.Leader_Id  = mh.Member_Id
     AND fm.Faction_Id = mh.Faction_Id
)
SELECT
    mh.Member_Id,
    mh.Fname,
    mh.Lname,
    mh.Faction_Id,
    mh.Leader_Id,
    mh.Level,
    f.Aim AS Faction_Name,
    (SELECT COUNT(*) FROM Faction_Members sub
      WHERE sub.Leader_Id = mh.Member_Id) AS Subordinates
FROM MemberHierarchy mh
JOIN Factions f ON mh.Faction_Id = f.Faction_Id;

-- Surveillance operations with their target resolved across the specialization.
-- 'Unclassified' is not defensive padding: the schema does not force a
-- surveillance row to be exactly one of Individual or Organization, and the
-- seed data contains one operation that is neither.
CREATE VIEW v_surveillance_targets AS
SELECT
    s.Surveillance_Id,
    s.Start_Date_Of_Survey,
    CASE
        WHEN i.Surveillance_Id IS NOT NULL THEN 'Individual'
        WHEN o.Surveillance_Id IS NOT NULL THEN 'Organization'
        ELSE 'Unclassified'
    END AS Target_Type,
    -- Mirrors the CASE above rather than COALESCE(CONCAT_WS(...), o.Name):
    -- CONCAT_WS returns '' (not NULL) when every argument is NULL, so a
    -- COALESCE would latch onto the empty string and never reach o.Name.
    CASE
        WHEN i.Surveillance_Id IS NOT NULL THEN CONCAT_WS(' ', i.Fname, i.Lname)
        WHEN o.Surveillance_Id IS NOT NULL THEN o.Name
    END AS Target_Name,
    i.Nationality,
    i.Current_Location,
    o.Type      AS Organization_Type,
    o.President
FROM Surveillance s
LEFT JOIN Individuals   i ON s.Surveillance_Id = i.Surveillance_Id
LEFT JOIN Organizations o ON s.Surveillance_Id = o.Surveillance_Id;
