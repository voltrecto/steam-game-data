SELECT *
FROM dbo.Dataset;

SELECT DISTINCT Estimated_owners
FROM dbo.Dataset;

--Creating new table for EstimatedOwners

CREATE TABLE EstimatedOwners (
	EstimatedOwnersID INT IDENTITY(1, 1) PRIMARY KEY
	,Range VARCHAR(50)
	);

INSERT INTO EstimatedOwners (Range)
VALUES ('0')
	,('0 - 20K')
	,('20K - 50K')
	,('50K - 100K')
	,('100K - 200K')
	,('200K - 500K')
	,('500K - 1M')
	,('1M - 2M')
	,('2M - 5M')
	,('5M - 10M')
	,('10M - 20M')
	,('20M - 50M')
	,('50M - 100M')
	,('100M - 200M');

SELECT *
FROM EstimatedOwners;

--Create Games table

CREATE TABLE Games (
	AppID INT PRIMARY KEY
	,Name NVARCHAR(255)
	,Release_date DATE
	,EstimatedOwnersID INT FOREIGN KEY REFERENCES EstimatedOwners(EstimatedOwnersID)
	,Peak_CCU INT
	,Required_age INT
	,Price MONEY
	,DLC_count INT
	,About_the_game NVARCHAR(MAX)
	,Windows INT
	,Mac INT
	,Linux INT
	,Metacritic_score INT
	,User_score INT
	,Positive INT
	,Negative INT
	,Achievements INT
	,Recommendations INT
	,Average_playtime_forever INT
	,Average_playtime_two_weeks INT
	,Median_playtime_forever INT
	,Median_playtime_two_weeks INT
	);

--Check the data that is going to be inserted into the games table

SELECT A.AppID
	,A.Name
	,A.Release_date
	,B.EstimatedOwnersID
	,A.Peak_CCU
	,A.Required_age
	,A.Price
	,A.DLC_count
	,A.About_the_game
	,A.Windows
	,A.Mac
	,A.Linux
	,A.Metacritic_score
	,A.User_score
	,A.Positive
	,A.Negative
	,A.Achievements
	,A.Recommendations
	,A.Average_playtime_forever
	,A.Average_playtime_two_weeks
	,A.Median_playtime_forever
	,A.Median_playtime_two_weeks
FROM Dataset A
JOIN EstimatedOwners B
	ON A.Estimated_owners = B.Range
ORDER BY 1;

--Insert data into Games

INSERT INTO Games
SELECT A.AppID
	,A.Name
	,A.Release_date
	,B.EstimatedOwnersID
	,A.Peak_CCU
	,A.Required_age
	,A.Price
	,A.DLC_count
	,A.About_the_game
	,A.Windows
	,A.Mac
	,A.Linux
	,A.Metacritic_score
	,A.User_score
	,A.Positive
	,A.Negative
	,A.Achievements
	,A.Recommendations
	,A.Average_playtime_forever
	,A.Average_playtime_two_weeks
	,A.Median_playtime_forever
	,A.Median_playtime_two_weeks
FROM Dataset A
JOIN EstimatedOwners B
	ON A.Estimated_owners = B.Range
ORDER BY 1;

SELECT *
FROM Games;

--Testing STRING_SPLIT to separate multiple values per row

SELECT PublisherList = Split.value
	,PublisherCount = COUNT(*)
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Publishers, ',') AS Split
GROUP BY Split.value
ORDER BY 2 DESC;

SELECT DeveloperList = Split.value
	,DeveloperCount = COUNT(*)
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Developers, ',') AS Split
GROUP BY Split.value
ORDER BY 2 DESC;

SELECT CategoryList = Split.value
	,CategoryCount = COUNT(*)
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Categories, ',') AS Split
GROUP BY Split.value
ORDER BY 2 DESC;

SELECT GenreList = Split.value
	,GenreCount = COUNT(*)
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Genres, ',') AS Split
GROUP BY Split.value
ORDER BY 2 DESC;

SELECT TagList = Split.value
	,TagCount = COUNT(*)
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Tags, ',') AS Split
GROUP BY Split.value
ORDER BY 2 DESC;

--Creating table for all Tags

