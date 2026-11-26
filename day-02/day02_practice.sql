/* =====================================================================
   Day 02 · SELECT and filtering — practice script
   Power BI with SQL workshop · Leading University
   Tool: SQL Server Express + SSMS (T-SQL)

   HOW TO USE
   1. Open this file in SSMS.
   2. Select PART A (setup) and press F5. You should see
      "(12 rows affected)" and "(13 rows affected)".
   3. Then select ONE query at a time and press F5 to run only it.
   4. Try every exercise yourself before you scroll to the solution.
   ===================================================================== */


/* =====================================================================
   PART A · SETUP  (safe to re-run)
   ===================================================================== */
IF DB_ID('LU_Workshop') IS NULL
    CREATE DATABASE LU_Workshop;
GO
USE LU_Workshop;
GO

DROP TABLE IF EXISTS dbo.Students;
DROP TABLE IF EXISTS dbo.Products;
GO

CREATE TABLE dbo.Students (
    student_id      INT            NOT NULL PRIMARY KEY,  -- unique ID card
    name            NVARCHAR(50)   NOT NULL,              -- text, up to 50 chars
    department      NVARCHAR(10)   NOT NULL,              -- SWE, CSE, EEE, BBA
    city            NVARCHAR(30)   NOT NULL,
    cgpa            DECIMAL(3,2)   NULL,                  -- 3 digits, 2 after the point; NULL = not yet
    credits         INT            NOT NULL,              -- credits completed (144 to graduate)
    admission_date  DATE           NOT NULL,              -- 'YYYY-MM-DD'
    email           NVARCHAR(100)  NULL                   -- NULL = not given
);

INSERT INTO dbo.Students (student_id, name, department, city, cgpa, credits, admission_date, email) VALUES
(101, N'Rahim',   N'SWE', N'Sylhet',     3.75, 120, '2022-01-10', N'rahim@lu.ac.bd'),
(102, N'Karim',   N'CSE', N'Dhaka',      3.60,  96, '2022-05-15', N'karim@lu.ac.bd'),
(103, N'Nusrat',  N'SWE', N'Sylhet',     3.90, 132, '2021-09-01', N'nusrat@lu.ac.bd'),
(104, N'Tania',   N'BBA', N'Chattogram', 3.20,  84, '2023-01-12', NULL),
(105, N'Sakib',   N'CSE', N'Sylhet',     2.85,  60, '2023-05-20', N'sakib@lu.ac.bd'),
(106, N'Farhana', N'EEE', N'Dhaka',      3.45, 110, '2022-01-10', NULL),
(107, N'Nabil',   N'SWE', N'Khulna',     3.10,  72, '2023-09-05', N'nabil@lu.ac.bd'),
(108, N'Sumaiya', N'CSE', N'Sylhet',     3.98, 140, '2021-01-15', N'sumaiya@lu.ac.bd'),
(109, N'Arif',    N'BBA', N'Rajshahi',   2.60,  45, '2024-01-08', NULL),
(110, N'Mim',     N'EEE', N'Sylhet',     3.55, 100, '2022-09-01', N'mim@lu.ac.bd'),
(111, N'Shafin',  N'CSE', N'Chattogram', 3.30,  90, '2022-09-01', N'shafin@lu.ac.bd'),
(112, N'Riya',    N'SWE', N'Dhaka',      NULL,   0, '2024-09-02', N'riya@lu.ac.bd');

CREATE TABLE dbo.Products (
    product_id    INT            NOT NULL PRIMARY KEY,
    product_name  NVARCHAR(50)   NOT NULL,
    category      NVARCHAR(30)   NOT NULL,
    list_price    DECIMAL(12,2)  NOT NULL                -- BDT
);

INSERT INTO dbo.Products (product_id, product_name, category, list_price) VALUES
( 1, N'Laptop',           N'Electronics', 65000),
( 2, N'Smartphone',       N'Electronics', 28000),
( 3, N'Headphones',       N'Electronics',  3500),
( 4, N'Smart Watch',      N'Electronics',  9000),
( 5, N'Office Chair',     N'Furniture',   12000),
( 6, N'Study Table',      N'Furniture',   15000),
( 7, N'Bookshelf',        N'Furniture',    8000),
( 8, N'T-Shirt',          N'Clothing',      600),
( 9, N'Jeans',            N'Clothing',     1800),
(10, N'Jacket',           N'Clothing',     4500),
(11, N'Rice (25kg)',      N'Groceries',    1900),
(12, N'Tea Pack',         N'Groceries',     450),
(13, N'Cooking Oil (5L)', N'Groceries',     950);
GO

