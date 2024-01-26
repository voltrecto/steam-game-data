--Exploratory Data Analysis

SELECT * FROM Games;

--Number of game releases per year

SELECT ReleaseYear = YEAR(Release_date)
	,GameCount = COUNT(*)
FROM Games
GROUP BY YEAR(Release_DATE)
ORDER BY 1;

--Distribution of estimated owners

SELECT B.Range
	,RangeCount = COUNT(*)
FROM Games A
JOIN EstimatedOwners B
	ON A.EstimatedOwnersID = B.EstimatedOwnersID
GROUP BY B.Range
ORDER BY 2 DESC;

--Top 20 games with peak concurrent users during 2nd week of January 2024

SELECT TOP (20) Name
	,Peak_CCU
FROM Games
ORDER BY Peak_CCU DESC;

--Distribution of prices

SELECT Price
	,GameCount = COUNT(*)
FROM Games
GROUP BY Price
ORDER BY 2 DESC;

--Distribution of games across platforms

SELECT Windows
	,Mac
	,Linux
	,GameCount = COUNT(*)
FROM Games
GROUP BY Windows
	,Mac
	,Linux
ORDER BY GameCount DESC;

--Top 20 games with highest metacritic score

SELECT TOP (20) Name
	,AppID
	,Metacritic_score
FROM Games
ORDER BY Metacritic_score DESC;

--Note: Checked the duplicate Portal 2 and they are 2 AppIDs listed separately in the Steam store but direct to the same game.

--Top 20 games with highest positive score % (positive + negative / total user votes) and over 10000 votes

SELECT TOP (20) Name
	,Positive
	,Negative
	,PercentPositive = CASE 
		WHEN Positive + Negative = 0
			THEN 0
		ELSE CAST(Positive * 1.0 / (Positive + Negative) * 100 AS DECIMAL(10, 2))
		END
FROM Games
WHERE Positive + Negative > 10000
ORDER BY PercentPositive DESC;

--Top 10 game with highest user recommendations

SELECT TOP (10) Name
	,AppID
	,Recommendations
FROM Games
ORDER BY Recommendations DESC;

--Top 10 games with highest all time average playtime

SELECT TOP (10) Name
	,Average_playtime_forever
FROM Games
ORDER BY 2 DESC;

--Top 10 games with highest all time median playtime

SELECT TOP (10) Name
	,Median_playtime_forever
FROM Games
ORDER BY 2 DESC;

--Average metacritic score per genre

SELECT C.Name
	,MetacriticAverage = AVG(CAST(A.Metacritic_score AS FLOAT))
FROM Games A
JOIN Game_Genres B
	ON A.AppID = B.AppID
JOIN Genres C
	ON B.GenreID = C.GenreID
WHERE A.Metacritic_score > 0
	AND C.Name <> 'None'
GROUP BY (C.Name)
ORDER BY 2 DESC;

--Average metacritic score per user-created tags

SELECT C.Name
	,MetacriticAverage = AVG(CAST(A.Metacritic_score AS FLOAT))
FROM Games A
JOIN Game_Tags B
	ON A.AppID = B.AppID
JOIN Tags C
	ON B.TagID = C.TagID
WHERE A.Metacritic_score > 0
	AND C.Name <> 'None'
GROUP BY C.Name
ORDER BY 2 DESC;

--When this data was updated there was only 1 game with a Batman tag and that was Batman Arkham Asylum.

--Top developers in terms of total concurrent users

SELECT TOP (20) C.Name
	,TotalPeak_CCU = SUM(A.Peak_CCU)
FROM Games A
JOIN Game_Developers B
	ON A.AppID = B.AppID
JOIN Developers C
	ON B.DeveloperID = C.DeveloperID
GROUP BY C.Name
ORDER BY 2 DESC;

--Top publishers in terms of total recommendations

SELECT TOP (20) C.Name
	,TotalRecommendations = SUM(A.Recommendations)
FROM Games A
JOIN Game_Publishers B
	ON A.AppID = B.AppID
JOIN Publishers C
	ON B.PublisherID = C.PublisherID
GROUP BY C.Name
ORDER BY 2 DESC;

