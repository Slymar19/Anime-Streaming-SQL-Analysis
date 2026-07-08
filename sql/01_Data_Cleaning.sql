-- Import and insert table into a staging table called 'anime_streaming', 
-- the data cleaning will be done there 

SELECT * FROM anime_streaming_analysis_raw; 

DROP TABLE IF EXISTS anime_streaming;
CREATE TABLE anime_streaming LIKE anime_streaming_analysis_raw;

-- Check that the newly created table has the correct columns
SELECT * 
FROM anime_streaming; 

-- Transfer the data into the new table
INSERT INTO anime_streaming
SELECT * 
FROM anime_streaming_analysis_raw;

-- STEP1: Remove duplicates 
-- Assign a row number using a CTE and partition it by all the columns  
WITH duplicate_checker AS 
( SELECT *, ROW_NUMBER () OVER(PARTITION BY Anime_Title, Media_Type, Primary_Genre,
 Episodes, Release_Year, 
User_Rating, Global_Streams_Millions, Production_Studio) AS Row_num 
FROM anime_streaming
) 
SELECT * 
FROM duplicate_checker
WHERE Row_num >1;

-- Drop Duplicates using a CTE 
-- First create a table like the previous one then add the new column called Row_num

DROP TABLE IF EXISTS anime_streaming2;
CREATE TABLE `anime_streaming2` (
  `Anime_Title` text,
  `Media_Type` text,
  `Primary_Genre` text,
  `Episodes` double DEFAULT NULL,
  `Release_Year` double DEFAULT NULL,
  `User_Rating` text,
  `Global_Streams_Millions` double DEFAULT NULL,
  `Production_Studio` text,
  `Row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Check that the newly created table has the correct columns
SELECT * 
FROM anime_streaming2;

-- Transfer the data into the new table

INSERT INTO anime_streaming2
SELECT *, ROW_NUMBER () OVER(PARTITION BY Anime_Title, Media_Type, Primary_Genre, Episodes,
 Release_Year, User_Rating, Global_Streams_Millions, Production_Studio) AS Row_num 
FROM anime_streaming;

-- Check the new table  
SELECT * 
FROM anime_streaming2; 

-- Delete the duplicates now 
DELETE 
FROM anime_streaming2 
WHERE Row_num > 1; 

-- Check the new table and confirm the data has been deleted 
SELECT * 
FROM anime_streaming2 
WHERE Row_num > 1; 

--  STEP 2: Standardise the data column by column 
SELECT * 
FROM anime_streaming2;

-- Column 1: anime title 
-- Trim leading and trailing spaces

UPDATE anime_streaming2
SET Anime_Title = TRIM(Anime_Title); 

-- Column 2: Media Type 
-- Check distinct data points 

SELECT DISTINCT(Media_Type)
FROM anime_streaming2; 

-- Case-insensitive comparison shows only two values.
-- Check again using a binary collation to identify case variations.

SELECT DISTINCT Media_Type COLLATE utf8mb4_bin
FROM anime_streaming2; 

-- The columns would be standardised to have only first letter capital for both variations,
-- and also trim the type incase of trailing spaces 

UPDATE anime_streaming2
SET Media_Type = TRIM(Media_Type); 

UPDATE anime_streaming2
SET Media_Type = CONCAT(UPPER(LEFT(Media_Type,1)),LOWER(SUBSTRING(Media_Type, 2)));  

-- Verify the changes have been applied
SELECT DISTINCT Media_Type COLLATE utf8mb4_bin
FROM anime_streaming2; 

-- Column 3: Primary Genre

SELECT DISTINCT Primary_Genre COLLATE utf8mb4_bin
FROM anime_streaming2; 

-- There are blank values which would be replaced to null 

SELECT Anime_Title, Primary_Genre 
FROM anime_streaming2 
WHERE Primary_Genre = '';

-- 46 rows were returned and will be set to NULL to make analysis easier

UPDATE anime_streaming2
SET Primary_Genre = NULL 
WHERE Primary_Genre = '' ;

-- Verify changes are implemented

SELECT Anime_Title, Primary_Genre 
FROM anime_streaming2 
WHERE Primary_Genre = ''; 

-- Column 4: Episodes 
-- The Episodes column was created using the same datatype as the original table, 
-- which is `double` but it is meant to be an `INT` datatype

ALTER TABLE anime_streaming2
MODIFY Episodes INT;

SELECT MAX(Episodes) , MIN(Episodes)
FROM anime_streaming2;
 
-- We have 500 as max for Anime and 1 as min which should be Movie. 
-- Next, check whether any movie has more than 1 episode, which would be incorrect

SELECT * 
FROM anime_streaming2
WHERE Media_Type = 'Movie' AND Episodes > 1;
-- No rows appeared. 

-- Column 5: Release Year
-- The Release_Year column was also created the same way as the original table,
-- which is `double` but it is meant to be an `INT` datatype
ALTER TABLE anime_streaming2
MODIFY Release_Year INT;

SELECT MAX(Release_Year), MIN(Release_Year)
FROM anime_streaming2;
 
-- Check for distinct year, as there appear to be some errors
SELECT DISTINCT(Release_Year) 
FROM anime_streaming2 
ORDER BY 1 ASC;

-- Check for animes with years greater than 2026 (Present Year) and delete them 
SELECT Anime_Title, Release_Year 
FROM anime_streaming2
WHERE Release_Year > 2026;

DELETE 
FROM anime_streaming2 
WHERE Release_Year > 2026;

-- Based on historical records, the first piece of Japanese animation is widely believed 
-- to be to be the 1917 short film Namakura Gatana (A Dull Sword). 
-- Therefore, check for any row with year less than 1917 and delete 
SELECT Anime_Title, Release_Year 
FROM anime_streaming2
WHERE Release_Year < 1917;

DELETE 
FROM anime_streaming2 
WHERE Release_Year < 1917;

-- Column 6: User_Rating
-- There are blank values, so these will be converted to NULL
UPDATE anime_streaming2
SET User_Rating = NULL 
WHERE User_Rating = '';

-- This is a numerical column, but it is currently stored as text datatype and should be converted
ALTER TABLE anime_streaming2
MODIFY User_Rating DECIMAL(4,2);

-- Check the rating range
SELECT MAX(User_Rating) , MIN(User_Rating)
FROM anime_streaming2; 
 
-- There are outliers with figures having over 10, which is the max for rating and 1 minimum.
-- Therefore, these records will be removed rather than normalised,
-- as rating values are critical and should not be artificially adjusted

-- Remove invalid ratings
DELETE 
FROM anime_streaming2
WHERE User_Rating < 1 OR User_Rating > 10;

-- Verify the cleaned data 
SELECT MAX(User_Rating), MIN(User_Rating)
FROM anime_streaming2; 
-- Although a perfect rating may seem unrealistic, it is still possible, so it will be retained

-- Column 7: Global_Streams_Millions
SELECT  MAX(Global_Streams_Millions) , MIN(Global_Streams_Millions), AVG(Global_Streams_Millions) as avg_streams
FROM anime_streaming2;

-- The maximum value is more than 77× larger than the mean, which indicates an extreme outlier. 
-- Since this is a synthetic dataset, extremely large stream values are treated as simulated data-entry errors.

SELECT * 
FROM anime_streaming2 
WHERE Global_Streams_Millions > 1000
ORDER BY Global_Streams_Millions ASC;

-- Two records contained approximately 1.2 billion streams, 
-- which were considered reasonable within the context of this synthetic dataset.
-- Therefore, only values exceeding 1.5 billion streams are removed as potential data-entry errors.

DELETE FROM anime_streaming2
WHERE Global_Streams_Millions > 1500; 

-- Verify the cleaned data
SELECT * 
FROM anime_streaming2 
WHERE Global_Streams_Millions > 1500; 

SELECT  MAX(Global_Streams_Millions) , MIN(Global_Streams_Millions), AVG(Global_Streams_Millions) as avg_streams
FROM anime_streaming2;

-- Column 8: Production_Studio 
-- Trim leading and trailing spaces

UPDATE anime_streaming2 
SET Production_Studio = TRIM(Production_Studio);

-- Check for DISTINCT values
SELECT DISTINCT Production_Studio COLLATE utf8mb4_bin 
FROM anime_streaming2; 

-- Replace blank values and 'Unknown' with NULL

UPDATE anime_streaming2
SET Production_Studio = NULL
WHERE Production_Studio = '' OR Production_Studio = 'Unknown';

-- Step 3: Final validation and removal of unnecessary columns/duplicates
SELECT * 
FROM anime_streaming2; 
-- Remove the helper column used for duplicate identification, as it is no longer required.
ALTER TABLE anime_streaming2
DROP COLUMN Row_num;

-- Final duplicate check after standardisation

SELECT 
Anime_Title, Media_Type, Primary_Genre, Episodes,
Release_Year, User_Rating, Global_Streams_Millions,
Production_Studio, COUNT(*) AS Duplicate_Count
FROM anime_streaming2
GROUP BY 
Anime_Title, Media_Type, Primary_Genre, Episodes,
Release_Year, User_Rating, Global_Streams_Millions,
Production_Studio
HAVING COUNT(*) > 1;

-- After standardising, some duplicates occured. Therefore, they would be removed
-- create a new table to insert the distinct rows 
CREATE TABLE anime_streaming_final AS
SELECT DISTINCT *
FROM anime_streaming2;

-- Compare counts
SELECT COUNT(*)
FROM anime_streaming2;

SELECT COUNT(*)
FROM anime_streaming_final;
-- 1452 rows are in anime_streaming2 while 1446 are in anime_streaming_final 
-- with 6 duplicate pairs confirmed earlier, the removal worked

DROP TABLE anime_streaming2;
RENAME TABLE anime_streaming_final TO anime_streaming2;

-- Verify that the changes have been applied
SELECT * 
FROM anime_streaming2; 