SELECT * FROM dbo.Students;   -- 12 rows
SELECT * FROM dbo.Products;   -- 13 rows


/* =====================================================================
   PART B · SLIDE EXAMPLES  (run one at a time)
   ===================================================================== */

-- 02 · SELECT -----------------------------------------------------------
SELECT name, department, cgpa
FROM Students;

SELECT 2 + 3 AS answer;                       -- SELECT without FROM = calculator

-- 03 · Aliases & calculated columns -------------------------------------
SELECT name                               AS [Student],
       credits,
       144 - credits                      AS [Credits Left],
       name + ' (' + department + ')'     AS Label
FROM Students;

SELECT 7 / 2      AS int_division,            -- 3   (INT / INT = INT)
       7 / 2.0    AS decimal_division,        -- 3.5
       7 % 2      AS remainder;               -- 1

SELECT name, 'Mail: ' + email         AS plus_version,    -- NULL when email is NULL
             CONCAT('Mail: ', email)  AS concat_version   -- NULL treated as ''
FROM Students;

-- 04 · DISTINCT ---------------------------------------------------------
SELECT department FROM Students;              -- 12 rows, repeats
SELECT DISTINCT department FROM Students;     -- 4 rows
SELECT DISTINCT city FROM Students;           -- 5 rows
SELECT DISTINCT department, city FROM Students;   -- 10 unique pairs

-- 05 · ORDER BY ---------------------------------------------------------
SELECT name, cgpa FROM Students ORDER BY cgpa DESC;              -- NULL (Riya) last
SELECT name, cgpa FROM Students ORDER BY cgpa;                   -- ASC: NULL first
SELECT name, department, cgpa
FROM Students
ORDER BY department ASC, cgpa DESC;                              -- 2 sort levels
SELECT name, 144 - credits AS left_credits
FROM Students ORDER BY left_credits;                             -- alias works here

-- 06 · TOP and OFFSET-FETCH --------------------------------------------
SELECT TOP 3 name, cgpa FROM Students ORDER BY cgpa DESC;              -- 3 rows
SELECT TOP 25 PERCENT name, cgpa FROM Students ORDER BY cgpa DESC;     -- 3 rows (25% of 12)
SELECT TOP 3 WITH TIES name, admission_date
FROM Students ORDER BY admission_date;                                 -- 4 rows (tie on 2022-01-10)
SELECT name, cgpa FROM Students
ORDER BY cgpa DESC
OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;                                  -- rows 4–6
-- MySQL / PostgreSQL write the same idea as:  ... ORDER BY cgpa DESC LIMIT 3 OFFSET 3;

-- 07 · WHERE and comparison operators ---------------------------------
SELECT name, city FROM Students WHERE city = 'Sylhet';           -- 5 rows
SELECT name, cgpa FROM Students WHERE cgpa >= 3.50;              -- 5 rows
SELECT name, department FROM Students WHERE department <> 'CSE'; -- 8 rows
SELECT name, credits FROM Students WHERE credits < 80;           -- 4 rows
SELECT name, admission_date FROM Students
WHERE admission_date >= '2023-01-01';                            -- 5 rows

-- 08 · AND / OR / NOT ---------------------------------------------------
SELECT name, department, cgpa FROM Students
WHERE department = 'CSE' AND cgpa >= 3.5;                        -- Karim, Sumaiya
SELECT name, city FROM Students
WHERE city = 'Khulna' OR city = 'Rajshahi';                      -- Nabil, Arif
SELECT name, department FROM Students
WHERE NOT department = 'SWE';                                    -- 8 rows

-- precedence: AND runs before OR
SELECT name, department, cgpa FROM Students
WHERE department = 'SWE' OR department = 'CSE' AND cgpa > 3.5;   -- 6 rows (surprise!)
SELECT name, department, cgpa FROM Students
WHERE (department = 'SWE' OR department = 'CSE') AND cgpa > 3.5; -- 4 rows (intended)