CREATE TABLE Tags (
	TagID INT IDENTITY(1, 1) PRIMARY KEY
	,Name NVARCHAR(50)
	);

INSERT INTO Tags (Name)
SELECT DISTINCT Split.value
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Tags, ',') AS Split
ORDER BY 1;

SELECT *
FROM Tags;

--Creating table for Game_Tags which will link the AppIDs from Games table with the TagIDs from Tags table

CREATE TABLE Game_Tags (
	AppID INT FOREIGN KEY REFERENCES Games(AppID)
	,TagID INT FOREIGN KEY REFERENCES Tags(TagID)
	,PRIMARY KEY (
		AppID
		,TagID
		)
	);

INSERT INTO Game_Tags (
	AppID
	,TagID
	)
SELECT Games.AppID
	,Tags.TagID
FROM Games
JOIN dbo.Dataset
	ON Games.AppID = Dataset.AppID
CROSS APPLY STRING_SPLIT(dbo.Dataset.Tags, ',') AS GameTags
JOIN Tags
	ON GameTags.value = Tags.Name;

--Testing Game_Tags by getting all Tags under an App ID and comparing with original dataset

SELECT Name
FROM Games
WHERE AppID = 50;

SELECT Tags
FROM Dataset
WHERE AppID = 50;

SELECT A.Name
FROM Tags A
JOIN Game_Tags B
	ON A.TagID = B.TagID
WHERE B.AppID = 50;

--Repeating the steps for Categories

CREATE TABLE Categories (
	CategoryID INT IDENTITY(1, 1) PRIMARY KEY
	,Name NVARCHAR(50)
	);

INSERT INTO Categories (Name)
SELECT DISTINCT Split.value
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Categories, ',') AS Split
ORDER BY 1;

CREATE TABLE Game_Categories (
	AppID INT FOREIGN KEY REFERENCES Games(AppID)
	,CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID)
	,PRIMARY KEY (
		AppID
		,CategoryID
		)
	);

INSERT INTO Game_Categories (
	AppID
	,CategoryID
	)
SELECT Games.AppID
	,Categories.CategoryID
FROM Games
JOIN dbo.Dataset
	ON Games.AppID = Dataset.AppID
CROSS APPLY STRING_SPLIT(dbo.Dataset.Categories, ',') AS GameCategories
JOIN Categories
	ON GameCategories.value = Categories.Name;

--Got the error Violation of PRIMARY KEY constraint 'PK__Game_Cat__2FBC647BE76770E9'. Cannot insert duplicate key in object 'dbo.Game_Categories'. 
--The duplicate key value is (620, 35). The statement has been terminated.
--Checking the duplicated value

SELECT *
FROM Games
WHERE AppID = 620;

--Game is Portal 2

SELECT *
FROM Categories
WHERE CategoryID = 35;

--Category is Steam Workshop

--Looking at the original dataset

SELECT Categories
FROM Dataset
WHERE AppID = 620;

--The issue is that Steam Workshop is listed twice under Categories
--Adding DISTINCT so that any duplicate doesn't get attempted to be added

INSERT INTO Game_Categories (
	AppID
	,CategoryID
	)
SELECT DISTINCT Games.AppID
	,Categories.CategoryID
FROM Games
JOIN dbo.Dataset
	ON Games.AppID = Dataset.AppID
CROSS APPLY STRING_SPLIT(dbo.Dataset.Categories, ',') AS GameCategories
JOIN Categories
	ON GameCategories.value = Categories.Name;

--Testing Categories

SELECT Categories
FROM Dataset
WHERE AppID = 620;

SELECT A.Name
FROM Categories A
JOIN Game_Categories B
	ON A.CategoryID = B.CategoryID
WHERE B.AppID = 620;

--Repeating the processfor Genres

CREATE TABLE Genres (
	GenreID INT IDENTITY(1, 1) PRIMARY KEY
	,Name NVARCHAR(50)
	);

INSERT INTO Genres (Name)
SELECT DISTINCT Split.value
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Genres, ',') AS Split
ORDER BY 1;

CREATE TABLE Game_Genres (
	AppID INT FOREIGN KEY REFERENCES Games(AppID)
	,GenreID INT FOREIGN KEY REFERENCES Genres(GenreID)
	,PRIMARY KEY (
		AppID
		,GenreID
		)
	);

