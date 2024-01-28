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

**SQL Queries:** [Data Cleaning Queries](https://github.com/voltrecto/steam-game-data/blob/main/SteamDataCleaning.sql)
* Removed columns that do not have data relevant to our analysis or those that are mostly NULL:
	1. Support_languages
	2. Full_audio_languages
	3. Reviews
	4. Header_image
	5. Website
	6. Support_url
	7. Support_email
	8. Metacritic_url
	9. Score_rank
	10. Notes
	11. Screenshots
	12. Movies
* Checked remaining columns for NULL values.
* Manually updated Name values for 2 entries.
* Renamed Estimated_owner values for better readability.
* Replaced NULL values with "None" for multiple columns.
## Data Normalization

**SQL Queries:** [Data Normalization](https://github.com/voltrecto/steam-game-data/blob/main/SteamDataNormalization.sql)
* Created new table Games.
* Created separate tables for the following columns because these columns had multiple comma-separated values in the original dataset:
	1. Developers
	2. Publishers
	3. Categories
	4. Genres
	5. Tags
* Created separate table for Estimated_owners.