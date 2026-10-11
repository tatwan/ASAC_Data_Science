-- ============================================================
-- D03 Lab · Life expectancy
-- Table: owid.life_expectancy_data
-- Name: AMAL OMAR MOHAMMAD ALKILANY
-- For every question, fill in all four comment lines, then write the query under them.
-- ============================================================

-- ============================================================
-- C1  Is one row one place in one year? Check with Jordan in 2023.
-- One row is:A countrys life expectancy in a single year.
-- Result check:1 row for jordan in 2023.
-- Interpretation:jourdans life expectancy in 2023 was around 74.
-- ============================================================


-- ============================================================
-- Q2  How has life expectancy in Jordan changed since 1950? Every year, oldest first.
-- One row is:A country in a specific year.
-- Result check: 74 rows.
-- Interpretation:Life expectancy has increased significantly over time.
-- ============================================================
SELECT year, life_expectancy
FROM owid.life_expectancy_data
WHERE entity ='Jordan'
ORDER BY year ASC ;

-- ============================================================
-- Q3  Which ten places had the highest life expectancy in 2023?
-- One row is:
-- Result check:
-- Interpretation:
-- ============================================================
SELECT  entity, year, life_expectancy
FROM owid.life_expectancy_data
WHERE year = 2023
ORDER BY life_expectancy DESC
LIMIT 10;

-- ============================================================
-- C3  "There are 193 UN member states. Why does 2023 have 261 rows?"
-- One row is:A country or a region/continent group.
-- Result check:261 rows total.
-- Interpretation:The tabel includs geographic and economic regions, not just countries.
-- ============================================================
-- (a) every row for 2023
SELECT*
FROM owid.life_expectancy_data
WHERE year= 2023 ;
-- (b) 2023 rows with no code
SELECT*
FROM owid.life_expectancy_data
WHERE year= 2023 AND code IS NULL ;
-- (c) 2023 rows with a code

-- (d) 2023 rows whose code starts with OWID
SELECT*
FROM owid.life_expectancy_data
WHERE year = 2023 AND code LIKE 'OWID%';
-- C3a every row for 2023

-- C3b 2023 rows with no code

-- C3c 2023 rows with a code

-- C3d 2023 rows whose code starts with OWID

-- C3e countries and territories only, highest life expectancy first


-- ============================================================
-- Stretch card: bytes estimates (write them here, do not run)
-- SELECT *:632.61 KB
-- two named columns:316.3 KB
-- SELECT * ... LIMIT 10:632.61 KB
-- ============================================================


-- ============================================================
-- More practice (not checked): P1 to P6 from the README
-- ============================================================

