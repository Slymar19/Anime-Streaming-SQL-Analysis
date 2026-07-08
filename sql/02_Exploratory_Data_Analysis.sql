-- Check for remaining missing values in critical analytical columns.
SELECT *
FROM anime_streaming2
WHERE User_Rating IS NULL 
   OR Global_Streams_Millions IS NULL
   OR Episodes IS NULL
   OR Production_Studio IS NULL;
   
-- Overall Dataset Summary
SELECT
COUNT(*) AS Total_Records,
COUNT(DISTINCT Anime_Title) AS Unique_Anime_Titles,
COUNT(DISTINCT Production_Studio) AS Total_Studios,
COUNT(DISTINCT Primary_Genre) AS Total_Genre_Combinations,
ROUND(AVG(User_Rating),2) AS Average_Rating,
ROUND(SUM(Global_Streams_Millions),2) AS Total_Streams
FROM anime_streaming2;

-- Deliverable 1: Anime Format Performance: Series vs. Movies
SELECT Media_Type, ROUND(AVG(Global_Streams_Millions), 2) AS Average_Stream_Count_Millions, 
round(AVG(User_Rating), 2) AS Average_User_Rating 
FROM anime_streaming2
GROUP BY Media_Type;

-- Anime-format content generated higher average streams compared to movies,
-- while user ratings remained relatively similar across both formats.

-- Deliverable 2: Studio Performance
SELECT COUNT(*) AS Number_of_Titles, Production_Studio, 
ROUND(AVG(User_Rating), 2) AS Average_User_Rating,
ROUND(SUM(Global_Streams_Millions), 3) AS Total_Global_Streams
FROM anime_streaming2
WHERE Production_Studio IS NOT NULL
GROUP BY Production_Studio
ORDER BY Total_Global_Streams DESC; 

-- Titles produced by A-1 Pictures accumulated the highest total streams,
-- while Bones and Toei achieved the highest average ratings,
-- although all top-performing studios remained around the 7.5 rating range.

-- Deliverable 3: Top anime titles
SELECT Anime_Title, Production_Studio, Global_Streams_Millions, User_Rating
FROM anime_streaming2
ORDER BY Global_Streams_Millions DESC
LIMIT 10;
-- Hunter x Hunter Spin-Off Col. 2 recorded the highest streams at 1,244 million streams,
-- while still maintaining a strong average rating of 8.06/10.

-- Deliverable 4: Outlier Detection
WITH Stats_KPI AS (
    SELECT 
        AVG(Global_Streams_Millions) AS overall_avg,
        STDDEV_POP(Global_Streams_Millions) AS overall_std
    FROM anime_streaming2
)
SELECT 
    a.Anime_Title,
    a.Production_Studio,
    a.Global_Streams_Millions,
    ROUND((a.Global_Streams_Millions - s.overall_avg) / s.overall_std, 2) AS Standard_Deviations_Away
FROM anime_streaming2 a
CROSS JOIN Stats_KPI s
WHERE a.Global_Streams_Millions > (s.overall_avg + (2 * s.overall_std))
ORDER BY a.Global_Streams_Millions DESC;

-- Deliverable 5: Genre Popularity & Content Bins
-- Note: Primary_Genre contains combined genre categories, so results represent
-- genre combinations rather than individual genres.

SELECT Primary_Genre, ROUND(SUM(Global_Streams_Millions), 3) AS Total_Global_Streams
FROM anime_streaming2
WHERE Primary_Genre IS NOT NULL
GROUP BY Primary_Genre
ORDER BY Total_Global_Streams DESC;

-- The highest-performing genre combinations by total streams were:
-- 1. Shonen, Action
-- 2. Fantasy, Adventure
-- 3. Shonen, Adventure.

-- Next: Create episode length categories using a CASE statement and CTE
-- to analyse average user ratings by episode range.

WITH Ep_Bin AS
(
SELECT *, 
CASE
	WHEN Episodes BETWEEN 2 AND 13 THEN 'Short-form Anime'
	WHEN Episodes BETWEEN 14 AND 26 THEN 'Mid-length Anime'
    WHEN Episodes BETWEEN 27 AND 99 THEN 'Extended Anime'
    WHEN Episodes >= 100 THEN 'Long-Running Anime'
    WHEN Episodes = 1 THEN 'Standalone Movie'
    ELSE 'Unknown'
END AS Episode_Bin
FROM anime_streaming2 
) 
SELECT Episode_Bin, ROUND(AVG(User_Rating), 2) AS Average_Ratings, COUNT(*)
FROM Ep_Bin
GROUP BY Episode_Bin
ORDER BY 2 DESC;

-- Although all episode categories had similar average ratings between 7.51 and 7.64,
-- Short-form anime achieved the highest average rating at 7.64/10.


