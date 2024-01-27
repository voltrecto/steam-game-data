--Exploratory Data Analysis

SELECT * FROM Games;

--Positive User Review % = (Positive + Negative / Total User Votes)

--Dataset overall positive user review % excluding games with no user review

SELECT PercentPositive = SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100
FROM Games
WHERE Positive + Negative > 0

--Top 10 games with highest positive user review % and over 10000 votes

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

--Note: Checked the duplicate Portal 2 and they are 2 AppIDs listed separately in the Steam store but direct to the same game.
--Bottom 10 games with over 10000 votes

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

--Positive user review % per release year

SELECT ReleaseYear = YEAR(Release_date)
	,PercentPositive = CAST(SUM(Positive) * 1.0 / (SUM(Positive) + SUM(Negative)) * 100 AS DECIMAL(5, 2))
FROM Games
WHERE Positive + Negative > 0
GROUP BY YEAR(Release_date)
ORDER BY 1;

--Looking at contributors to low % for year 2023

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

--Positive user review % per estimated owners

SELECT EstimatedOwners = B.Range
	,PercentPositive = CAST(SUM(A.Positive) * 1.0 / (SUM(A.Positive) + SUM(A.Negative)) * 100 AS DECIMAL(5, 2))
FROM Games A
JOIN EstimatedOwners B
ON A.EstimatedOwnersID = B.EstimatedOwnersID
WHERE A.Positive + A.Negative > 0
GROUP BY B.Range
ORDER BY 2 DESC;

--Positive % per concurrent users

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

--Looking at smaller range for games with less than 10k CCU

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

--Positive % per price range

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

--Positive user % per platform

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

--Looking at Mac and Linux Games

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
WHERE A.Positive + A.Negative > 0
AND (
(A.Windows = 0 AND A.Mac = 1 AND A.Linux = 0)
OR
(A.Windows = 0 AND A.Mac = 0 AND A.Linux = 1))
ORDER BY PercentPositive;

--Positive user % per genre

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

--Positive user % score per category

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

--Positive user % per user-created tags

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

--Top developers with over 10000 reviews

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

--Checking devs with at least 5 games

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

--Bottom developers with at least 5 games

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

--Top publishers with at least 5 games

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

--Bottom publishers

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

