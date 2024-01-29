## Project Overview

**Objective:** The goal of this project is to explore data available through the Steam Web API to get insights into potential factors contributing to a game's success. Based on the data available, we will focus on user reviews, identify features, and aim to uncover patterns that can be valuable for both players and developers.

**Background:** Steam is a digital video game distribution platform developed by Valve Corporation. It is one of the biggest online game stores today, and a title's performance on Steam is an indicator of how well the title performs in general.

**Data Source:** Dataset was created by Martin Bustos using the Steam Web API and published on Kaggle. It is updated monthly, and the dataset we used for this analysis was from the January 12, 2024 update. 
**Link:** [Steam Games Dataset](https://www.kaggle.com/datasets/fronkongames/steam-games-dataset)

## Dataset Information

**Name:** Steam Games Dataset

**Number of Records:** 85099

The dataset was imported into the system using SQL Server Management Studio and analyzed using SQL Server.

**Columns:** 
* **AppID:** Unique ID for each game assigned by Steam (int)
* **Name:** Game name (nvarchar)
* **Release_date:** Original date game was released according to Steam (date)
* **Estimated_owners:** Estimated number of owners of the game (nvarchar)
* **Peak_CCU:** Number of concurrent users as of when the data was taken (int) 
* **Required_age:** Age required to play, no requirement if 0 (int)
* **Price:** Price in USD (money)
* **DLC_count:** Number of DLCs (int)
* **About_the_game:** Description of the game (nvarchar)
* **Supported_languages:** Comma-separated ist of supported languages (nvarchar)
* **Full_audio_languages:** Comma-separated list of languages with audio support (nvarchar)
* **Reviews:** Featured reviews on store page (nvarchar)
* **Header_image:** URL of header image used on store page (nvarchar)
* **Website:** Game website (nvarchar)
* **Support_url:** Game support URL (nvarchar)
* **Support_email:** Game support email (nvarchar)
* **Windows:** Boolean value if game is playable in Windows (bit)
* **Mac:** Boolean value if game is playable in Mac (bit)
* **Linux:** Boolean value if game is playable in Linux (bit)
* **Metacritic_score:** Metacritic score, not available if 0 (int)
* **Metacritic_url:** URL of Metacritic review (nvarchar)
* **User_score:** User score, not available if 0 (int)
* **Positive:** Number of positive user reviews (int)
* **Negative:** Number of negative user reviews (int)
* **Score_rank:** Score rank based on user reviews (int)
* **Achievements:** Number of achievements (int)
* **Recommendations:** Number of user recommendations (int) 
* **Notes:** Additional information about game (nvarchar)
* **Average_playtime_forever:** Average playtime since March 2009 in minutes (int)
* **Average_playtime_two_weeks:** Average playtime in the last two weeks in minutes (int)
* **Median_playtime_forever:** Median playtime since March 2009 in minutes (int)
* **Median_playtime_two_weeks:** Median playtime in the last two weeks in minutes (int)
* **Developers:** Comma-separated list of developers (nvarchar)
* **Publishers:** Comma-separated list of publishers (nvarchar)
* **Categories:** Comma-separated list of categories (nvarchar)
* **Genres:** Comma-separated list of genres (nvarchar)
* **Tags:** Comma-separated list of user-defined tags (nvarchar)
* **Screenshots:** URL of screenshots (nvarchar)
* **Movies:** URL of movies (nvarchar)

## Data Cleaning

**SQL Queries:** [Data Cleaning Queries](/SteamDataCleaning.sql)
* Removed columns that do not have data relevant to our analysis or those that are mostly NULL:
	* Support_languages
	* Full_audio_languages
	* Reviews
	* Header_image
	* Website
	* Support_url
	* Support_email
	* Metacritic_url
	* Score_rank
	* Notes
	* Screenshots
	* Movies
* Checked remaining columns for NULL values.
* Manually updated Name values for 2 entries.
* Renamed Estimated_owner values for better readability.
* Replaced NULL values with "None" for multiple columns.

## Data Normalization

**SQL Queries:** [Data Normalization](/SteamDataNormalization.sql)
* Created new table Games.
* Created separate tables for columns cotaining multiple comma-separated values in the original dataset:
	* Developers
	* Publishers
	* Categories
	* Genres
	* Tags
* Created separate table for Estimated_owners.

**Database Diagram**
![dbd](/images/dbdiagram.png)
(Created using [Quick DBD](https://app.quickdatabasediagrams.com/))

## Exploratory Data Analysis

**SQL Queries:** [EDA](/SteamDataEDA.sql)

The focus of our queries was on positive user review % (Positive + Negative / Total User Votes). We also filtered out low player vote counts for certain queries to get insights on performance of popular games.


Overall Positive User Review % for Dataset
```
SELECT PercentPositive = SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100
FROM Games
WHERE Positive + Negative > 0
```
![result](/images/EDAdataset.png)


Top 10 Games (Over 10000 Reviews)
```
SELECT TOP (10) A.Name
	,A.Positive
	,A.Negative
	,PercentPositive = CAST(A.Positive * 1.0 / (A.Positive + A.Negative) * 100 AS DECIMAL(5, 2))
	,A.Metacritic_score
	,A.Price
	,Genres = REPLACE(STUFF((
			SELECT ', ' + C.Name
			FROM Game_Genres B
			JOIN Genres C
				ON B.GenreID = C.GenreID
			WHERE A.AppID = B.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,Developers =  REPLACE(STUFF((
			SELECT ', ' + E.Name
			FROM Game_Developers D
			JOIN Developers E
				ON D.DeveloperID = E.DeveloperID
			WHERE A.AppID = D.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,EstimatedOwners = F.Range
FROM Games A
JOIN EstimatedOwners F
ON A.EstimatedOwnersID = F.EstimatedOwnersID
WHERE A.Positive + A.Negative > 10000
ORDER BY PercentPositive DESC;
```
![result](/images/EDAtop10.png)


Bottom 10 Games (Over 10000 Reviews)
```
SELECT TOP (10) A.Name
	,A.Positive
	,A.Negative
	,PercentPositive = CAST(A.Positive * 1.0 / (A.Positive + A.Negative) * 100 AS DECIMAL(5, 2))
	,A.Metacritic_score
	,A.Price
	,Genres = REPLACE(STUFF((
			SELECT ', ' + C.Name
			FROM Game_Genres B
			JOIN Genres C
				ON B.GenreID = C.GenreID
			WHERE A.AppID = B.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,Developers =  REPLACE(STUFF((
			SELECT ', ' + E.Name
			FROM Game_Developers D
			JOIN Developers E
				ON D.DeveloperID = E.DeveloperID
			WHERE A.AppID = D.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,EstimatedOwners = F.Range
FROM Games A
JOIN EstimatedOwners F
ON A.EstimatedOwnersID = F.EstimatedOwnersID
WHERE A.Positive + A.Negative > 10000
ORDER BY PercentPositive;
```
![result](/images/EDAbottom10.png)


Positive Review % per Release Year
```
SELECT ReleaseYear = YEAR(Release_date)
	,PercentPositive = CAST(SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100 AS DECIMAL(5, 2))
FROM Games
WHERE Positive + Negative > 0
GROUP BY YEAR(Release_date)
ORDER BY 1;
```
![result](/images/EDAreleaseyear.png)


Bottom Games for 2023
```
SELECT TOP (10) A.Name
	,A.Positive
	,A.Negative
	,PercentPositive = CAST(A.Positive * 1.0 / (A.Positive + A.Negative) * 100 AS DECIMAL(5, 2))
	,A.Metacritic_score
	,A.Price
	,Genres = REPLACE(STUFF((
			SELECT ', ' + C.Name
			FROM Game_Genres B
			JOIN Genres C
				ON B.GenreID = C.GenreID
			WHERE A.AppID = B.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,Developers =  REPLACE(STUFF((
			SELECT ', ' + E.Name
			FROM Game_Developers D
			JOIN Developers E
				ON D.DeveloperID = E.DeveloperID
			WHERE A.AppID = D.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,EstimatedOwners = F.Range
FROM Games A
JOIN EstimatedOwners F
ON A.EstimatedOwnersID = F.EstimatedOwnersID
WHERE A.Positive + A.Negative > 10000
AND YEAR(Release_date) = 2023
ORDER BY PercentPositive;
```
![result](/images/EDAbottom2023.png)


Positive Review % per Estimated Owners
```
SELECT EstimatedOwners = B.Range
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN EstimatedOwners B
ON A.EstimatedOwnersID = B.EstimatedOwnersID
WHERE A.Positive + A.Negative > 0
GROUP BY B.Range
ORDER BY 2 DESC;
```
![result](/images/EDAowners.png)


Positive Review % per Range of Concurrent Users
```
SELECT
  CCURange = FLOOR(Peak_CCU / 10000) * 10000,
  GameCount = COUNT(*),
  PercentPositive = CAST(SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100 AS DECIMAL(5, 2))  
FROM
  Games
WHERE Positive + Negative > 0
GROUP BY
  FLOOR(Peak_CCU / 10000) * 10000
ORDER BY
  CCURange DESC;
```
![result](/images/EDAccu1.png)


Games with Less than 10k CCU
```
SELECT
  CCURange = FLOOR(Peak_CCU / 500) * 500,
  GameCount = COUNT(*),
  PercentPositive = CAST(SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100 AS DECIMAL(5, 2))  
FROM
  Games
WHERE Positive + Negative > 0
AND FLOOR(Peak_CCU / 500) * 500 < 10000
GROUP BY
  FLOOR(Peak_CCU / 500) * 500
ORDER BY
  CCURange DESC;
```
![result](/images/EDAccu2.png)


Positive Review % per Price Range
```
SELECT
  PriceRange = FLOOR(Price / 10) * 10,
  GameCount = COUNT(*),
  PercentPositive = CAST(SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100 AS DECIMAL(5, 2))  
FROM
  Games
WHERE Positive + Negative > 0
GROUP BY
  FLOOR(Price / 10) * 10
ORDER BY
  PriceRange;
```
![result](/images/EDApricerange.png)


Positive Review % per Platform
```
SELECT Windows
	,Mac
	,Linux
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100 AS DECIMAL(5, 2))
FROM Games
WHERE Positive + Negative > 0
GROUP BY Windows
	,Mac
	,Linux
ORDER BY GameCount DESC;
```
![result](/images/EDAplatform1.png)


Getting details of the Exclusive Mac and Linux Games
```
SELECT TOP (10) A.Name
	,A.Windows
	,A.Mac
	,A.Linux
	,A.Positive
	,A.Negative
	,PercentPositive = CAST(A.Positive * 1.0 / (A.Positive + A.Negative) * 100 AS DECIMAL(5, 2))
	,A.Metacritic_score
	,A.Price
	,Genres = REPLACE(STUFF((
			SELECT ', ' + C.Name
			FROM Game_Genres B
			JOIN Genres C
				ON B.GenreID = C.GenreID
			WHERE A.AppID = B.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,Developers =  REPLACE(STUFF((
			SELECT ', ' + E.Name
			FROM Game_Developers D
			JOIN Developers E
				ON D.DeveloperID = E.DeveloperID
			WHERE A.AppID = D.AppID
			FOR XML PATH('')
			), 1, 1, ''), '&amp;', '&')
	,EstimatedOwners = F.Range
FROM Games A
JOIN EstimatedOwners F
ON A.EstimatedOwnersID = F.EstimatedOwnersID
WHERE A.Positive + A.Negative > 0
AND (
(A.Windows = 0 AND A.Mac = 1 AND A.Linux = 0)
OR
(A.Windows = 0 AND A.Mac = 0 AND A.Linux = 1))
ORDER BY PercentPositive;
```
![result](/images/EDAplatform2.png)


Positive Review % per Genre
```
SELECT Genre = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Genres B
	ON A.AppID = B.AppID
JOIN Genres C
	ON B.GenreID = C.GenreID
WHERE A.Positive + A.Negative > 0
	AND C.Name <> 'None'
GROUP BY (C.Name)
ORDER BY 3 DESC;
```
![result](/images/EDAgenre.png)


Positive Review % per Category
```
SELECT Category = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Categories B
	ON A.AppID = B.AppID
JOIN Categories C
	ON B.CategoryID = C.CategoryID
WHERE A.Positive + A.Negative > 0
	AND C.Name <> 'None'
GROUP BY (C.Name)
ORDER BY 3 DESC;
```
![result](/images/EDAcategory.png)


Positive Review % per User-Submitted Tags
```
SELECT Tag = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Tags B
	ON A.AppID = B.AppID
JOIN Tags C
	ON B.TagID = C.TagID
WHERE A.Positive + A.Negative > 0
	AND C.Name <> 'None'
GROUP BY C.Name
ORDER BY 3 DESC;
```
![result](/images/EDAtag.png)


Top Developers with over 10000 Reviews
```
SELECT TOP (10) Developer = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Developers B
	ON A.AppID = B.AppID
JOIN Developers C
	ON B.DeveloperID = C.DeveloperID
WHERE A.Positive + A.Negative > 10000
	AND C.Name <> 'None'
GROUP BY C.Name
ORDER BY 3 DESC;
```
![result](/images/EDAtopdevelopers1.png)


Top Developers with over 10000 Reviews and At Least 5 Games
```
SELECT TOP (10) Developer = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Developers B
	ON A.AppID = B.AppID
JOIN Developers C
	ON B.DeveloperID = C.DeveloperID
WHERE A.Positive + A.Negative > 10000
	AND C.Name <> 'None'
GROUP BY C.Name
HAVING COUNT(*) >= 5
ORDER BY 3 DESC;
```
![result](/images/EDAtopdevelopers2.png)


Bottom Developers with over 10000 Reviews and At Least 5 Games
```
SELECT TOP (10) Developer = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Developers B
	ON A.AppID = B.AppID
JOIN Developers C
	ON B.DeveloperID = C.DeveloperID
WHERE A.Positive + A.Negative > 10000
	AND C.Name <> 'None'
GROUP BY C.Name
HAVING COUNT(*) >= 5
ORDER BY 3;
```
![result](/images/EDAbottomdevelopers.png)


Top Publishers with over 10000 Reviews and At Least 5 Games
```
SELECT TOP (10) Publisher = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Publishers B
	ON A.AppID = B.AppID
JOIN Publishers C
	ON B.PublisherID= C.PublisherID
WHERE A.Positive + A.Negative > 10000
	AND C.Name <> 'None'
GROUP BY C.Name
HAVING COUNT(*) >= 5
ORDER BY 3 DESC;
```
![result](/images/EDAtoppublishers.png)


Bottom Publishers with over 10000 Reviews and At Least 5 Games
```
SELECT TOP (10) Publisher = C.Name
	,GameCount = COUNT(*)
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN Game_Publishers B
	ON A.AppID = B.AppID
JOIN Publishers C
	ON B.PublisherID= C.PublisherID
WHERE A.Positive + A.Negative > 10000
	AND C.Name <> 'None'
GROUP BY C.Name
HAVING COUNT(*) >= 5
ORDER BY 3;
```
![result](/images/EDAbottompublishers.png)