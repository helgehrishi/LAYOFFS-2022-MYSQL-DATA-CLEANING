-- FIRST IMPORT THE DATA FROM CSV FILE 
-- THERE ARE TOTAL 2361 ROWS IN THE TABLE
-- TO IMPORT THE DATA CREATE A TABLE NAMED LAYOFF IN THE DATABASES
-- OPEN MYSQL WORK BENCH AND RIGHT CLICK ON THE TABLE
-- AND PROVIDE PATH OF THE CSV FILE TO IMPORT THE DATA
;

-- STEP 1 REMOVE DUPLICATES
-- STEP 2 STANDARDIZE THE DATA (ISSUES WITH SPELLINGS)
-- STEP 3 DEAL WITH THE NULL VALUES OR BLANK VALUES
-- STEP 4 REMOVE ROWS AND COLUMNS WHICH AREN'T NECESSARY
;

-- CREATE A STAGING TABLE 
CREATE TABLE LAYOFF_STAGING LIKE LAYOFFS;

-- PRINT THE ORIGINAL TABLE
SELECT
    *
FROM
    LAYOFFS;

-- INSERT / COPY ALL THE DATA FROM ORIGINAL TABLE TO STAGING TABLE
INSERT INTO
    LAYOFF_STAGING
SELECT
    *
FROM
    LAYOFFS;

-- STAGED DATA
SELECT
    *
FROM
    LAYOFF_STAGING;

-- FOR THIS DATASET WE DON'T HAVE UNIQUE ID
-- FIRST WE WILL CREATE AN PRIMARY_KEY / ID COLUMN
-- WE WILL CREATE A ROW NUMBER COLUMN
-- FOR CREATE RO NUMBER WE NEED TO USE WINDOW FUNCTION ROW_NUMBER() OVER()
SELECT
    *,
    ROW_NUMBER() OVER(
        PARTITION BY COMPANY,
        INDUSTRY,
        TOTAL_LAID_OFF,
        PERCENTAGE_LAID_OFF,
        `DATE`
    ) AS ROW_NUM
FROM
    LAYOFF_STAGING;

-- THE OUTPUT OF THE QUERY PROVIDES ROW_NUM FOR MOST OF THE COLUMN AS 1 
-- 1 DENOTES UNIQUE VALUE 
-- WE NEED TO APPLY A WHERE ON ROW_NUM WHERE ROW_NUM >= 2 
-- IT MEANS THAT THE DATA IS REDUNDANT
SELECT
    *,
    ROW_NUMBER() OVER(
        PARTITION BY COMPANY,
        INDUSTRY,
        TOTAL_LAID_OFF,
        PERCENTAGE_LAID_OFF,
        `DATE`
    ) AS ROW_NUM
FROM
    LAYOFF_STAGING
WHERE
    ROW_NUM > 1;

WITH DUPLICATES_CTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY COMPANY,
            INDUSTRY,
            TOTAL_LAID_OFF,
            PERCENTAGE_LAID_OFF,
            `DATE`
        ) AS ROW_NUM
    FROM
        LAYOFF_STAGING
)
SELECT
    *
FROM
    DUPLICATES_CTE
WHERE
    ROW_NUM > 1;

-- WE NEED TO CONFIRM THAT THE TABLE OUTPUT IS CORRECT 
SELECT
    *
FROM
    LAYOFF_STAGING
WHERE
    COMPANY = 'Oda';

-- WHEN WE LOOKED AT THE OUTPUT FROM ABOVE QUERY WE NOTICED THAT THOSE ARE NOT DUPLICATES
-- THE COUNTRY COLUMN HAS UNIQUE VALUES
-- WE WILL PARTITION BY COUNTY AS WELL  
WITH DUPLICATES_CTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER(
            PARTITION BY COMPANY,
            INDUSTRY,
            TOTAL_LAID_OFF,
            PERCENTAGE_LAID_OFF,
            `DATE`,
            STAGE,
            COUNTRY,
            FUNDS_RAISED_MILLIONS
        ) AS ROW_NUM
    FROM
        LAYOFF_STAGING
)
SELECT
    *
FROM
    DUPLICATES_CTE