INSERT INTO Game_Genres (
	AppID
	,GenreID
	)
SELECT Games.AppID
	,Genres.GenreID
FROM Games
JOIN dbo.Dataset
	ON Games.AppID = Dataset.AppID
CROSS APPLY STRING_SPLIT(dbo.Dataset.Genres, ',') AS GameGenres
JOIN Genres
	ON GameGenres.value = Genres.Name;

--Checking Genres

SELECT Genres
FROM Dataset
WHERE AppID = 485360;

SELECT A.Name
FROM Genres A
JOIN Game_Genres B
	ON A.GenreID = B.GenreID
WHERE B.AppID = 485360;

--Looking at Developers list

SELECT DeveloperList = Split.value
	,DeveloperCount = COUNT(*)
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Developers, ',') AS Split
GROUP BY Split.value
ORDER BY 2 DESC

--There are several entries that are only inc, LLC or ltd because some developer names included commas ending with these strings
--All of them start with a whitespace
--We are repeating what we did with Tags, Categories and Genres but excluding values that begin with a whitespace.
--This leaves only the actual developer names to be added to the Developers table

CREATE TABLE Developers (
	DeveloperID INT IDENTITY(1, 1) PRIMARY KEY
	,Name NVARCHAR(200)
	);

--Insert developers except those that start with a whitepsace

INSERT INTO Developers (Name)
SELECT DISTINCT Split.value
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Developers, ',') AS Split
WHERE NOT LEFT(Split.value, 1) = ' '
ORDER BY 1;

CREATE TABLE Game_Developers (
	AppID INT FOREIGN KEY REFERENCES Games(AppID)
	,DeveloperID INT FOREIGN KEY REFERENCES Developers(DeveloperID)
	,PRIMARY KEY (
		AppID
		,DeveloperID
		)
	);

INSERT INTO Game_Developers (
	AppID
	,DeveloperID
	)
SELECT DISTINCT Games.AppID
	,Developers.DeveloperID
FROM Games
JOIN dbo.Dataset
	ON Games.AppID = Dataset.AppID
CROSS APPLY STRING_SPLIT(dbo.Dataset.Developers, ',') AS GameDevelopers
JOIN Developers
	ON GameDevelopers.value = Developers.Name;

--Doing the same with publishers

CREATE TABLE Publishers (
	PublisherID INT IDENTITY(1, 1) PRIMARY KEY
	,Name NVARCHAR(200)
	);

--Insert publishers except those that start with a whitepsace

INSERT INTO Publishers (Name)
SELECT DISTINCT Split.value
FROM dbo.Dataset
CROSS APPLY STRING_SPLIT(Publishers, ',') AS Split
WHERE NOT LEFT(Split.value, 1) = ' '
ORDER BY 1;

CREATE TABLE Game_Publishers (
	AppID INT FOREIGN KEY REFERENCES Games(AppID)
	,PublisherID INT FOREIGN KEY REFERENCES Publishers(PublisherID)
	,PRIMARY KEY (
		AppID
		,PublisherID
		)
	);

INSERT INTO Game_Publishers (
	AppID
	,PublisherID
	)
SELECT DISTINCT Games.AppID
	,Publishers.PublisherID
FROM Games
JOIN dbo.Dataset
	ON Games.AppID = Dataset.AppID
CROSS APPLY STRING_SPLIT(dbo.Dataset.Publishers, ',') AS GamePublishers
JOIN Publishers
	ON GamePublishers.value = Publishers.Name;

--Validating developer and publisher data

SELECT *
FROM Dataset
WHERE AppID = 203160

SELECT GameName = A.Name
	,Developer = C.Name
FROM Games A
JOIN Game_Developers B
	ON A.AppID = B.AppID
JOIN Developers C
	ON B.DeveloperID = C.DeveloperID
WHERE A.AppID = 203160;

SELECT GameName = A.Name
	,Publisher = C.Name
FROM Games A
JOIN Game_Publishers B
	ON A.AppID = B.AppID
JOIN Publishers C
	ON B.PublisherID = C.PublisherID
WHERE A.AppID = 203160;

--Created tables accurately list developers, publishers, categories, genres, and tags for random games tested