-- 09 · IN / NOT IN ------------------------------------------------------
SELECT name, city FROM Students WHERE city IN ('Dhaka', 'Chattogram');       -- 5 rows
SELECT name, city FROM Students WHERE city NOT IN ('Sylhet', 'Dhaka');       -- 4 rows

-- 10 · BETWEEN ----------------------------------------------------------
SELECT name, cgpa FROM Students WHERE cgpa BETWEEN 3.00 AND 3.50;            -- 4 rows
SELECT name, admission_date FROM Students
WHERE admission_date BETWEEN '2022-01-01' AND '2022-12-31';                  -- 5 rows
-- Safer for DATETIME columns (they have a time part):
--   WHERE order_time >= '2022-01-01' AND order_time < '2023-01-01'

-- 11 · LIKE -------------------------------------------------------------
SELECT name FROM Students WHERE name LIKE 'S%';       -- Sakib, Sumaiya, Shafin
SELECT name FROM Students WHERE name LIKE '%a';       -- Tania, Farhana, Sumaiya, Riya
SELECT name FROM Students WHERE name LIKE '%im';      -- Rahim, Karim, Mim
SELECT name FROM Students WHERE name LIKE '_a%';      -- 6 rows: 2nd letter is a
SELECT name FROM Students WHERE name LIKE '[NR]%';    -- Rahim, Nusrat, Nabil, Riya
SELECT name FROM Students WHERE name LIKE '[^NRS]%';  -- does NOT start with N, R or S

-- 12 · NULL -------------------------------------------------------------
SELECT name, email FROM Students WHERE email = NULL;      -- 0 rows!  (never do this)
SELECT name, email FROM Students WHERE email IS NULL;     -- Tania, Farhana, Arif
SELECT name, email FROM Students WHERE email IS NOT NULL; -- 9 rows
SELECT name FROM Students WHERE cgpa <  3.5;              -- 6 rows
SELECT name FROM Students WHERE cgpa >= 3.5;              -- 5 rows  → 6 + 5 = 11, Riya is in neither
SELECT name,
       ISNULL(email, 'not given') AS email,
       COALESCE(cgpa, 0)          AS cgpa
FROM Students;

-- Putting it together: written order vs run order -----------------------
SELECT name, cgpa AS gpa          -- runs 3rd
FROM Students                     -- runs 1st
WHERE city = 'Sylhet'             -- runs 2nd
ORDER BY gpa DESC;                -- runs 4th  (alias allowed here, not in WHERE)


/* =====================================================================
   PART C · EXERCISES — try first, then check the solution
   ===================================================================== */

-- 01-E1  Switch to the practice database.
USE LU_Workshop;

-- 02-E1  Show only name and email of every student.
SELECT name, email FROM Students;
-- 02-E2  Show city first, then name.
SELECT city, name FROM Students;

-- 03-E1  Name and credits left to graduate (144 needed) as [Credits Left].
SELECT name, 144 - credits AS [Credits Left] FROM Students;          -- Rahim → 24
-- 03-E2  One column called Label like 'Rahim - SWE'.
SELECT name + ' - ' + department AS Label FROM Students;

-- 04-E1  Every department, once.
SELECT DISTINCT department FROM Students;                            -- BBA, CSE, EEE, SWE
-- 04-E2  Every admission date, once. How many?
SELECT DISTINCT admission_date FROM Students;                        -- 10 rows

-- 05-E1  Students A → Z by name.
SELECT name FROM Students ORDER BY name;                             -- Arif … Tania
-- 05-E2  City A → Z, then credits high → low.
SELECT name, city, credits FROM Students ORDER BY city, credits DESC; -- Shafin first

-- 06-E1  The 2 students with the fewest credits.
SELECT TOP 2 name, credits FROM Students ORDER BY credits;           -- Riya 0, Arif 45
-- 06-E2  Page 2 of an A → Z list, 5 students per page.
SELECT name FROM Students ORDER BY name
OFFSET 5 ROWS FETCH NEXT 5 ROWS ONLY;                                -- Nusrat … Shafin

-- 07-E1  Students with 100 or more credits.
SELECT name, credits FROM Students WHERE credits >= 100;             -- 5 rows
-- 07-E2  Students NOT from Sylhet.
SELECT name, city FROM Students WHERE city <> 'Sylhet';              -- 7 rows

