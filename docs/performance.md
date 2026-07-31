# Query performance

## Method

The demo database holds 89 rows. At that size every plan is a table scan and
every timing is noise, so conclusions about indexes would be worthless. All
measurements below were taken against a separate `Illuminati_bench` database
built by [`sql/benchmark/generate.sql`](../sql/benchmark/generate.sql):

| Table | Rows |
|---|---|
| `Factions` | 1,000 |
| `Faction_Members` | 100,000 |
| `Faction_Meetings` | 200,000 |
| `Artifacts_And_Treasures` | 50,000 |
| `Powers` | 200,100 |

Members are arranged as a binary tree of 100 per faction, giving the recursive
descent a real depth of 6 rather than a flat one-level star. The generator ends
by asserting the graph it produced is valid — no orphaned leaders, no self-led
members, no cross-faction leaders — all returning zero.

Timings come from `EXPLAIN ANALYZE`'s reported actual time, MySQL 8.4.9, three
runs each. `ANALYZE TABLE` was run before measuring so the optimiser had current
statistics.

---

## 1. A function around a column defeats the index

The monthly report originally filtered with `YEAR(Date) = ? AND MONTH(Date) = ?`.
Wrapping the column in a function makes the predicate **non-sargable**: the
optimiser cannot convert it into a range on the index, because it would have to
invert `YEAR()` and `MONTH()` to know which key values to seek.

Selecting December 2024 — 3,000 of 200,000 rows, 1.5%:

| Predicate | Index | Access path | Rows read | Time |
|---|---|---|---|---|
| `YEAR()/MONTH()` | none | covering scan on `PRIMARY` | 200,000 | 39.1 ms |
| range | none | covering scan on `PRIMARY` | 200,000 | 31.3 ms |
| `YEAR()/MONTH()` | `idx_meetings_date` | covering **scan** | 200,000 | 48.2 ms |
| range | `idx_meetings_date` | covering **range scan** | 3,000 | 1.32 ms |

Repeat runs: `YEAR()/MONTH()` 32.5 / 35.8 / 29.7 ms, range 1.73 / 1.05 / 1.34 ms.

**The index on its own changed nothing.** With `idx_meetings_date` in place the
function-wrapped predicate still read all 200,000 rows — it merely scanned the
new index instead of the primary key, and got slightly slower for it. Only
rewriting the predicate unlocked the index, for roughly a **25x** improvement
and a 67x reduction in rows read.

Both forms are applied in [`script.py`](../script.py) as a half-open range:

```sql
WHERE fm.Date >= MAKEDATE(?, 1) + INTERVAL (? - 1) MONTH
  AND fm.Date <  MAKEDATE(?, 1) + INTERVAL ? MONTH
```

The bounds are computed from the parameters, not from the column, so MySQL folds
them to constants (visible as `<cache>` in the plan) and still range-scans.
Half-open avoids `BETWEEN`, which would need the last day of the month and a
leap-year rule; here December correctly resolves to `2024-12-01 .. 2025-01-01`.

`idx_meetings_date` is now in [`sql/schema.sql`](../sql/schema.sql). `Date` is the
third column of the primary key `(Faction_Id, Time, Date)`, and a composite index
cannot serve a lookup that does not constrain its leading columns — so the PK was
of no use here.

---

## 2. Rewriting the correlated subquery: a modest win, honestly reported

`v_member_hierarchy` computes each member's subordinate count with a correlated
subquery, which runs once per row — 100,000 times. Replacing it with a single
pre-aggregation joined once looked like the obvious fix:

```sql
SubordinateCounts AS (
    SELECT Leader_Id, COUNT(*) AS Subordinates
    FROM Faction_Members WHERE Leader_Id IS NOT NULL GROUP BY Leader_Id
)
```

| Form | Run 1 | Run 2 | Run 3 |
|---|---|---|---|
| Correlated subquery | 459 ms | 492 ms | 463 ms |
| Pre-aggregated join | 362 ms | 357 ms | 398 ms |

Both return `99000`, so they agree.

That is about **20%** — real, but far less than expected. The plan explains why:
materialising the recursive CTE alone accounts for ~226 ms of the ~470 ms total.
The correlated subquery was never the bottleneck; the recursion is. Optimising it
harder would not have paid.

**This rewrite has not been applied.** A 20% gain does not justify making the
view harder to read, and the profile says the effort belongs elsewhere. It is
recorded here because knowing which optimisation *not* to make is the point of
measuring first.

---

## 3. Text search: what an index can and cannot rescue

`search_artifacts_by_power` matches with `LIKE '%text%'`. A leading wildcard is
unindexable by a B-tree for the same reason as case 1: a B-tree is ordered by
prefix, and a pattern that can start anywhere gives no prefix to seek on.

Searching a term matching 100 of 200,100 rows:

| Query | Index | Access path | Time |
|---|---|---|---|
| `LIKE '%Necromancy%'` | none | covering scan, 200,100 rows | 61.3 ms |
| `LIKE '%Necromancy%'` | B-tree on `Power` | covering scan, 200,100 rows | 104 ms |
| `LIKE 'Necromancy%'` | B-tree on `Power` | covering **range scan**, 100 rows | 0.098 ms |
| `MATCH … AGAINST` | `FULLTEXT` | full-text index search, 100 rows | 0.41 ms |

All four return 100 rows.

Adding a B-tree index made the leading-wildcard query **slower** — 61 ms to
104 ms — because the index is wider than the primary key, so scanning it end to
end costs more. An index that cannot be seeked is worse than no index.

Dropping the leading wildcard makes the same B-tree ~600x faster. Where a
substring match is genuinely required, `FULLTEXT` handles it in ~0.41 ms, about
**145x** faster than the scan.

`FULLTEXT` is not a drop-in replacement: it matches whole words, not substrings,
so `MATCH … AGAINST('Necro')` will not find `Necromancy` the way `LIKE
'%Necro%'` does. It also ignores tokens below `innodb_ft_min_token_size`
(3 by default) and applies a stopword list. That semantic change is why neither
index has been added to the schema — the right fix depends on the search
behaviour the application wants to promise.

### Selectivity decides whether any index is worth it

The generated vocabulary made this measurable. Searching `Time` matches
**50,000 of 200,000 rows — 25%**. At that selectivity no index helps: the
optimiser would correctly ignore one, since reading 25% of a table through
random index lookups costs more than scanning it. Indexes pay for selective
predicates; the 100-row search above is 0.05%.

---

## Applied vs. recorded

**Applied:**
- `idx_meetings_date` added to `sql/schema.sql`.
- Both `YEAR()/MONTH()` filters in `script.py` rewritten to half-open ranges.
  The full read-operation capture is byte-identical before and after.

**Deliberately not applied:**
- The subordinate-count rewrite — 20% for a real readability cost, against a
  bottleneck that lies elsewhere.
- Any index on `Powers.Power` — a B-tree does not help the query as written, and
  `FULLTEXT` would change the matching semantics.
