--Review the dataset

SELECT *
FROM dbo.Dataset;

--Remove columns that we don't need

SELECT Score_rank
	,COUNT(*)
FROM dbo.Dataset
GROUP BY Score_rank;

--Score rank of the game based on user reviews 
--85055 NULL

--We're dropping all columns that we don't need

ALTER TABLE dbo.Dataset

DROP COLUMN Supported_languages
	,Full_audio_languages
	,Reviews
	,Header_image
	,Website
	,Support_url
	,Support_email
	,Metacritic_url
	,Score_rank
	,Notes
	,Screenshots
	,Movies;

--Check for null names

SELECT *
FROM dbo.Dataset
WHERE Name IS NULL;

--Found 6 games with NULL names
--Checked each game manually directly on Steam.
--4 out of the 6 games are no longer available in the store.

-- Delete rows for games with NULL names and are no longer in the Steam store

DELETE
FROM dbo.Dataset
WHERE AppID IN (
		1080790
		,1172120
		,1256960
		,1365520
		);

--Manually updating the 2 games with names found on the Steam site.

UPDATE dbo.Dataset
SET Name = 'The Spookening'
WHERE AppID = 396420;

UPDATE dbo.Dataset
SET Name = 'I am the dirt-for art'
WHERE AppID = 1116910;

--Checking other columns for nulls

SELECT *
FROM dbo.Dataset
WHERE Release_date IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Estimated_owners IS NULL;

SELECT DISTINCT Estimated_owners
FROM dbo.Dataset
ORDER BY 1;

--To make it easier to read Estimated_owners, I'm renaming the categories

UPDATE dbo.Dataset
SET Estimated_owners = CASE 
		WHEN Estimated_owners = '0 - 20000'
			THEN '0 - 20K'
		WHEN Estimated_owners = '100000 - 200000'
			THEN '100K - 200K'
		WHEN Estimated_owners = '1000000 - 2000000'
			THEN '1M - 2M'
		WHEN Estimated_owners = '10000000 - 20000000'
			THEN '10M - 20M'
		WHEN Estimated_owners = '100000000 - 200000000'
			THEN '100M - 200M'
		WHEN Estimated_owners = '20000 - 50000'
			THEN '20K - 50K'
		WHEN Estimated_owners = '200000 - 500000'
			THEN '200K - 500K'
		WHEN Estimated_owners = '2000000 - 5000000'
			THEN '2M - 5M'
		WHEN Estimated_owners = '20000000 - 50000000'
			THEN '20M - 50M'
		WHEN Estimated_owners = '50000 - 100000'
			THEN '50K - 100K'
		WHEN Estimated_owners = '500000 - 1000000'
			THEN '500K - 1M'
		WHEN Estimated_owners = '5000000 - 10000000'
			THEN '5M - 10M'
		WHEN Estimated_owners = '50000000 - 100000000'
			THEN '50M - 100M'
		ELSE '0'
		END;

--(85099 rows affected)

SELECT *
FROM dbo.Dataset
WHERE Peak_CCU IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Required_age IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Price IS NULL;

SELECT *
FROM dbo.Dataset
WHERE DLC_count IS NULL;

SELECT *
FROM dbo.Dataset
WHERE About_the_game IS NULL;

--Replacing null values with 'None'

UPDATE dbo.Dataset
SET About_the_game = 'None'
WHERE About_the_game IS NULL;

--(3563 rows affected)

--Continue checking for null values

SELECT DISTINCT Windows
FROM dbo.Dataset;

SELECT DISTINCT Mac
FROM dbo.Dataset;

SELECT DISTINCT Linux
FROM dbo.Dataset;

SELECT *
FROM dbo.Dataset
WHERE Metacritic_score IS NULL;

SELECT Metacritic_score
	,COUNT(Metacritic_score)
FROM dbo.Dataset
GROUP BY Metacritic_score
ORDER BY 2 DESC;

SELECT *
FROM dbo.Dataset
WHERE User_score IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Positive IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Negative IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Achievements IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Recommendations IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Average_playtime_forever IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Average_playtime_two_weeks IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Median_playtime_forever IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Median_playtime_two_weeks IS NULL;

SELECT *
FROM dbo.Dataset
WHERE Developers IS NULL;

--Replace null values with 'Unknown'

UPDATE dbo.Dataset
SET Developers = 'Unknown'
WHERE Developers IS NULL;

--(3579 rows affected)

SELECT *
FROM dbo.Dataset
WHERE Publishers IS NULL;

--Replace null values with 'Unknown'

UPDATE dbo.Dataset
SET Publishers = 'Unknown'
WHERE Publishers IS NULL;

--(3798 rows affected)

SELECT *
FROM dbo.Dataset
WHERE Categories IS NULL;

--Replace null values with 'None'

UPDATE dbo.Dataset
SET Categories = 'None'
WHERE Categories IS NULL;

--(4596 rows affected)

UPDATE dbo.Dataset
SET Genres = 'None'
WHERE Genres IS NULL;

--(3554 rows affected)

UPDATE dbo.Dataset
SET Tags = 'None'
WHERE Tags IS NULL;

--(21096 rows affected)