-- 08-E1  SWE students from Sylhet.
SELECT name FROM Students WHERE department = 'SWE' AND city = 'Sylhet';   -- Rahim, Nusrat
-- 08-E2  EEE or BBA students with CGPA above 3.0.
SELECT name, department, cgpa FROM Students
WHERE (department = 'EEE' OR department = 'BBA') AND cgpa > 3.0;          -- Tania, Farhana, Mim

-- 09-E1  Students with ID 101, 105 or 109.
SELECT student_id, name FROM Students WHERE student_id IN (101, 105, 109); -- Rahim, Sakib, Arif
-- 09-E2  Students not in CSE or SWE.
SELECT name, department FROM Students WHERE department NOT IN ('CSE', 'SWE'); -- 4 rows

-- 10-E1  Credits between 60 and 100.
SELECT name, credits FROM Students WHERE credits BETWEEN 60 AND 100;      -- 6 rows
-- 10-E2  Students admitted in 2023.
SELECT name, admission_date FROM Students
WHERE admission_date BETWEEN '2023-01-01' AND '2023-12-31';               -- Tania, Sakib, Nabil

-- 11-E1  Names that contain 'ar'.
SELECT name FROM Students WHERE name LIKE '%ar%';     -- Karim, Farhana, Arif (case-insensitive!)
-- 11-E2  Names with exactly 4 letters.
SELECT name FROM Students WHERE name LIKE '____';     -- Arif, Riya

-- 12-E1  Students with no email.
SELECT name FROM Students WHERE email IS NULL;        -- Tania, Farhana, Arif
-- 12-E2  Name and CGPA, showing 0 when CGPA is missing.
SELECT name, COALESCE(cgpa, 0) AS cgpa FROM Students;


/* =====================================================================
   PART D · CHALLENGE on the Products table
   ===================================================================== */

-- C1  All Electronics, most expensive first.
SELECT product_name, list_price FROM Products
WHERE category = 'Electronics' ORDER BY list_price DESC;   -- Laptop, Smartphone, Smart Watch, Headphones
-- C2  Products priced 1,000 to 10,000.
SELECT product_name, list_price FROM Products
WHERE list_price BETWEEN 1000 AND 10000;                   -- 6 rows
-- C3  The 3 cheapest products.
SELECT TOP 3 product_name, list_price FROM Products
ORDER BY list_price;                                       -- Tea Pack, T-Shirt, Cooking Oil
-- C4  Clothing or Groceries under ৳1,000.
SELECT product_name, category, list_price FROM Products
WHERE category IN ('Clothing', 'Groceries') AND list_price < 1000;   -- T-Shirt, Tea Pack, Cooking Oil
-- C5  Every category, once.
SELECT DISTINCT category FROM Products;                    -- 4 rows
-- C6  Products with 'Smart' in the name.
SELECT product_name FROM Products WHERE product_name LIKE '%Smart%';  -- Smartphone, Smart Watch


/* =====================================================================
   PART E · HOMEWORK solutions (do the homework first!)
   ===================================================================== */

-- H1  Top 5 students by CGPA, students without a CGPA left out.
SELECT TOP 5 name, cgpa FROM Students
WHERE cgpa IS NOT NULL ORDER BY cgpa DESC;     -- Sumaiya, Nusrat, Rahim, Karim, Mim

-- H2  Students from Sylhet or Dhaka admitted before 2023, oldest admission first.
SELECT name, city, admission_date FROM Students
WHERE city IN ('Sylhet', 'Dhaka') AND admission_date < '2023-01-01'
ORDER BY admission_date;                       -- Sumaiya, Nusrat, Rahim, Farhana, Karim, Mim

-- H3  Products that are NOT Furniture and cost more than ৳1,000, cheapest first.
SELECT product_name, category, list_price FROM Products
WHERE category <> 'Furniture' AND list_price > 1000
ORDER BY list_price;                           -- Jeans … Laptop (7 rows)

-- H4  Students whose name ends with 'n' or 'm'.
SELECT name FROM Students
WHERE name LIKE '%n' OR name LIKE '%m';        -- Rahim, Karim, Mim, Shafin

-- H5  Final-year students (120+ credits), most credits first.
SELECT name, department, credits FROM Students
WHERE credits >= 120
ORDER BY credits DESC;                         -- Sumaiya 140, Nusrat 132, Rahim 120