WHERE
    ROW_NUM > 1;

-- PRINTING THE OUTPUT
SELECT
    *
FROM
    LAYOFF_STAGING
WHERE
    COMPANY = 'Casper';

SELECT
    *
FROM
    LAYOFF_STAGING
WHERE
    COMPANY = 'Hibob';

/*
 +------------------+---------------+----------------+----------------+---------------------+------------+----------+----------------+-----------------------+---------+
 | company          | location      | industry       | total_laid_off | percentage_laid_off | date       | stage    | country        | funds_raised_millions | ROW_NUM |
 +------------------+---------------+----------------+----------------+---------------------+------------+----------+----------------+-----------------------+---------+
 | Casper           | New York City | Retail         |           NULL | NULL                | 9/14/2021  | Post-IPO | United States  |                   339 |       2 |
 | Cazoo            | London        | Transportation |            750 | 0.15                | 6/7/2022   | Post-IPO | United Kingdom |                  2000 |       2 |
 | Hibob            | Tel Aviv      | HR             |             70 | 0.3                 | 3/30/2020  | Series A | Israel         |                    45 |       2 |
 | Wildlife Studios | Sao Paulo     | Consumer       |            300 | 0.2                 | 11/28/2022 | Unknown  | Brazil         |                   260 |       2 |
 | Yahoo            | SF Bay Area   | Consumer       |           1600 | 0.2                 | 2/9/2023   | Acquired | United States  |                     6 |       2 |
 +------------------+---------------+----------------+----------------+---------------------+------------+----------+----------------+-----------------------+---------+
 */
-- IF YOU LOOKED AT THE ROW_NUM FROM ABOVE OUTPUT IF ROW_NUM IS 2 THE ROW IS GETTING REPEATED
-- NOW TECHNICALLY WE NEED TO APPLY A DELETE CLAUSE OVER ABOVE QUERY - BUT IT IS NOT POSSIBLE IN MYSQL YOU  CAN DO THIS IS MICROSOFT SQL
-- IN MY SQL RDBMS WE NEED TO CREATE A NEW TABLE FIRST ADD VALUES FROM THR ABOVE QUERY TO THAT NEW "STAGING_2" TABLE;
;

-- TO CREATE A CLONE OF ANY TABLE (JUST THE TABLE NOT THE DATA)
-- OPEN MYSQL WORKBENCH
-- RIGHT-CLICK ON THE TABLE WHICH NEEDS TO BE DUPLICATED AND THEN 
-- CLICK ON COPY TO CLIPBOARD OPTION 
-- CLICK ON CREATE STATEMENT
-- YOU HAVE TO PASTE IT BELOW
-- RENAME THE TABLE NAME IN CREATE STATEMENT
-- ADD EXTRA COLUMN IF NECESSARY
-- IN THIS EXAMPLE IT WOULD BE ROW_NUM
;

