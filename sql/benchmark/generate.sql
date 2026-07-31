-- Synthetic data for index and query-plan experiments.
--
--   mysql Illuminati_bench < sql/schema.sql
--   mysql Illuminati_bench < sql/benchmark/generate.sql
--
-- Loaded into a SEPARATE database so the demo data is never polluted. The seed
-- set is 89 rows, at which size every plan is a table scan and every timing is
-- noise -- conclusions about indexes need volume to be worth anything.
--
-- Produces roughly: 1k factions, 100k members, 200k meetings, 50k artifacts,
-- 200k powers.

SET SESSION cte_max_recursion_depth = 1000000;

-- Bulk load: the generator computes parent ids arithmetically, so referential
-- integrity holds by construction. Checks are re-enabled and verified at the end.
SET FOREIGN_KEY_CHECKS = 0;

-- 1000 factions ------------------------------------------------------------
INSERT INTO Factions (Faction_Id, Aim, Symbol, HeadTitle)
WITH RECURSIVE seq(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 1000
)
SELECT n, CONCAT('Synthetic Faction ', n), CONCAT('SYM-', n), NULL
FROM seq;

-- 100k members, 100 per faction, arranged as a binary tree inside each faction
-- so the recursive descent has real depth (~7 levels) instead of a flat star.
--
-- Position j within a faction runs 1..100; j=1 is the root, and the parent of
-- j is j DIV 2. Parent ids are always lower than child ids, so the tree is
-- acyclic by construction.
INSERT INTO Faction_Members (Member_Id, Fname, Mname, Lname, Dob, Faction_Id, Leader_Id)
WITH RECURSIVE seq(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT
    n,
    CONCAT('First', n),
    NULL,
    CONCAT('Last', n),
    DATE_ADD('1950-01-01', INTERVAL (n % 20000) DAY),
    ((n - 1) DIV 100) + 1,
    CASE
        WHEN ((n - 1) % 100) = 0 THEN NULL
        ELSE (((n - 1) DIV 100) * 100) + ((((n - 1) % 100) + 1) DIV 2)
    END
FROM seq;

-- 200k meetings spread across ~5.5 years, 200 per faction.
-- Dates are spread deliberately: the whole point of the date experiments is a
-- predicate that selects a small slice of a large range.
INSERT INTO Faction_Meetings (Faction_Id, Time, Date, Agenda, Street, City, Country)
WITH RECURSIVE seq(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 200000
)
SELECT
    ((n - 1) DIV 200) + 1,
    SEC_TO_TIME(((n - 1) % 200) * 431 % 86400),
    DATE_ADD('2020-01-01', INTERVAL ((n - 1) % 200) * 10 DAY),
    CONCAT('Agenda item ', n),
    CONCAT('Street ', n), 'City', 'Country'
FROM seq;

-- 50k artifacts -------------------------------------------------------------
INSERT INTO Artifacts_And_Treasures (Artifact_Id, Origin, Date_Of_Procurement, Faction_Id)
WITH RECURSIVE seq(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 50000
)
SELECT n, CONCAT('Origin ', n), DATE_ADD('1500-01-01', INTERVAL n DAY),
       ((n - 1) % 1000) + 1
FROM seq;

-- 200k powers, 4 per artifact. Vocabulary is intentionally small and repetitive
-- so a substring search matches a predictable slice.
INSERT INTO Powers (Artifact_Id, Power)
WITH RECURSIVE seq(n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 200000
)
SELECT
    ((n - 1) DIV 4) + 1,
    CONCAT(
        ELT(((n - 1) % 4) + 1, 'Time', 'Mind', 'Reality', 'Spatial'),
        ' ',
        ELT(((n - 1) % 4) + 1, 'Manipulation', 'Control', 'Alteration', 'Folding'),
        ' variant ', n
    )
FROM seq;

SET FOREIGN_KEY_CHECKS = 1;

-- Prove the generated graph is actually valid rather than assuming it.
SELECT 'orphaned leaders' AS check_name, COUNT(*) AS violations
FROM Faction_Members c
LEFT JOIN Faction_Members p ON c.Leader_Id = p.Member_Id
WHERE c.Leader_Id IS NOT NULL AND p.Member_Id IS NULL
UNION ALL
SELECT 'self-led members', COUNT(*) FROM Faction_Members WHERE Leader_Id = Member_Id
UNION ALL
SELECT 'cross-faction leaders', COUNT(*)
FROM Faction_Members c JOIN Faction_Members p ON c.Leader_Id = p.Member_Id
WHERE c.Faction_Id <> p.Faction_Id;

ANALYZE TABLE Factions, Faction_Members, Faction_Meetings,
              Artifacts_And_Treasures, Powers;
