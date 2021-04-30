/*
CTEs, Temp Tables, and APPLY

This script is from our Mastering Query Tuning class.
To learn more: https://www.BrentOzar.com/go/tuninglabs



License: Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
More info: https://creativecommons.org/licenses/by-sa/3.0/

You are free to:
* Share - copy and redistribute the material in any medium or format
* Adapt - remix, transform, and build upon the material for any purpose, even 
  commercially

Under the following terms:
* Attribution - You must give appropriate credit, provide a link to the license,
  and indicate if changes were made.
* ShareAlike - If you remix, transform, or build upon the material, you must
  distribute your contributions under the same license as the original.
*/






/* Say someone gives us this query to tune, and we've already added an index: */
CREATE INDEX Location ON dbo.Users (Location);
GO
CREATE OR ALTER PROC dbo.usp_UsersInTop10Locations AS
BEGIN
WITH TopLocation AS (SELECT TOP 10 Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC)
SELECT u.*
  FROM TopLocation
    INNER JOIN dbo.Users u ON TopLocation.Location = u.Location
  ORDER BY DisplayName;
END
GO

EXEC usp_UsersInTop10Locations
GO






CREATE OR ALTER PROC dbo.usp_UsersInTop10Locations AS
BEGIN
/* Phase 1 */
CREATE TABLE #TopLocations (Location NVARCHAR(100));
INSERT INTO #TopLocations (Location)
SELECT TOP 10 Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC;

/* Phase 2 */
SELECT u.*
  FROM #TopLocations tl
    INNER JOIN dbo.Users u ON tl.Location = u.Location
  ORDER BY DisplayName;
END
GO

EXEC usp_UsersInTop10Locations
GO



/* Seeing the statistics */
/* Phase 1 */
CREATE TABLE #TopLocations (Location NVARCHAR(100));
INSERT INTO #TopLocations (Location)
SELECT TOP 10 Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC;

/* Phase 2 */
SELECT u.*
  FROM #TopLocations tl
    INNER JOIN dbo.Users u ON tl.Location = u.Location
  ORDER BY DisplayName;
GO

USE tempdb;
GO
/* Get the temp table's full name: */
SELECT * FROM sys.all_objects WHERE name LIKE '%TopLocations%'

/* Then paste it into here: */
sp_BlitzIndex @TableName = '#TopLocations_______________________________________________________________________________________________________000000000C93'

DROP TABLE #TopLocations;
GO




CREATE OR ALTER PROC dbo.usp_UsersInTop10Locations AS
BEGIN
/* Phase 1 */
DECLARE @TopLocations TABLE (Location NVARCHAR(100));
INSERT INTO @TopLocations (Location)
SELECT TOP 10 Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC;

/* Phase 2 */
SELECT u.*
  FROM @TopLocations tl
    INNER JOIN dbo.Users u ON tl.Location = u.Location
  ORDER BY DisplayName;
END
GO

EXEC usp_UsersInTop10Locations
GO







USE StackOverflow;
GO
CREATE OR ALTER PROC dbo.usp_TopVotersInCity @Location NVARCHAR(40) AS
BEGIN
/* Find the users who have left the most votes */
SELECT UserId, COUNT(*) AS TotalVotes
  INTO #TopVoters
  FROM dbo.Votes v
  GROUP BY v.UserId
  ORDER BY COUNT(*) DESC;

SELECT TOP 100 tv.TotalVotes, u.DisplayName, u.Location
  FROM #TopVoters tv
  INNER JOIN dbo.Users u ON tv.UserId = u.Id
  WHERE u.Location = @Location
  ORDER BY u.DisplayName;
END
GO

EXEC usp_TopVotersInCity @Location = 'San Diego';
GO




CREATE OR ALTER PROC dbo.usp_TopVotersInCity_CTE @Location NVARCHAR(40) AS
BEGIN
WITH TopVoters AS (
	SELECT UserId, COUNT(*) AS TotalVotes
	  FROM dbo.Votes v
	  GROUP BY v.UserId
	  /* ORDER BY COUNT(*) DESC */)
SELECT TOP 100 tv.TotalVotes, u.DisplayName, u.Location
  FROM TopVoters tv
  INNER JOIN dbo.Users u ON tv.UserId = u.Id
  WHERE u.Location = @Location
  ORDER BY u.DisplayName;
END
GO

EXEC usp_TopVotersInCity_CTE @Location = 'San Diego';
GO








/* APPLY */

/* Show a user's top-scoring questions */

SELECT q.Id AS QuestionId, q.Title AS CurrentTitle, q.Score
  FROM dbo.Posts q
  WHERE q.OwnerUserId = 1031417
    AND q.PostTypeId = 1 /* Question */
  ORDER BY q.Score DESC;


/* Add rows for the first 5 titles per post... */

SELECT q.Id AS QuestionId, q.Title AS CurrentTitle, q.Score,
	qTitles.CreationDate AS TitleEditDate, qTitles.Text AS TitleText
  FROM dbo.Posts q

  CROSS APPLY (SELECT TOP 5 ph.CreationDate, ph.Text
				FROM dbo.PostHistory ph
				WHERE ph.PostId = q.Id
					AND ph.PostHistoryTypeId = 4
				ORDER BY ph.CreationDate) qTitles

  WHERE q.OwnerUserId = 1031417
    AND q.PostTypeId = 1 /* Question */
  ORDER BY q.Score DESC, q.Id, qTitles.CreationDate;