CREATE TABLE `layoff_staging_2` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` int DEFAULT NULL,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int DEFAULT NULL,
    `row_num` int
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci;

-- THE TABLE IS BEEN SUCCESSFULLY CREATED WE NEED TO INSERT VALUES INTO IT
-- THE ROW_NUM WHICH WE ADDED WAS TEMPERER DATA (OUTPUT OF A QUERY) WE NEED TO PERMANENTLY ADD THAT DATA TO THE TABLE
-- STEP 1 WAS TO WRITE A CREATE STATEMENT WHICH WE DID ABOVE NOW WE WILL WRITE A INSERT STATEMENT REFERRING TO BELOW
SELECT
    *,
    ROW_NUMBER() OVER(
        PARTITION BY COMPANY,
        INDUSTRY,
        TOTAL_LAID_OFF,
        PERCENTAGE_LAID_OFF,
        `DATE`,
        STAGE,
        COUNTRY,
        FUNDS_RAISED_MILLIONS
    ) AS ROW_NUM
FROM
    LAYOFF_STAGING;

-- STEP 2 WAS TO WRITE A INSERT STATEMENT
INSERT INTO
    layoff_staging_2
SELECT
    *,
    ROW_NUMBER() OVER(
        PARTITION BY COMPANY,
        INDUSTRY,
        TOTAL_LAID_OFF,
        PERCENTAGE_LAID_OFF,
        `DATE`,
        STAGE,
        COUNTRY,
        FUNDS_RAISED_MILLIONS
    ) AS ROW_NUM
FROM
    LAYOFF_STAGING;

-- AFTER THESE 2 STEPS WE HAVE A STAGING_2 TABLE READY WHICH HAS ROW_NUM COLUMN IN IT
SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    ROW_NUM > 1;

DELETE FROM
    LAYOFF_STAGING_2
WHERE
    ROW_NUM > 1;

-- TILL THIS STEP WE HAVE SUCCESSFULLY REMOVED REMOVED THE DUPLICATES FROM THE TABLE
-- AND ALL THIS TRANSFORMATIONS ARE PERFORMED ON A STAGING TABLE AND NOT ON THE MAIN TABLE
-- STEP 1 REMOVING DUPLICATES DONE
-- STEP 2 STANDARDIZING THE DATA
-- TO STANDARDIZE THE DATA WE NEED TO CHECK EACH AND EVERY COLUMN FIRST
SELECT
    *
FROM
    LAYOFF_STAGING_2
LIMIT
    10;

-- company
SELECT
    DISTINCT(company)
FROM
    LAYOFF_STAGING_2
LIMIT
    10;

-- FROM THE OUTPUT THERE ARE BLANK SPACES IN FRONT OF FEW COMPANY NAMES
SELECT
    company,
    TRIM(company)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

UPDATE
    LAYOFF_STAGING_2
SET
    company = TRIM(company);

SELECT
    DISTINCT(company)
FROM
    LAYOFF_STAGING_2
LIMIT
    10;

-- PERFORM SAME FOR LOCATION 
UPDATE
    LAYOFF_STAGING_2
SET
    location = TRIM(location);

UPDATE
    LAYOFF_STAGING_2
SET
    industry = TRIM(industry);

-- WE WILL TAKE A LOOK AT INDUSTRY COLUMN
SELECT
    DISTINCT(industry)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- HERE Crypto | Crypto Currency | CryptoCurrency are same industry
SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    INDUSTRY LIKE "Crypto%";

UPDATE
    LAYOFF_STAGING_2
SET
    INDUSTRY = "Crypto"
WHERE
    INDUSTRY LIKE "Crypto%";

SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    INDUSTRY LIKE "Crypto%";

-- NOW LETS LOOK AT COUNTRY COLUMN
SELECT
    DISTINCT(COUNTRY)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- HERE THERE IS United States & United States.
-- WE NEED TO SCANDALIZE THIS DATA AS WELL
SELECT
    DISTINCT(COUNTRY)
FROM
    LAYOFF_STAGING_2
WHERE
    COUNTRY LIKE "United S%";

UPDATE
    LAYOFF_STAGING_2
SET
    COUNTRY = "United States"
WHERE
    COUNTRY LIKE "United S%";

-- NOW THE NEXT STEP IS TO STANDARDIZED THE DATE COLUMN
-- MYSQL STORES THE DATE IN THE FORMAT YYYY-MM-DD
-- HERE THE FORMAT IS IN CORRECT AND THE DATATYPE IS STRING/TEXT WE NEED TO CONVERT IT TO YEAR DATATYPE AND CHANGE THE DATE FORMAT
DESCRIBE LAYOFF_STAGING_2;

SELECT
    `DATE`,
    STR_TO_DATE(`DATE`, "%m/%d/%Y")
FROM
    LAYOFF_STAGING_2;

UPDATE
    LAYOFF_STAGING_2
SET
    `DATE` = STR_TO_DATE(`DATE`, "%m/%d/%Y");

-- STILL THE DATA TYPE IS TEXT OVER HERE
ALTER TABLE
    LAYOFF_STAGING_2
MODIFY
    COLUMN `DATE` DATE;

-- STEP 1 : REMOVE DUPLICATE COMPLETED
-- STEP 2 : STANDARDIZING DATA AND DATA TYPE
-- STEP 3 : DEALING WITH NULL VALUES
-- WE WILL TAKE A LOOK AT total_laid_off, percentage_laid_off
SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- THESE 361 ROWS ARE OF NO USE 
-- WE WILL DEAL WITH THESE ROWS LATER 
DESCRIBE LAYOFF_STAGING_2;

-- IN INDUSTRY COLUMN THERE ARE FEW NULL / EMPTY ROWS
SELECT
    DISTINCT(industry)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- 1 NULL VALUE IN DATE COLUMN
SELECT
    DISTINCT(DATE)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- 1 NULL VALUE IN STAGE COLUMN
SELECT
    DISTINCT(stage)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- 1 NULL VALUE IN funds_raised_millions COLUMN
SELECT
    DISTINCT(funds_raised_millions)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- NOW WE WILL DEAL WITH THE
-- NULL VALUES FROM INDUSTRY COLUMN FIRST
SELECT
    DISTINCT(industry)
FROM
    LAYOFF_STAGING_2
ORDER BY
    1;

-- WE WILL LOOK AT DATA WHERE INDUSTRY IS NULL OR BLANK
SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    INDUSTRY IS NULL
    OR INDUSTRY = '';

/*
 +---------------------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 | company             | location    | industry | total_laid_off | percentage_laid_off | DATE       | stage    | country       | funds_raised_millions | row_num |
 +---------------------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 | Airbnb              | SF Bay Area |          |             30 | NULL                | 2023-03-03 | Post-IPO | United States |                  6400 |       1 |
 | Bally's Interactive | Providence  | NULL     |           NULL | 0.15                | 2023-01-18 | Post-IPO | United States |                   946 |       1 |
 | Carvana             | Phoenix     |          |           2500 | 0.12                | 2022-05-10 | Post-IPO | United States |                  1600 |       1 |
 | Juul                | SF Bay Area |          |            400 | 0.3                 | 2022-11-10 | Unknown  | United States |                  1500 |       1 |
 +---------------------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 */
-- WE FOUND OUT THIS LIST OF COMPANY'S
SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    COMPANY = "Airbnb";

/*
 +---------+-------------+----------+----------------+---------------------+------------+----------------+---------------+-----------------------+---------+
 | company | location    | industry | total_laid_off | percentage_laid_off | DATE       | stage          | country       | funds_raised_millions | row_num |
 +---------+-------------+----------+----------------+---------------------+------------+----------------+---------------+-----------------------+---------+
 | Airbnb  | SF Bay Area |          |             30 | NULL                | 2023-03-03 | Post-IPO       | United States |                  6400 |       1 |
 | Airbnb  | SF Bay Area | Travel   |           1900 | 0.25                | 2020-05-05 | Private Equity | United States |                  5400 |       1 |
 +---------+-------------+----------+----------------+---------------------+------------+----------------+---------------+-----------------------+---------+
 */
-- Airbnb BELONGS TO TRAVEL INDUSTRY SO FURTHER WE CAN UPDATE THE BLANK VALUE WITH TRAVEL
-- WE WILL PERFORM SAME STEPS FOR REMAINING COMPANY'S
;

SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    COMPANY = "Bally's Interactive";

-- RESULT HAS ONLY 1 VALUE AND WHICH IS NULL
;

SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    COMPANY = "Carvana";

/*
 +---------+----------+----------------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 | company | location | industry       | total_laid_off | percentage_laid_off | DATE       | stage    | country       | funds_raised_millions | row_num |
 +---------+----------+----------------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 | Carvana | Phoenix  |                |           2500 | 0.12                | 2022-05-10 | Post-IPO | United States |                  1600 |       1 |
 | Carvana | Phoenix  | Transportation |           NULL | NULL                | 2023-01-13 | Post-IPO | United States |                  1600 |       1 |
 | Carvana | Phoenix  | Transportation |           1500 | 0.08                | 2022-11-18 | Post-IPO | United States |                  1600 |       1 |
 +---------+----------+----------------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 */
-- Carvana BELONGS TO Transportation INDUSTRY SO FURTHER WE CAN UPDATE THE BLANK VALUE WITH Transportation
;

SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    COMPANY = "Juul";

/*
 +---------+-------------+----------+----------------+---------------------+------------+---------+---------------+-----------------------+---------+
 | company | location    | industry | total_laid_off | percentage_laid_off | DATE       | stage   | country       | funds_raised_millions | row_num |
 +---------+-------------+----------+----------------+---------------------+------------+---------+---------------+-----------------------+---------+
 | Juul    | SF Bay Area |          |            400 | 0.3                 | 2022-11-10 | Unknown | United States |                  1500 |       1 |
 | Juul    | SF Bay Area | Consumer |            900 | 0.3                 | 2020-05-05 | Unknown | United States |                  1500 |       1 |
 +---------+-------------+----------+----------------+---------------------+------------+---------+---------------+-----------------------+---------+
 */
;

-- Juul BELONGS TO Consumer INDUSTRY SO FURTHER WE CAN UPDATE THE BLANK VALUE WITH Consumer
/*
 +---------------------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 | company             | location    | industry | total_laid_off | percentage_laid_off | DATE       | stage    | country       | funds_raised_millions | row_num |
 +---------------------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 | Airbnb              | SF Bay Area |          |             30 | NULL                | 2023-03-03 | Post-IPO | United States |                  6400 |       1 |
 | Bally's Interactive | Providence  | NULL     |           NULL | 0.15                | 2023-01-18 | Post-IPO | United States |                   946 |       1 |
 | Carvana             | Phoenix     |          |           2500 | 0.12                | 2022-05-10 | Post-IPO | United States |                  1600 |       1 |
 | Juul                | SF Bay Area |          |            400 | 0.3                 | 2022-11-10 | Unknown  | United States |                  1500 |       1 |
 +---------------------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+
 */
;

-- REFERRING TO THE ABOVE TABLE WE NEED TO WRITE FURTHER QUERY
-- HERE WE NEED TO APPLY SELF JOIN 
-- WE ARE CHECKING CONDITION ON SAME TABLE
SELECT
    *
FROM
    LAYOFF_STAGING_2 AS T1
    INNER JOIN LAYOFF_STAGING_2 AS T2 ON T1.COMPANY = T2.COMPANY
    AND T1.LOCATION = T2.LOCATION
    AND (
        T1.INDUSTRY IS NULL
        OR T1.INDUSTRY = ''
    )
    AND T2.INDUSTRY IS NOT NULL;

/*
 +---------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+---------+-------------+----------------+----------------+---------------------+------------+----------------+---------------+-----------------------+---------+
 | company | location    | industry | total_laid_off | percentage_laid_off | DATE       | stage    | country       | funds_raised_millions | row_num | company | location    | industry       | total_laid_off | percentage_laid_off | DATE       | stage          | country       | funds_raised_millions | row_num |
 +---------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+---------+-------------+----------------+----------------+---------------------+------------+----------------+---------------+-----------------------+---------+
 | Airbnb  | SF Bay Area |          |             30 | NULL                | 2023-03-03 | Post-IPO | United States |                  6400 |       1 | Airbnb  | SF Bay Area |                |             30 | NULL                | 2023-03-03 | Post-IPO       | United States |                  6400 |       1 |
 | Airbnb  | SF Bay Area |          |             30 | NULL                | 2023-03-03 | Post-IPO | United States |                  6400 |       1 | Airbnb  | SF Bay Area | Travel         |           1900 | 0.25                | 2020-05-05 | Private Equity | United States |                  5400 |       1 |
 | Carvana | Phoenix     |          |           2500 | 0.12                | 2022-05-10 | Post-IPO | United States |                  1600 |       1 | Carvana | Phoenix     |                |           2500 | 0.12                | 2022-05-10 | Post-IPO       | United States |                  1600 |       1 |
 | Carvana | Phoenix     |          |           2500 | 0.12                | 2022-05-10 | Post-IPO | United States |                  1600 |       1 | Carvana | Phoenix     | Transportation |           NULL | NULL                | 2023-01-13 | Post-IPO       | United States |                  1600 |       1 |
 | Carvana | Phoenix     |          |           2500 | 0.12                | 2022-05-10 | Post-IPO | United States |                  1600 |       1 | Carvana | Phoenix     | Transportation |           1500 | 0.08                | 2022-11-18 | Post-IPO       | United States |                  1600 |       1 |
 | Juul    | SF Bay Area |          |            400 | 0.3                 | 2022-11-10 | Unknown  | United States |                  1500 |       1 | Juul    | SF Bay Area |                |            400 | 0.3                 | 2022-11-10 | Unknown        | United States |                  1500 |       1 |
 | Juul    | SF Bay Area |          |            400 | 0.3                 | 2022-11-10 | Unknown  | United States |                  1500 |       1 | Juul    | SF Bay Area | Consumer       |            900 | 0.3                 | 2020-05-05 | Unknown        | United States |                  1500 |       1 |
 +---------+-------------+----------+----------------+---------------------+------------+----------+---------------+-----------------------+---------+---------+-------------+----------------+----------------+---------------------+------------+----------------+---------------+-----------------------+---------+
 */
-- THE OUTPUT OF T1 INDUSTRY IS NULL
-- BUT THE OUTPUT OF INDUSTRY FROM T2 HAS VALUES
UPDATE
    LAYOFF_STAGING_2 T1
    JOIN LAYOFF_STAGING_2 T2 ON T1.COMPANY = T2.COMPANY
SET
    T1.INDUSTRY = T2.INDUSTRY
WHERE
    (
        T1.INDUSTRY IS NULL
        OR T1.INDUSTRY = ''
    )
    AND T2.INDUSTRY IS NOT NULL;

-- THE ABOVE QUERY HAS CORRECT SYNTAX BUT IT IS NOT WORKING FOR US
-- WHAT WE CAN DO IS FIRST UPDATE THE BLANK VALUES WITH NULL FIRST
UPDATE
    LAYOFF_STAGING_2
SET
    INDUSTRY = NULL
WHERE
    INDUSTRY = '';

--
UPDATE
    LAYOFF_STAGING_2 T1
    JOIN LAYOFF_STAGING_2 T2 ON T1.COMPANY = T2.COMPANY
SET
    T1.INDUSTRY = T2.INDUSTRY
WHERE
    (
        T1.INDUSTRY IS NULL
        OR T1.INDUSTRY = ''
    )
    AND T2.INDUSTRY IS NOT NULL;

-- NOW THE SAME QUERY IS WORKING
-- WE HAVE Bally's Interactive WITH NO INDUSTRY 
-- THIS IS THE LAST STEP FOR SCANDALIZING THE DATA
-- IN THIS EXAMPLE IF WE KNEW THE TOTAL STRENGTH OF THEE ORG BEFORE LAYOFF 
-- IT WOULD BE POSSIBLE FOR US TO GENERA LAYOFF FROM PERCENTAGE LAYOFF
-- STEP 1 REMOVE DUPLICATES                                            DONE
-- STEP 2 STANDARDIZE THE DATA (ISSUES WITH SPELLINGS) AND DATATYPE    DONE
-- STEP 3 DEAL WITH THE NULL VALUES OR BLANK VALUES                    DONE
-- STEP 4 REMOVE ROWS AND COLUMNS WHICH AREN'T NECESSARY               DONE            
-- WE WILL TAKE A LOOK AT total_laid_off, percentage_laid_off
SELECT
    *
FROM
    LAYOFF_STAGING_2
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- THE ABOVE DATA IS OF NO USE TO US SO IT WILL BE BETTER TO REMOVE THESE ROWS FROM THE DATABASE
-- TO IMPROVE THE ACCURACY OF OUR QUERY
DELETE FROM
    LAYOFF_STAGING_2
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

-- REMOVE THE ROW_NUM COLUMNS WHICH WE ADDED AT THE BEGINNING 
ALTER TABLE
    LAYOFF_STAGING_2 DROP COLUMN ROW_NUM;

-- STEP 1 REMOVE DUPLICATES                                            DONE
-- STEP 2 STANDARDIZE THE DATA (ISSUES WITH SPELLINGS) AND DATATYPE    DONE
-- STEP 3 DEAL WITH THE NULL VALUES OR BLANK VALUES                    DONE
-- STEP 4 REMOVE ROWS AND COLUMNS WHICH AREN'T NECESSARY               DONE