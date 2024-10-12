DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

---- Exploratory Data Analysis ----

SELECT COUNT (*) FROM SPOTIFY;

SELECT COUNT(DISTINCT ARTIST) FROM SPOTIFY;

SELECT DISTINCT ALBUM_TYPE FROM SPOTIFY;

SELECT DURATION_MIN FROM SPOTIFY;

SELECT MAX(DURATION_MIN) FROM SPOTIFY;
SELECT MIN(DURATION_MIN) FROM SPOTIFY;

SELECT * FROM SPOTIFY
WHERE DURATION_MIN = 0;

DELETE * FROM SPOTIFY
WHERE DUARATION_MIN = 0;

SELECT DISTINCT CHANNEL FROM SPOTIFY;

SELECT DISTINCT MOST_PLAYED_ON FROM SPOTIFY;

---- DATA ANALYSIS - EASY QUERIES SECTION.----

-- QUE 01: Retrievethe names of all tracks that have more than 1 billion streams
SELECT * FROM SPOTIFY
WHERE STREAM > 1000000000;

-- QUE 02: List all albums along with their respectives artists.
SELECT
	DISTINCT ALBUM, ARTIST
FROM SPOTIFY
ORDER BY 1;

-- QUE 03: Get the total number of comments for tracks where licenced = true
SELECT
	SUM(COMMENTS) AS TOTAL_COMMENTS
FROM SPOTIFY
WHERE LICENSED = 'TRUE';

-- QUE 04: Find all tracks that belong to the album type single.
SELECT * FROM SPOTIFY
WHERE ALBUM_TYPE = 'SINGLE';

-- QUE 05: Count the total numberof tracks by each artist.
SELECT 
	ARTIST,
	COUNT(*) AS TOTAL_SONGS
	FROM SPOTIFY
GROUP BY ARTIST
ORDER BY 2;

---- Medium Level Queries ----

-- QUE 06: Calculate the average dancebility of tracks in each album.
SELECT 
	ALBUM,
	AVG(DANCEABILITY) AS AVG_DANCEABILITY
FROM SPOTIFY
GROUP BY 1
ORDER BY 2 DESC;

-- QUE 07: Find the Top 5 tracks with the Highest Energy Vakues.
SELECT 
	TRACK,
	MAX(ENERGY)
FROM SPOTIFY
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- QUE 08: List all the tracks along with their views and like where official video = true
SELECT
	TRACK,
SUM(VIEWS) AS TOTAL_VIEWS,
SUM (LIKES) AS TOTAL_LIKES
FROM SPOTIFY
	WHERE OFFICIAL_VIDEO= 'TRUE'
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5;

-- QUE 09: For Each album, calculate the total vies of all associated tracks.
SELECT
	ALBUM,
	TRACK,
	SUM(VIEWS)
FROM SPOTIFY 
GROUP BY 1,2
ORDER BY 3 DESC;

-- QUE 10: Retrive the track name that have been streamed on spotify more than youtube.
SELECT * FROM
	(
	SELECT
	TRACK,
	COALESCE (SUM(CASE WHEN MOST_PLAYED_ON='YOUTUBE' THEN STREAM END),0) AS STREAMED_ON_YOUTUBE,
	COALESCE (SUM(CASE WHEN MOST_PLAYED_ON='SPOTIFY' THEN STREAM END),0) AS STREAMED_ON_SPOTIFY
FROM SPOTIFY
GROUP BY 1
) AS T1
WHERE
	STREAMED_ON_SPOTIFY > STREAMED_ON_YOUTUBE
	AND
STREAMED_ON_YOUTUBE <> 0;

-- QUE 11: Find the top 3 most viewed tracks for each artist using window function
-- Each Artist and total view for each track
-- track with Highest views for each artist (we need top)
-- dense rank
-- CTE and Filter rank <=3
WITH RANKING_ARTIST
	AS
(SELECT
	ARTIST,
	TRACK,
	SUM(VIEWS) AS TOTAL_VIEWS,
	DENSE_RANK() OVER(PARTITION BY ARTIST ORDER BY SUM(VIEWS) DESC) AS RANK
FROM SPOTIFY
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT * FROM RANKING_ARTIST
WHERE RANK <=3;


-- QUE 12: Write a query to find tracks where the liveness score is above the average.
SELECT
	TRACK,
	ARTIST,
	LIVENESS
FROM SPOTIFY
WHERE LIVENESS > (SELECT AVG(LIVENESS) FROM SPOTIFY)

-- QUE 13: use a with clause to calculate the difference between the
-- Highest and Lowest Energy values for tracks in each album.
WITH CTE
	AS
	(SELECT ALBUM,
MAX(ENERGY) AS HIGHEST_ENERGY,
MIN(ENERGY) AS LOWEST_ENERGY
FROM SPOTIFY
GROUP BY 1
)
SELECT ALBUM,
HIGHEST_ENERGY - LOWEST_ENERGY AS ENERGY_DIFF
FROM CTE
ORDER BY 2 DESC;