/*
===========================================================
House Price Dataset Cleaning & Preprocessing (MySQL)
===========================================================

Goal:
Prepare the dataset for analysis by:
1. Standardizing boolean values
2. Cleaning invalid addresses
3. Checking for abnormal values
4. Removing incorrect records
5. Recreating the USD price column
6. Removing neighborhoods with very few observations

===========================================================
*/

-- Preview the dataset
SELECT *
FROM houseprice;

-- Check the table structure
DESCRIBE houseprice;

/*
===========================================================
STEP 1: Convert True/False columns into numeric values
===========================================================

Before converting the columns, verify that they only contain
"True" and "False" values. This ensures there are no unexpected
values such as extra spaces, lowercase text, or typos.
*/

SELECT DISTINCT parking, COUNT(*)
FROM houseprice
GROUP BY parking;

SELECT DISTINCT elevator, COUNT(*)
FROM houseprice
GROUP BY elevator;

SELECT DISTINCT warehouse, COUNT(*)
FROM houseprice
GROUP BY warehouse;


-- Convert Parking to 1/0

UPDATE houseprice
SET parking = 1
WHERE parking = 'True';

UPDATE houseprice
SET parking = 0
WHERE parking = 'False';

ALTER TABLE houseprice
MODIFY COLUMN parking TINYINT;


-- Convert Elevator to 1/0

UPDATE houseprice
SET elevator = 1
WHERE elevator = 'True';

UPDATE houseprice
SET elevator = 0
WHERE elevator = 'False';

ALTER TABLE houseprice
MODIFY COLUMN elevator TINYINT;


-- Convert Warehouse to 1/0

UPDATE houseprice
SET warehouse = 1
WHERE warehouse = 'True';

UPDATE houseprice
SET warehouse = 0
WHERE warehouse = 'False';

ALTER TABLE houseprice
MODIFY COLUMN warehouse TINYINT;


-- Verify the conversion

SELECT parking, COUNT(*)
FROM houseprice
GROUP BY parking;

SELECT elevator, COUNT(*)
FROM houseprice
GROUP BY elevator;

SELECT warehouse, COUNT(*)
FROM houseprice
GROUP BY warehouse;

/*
===========================================================
STEP 2: Clean the Address column
===========================================================

Check whether addresses differ only because of capitalization
or formatting.
*/

SELECT COUNT(DISTINCT address),
       COUNT(DISTINCT LOWER(address))
FROM houseprice;


-- Look for leading or trailing spaces

SELECT DISTINCT TRIM(address), LENGTH(address)
FROM houseprice;


-- "Tenant" is not a valid neighborhood, so replace it
-- with "Unknown"

SELECT *
FROM houseprice
WHERE address = 'Tenant';

UPDATE houseprice
SET address = 'Unknown'
WHERE address = 'Tenant';


-- Replace NULL or empty addresses with "Unknown"

SELECT COUNT(*)
FROM houseprice
WHERE address IS NULL
   OR address = '';

UPDATE houseprice
SET address = 'Unknown'
WHERE address IS NULL
   OR address = '';

/*
===========================================================
STEP 3: Explore Numerical Columns
===========================================================

Review the minimum, maximum, and average values to identify
possible outliers or incorrect records.
*/

SELECT MIN(area),
       MAX(area),
       AVG(area)
FROM houseprice;

SELECT MIN(room),
       MAX(room),
       AVG(room)
FROM houseprice;

SELECT MIN(price),
       MAX(price),
       AVG(price)
FROM houseprice;

SELECT MIN(`Price(USD)`),
       MAX(`Price(USD)`),
       AVG(`Price(USD)`)
FROM houseprice;


-- Investigate suspiciously expensive properties

SELECT *
FROM houseprice
WHERE price > 50000000000;


-- Investigate suspiciously low USD prices

SELECT *
FROM houseprice
WHERE `Price(USD)` < 150;

/*
===========================================================
STEP 4: Remove Invalid Records
===========================================================

Properties with zero rooms and very large areas are considered
data entry errors and are removed.
*/

DELETE
FROM houseprice
WHERE room = 0
  AND area > 150;

/*
===========================================================
STEP 5: Recreate the USD Price Column
===========================================================

Instead of relying on the existing values, recreate the
Price(USD) column using the exchange rate.

Formula:
Price(USD) = Price / 30,000
*/

ALTER TABLE houseprice
DROP COLUMN `Price(USD)`;

ALTER TABLE houseprice
ADD `Price(USD)` DOUBLE;

UPDATE houseprice
SET `Price(USD)` = price / 30000;


DESCRIBE houseprice;

/*
===========================================================
STEP 6: Additional Data Exploration
===========================================================
*/

-- Average size of one-bedroom houses

SELECT AVG(area)
FROM houseprice
WHERE room = 1;


-- Small two-bedroom houses

SELECT *
FROM houseprice
WHERE room = 2
  AND area < 50;

/*
===========================================================
STEP 7: Remove Neighborhoods with Too Few Properties
===========================================================

Neighborhoods containing fewer than 8 houses provide too little
data for meaningful analysis, so they are removed.
*/

-- Preview neighborhoods that will be removed

WITH neighborhood_counts AS
(
    SELECT address,
           COUNT(*) AS house_count
    FROM houseprice
    GROUP BY address
)

SELECT address
FROM neighborhood_counts
WHERE house_count < 8;


-- Delete those neighborhoods

DELETE h
FROM houseprice h
JOIN
(
    SELECT address
    FROM houseprice
    GROUP BY address
    HAVING COUNT(*) < 8
) n
ON h.address = n.address;

/*
===========================================================
Final Verification
===========================================================
*/

SELECT *
FROM houseprice;

DESCRIBE houseprice;