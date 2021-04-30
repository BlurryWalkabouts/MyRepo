
------------------- The D.E.A.T.H. Method - Starting with the D.E.
-------------------  Dedupe and Eliminate (51:43)
/* 2019-11-29: Hi! Wow, you smell much better today, even across Slack. Not nearly as bad as yesterday.

I reviewed the Users table, and we need to drop these indexes because they're not getting used: */
DROP INDEX IX_DisplayName ON dbo.Users;
DROP INDEX IX_LastAccessDate ON dbo.Users;
DROP INDEX IX_ID4 ON dbo.Users;
GO

/* In case things go wrong, here's an undo script:
CREATE INDEX IX_DisplayName ON dbo.Users(DisplayName);
CREATE INDEX IX_LastAccessDate ON dbo.Users(LastAccessDate);
CREATE INDEX IX_ID4 ON dbo.Users(Id);


This index is a narrower subset of IX_LocationWebsiteUrl, so we should drop it: */
DROP INDEX IX_Location ON dbo.Users;
GO

/* In case things go wrong, here's an undo script:
CREATE INDEX IX_Location ON dbo.Users(Location);

I'd like to merge these two indexes together into one:

CREATE INDEX IX_Reputation_Includes ON dbo.Users(Reputation) INCLUDE (LastAccessDate);
CREATE INDEX IX_Reputation_Location ON dbo.Users(Reputation, Location);

Into this one: */
CREATE INDEX IX_Reputation_Location_Includes ON dbo.Users(Reputation, Location) INCLUDE (LastAccessDate);
GO
/* And get rid of those above two afterwards: */
DROP INDEX IX_Reputation_Includes ON dbo.Users;
DROP INDEX IX_Reputation_Location ON dbo.Users;
GO
-------------------
-------------------Why Index Read & Write Numbers are Wrong (47:47)
/*
Mastering Index Tuning - Index Usage DMV Gotchas
 
This script is from our Mastering Index Tuning class.
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



/* Doorstop */
RAISERROR(N'Did you mean to run the whole thing?', 20, 1) WITH LOG;
GO




USE StackOverflow;
GO
EXEC DropIndexes;
GO
CREATE INDEX IX_LastAccessDate ON dbo.Users(LastAccessDate);
GO
EXEC sp_BlitzIndex @SchemaName='dbo', @TableName='Users';
GO


/* Look at the Usage Stats and Operational Stats columns */
/* These comes from sys.dm_db_index_usage_stats and sys.dm_db_index_operational_stats */


/* Look at the page reads for this query. */
/* Did it scan the whole index? */
SET STATISTICS IO ON;
GO
SELECT TOP 10 Id
FROM dbo.Users
ORDER BY LastAccessDate;
GO


/* Can you tell if it's a bad scan from the index DMVs? */
exec sp_BlitzIndex @SchemaName='dbo', @TableName='Users';
GO



/* Try a descending one. Does it read the whole table? */
SELECT TOP 10 Id
FROM dbo.Users
ORDER BY LastAccessDate DESC;
GO
/* Look in the properties of the NC index scan-- it did a backwards scan */


exec sp_BlitzIndex @SchemaName='dbo', @TableName='Users';
GO



/* Reset the index usage statistics. Man, I wish there was an easier way to do this in 2016. */
USE [master]
GO
ALTER DATABASE [StackOverflow] SET  OFFLINE WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE [StackOverflow] SET ONLINE;
GO
USE StackOverflow;
GO



/* This plan is slightly different, it has a key lookup */
SELECT TOP 10 Id, Location
FROM dbo.Users
ORDER BY LastAccessDate;
GO


/* Compare how the key lookup is recorded differently in index_stats and usage_stats */
exec sp_BlitzIndex @SchemaName='dbo', @TableName='Users';
GO





/* Reset the index usage statistics. Man, I wish there was an easier way to do this in 2016. */
USE [master]
GO
ALTER DATABASE [StackOverflow] SET  OFFLINE WITH ROLLBACK IMMEDIATE;
GO
ALTER DATABASE [StackOverflow] SET ONLINE;
GO
USE StackOverflow;
GO




/* This plan is slightly different, it has a key lookup - but it doesn't get executed. */
SELECT TOP 10 Id, Location
FROM dbo.Users
WHERE LastAccessDate > GETDATE()
ORDER BY LastAccessDate;
GO


/* How does that show up in the DMVs? */
exec sp_BlitzIndex @SchemaName='dbo', @TableName='Users';
GO
-------------------
-------------------Lab 1 Setup: Do the D.E. Steps (7:03)
/* 2019-11-29: Hi! Wow, you smell much better today, even across Slack. Not nearly as bad as yesterday.

I reviewed the Users table, and we need to drop these indexes because they're not getting used: */
DROP INDEX IX_DisplayName ON dbo.Users;
DROP INDEX IX_LastAccessDate ON dbo.Users;
DROP INDEX IX_ID4 ON dbo.Users;
GO

/* In case things go wrong, here's an undo script:
CREATE INDEX IX_DisplayName ON dbo.Users(DisplayName);
CREATE INDEX IX_LastAccessDate ON dbo.Users(LastAccessDate);
CREATE INDEX IX_ID4 ON dbo.Users(Id);


This index is a narrower subset of IX_LocationWebsiteUrl, so we should drop it: */
DROP INDEX IX_Location ON dbo.Users;
GO

/* In case things go wrong, here's an undo script:
CREATE INDEX IX_Location ON dbo.Users(Location);

I'd like to merge these two indexes together into one:

CREATE INDEX IX_Reputation_Includes ON dbo.Users(Reputation) INCLUDE (LastAccessDate);
CREATE INDEX IX_Reputation_Location ON dbo.Users(Reputation, Location);

Into this one: */
CREATE INDEX IX_Reputation_Location_Includes ON dbo.Users(Reputation, Location) INCLUDE (LastAccessDate);
GO
/* And get rid of those above two afterwards: */
DROP INDEX IX_Reputation_Includes ON dbo.Users;
DROP INDEX IX_Reputation_Location ON dbo.Users;
GO
-------------------
-------------------Lab 1: Brent's Solution (42:39)
-------------------The T Step: Tuning Indexes for Specific Queries
------------------- 
------------------- Tuning Indexes for Specific Queries (55:10)
MYSQL
SELECT Id
  FROM dbo.Users
  WHERE DisplayName = 'Brent Ozar'
  AND WebsiteUrl = 'https://www.brentozar.com';
GO


/* Turn on actual plans (control-M) and: */
SET STATISTICS IO, TIME ON;
GO

CREATE OR ALTER PROC [dbo].[usp_Q6925] @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/6925/newer-users-with-more-reputation-than-me */
 
 
SELECT u.Id as [User Link], u.Reputation, u.Reputation - me.Reputation as Difference
FROM dbo.Users me 
INNER JOIN dbo.Users u 
	ON u.CreationDate > me.CreationDate
	AND u.Reputation > me.Reputation
WHERE me.Id = @UserId
ORDER BY u.Reputation DESC; 
END
GO


EXEC usp_Q6925 @UserId = 26837
GO

CREATE OR ALTER   PROC [dbo].[usp_PostsByCommentCount] @PostTypeId INT
AS
SELECT TOP 10 CommentCount, Score, ViewCount
FROM dbo.Posts
WHERE PostTypeId = @PostTypeId
ORDER BY CommentCount DESC;
GO

CREATE OR ALTER   PROC [dbo].[usp_PostsByScore] @PostTypeId INT, @CommentCountMinimum INT
AS
SELECT TOP 10 Id, CommentCount, Score
FROM dbo.Posts
WHERE CommentCount >= @CommentCountMinimum
AND PostTypeId = @PostTypeId
ORDER BY Score DESC;
GO

/* Create one index to improve both of these: */
EXEC usp_PostsByCommentCount @PostTypeId = 2;
GO
EXEC usp_PostsByScore @PostTypeId = 2, @CommentCountMinimum = 2;
GO
Demo scripts for sp_BlitzCache:



MYSQL
/*
Using sp_BlitzCache to Find the Right Queries to Tune

2021-02-12 - v1.1

This demo requires:
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack

This script runs in 3-5 minutes. It creates & runs several stored procs to
populate your plan cache with bad queries for sp_BlitzCache to see.
*/
USE StackOverflow;
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'50' /* Keep small queries serial */
GO
EXEC sys.sp_configure N'max degree of parallelism', N'0' /* Let queries go parallel */
GO
RECONFIGURE
GO
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL=150;
GO
SET NOCOUNT ON;
GO
DropIndexes;
GO
CREATE INDEX Reputation ON dbo.Users(Reputation);
GO
CREATE OR ALTER PROCEDURE dbo.usp_MissAnIndex @DisplayName NVARCHAR(40) ='Brent Ozar'
AS
SELECT COUNT_BIG(*) AS Records
FROM dbo.Users AS u
WHERE u.DisplayName=@DisplayName;
GO
CREATE OR ALTER PROCEDURE dbo.usp_MissingMissingIndex
AS
SELECT Location, COUNT(*) AS recs
FROM dbo.Users u
GROUP BY Location
ORDER BY COUNT(*) DESC;
GO
CREATE OR ALTER PROCEDURE dbo.usp_MissACoupleIndexes @Location NVARCHAR(200) =N'Antarctica'
AS
SELECT p.Score, p.Title, c.Score, c.Text AS CommentText
FROM dbo.Users u
INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
INNER JOIN dbo.Comments c ON p.Id = c.PostId
WHERE u.Location = @Location
ORDER BY p.Score DESC, p.Title, c.Score DESC;
GO
CREATE OR ALTER PROCEDURE dbo.usp_CauseImplicitConversion @DisplayName SQL_VARIANT='Brent Ozar'
AS BEGIN
    /*This proc will cause implicit conversion. The DisplayName is stored as NVARCHAR(40) in the Users table*/
    SELECT COUNT_BIG(*) AS Records
    FROM dbo.Users AS u
    WHERE u.DisplayName=@DisplayName;
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_ForceSerialScalarFunction(@Id INT)
RETURNS INT
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS BEGIN
    IF MONTH(GETDATE())>6 SET @Id=@Id+1;
    RETURN @Id;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ForceSerialProc(@Id INT=26837)
AS BEGIN
    DECLARE @idiot INT
    SELECT @idiot=dbo.fn_ForceSerialScalarFunction(u.Id)FROM dbo.Users AS u
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_TableVariables(@Reputation INT=2)
AS BEGIN
    DECLARE @Staging TABLE(Id INT NOT NULL);
    INSERT @Staging(Id)
    SELECT u.Id FROM dbo.Users AS u WHERE u.Reputation=@Reputation;
    SELECT * FROM @Staging AS c;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ExpensiveSort(@Id INT=26837)
AS BEGIN
    SELECT DENSE_RANK() OVER (PARTITION BY u.Age ORDER BY u.Reputation DESC, u.UpVotes DESC) AS ranker
    INTO #Staging
    FROM dbo.Users AS u
    WHERE u.Id>@Id;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ExpensiveKeyLookup(@Reputation INT=2)
AS BEGIN
    SELECT * FROM dbo.Users AS u WHERE u.Reputation=@Reputation;
END;
GO






DBCC FREEPROCCACHE;
GO
EXEC usp_MissAnIndex;
GO 3
EXEC usp_MissingMissingIndex
GO 3
EXEC usp_CauseImplicitConversion;
GO 3
EXEC usp_TableVariables;
GO 3
EXEC usp_ExpensiveKeyLookup;
GO 3
EXEC usp_ForceSerialProc;
GO
EXEC usp_ExpensiveSort;
GO
EXEC usp_MissACoupleIndexes;
GO

/*
Then, what's in your plan cache?
Run this separately:

EXEC sp_BlitzCache
*/



/*
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
HTML
/*
Using sp_BlitzCache to Find the Right Queries to Tune

2021-02-12 - v1.1

This demo requires:
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack

This script runs in 3-5 minutes. It creates & runs several stored procs to
populate your plan cache with bad queries for sp_BlitzCache to see.
*/
USE StackOverflow;
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'50' /* Keep small queries serial */
GO
EXEC sys.sp_configure N'max degree of parallelism', N'0' /* Let queries go parallel */
GO
RECONFIGURE
GO
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL=150;
GO
SET NOCOUNT ON;
GO
DropIndexes;
GO
CREATE INDEX Reputation ON dbo.Users(Reputation);
GO
CREATE OR ALTER PROCEDURE dbo.usp_MissAnIndex @DisplayName NVARCHAR(40) ='Brent Ozar'
AS
SELECT COUNT_BIG(*) AS Records
FROM dbo.Users AS u
WHERE u.DisplayName=@DisplayName;
GO
CREATE OR ALTER PROCEDURE dbo.usp_MissingMissingIndex
AS
SELECT Location, COUNT(*) AS recs
FROM dbo.Users u
GROUP BY Location
ORDER BY COUNT(*) DESC;
GO
CREATE OR ALTER PROCEDURE dbo.usp_MissACoupleIndexes @Location NVARCHAR(200) =N'Antarctica'
AS
SELECT p.Score, p.Title, c.Score, c.Text AS CommentText
FROM dbo.Users u
INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
INNER JOIN dbo.Comments c ON p.Id = c.PostId
WHERE u.Location = @Location
ORDER BY p.Score DESC, p.Title, c.Score DESC;
GO
CREATE OR ALTER PROCEDURE dbo.usp_CauseImplicitConversion @DisplayName SQL_VARIANT='Brent Ozar'
AS BEGIN
    /*This proc will cause implicit conversion. The DisplayName is stored as NVARCHAR(40) in the Users table*/
    SELECT COUNT_BIG(*) AS Records
    FROM dbo.Users AS u
    WHERE u.DisplayName=@DisplayName;
END;
GO
CREATE OR ALTER FUNCTION dbo.fn_ForceSerialScalarFunction(@Id INT)
RETURNS INT
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS BEGIN
    IF MONTH(GETDATE())>6 SET @Id=@Id+1;
    RETURN @Id;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ForceSerialProc(@Id INT=26837)
AS BEGIN
    DECLARE @idiot INT
    SELECT @idiot=dbo.fn_ForceSerialScalarFunction(u.Id)FROM dbo.Users AS u
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_TableVariables(@Reputation INT=2)
AS BEGIN
    DECLARE @Staging TABLE(Id INT NOT NULL);
    INSERT @Staging(Id)
    SELECT u.Id FROM dbo.Users AS u WHERE u.Reputation=@Reputation;
    SELECT * FROM @Staging AS c;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ExpensiveSort(@Id INT=26837)
AS BEGIN
    SELECT DENSE_RANK() OVER (PARTITION BY u.Age ORDER BY u.Reputation DESC, u.UpVotes DESC) AS ranker
    INTO #Staging
    FROM dbo.Users AS u
    WHERE u.Id>@Id;
END;
GO
CREATE OR ALTER PROCEDURE dbo.usp_ExpensiveKeyLookup(@Reputation INT=2)
AS BEGIN
    SELECT * FROM dbo.Users AS u WHERE u.Reputation=@Reputation;
END;
GO






DBCC FREEPROCCACHE;
GO
EXEC usp_MissAnIndex;
GO 3
EXEC usp_MissingMissingIndex
GO 3
EXEC usp_CauseImplicitConversion;
GO 3
EXEC usp_TableVariables;
GO 3
EXEC usp_ExpensiveKeyLookup;
GO 3
EXEC usp_ForceSerialProc;
GO
EXEC usp_ExpensiveSort;
GO
EXEC usp_MissACoupleIndexes;
GO

/*
Then, what's in your plan cache?
Run this separately:

EXEC sp_BlitzCache
*/



/*
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
------------------- 
------------------- Lab 2 Setup: Do the T Step (6:34)
------------------- 
------------------- Lab 2: Brent's Solution (47:54)
-------------------The A Step: Adding Indexes with Clippy and the DMVs
------------------- 
------------------- Adding Indexes with Clippy's Recommendations (44:41)
/*
Reverse Engineering Queries from Missing Index Recommendations

v1.0 - 2019-06-16

From Mastering Index Tuning: https://BrentOzar.com/go/masterindexes

This demo requires:

* Any supported version of SQL Server or Azure SQL DB
  (although the 10M row table creation can be pretty slow in Azure)
* Any Stack Overflow database: https://BrentOzar.com/go/querystack

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO
 
 
/* Demo setup: */
USE StackOverflow;
GO
EXEC DropIndexes;
GO



SELECT *
  FROM dbo.Users
  WHERE DisplayName = 'Brent Ozar'
    AND Location = 'San Diego, CA, USA';
GO

SELECT Location
  FROM dbo.Users
  WHERE DisplayName LIKE 'B%';
GO


SELECT Location
  FROM dbo.Users
  WHERE DisplayName LIKE 'B%'
  ORDER BY Location;
GO




SELECT *
  FROM dbo.Users
  WHERE DisplayName = 'Brent Ozar'
    AND Location <> 'San Diego, CA, USA';
GO



SELECT *
  FROM dbo.Users
  WHERE DisplayName <> 'Brent Ozar'
    AND Location = 'San Diego, CA, USA';
GO




/* Quiz 2: 2 queries at a time: */
SELECT Id
  FROM dbo.Users
  WHERE LastAccessDate = GETDATE()
    AND WebsiteUrl = 'https://www.BrentOzar.com';

SELECT Id
  FROM dbo.Users
  WHERE DownVotes = 0
    AND WebsiteUrl = 'https://www.BrentOzar.com';
GO



/* Quiz 3: 3 queries at a time: */
SELECT VoteTypeId, COUNT(*) AS TotalVotes
  FROM dbo.Votes
  WHERE PostId = 12345
  GROUP BY VoteTypeId;

SELECT *
  FROM dbo.Votes
  WHERE PostId = 12345
  ORDER BY CreationDate;

SELECT *
  FROM dbo.Votes
  WHERE PostId = 12345
    AND VoteTypeId IN (2, 3);
GO 5

/*
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
------------------- 
------------------- Avoiding Key Lookups and Residual Predicates (21:44)
------------------- 
------------------- Lab 3 Setup: Do the A Step (3:35)
------------------- 
------------------- Lab 3: Brent's Solution (43:19)
-------------------Tuning Indexes to Avoid Blocking
------------------- 
------------------- Blocking: When the 5 & 5 Guideline Isn't Specific Enough (38:21)
/* UPDATE WINDOW */

DropIndexes;
GO

SELECT COUNT(*)
FROM dbo.Users
WHERE LastAccessDate >= '2013/11/10'
AND LastAccessDate <= '2013/11/11'


BEGIN TRAN
UPDATE dbo.Users
SET Reputation = Reputation + 100
WHERE LastAccessDate >= '2013/11/10'
AND LastAccessDate <= '2013/11/11'
GO




ROLLBACK
GO
CREATE INDEX 
IX_LastAccessDate_Id
ON dbo.Users(LastAccessDate, Id)
GO


BEGIN TRAN
UPDATE dbo.Users
SET Reputation = Reputation + 100
WHERE LastAccessDate >= '2013/11/10'
AND LastAccessDate <= '2013/11/11'
GO



/* Come back after showing selects */
UPDATE dbo.Users
SET Reputation = Reputation + 100
WHERE LastAccessDate >= '2014/11/10'
AND LastAccessDate <= '2014/11/11'
GO

/* Go query Brent */


UPDATE dbo.Users
SET Reputation = Reputation + 100
WHERE LastAccessDate >= '2015/11/10'
AND LastAccessDate <= '2015/11/11'
GO
MYSQL
/* SELECT WINDOW */


SELECT *
FROM dbo.Users
WHERE Id = 26837
GO

SELECT COUNT(*)
  FROM dbo.Users;
GO


SELECT Id
FROM dbo.Users
WHERE LastAccessDate >= '1800/01/01'
AND LastAccessDate <= '1800/01/02'
GO


/* Now go add the index */

SELECT Id
FROM dbo.Users
WHERE LastAccessDate >= '1800/01/01'
AND LastAccessDate <= '1800/01/02'
GO



/* Let's also do a key lookup for Reputation */
SELECT Id, Reputation
FROM dbo.Users
WHERE LastAccessDate >= '1800/01/01'
AND LastAccessDate <= '1800/01/02'
GO


/* Let's try to hit the same dates we're updating */
SELECT Id, Reputation
FROM dbo.Users
WHERE LastAccessDate >= '2013/11/10'
AND LastAccessDate <= '2013/11/11'
GO


/* Maybe that's because we're changing Reputation.
   What if we select just Location instead, which isn't changing? */
SELECT Id, Location
FROM dbo.Users
WHERE LastAccessDate >= '2013/11/10'
AND LastAccessDate <= '2013/11/11'
GO


/* How could we fix that? */


/* Go update more rows, then get Brent again */
SELECT *
FROM dbo.Users
WHERE Id = 26837
GO




/* Go update more rows, then get Brent again */
SELECT *
FROM dbo.Users
WHERE Id = 26837
GO
------------------- 
------------------- Lab 4 Setup: Reducing Blocking with Just Index Changes (4:45)
/*
Mastering Index Tuning - Lab 4
Last updated: 2021-01-25

This script is from our Mastering Index Tuning class.
To learn more: https://www.BrentOzar.com/go/tuninglabs

Before running this setup script, restore the Stack Overflow database.
This script takes ~5 minutes with 4 cores, 30GB RAM, and SSD storage.




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


USE StackOverflow;
GO

IF DB_NAME() <> 'StackOverflow'
  RAISERROR(N'Oops! For some reason the StackOverflow database does not exist here.', 20, 1) WITH LOG;
GO


CREATE OR ALTER PROC dbo.usp_LogUserVisit @Id INT AS
BEGIN
UPDATE dbo.Users
	SET LastAccessDate = GETUTCDATE()
	WHERE Id = @Id;
END
GO

CREATE OR ALTER PROC dbo.usp_LogPostView @PostId INT, @UserId INT = NULL AS
BEGIN
BEGIN TRAN
	UPDATE dbo.Posts
		SET ViewCount = ViewCount + 1, LastActivityDate = GETUTCDATE()
		WHERE Id = @PostId;

	/* If the post is a question, and it has achieved 1,000 views, give the owner a badge */
	IF 1000 >= (SELECT ViewCount FROM dbo.Posts WHERE Id = @PostId AND PostTypeId = 1)
		AND NOT EXISTS (SELECT * 
							FROM dbo.Posts p
							INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
							INNER JOIN dbo.Badges b ON u.Id = b.UserId AND b.Name = 'Popular Question'
							WHERE p.Id = @PostId)
		BEGIN
		INSERT INTO dbo.Badges(Name, UserId, Date)
			SELECT 'Popular Question', OwnerUserId, GETUTCDATE()
			FROM dbo.Posts p
			INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
			WHERE p.Id = @PostId;
		END 

	/* If the post is an answer, and it has achieved 1,000 views, give the owner a badge */
	IF 1000 >= (SELECT ViewCount FROM dbo.Posts WHERE Id = @PostId AND PostTypeId = 2)
		AND NOT EXISTS (SELECT * 
							FROM dbo.Posts p
							INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
							INNER JOIN dbo.Badges b ON u.Id = b.UserId AND b.Name = 'Popular Answer'
							WHERE p.Id = @PostId)
		BEGIN
		INSERT INTO dbo.Badges(Name, UserId, Date)
			SELECT 'Popular Answer', OwnerUserId, GETUTCDATE()
			FROM dbo.Posts p
			INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
			WHERE p.Id = @PostId;
		END 

	IF @UserId IS NOT NULL
		UPDATE dbo.Users
			SET LastAccessDate = GETUTCDATE()
			WHERE Id = @UserId;

COMMIT
END
GO

CREATE OR ALTER PROC dbo.usp_LogVote @PostId INT, @UserId INT, @VoteTypeId INT AS
BEGIN
BEGIN TRAN
	INSERT INTO dbo.Votes(PostId, UserId, VoteTypeId, CreationDate)
	SELECT @PostId, @UserId, @VoteTypeId, GETDATE()
		FROM dbo.Posts p
		  LEFT OUTER JOIN dbo.Votes v ON p.Id = v.PostId
									AND v.VoteTypeId = @VoteTypeId
									AND v.UserId = @UserId /* Not allowed to vote twice */
		WHERE p.Id = @PostId			/* Make sure it's a valid post */
		  AND p.ClosedDate IS NULL		/* Not allowed to vote on closed posts */
		  AND p.OwnerUserId <> @UserId	/* Not allowed to vote on your own posts */
		  AND v.Id IS NULL				/* Not allowed to vote twice */
		  AND EXISTS (SELECT * FROM dbo.VoteTypes vt WHERE vt.Id = @VoteTypeId) /* Only accept current vote types */

	IF @VoteTypeId = 2 /* UpVote */
		BEGIN
		UPDATE dbo.Posts	
			SET Score = Score + 1
			WHERE Id = @PostId;
		END

	IF @VoteTypeId = 3 /* DownVote */
		BEGIN
		UPDATE dbo.Posts	
			SET Score = Score - 1
			WHERE Id = @PostId;
		UPDATE dbo.Users
			SET Reputation = Reputation - 1 /* Downvoting costs you a reputation point */
			WHERE Id = @UserId;
		END

	UPDATE dbo.Users
		SET LastAccessDate = GETUTCDATE()
		WHERE Id = @UserId;

	UPDATE dbo.Posts
		SET LastActivityDate = GETUTCDATE()
		WHERE Id = @PostId;

COMMIT
END
GO

CREATE OR ALTER PROC dbo.usp_ReportVotesByDate @StartDate DATETIME, @EndDate DATETIME AS
BEGIN
SELECT TOP 500 p.Title, vt.Name, COUNT(DISTINCT v.Id) AS Votes
  FROM dbo.Posts p
    INNER JOIN dbo.Votes v ON p.Id = v.PostId
	INNER JOIN dbo.VoteTypes vt ON v.VoteTypeId = vt.Id
	INNER JOIN dbo.Users u ON v.UserId = u.Id
  WHERE v.CreationDate BETWEEN @StartDate AND @EndDate
  GROUP BY p.Title, vt.Name
  ORDER BY COUNT(DISTINCT v.Id) DESC;
END
GO


CREATE OR ALTER PROC dbo.usp_IndexLab4_Setup AS
BEGIN
SELECT *
  INTO dbo.Users_New
  FROM dbo.Users;
DROP TABLE dbo.Users;
EXEC sp_rename 'dbo.Users_New', 'Users', 'OBJECT';

SET IDENTITY_INSERT dbo.Users ON;
INSERT INTO [dbo].[Users]
           ([AboutMe]
           ,[Age]
           ,[CreationDate]
           ,[DisplayName]
           ,[DownVotes]
           ,[EmailHash]
		   ,[Id]
           ,[LastAccessDate]
           ,[Location]
           ,[Reputation]
           ,[UpVotes]
           ,[Views]
           ,[WebsiteUrl]
           ,[AccountId])
SELECT [AboutMe]
           ,[Age]
           ,[CreationDate]
           ,[DisplayName]
           ,[DownVotes]
           ,[EmailHash]
		   ,[Id]
           ,[LastAccessDate]
           ,[Location]
           ,[Reputation]
           ,[UpVotes]
           ,[Views]
           ,[WebsiteUrl]
           ,[AccountId]
FROM dbo.Users
WHERE DisplayName LIKE '%duplic%';
SET IDENTITY_INSERT dbo.Users OFF;

EXEC DropIndexes @SchemaName = 'dbo', @TableName = 'Posts', @ExceptIndexNames = 'IX_OwnerUserId_Includes,IX_LastActivityDate_Includes,IX_Score,IX_ViewCount_Score_LastActivityDate';
EXEC DropIndexes @SchemaName = 'dbo', @TableName = 'Badges';

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Posts]') AND name = N'IX_OwnerUserId_Includes')
	CREATE INDEX IX_OwnerUserId_Includes ON dbo.Posts(OwnerUserId) INCLUDE (Score, ViewCount, LastActivityDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Posts]') AND name = N'IX_LastActivityDate_Includes')
	CREATE INDEX IX_LastActivityDate_Includes ON dbo.Posts(LastActivityDate) INCLUDE (Score, ViewCount);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Posts]') AND name = N'IX_Score')
	CREATE INDEX IX_Score ON dbo.Posts(Score) INCLUDE (LastActivityDate, ViewCount);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Posts]') AND name = N'IX_ViewCount_Score_LastActivityDate')
	CREATE INDEX IX_ViewCount_Score_LastActivityDate ON dbo.Posts(ViewCount, Score, LastActivityDate);
END
GO


CREATE OR ALTER PROC [dbo].[usp_IndexLab4] WITH RECOMPILE AS
BEGIN
/* Hi! You can ignore this stored procedure.
   This is used to run different random stored procs as part of your class.
   Don't change this in order to "tune" things.
*/
SET NOCOUNT ON

DECLARE @Id1 INT = CAST(RAND() * 10000000 AS INT) + 1,
		@Id2 INT = CAST(RAND() * 10000000 AS INT) + 1,
		@StartDate DATETIME = DATEADD(DAY, -1, GETUTCDATE()),
		@EndDate DATETIME = GETUTCDATE();

IF @Id1 % 13 = 11 AND @@SPID % 5 = 0
	EXEC usp_ReportVotesByDate @StartDate = @StartDate, @EndDate = @EndDate;
ELSE IF @Id1 % 13 = 10
	EXEC dbo.usp_LogPostView @PostId = 38549, @UserId = 22656
ELSE IF @Id1 % 13 = 9
	EXEC dbo.usp_LogPostView @PostId = 38549, @UserId = NULL /* Anonymous visitor */
ELSE IF @Id1 % 13 = 8
	EXEC dbo.usp_LogVote @PostId = 38549, @UserId = 22656, @VoteTypeId = 3
ELSE IF @Id1 % 13 = 7
	EXEC usp_LogUserVisit @Id = 22656;
ELSE IF @Id1 % 13 = 6
	EXEC dbo.usp_LogVote @PostId = @Id1, @UserId = @Id2, @VoteTypeId = 3
ELSE IF @Id1 % 13 = 5
	EXEC dbo.usp_LogVote @PostId = @Id1, @UserId = @Id2, @VoteTypeId = 2
ELSE IF @Id1 % 13 = 4
	EXEC dbo.usp_LogPostView @PostId = @Id1, @UserId = @Id2
ELSE IF @Id1 % 13 = 3
	EXEC dbo.usp_LogPostView @PostId = @Id1, @UserId = NULL /* Anonymous visitor */
ELSE IF @Id1 % 13 = 2
	EXEC usp_LogUserVisit @Id = @Id1;
ELSE
	EXEC dbo.usp_LogVote @PostId = 38549, @UserId = 22656, @VoteTypeId = 2

WHILE @@TRANCOUNT > 0
	BEGIN
	COMMIT
	END
END
GO

EXEC usp_IndexLab4_Setup
GO
------------------- 
------------------- Lab 4: Brent's Solution (132:28)
-------------------Artisanal, Hand-Crafted, Specialized Index Types
------------------- 
------------------- Filtered Indexes and Indexed Views (49:39)
/*
Artisanal Indexes: Filtered Indexes, Indexed Views, and Computed Columns
v1.1 - 2020-12-10

This script is from our SQL Server performance tuning classes.
To learn more: https://www.BrentOzar.com/go/tuninglabs

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO
USE StackOverflow;
GO
DropIndexes /* Source: https://www.brentozar.com/archive/2017/08/drop-indexes-fast/ */
GO
SET STATISTICS IO ON;




/* 
===============================================================================
=== PART 1: FILTERED INDEXES
===============================================================================
*/




/* 
We're going to add an IsDeleted field to the StackOverflow.dbo.Users table
that doesn't ship with the data dump, but it's the kind of thing you often see
out in real life in the field:
*/
ALTER TABLE dbo.Users
   ADD IsDeleted BIT NOT NULL DEFAULT 0,
       IsEmployee BIT NOT NULL DEFAULT 0
GO

/* Populate some of the employees: */
UPDATE dbo.Users
    SET IsEmployee = 1
    WHERE Id IN (1, 2, 3, 4, 13249, 23354, 115866, 130213, 146719);
GO
/* And update a random ~1% of the people: */
UPDATE dbo.Users
    SET IsDeleted = 1
    WHERE Id % 100 = 0;
GO


/* Now run a typical query: */
SET STATISTICS IO ON;

SELECT *
  FROM dbo.Users
  WHERE IsDeleted = 0
    AND DisplayName LIKE 'Br%'
  ORDER BY Reputation;
GO

CREATE INDEX IsDeleted_DisplayName ON dbo.Users (IsDeleted, DisplayName)
	INCLUDE (Reputation);
CREATE INDEX DisplayName_IsDeleted ON dbo.Users (DisplayName, IsDeleted)
	INCLUDE (Reputation);
GO
SELECT *
  FROM dbo.Users
  WHERE IsDeleted = 0
    AND DisplayName LIKE 'Br%'
  ORDER BY Reputation;
GO


CREATE INDEX DisplayName_Reputation_Filtered ON dbo.Users (DisplayName, Reputation)
    WHERE IsDeleted = 0;
GO
SELECT *
  FROM dbo.Users
  WHERE IsDeleted = 0
    AND DisplayName LIKE 'Br%'
  ORDER BY Reputation;
GO

sp_BlitzIndex @TableName = 'Users';
GO


SELECT *
  FROM dbo.Users
  WHERE IsEmployee = 1
  ORDER BY DisplayName;
GO

CREATE INDEX IX_IsEmployee_DisplayName ON dbo.Users(IsEmployee, DisplayName);
GO
SELECT *
  FROM dbo.Users
  WHERE IsEmployee = 1
  ORDER BY DisplayName;
GO


sp_BlitzIndex @TableName = 'Users';
GO

DropIndexes;
GO
CREATE INDEX IX_DisplayName_Filtered_Employees ON dbo.Users(DisplayName)
	INCLUDE ([Id], [AboutMe], [Age], [CreationDate], [DownVotes], 
		[EmailHash], [LastAccessDate], [Location], [Reputation], 
		[UpVotes], [Views], [WebsiteUrl], [AccountId])
  WHERE IsEmployee = 1;
GO
SELECT *
  FROM dbo.Users
  WHERE IsEmployee = 1
  ORDER BY DisplayName;
GO


sp_BlitzIndex @TableName = 'Users';
GO






/* 
===============================================================================
=== PART 2: INDEXED VIEWS
===============================================================================
*/

/* 
Say we need to quickly find which non-deleted users have the most comments: 
*/
ALTER TABLE dbo.Comments
  ADD IsDeleted BIT NOT NULL DEFAULT 0;
GO
SELECT TOP 100 u.Id, u.DisplayName, u.Location, u.AboutMe, SUM(1) AS CommentCount
  FROM dbo.Users u
  INNER JOIN dbo.Comments c ON u.Id = c.UserId
  WHERE u.IsDeleted = 0
    AND c.IsDeleted = 0
  GROUP BY u.Id, u.DisplayName, u.Location, u.AboutMe
  ORDER BY SUM(1) DESC;
GO



CREATE INDEX IX_UserId ON dbo.Comments(UserId) WHERE IsDeleted = 0;
GO
SELECT TOP 100 u.Id, u.DisplayName, u.Location, u.AboutMe, SUM(1) AS CommentCount
  FROM dbo.Users u
  INNER JOIN dbo.Comments c ON u.Id = c.UserId
  WHERE u.IsDeleted = 0
    AND c.IsDeleted = 0
  GROUP BY u.Id, u.DisplayName, u.Location, u.AboutMe
  ORDER BY SUM(1) DESC;
GO


CREATE OR ALTER VIEW dbo.vwCommentsByUser WITH SCHEMABINDING AS
    SELECT UserId, 
        SUM(1) AS CommentCount,
        COUNT_BIG(*) AS MeanOldSQLServerMakesMeDoThis
    FROM dbo.Comments
    WHERE IsDeleted = 0
    GROUP BY UserId;
GO
CREATE UNIQUE CLUSTERED INDEX CL_UserId ON dbo.vwCommentsByUser(UserId);
GO




SELECT TOP 100 u.Id, u.DisplayName, u.Location, u.AboutMe, SUM(1) AS CommentCount
  FROM dbo.Users u
  INNER JOIN dbo.Comments c ON u.Id = c.UserId
  WHERE u.IsDeleted = 0
    AND c.IsDeleted = 0
  GROUP BY u.Id, u.DisplayName, u.Location, u.AboutMe
  ORDER BY SUM(1) DESC;
GO




/*
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
------------------- 
------------------- Computed Columns and Partitioning (27:58)
/*
Artisanal Indexes: Indexed Views and Computed Columns
v1.1 - 2020-12-10

This script is from our SQL Server performance tuning classes.
To learn more: https://www.BrentOzar.com/go/tuninglabs

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO
USE StackOverflow;
GO
DropIndexes /* Source: https://www.brentozar.com/archive/2017/08/drop-indexes-fast/ */
GO
SET STATISTICS IO ON;





/* 
===============================================================================
=== PART 2: INDEXED VIEWS
===============================================================================
*/

/* 
Say we need to quickly find which non-deleted users have the most comments: 
*/
ALTER TABLE dbo.Comments
  ADD IsDeleted BIT NOT NULL DEFAULT 0;
GO
SELECT TOP 100 u.Id, u.DisplayName, u.Location, u.AboutMe, SUM(1) AS CommentCount
  FROM dbo.Users u
  INNER JOIN dbo.Comments c ON u.Id = c.UserId
  WHERE u.IsDeleted = 0
    AND c.IsDeleted = 0
  GROUP BY u.Id, u.DisplayName, u.Location, u.AboutMe
  ORDER BY SUM(1) DESC;
GO



CREATE INDEX IX_UserId ON dbo.Comments(UserId) WHERE IsDeleted = 0;
GO
SELECT TOP 100 u.Id, u.DisplayName, u.Location, u.AboutMe, SUM(1) AS CommentCount
  FROM dbo.Users u
  INNER JOIN dbo.Comments c ON u.Id = c.UserId
  WHERE u.IsDeleted = 0
    AND c.IsDeleted = 0
  GROUP BY u.Id, u.DisplayName, u.Location, u.AboutMe
  ORDER BY SUM(1) DESC;
GO


CREATE OR ALTER VIEW dbo.vwCommentsByUser WITH SCHEMABINDING AS
    SELECT UserId, 
        SUM(1) AS CommentCount,
        COUNT_BIG(*) AS MeanOldSQLServerMakesMeDoThis
    FROM dbo.Comments
    WHERE IsDeleted = 0
    GROUP BY UserId;
GO
CREATE UNIQUE CLUSTERED INDEX CL_UserId ON dbo.vwCommentsByUser(UserId);
GO




SELECT TOP 100 u.Id, u.DisplayName, u.Location, u.AboutMe, SUM(1) AS CommentCount
  FROM dbo.Users u
  INNER JOIN dbo.Comments c ON u.Id = c.UserId
  WHERE u.IsDeleted = 0
    AND c.IsDeleted = 0
  GROUP BY u.Id, u.DisplayName, u.Location, u.AboutMe
  ORDER BY SUM(1) DESC;
GO




/* 
===============================================================================
=== PART 3: COMPUTED COLUMNS
===============================================================================
*/


/* 
Before we get started, remember that index scans aren't necessarily bad. For
example, here's an index scan:
*/
SELECT TOP 10 *
  FROM dbo.Users;
GO
/* 
Its execution plan says "Clustered Index Scan," but if you look at the messages
tab and check logical reads, we only read 5 8KB pages. SQL Server didn't need
to read the whole table - it just read enough pages to deliver the results.
*/





/* 
Let's see a bad scan. Lemme tell you an imaginary story.

The dbo.Users.DisplayName field is NVARCHAR(40). Here's what typical usernames
look like:
*/
SELECT TOP 100 DisplayName
  FROM dbo.Users;
GO


 
/*
However, when a user asks for the GDPR's right to be forgotten, let's say we
immediately set their DisplayName to a GUID. Then, every minute, a query runs
and looks for those rows that need to be processed:
*/
SELECT *
  FROM dbo.Users
  WHERE LEN(DisplayName) > 30;
GO


/*
NO, THIS IS NOT HOW STACK OVERFLOW REALLY WORKS. But the data's kinda cool
because it helps to tell the story. (There's a few oddball accounts with GUID
names, especially in the newer 2017+ data dumps.)

So anyhoo, our mission is to make that query run faster with less logical
reads, but we're not allowed to change the query.

YES, I KNOW, YOU WANT TO FIND THAT DEVELOPER AND BREAK THEIR ARMS AND LEGS, but
there are penalties for that sort of thing. (Although I would just like to
point out that the penalties are lower for that than they are for violating the
GDPR to begin with.)


Back to the problem at hand:
*/
SELECT *
  FROM dbo.Users
  WHERE LEN(DisplayName) > 30;
GO

/*
Look at the actual execution plan. It's scanning the entire index, running
that LEN function on every single DisplayName, every time it runs.

How many logical reads are we doing? Check your Messages tab for the stats io
output. Then, can we reduce that number?

Add an index on that field:
*/
CREATE INDEX IX_DisplayName ON dbo.Users(DisplayName);
GO

/* Does the index get used? Do we do less logical reads? */
SELECT *
  FROM dbo.Users
  WHERE LEN(DisplayName) > 30;
GO



/* 
Huh. SQL Server refuses to use the index. 

Maybe it's because we're doing a SELECT *, and SQL Server doesn't know how
many rows will come back. Hover your mouse over the Clustered Index Scan, and
look at the estimated number of rows. Whoa, not even close!
*/



/*
We need to stop running that function every time, on every row.

We need to run it just once, and store that data.

One way we could do it is with a trigger: we could add a new column called
DisplayNameLength, and then whenever someone does an insert or update, the
trigger could keep that DisplayNameLength up to date. And that's okay - but
that's not BOSS.

Let's add a field that SQL Server will keep up to date for us:
*/

ALTER TABLE dbo.Users
ADD DisplayNameLength AS LEN(DisplayName);




/* SQL Server automatically calculates that for us. Check out the new column: */
SELECT TOP 100 * FROM dbo.Users;



/*
But...it's actually being calculated every time we run the SELECT. Look at the
actual plan and you'll see a Compute Scalar. It's like SQL Server made its own
built-in function to output that data.

Now run our query again:
*/
SELECT *
  FROM dbo.Users
  WHERE LEN(DisplayName) > 30;
GO




/*
WOOHOO! It's different. Specifically:
1 - estimated number of rows is now accurate, so
2 - we're scanning the smaller non-clustered index, which means
3 - we're doing less logical reads!

The #1 thing is that we now have statistics on that computed column. Even if we
don't persist it or index it, we suddenly have stats on it. That can be a big
benefit especially when we're doing filtering before joining multiple tables.

To see 'em:
*/
DBCC SHOW_STATISTICS('dbo.Users', '_WA_Sys_0000000F_08EA5793')
GO

/* They're not perfectly accurate because they were sampled, but: */
UPDATE STATISTICS dbo.Users WITH FULLSCAN;
GO

DBCC SHOW_STATISTICS('dbo.Users', '_WA_Sys_0000000F_08EA5793')
GO


/*
Now, we're not doing a SEEK, mind you - we're still doing a scan of the entire
nonclustered index, but it's better than before.

Let's try indexing the new field.
*/
CREATE INDEX IX_DisplayNameLength ON dbo.Users(DisplayNameLength);
GO


SELECT *
  FROM dbo.Users
  WHERE LEN(DisplayName) > 30;
GO


/* 
And look at your execution plan. Things to note:

1. We didn't change the query
2. SQL Server recognized that we already have a function on LEN(DisplayName)
3. We got an index SEEK, not an index SCAN
4. We smell better already


But the app queries need to be close to the computed column's definition.
Watch what happens if I change the query a little:
*/
SELECT *
  FROM dbo.Users
  WHERE LEN(UPPER(DisplayName)) > 30;
GO
SELECT *
  FROM dbo.Users
  WHERE LEN(COALESCE(DisplayName, '')) > 30;
GO
SELECT *
  FROM dbo.Users
  WHERE LEN(LTRIM(RTRIM(DisplayName))) > 30;
GO


/* Nope. Not gonna work. */



/*
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
------------------- 
------------------- Lab 5 Setup: Leverage Artisanal Indexes (4:26)
/*
Mastering Index Tuning - Lab 5
Last updated: 2019-02-23

This script is from our Mastering Index Tuning class.
To learn more: https://www.BrentOzar.com/go/tuninglabs

Before running this setup script, restore the Stack Overflow database.
This script takes ~5 minutes with 8 cores, 64GB RAM, and SSD storage.




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

USE StackOverflow;
GO

IF DB_NAME() <> 'StackOverflow'
  RAISERROR(N'Oops! For some reason the StackOverflow database does not exist here.', 20, 1) WITH LOG;
GO


USE [StackOverflow]
GO
DROP TABLE IF EXISTS dbo.Report_UsersByQuestions;
GO
CREATE TABLE dbo.Report_UsersByQuestions
	(UserId INT NOT NULL PRIMARY KEY CLUSTERED,
	 DisplayName VARCHAR(40),
	 CreationDate DATE,
	 LastAccessDate DATETIME2,
	 Location VARCHAR(100),
	 Questions INT,
	 Answers INT,
	 Comments INT);
INSERT INTO dbo.Report_UsersByQuestions (UserId, DisplayName, CreationDate, LastAccessDate, Location, Questions, Answers, Comments)
SELECT u.Id, u.DisplayName, u.CreationDate, u.LastAccessDate, u.Location, 0, 0, 0
FROM dbo.Users u;
GO

DROP TABLE IF EXISTS dbo.Report_BadgePopularity;
GO
CREATE TABLE dbo.Report_BadgePopularity
	(BadgeName VARCHAR(40) PRIMARY KEY CLUSTERED,
	 FirstAwarded VARCHAR(40),
	 FirstAwardedToUser VARCHAR(40),
	 TotalAwarded VARCHAR(40));
INSERT INTO dbo.Report_BadgePopularity (BadgeName, FirstAwarded, FirstAwardedToUser, TotalAwarded)
SELECT b.Name, MIN(Date), MIN(UserId), COUNT(*)
FROM dbo.Badges b
GROUP BY b.Name;
GO

CREATE OR ALTER PROC [dbo].[usp_IXReport1] @DisplayName NVARCHAR(40)
AS
BEGIN
SELECT *
  FROM dbo.Report_UsersByQuestions
  WHERE DisplayName = @DisplayName;
END;
GO

CREATE OR ALTER PROC [dbo].[usp_IXReport2] @LastActivityDate DATETIME, @Tags NVARCHAR(150) AS
BEGIN
/* Sample parameters: @LastActivityDate = '2017-07-17 23:16:39.037', @Tags = '%<indexing>%' */
SELECT TOP 100 u.DisplayName, u.Id AS UserId, u.Location, p.Id AS PostId, p.LastActivityDate, p.Body
  FROM dbo.Posts p
    INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
  WHERE p.Tags LIKE '%<sql-server>%'
    AND p.Tags LIKE @Tags
    AND p.LastActivityDate > @LastActivityDate
  ORDER BY u.DisplayName
END
GO


CREATE OR ALTER PROC [dbo].[usp_IXReport3] @SinceLastAccessDate DATETIME2 AS
BEGIN
SELECT TOP 200 r.DisplayName, r.UserId, r.CreationDate, r.LastAccessDate, u.AboutMe, r.Questions, r.Answers, r.Comments
  FROM dbo.Report_UsersByQuestions r
  INNER JOIN dbo.Users u ON r.UserId = u.Id AND r.DisplayName = u.DisplayName
  WHERE r.LastAccessDate > @SinceLastAccessDate
  ORDER BY r.LastAccessDate
END
GO
------------------- 
------------------- Lab 5: Brent's Solution (36:02)
-------------------The H Step: Heaps Usually Need Clustered Indexes
------------------- 
------------------- Heaps vs Clustered Indexes (31:37)
/*
Mastering Index Tuning - Heaps vs Clustered Indexes
Last updated: 2020-04-01

This script is from our Mastering Index Tuning class.
To learn more: https://www.BrentOzar.com/go/masterindexes
*/


USE [StackOverflow]
GO
DropIndexes;
SET STATISTICS IO ON; /* and turn on actual execution plans */
GO


/* How many reads does it take to scan the clustered index? */
SELECT COUNT(*) FROM dbo.Users WITH (INDEX = 1);
GO

CREATE INDEX IX_LastAccessDate_Id ON dbo.Users(LastAccessDate, Id);
GO
/* Here's what an index seek + key lookup looks like when we have a
   clustered index. Note the number of reads. */
SELECT *
  FROM dbo.Users
  WHERE LastAccessDate >= '2013/11/10'
    AND LastAccessDate <  '2013/11/11';
GO


/* Drop the clustered index: */
ALTER TABLE [dbo].[Users] DROP CONSTRAINT [PK_Users_Id] WITH ( ONLINE = OFF )
GO
/* But we still have the nonclustered index! */
SELECT *
  FROM dbo.Users
  WHERE LastAccessDate >= '2013/11/10'
    AND LastAccessDate <  '2013/11/11';
GO




/* How many reads does it take to scan the heap? */
SELECT COUNT(*) FROM dbo.Users WITH (INDEX = 0);
GO





/* Look at the forwarded_fetch_count column: */
SELECT * FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('dbo.Users'), 0, 0);
GO




/* See how a lot of the data is NULL?
   And take note of the number of logical reads... */
SELECT *
  FROM dbo.Users
  WHERE LastAccessDate >= '2013/11/10'
    AND LastAccessDate <  '2013/11/11';
GO


/* What if we went back and populated that? */
UPDATE dbo.Users
  SET AboutMe = 'Wow, I am really starting to like this site, so I will fill out my profile.',
      Age = 18,
	  Location = 'University of Alaska Fairbanks: University Park Building, University Avenue, Fairbanks, AK, United S',
	  WebsiteUrl = 'https://www.linkedin.com/profile/view?id=26971423&authType=NAME_SEARCH&authToken=qvpL&locale=en_US&srchid=969545191417678255996&srchindex=1&srchtotal=452&trk=vsrp_people_res_name&trkInfo=VSRPsearchId%'
  WHERE Id = 2977185;
GO

/* Now, check your logical reads: */
SELECT *
  FROM dbo.Users
  WHERE LastAccessDate >= '2013/11/10'
    AND LastAccessDate <  '2013/11/11';
GO


/* Look at the forwarded_fetch_count column: */
SELECT forwarded_fetch_count 
FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('dbo.Users'), 0, 0);
GO


/* The more users who update their data, the worse this becomes. What if everyone did? */
UPDATE dbo.Users
  SET AboutMe = 'Wow, I am really starting to like this site, so I will fill out my profile.',
      Age = 18,
	  Location = 'University of Alaska Fairbanks: University Park Building, University Avenue, Fairbanks, AK, United S',
	  WebsiteUrl = 'https://www.linkedin.com/profile/view?id=26971423&authType=NAME_SEARCH&authToken=qvpL&locale=en_US&srchid=969545191417678255996&srchindex=1&srchtotal=452&trk=vsrp_people_res_name&trkInfo=VSRPsearchId%'
  WHERE LastAccessDate >= '2013/11/10'
    AND LastAccessDate <  '2013/11/11';
GO



/* Now, check your logical reads: */
SELECT *
  FROM dbo.Users
  WHERE LastAccessDate >= '2013/11/10'
    AND LastAccessDate <  '2013/11/11';
GO



/* Look at the forwarded_fetch_count column: */
SELECT forwarded_fetch_count 
FROM sys.dm_db_index_operational_stats(DB_ID(), OBJECT_ID('dbo.Users'), 0, 0);
GO


/* To fix it, you can rebuild the table, which builds a new copy w/o forwarded pointers: */
ALTER TABLE dbo.Users REBUILD;
GO
/* But that's slow because:
  * It's logged
  * It takes the table offline on Standard Edition
  * It also has to rebuild all the nonclustered indexes because the File/Page/Slot number is changing

Or, put a clustered key on it, which fixes this problem permanently. */



/* The next problem: deletes don't actually delete.
Let's delete everyone who hasn't set their location: */
DropIndexes;
GO
DELETE dbo.Users WHERE Location IS NULL;
GO

SELECT COUNT(*) FROM dbo.Users;


/* Only one user is important anyway: */
DELETE dbo.Users WHERE Id <> 26837;
GO
SELECT COUNT(*) FROM dbo.Users;


/* Turn off actual plans: */
sp_BlitzIndex @TableName = 'Users';



/* Add the clustered primary key back in: */
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [PK_Users_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (ONLINE = OFF);
GO







/*
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
------------------- 
------------------- Foreign Keys and Check Constraints (16:56)
/*
Mastering Index Tuning - Foreign Keys and Check Constraints
Last updated: 2020-11-04

This script is from our Mastering Index Tuning class.
To learn more: https://www.BrentOzar.com/go/masterindexes

Before running this setup script, restore the Stack Overflow database.
Don't run this all at once: it's about interactively stepping through a few
statements and understanding the plans they produce.

Requirements:
* Any SQL Server version or Azure SQL DB
* Stack Overflow database of any size: https://BrentOzar.com/go/querystack
 

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO


USE StackOverflow;
GO

IF DB_NAME() <> 'StackOverflow'
  RAISERROR(N'Oops! For some reason the StackOverflow database does not exist here.', 20, 1) WITH LOG;
GO

/* Foreign key demos */
SELECT p.PostTypeId, COUNT(*) AS Posts
  FROM dbo.PostTypes pt
  INNER JOIN dbo.Posts p ON pt.Id = p.PostTypeId
  GROUP BY p.PostTypeId
  ORDER BY COUNT(*) DESC;
GO


ALTER TABLE dbo.Posts
ADD CONSTRAINT fk_Posts_PostTypeId 
	FOREIGN KEY (PostTypeId) 
REFERENCES dbo.PostTypes(Id);
GO

SELECT pt.Id, pt.Type, COUNT(*) AS Posts
  FROM dbo.PostTypes pt
  INNER JOIN dbo.Posts p ON pt.Id = p.PostTypeId
  GROUP BY pt.Id, pt.Type
  ORDER BY COUNT(*) DESC;
GO


ALTER TABLE dbo.Posts
ADD CONSTRAINT fk_Posts_OwnerUserId 
	FOREIGN KEY (OwnerUserId) 
REFERENCES dbo.Users(Id);
GO

SELECT p.*
  FROM dbo.Posts p
  LEFT OUTER JOIN dbo.Users u ON p.OwnerUserId = u.Id
  WHERE u.Id IS NULL;
GO

ALTER TABLE dbo.Posts WITH NOCHECK
ADD CONSTRAINT fk_Posts_OwnerUserId 
	FOREIGN KEY (OwnerUserId) 
REFERENCES dbo.Users(Id)
GO

EXEC sp_Blitz;

ALTER TABLE dbo.Posts
DROP CONSTRAINT fk_Posts_OwnerUserId;
GO



ALTER TABLE dbo.Posts WITH NOCHECK
ADD CONSTRAINT fk_Posts_OwnerUserId 
	FOREIGN KEY (OwnerUserId) 
REFERENCES dbo.Users(Id)
ON DELETE CASCADE;
GO


DELETE dbo.Users WHERE Id = 26837;


ALTER TABLE dbo.Posts
DROP CONSTRAINT fk_Posts_PostTypeId;
GO
ALTER TABLE dbo.Posts
DROP CONSTRAINT fk_Posts_OwnerUserId;
GO




/* Constraint demos */



/* Say we have a CompanyCode column in Users: */
EXEC sp_rename 'dbo.Users.Age', 'CompanyCode'
GO
/* And say everyone has the same CompanyCode:
 (this will take a minute) */
UPDATE dbo.Users SET CompanyCode = 100;

/* And all of our queries always ask for that CompanyCode: */
SELECT *
	FROM dbo.Users
	WHERE CompanyCode = 100
	AND DisplayName = N'Brent Ozar';

/* Then every missing index request will start with that,
even though it's basically useless: all the columns match.

Will a check constraint fix it? */
ALTER TABLE dbo.Users
	ADD CONSTRAINT CompanyCodeIsAlways100
	CHECK (CompanyCode = 100);

/* And then try your query again: */
SELECT *
	FROM dbo.Users
	WHERE CompanyCode = 100
	AND DisplayName = N'Brent Ozar';

/* Add an index just on DisplayName: */
CREATE INDEX DisplayName ON dbo.Users(DisplayName);

/* And then try your query again, and check the key lookup predicates: */
SELECT *
	FROM dbo.Users
	WHERE CompanyCode = 100
	AND DisplayName = N'Brent Ozar';

/* SQL Server will eliminate this, at least: */
SELECT * FROM dbo.Users WHERE CompanyCode <> 100;


/*
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

-------------------Recap and Final Lab
------------------- 
------------------- Tips from the Index Sommelier (17:56)
------------------- 
------------------- Lab 6 Setup and Class Recap (11:38)
/*
Mastering Index Tuning - Lab 6
Last updated: 2021-01-25

This script is from our Mastering Index Tuning class.
To learn more: https://www.BrentOzar.com/go/tuninglabs

Before running this setup script, restore the Stack Overflow database.

This script takes about 10 minutes on a machine with 4 cores, 30GB RAM, and SSD storage.



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

USE StackOverflow;
GO

IF DB_NAME() <> 'StackOverflow'
  RAISERROR(N'Oops! For some reason the StackOverflow database does not exist here.', 20, 1) WITH LOG;
GO

CREATE OR ALTER     FUNCTION [dbo].[fn_UserHasVoted] ( @UserId INT, @PostId INT )
RETURNS BIT
    WITH RETURNS NULL ON NULL INPUT
AS
    BEGIN
        DECLARE @HasVoted BIT;
		IF EXISTS (SELECT Id
					FROM dbo.Votes
					WHERE UserId = @UserId
					  AND PostId = @PostId)
			SET @HasVoted = 1
		ELSE
			SET @HasVoted = 0;
        RETURN @HasVoted;
    END;
GO

CREATE OR ALTER PROC dbo.usp_BadgeAward @Name NVARCHAR(40), @UserId INT, @Date DATETIME = NULL AS
BEGIN
SET NOCOUNT ON
IF @Date IS NULL SET @Date = GETUTCDATE();
INSERT INTO dbo.Badges(Name, UserId, Date)
VALUES(@Name, @UserId, @Date);
END
GO

CREATE OR ALTER PROC [dbo].[usp_FindInterestingPostsForUser]
	@UserId INT,
	@SinceDate DATETIME AS
BEGIN
SET NOCOUNT ON
SELECT TOP 25 p.*
FROM dbo.Posts p
WHERE PostTypeId = 1 /* Question */
  AND dbo.fn_UserHasVoted(@UserId, p.Id) = 0 /* Only want to show posts they haven't voted on yet */
  AND p.CreationDate >= @SinceDate
ORDER BY p.CreationDate DESC; /* Show the newest stuff first */
END
GO

CREATE OR ALTER   PROC [dbo].[usp_CheckForVoterFraud]
	@UserId INT AS
BEGIN
SET NOCOUNT ON

/* Who has this person voted for? */
DECLARE @Buddies TABLE (UserId INT, VotesCastForThisBuddy INT, VotesReceivedFromThisBuddy INT);
INSERT INTO @Buddies (UserId, VotesCastForThisBuddy)
  SELECT p.OwnerUserId, SUM(1) AS Votes
    FROM dbo.Votes v
	  INNER JOIN dbo.Posts p ON v.PostId = p.Id
	WHERE v.UserId = @UserId
	  AND p.OwnerUserId <> @UserId /* Specifically want other people's posts, where buddies are looking for each others' posts */
	GROUP BY p.OwnerUserId;


/* Have these people voted back in favor of @UserId? */
UPDATE @Buddies
  SET VotesReceivedFromThisBuddy = (SELECT SUM(1)
										FROM dbo.Votes v
										INNER JOIN dbo.Posts p ON v.PostId = p.Id
										WHERE v.UserId = b.UserId
										AND p.OwnerUserId <> @UserId) /* Specifically want other people's posts, where buddies are looking for each others' posts */
  FROM @Buddies b;

SELECT b.*, u.* 
  FROM @Buddies b
  INNER JOIN dbo.Users u ON b.UserId = u.Id
  ORDER BY (b.VotesCastForThisBuddy + b.VotesReceivedFromThisBuddy) DESC;
END
GO

CREATE OR ALTER PROC [dbo].[usp_SearchUsers]
	@DisplayNameLike NVARCHAR(40) = NULL,
	@LocationLike NVARCHAR(100) = NULL,
	@WebsiteUrlLike NVARCHAR(200) = NULL,
	@SortOrder NVARCHAR(20) = NULL AS
BEGIN
SET NOCOUNT ON
IF @SortOrder = 'Location'
	SELECT *
	FROM dbo.Users
	WHERE ((DisplayName LIKE (@DisplayNameLike + N'%') OR @DisplayNameLike IS NULL))
	   AND ((Location LIKE (@LocationLike + N'%') OR @LocationLike IS NULL))
	   AND ((WebsiteUrl LIKE (@WebsiteUrlLike + N'%') OR @WebsiteUrlLike IS NULL))
	   ORDER BY Location, Age;
ELSE IF @SortOrder = 'DownVotes'
	SELECT *
	FROM dbo.Users
	WHERE ((DisplayName LIKE (@DisplayNameLike + N'%') OR @DisplayNameLike IS NULL))
	   AND ((Location LIKE (@LocationLike + N'%') OR @LocationLike IS NULL))
	   AND ((WebsiteUrl LIKE (@WebsiteUrlLike + N'%') OR @WebsiteUrlLike IS NULL))
	   ORDER BY Location, DownVotes;
ELSE IF @SortOrder = 'Age'
	SELECT *
	FROM dbo.Users
	WHERE ((DisplayName LIKE (@DisplayNameLike + N'%') OR @DisplayNameLike IS NULL))
	   AND ((Location LIKE (@LocationLike + N'%') OR @LocationLike IS NULL))
	   AND ((WebsiteUrl LIKE (@WebsiteUrlLike + N'%') OR @WebsiteUrlLike IS NULL))
	   ORDER BY Age, DownVotes;
ELSE
	SELECT *
	FROM dbo.Users
	WHERE ((DisplayName LIKE (@DisplayNameLike + N'%') OR @DisplayNameLike IS NULL))
	   AND ((Location LIKE (@LocationLike + N'%') OR @LocationLike IS NULL))
	   AND ((WebsiteUrl LIKE (@WebsiteUrlLike + N'%') OR @WebsiteUrlLike IS NULL))
	   ORDER BY DownVotes;
END
GO

IF 'Question' <> (SELECT Type FROM dbo.PostTypes WHERE Id = 1)
	BEGIN
	DELETE dbo.PostTypes;
	SET IDENTITY_INSERT dbo.PostTypes ON;
	INSERT INTO dbo.PostTypes (Id, Type) VALUES
		(1, 'Question'),
		(2, 'Answer'),
		(3, 'Wiki'),
		(4, 'TagWikiExerpt'),
		(5, 'TagWiki'),
		(6, 'ModeratorNomination'),
		(7, 'WikiPlaceholder'),
		(8, 'PrivilegeWiki');
	SET IDENTITY_INSERT dbo.PostTypes OFF;
	END
GO

CREATE OR ALTER PROC [dbo].[usp_IndexLab6_Setup] AS
BEGIN

EXEC DropIndexes @TableName = 'Users', @ExceptIndexNames = 'Age,DownVotes,Index_Reputation_Views,Index_DownVotes,For_Reporting,IX_Location,IX_DV_LAD_DN,IX_Popular,IX_ReputationDisplayName';
EXEC DropIndexes @TableName = 'Badges';
EXEC DropIndexes @TableName = 'Comments';
EXEC DropIndexes @TableName = 'PostHistory';
EXEC DropIndexes @TableName = 'PostLinks';
EXEC DropIndexes @TableName = 'Posts';
EXEC DropIndexes @TableName = 'PostTypes';
EXEC DropIndexes @TableName = 'Report_BadgePopularity';
EXEC DropIndexes @TableName = 'Report_UsersByQuestions';
EXEC DropIndexes @TableName = 'Tags';
EXEC DropIndexes @TableName = 'Votes';
EXEC DropIndexes @TableName = 'VoteTypes';


IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'PK_Badges__Id')
	ALTER TABLE [dbo].[Badges] DROP CONSTRAINT [PK_Badges__Id] WITH ( ONLINE = OFF );
ALTER TABLE [dbo].[Badges] ADD  CONSTRAINT [PK_Badges__Id] PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'Age')
	CREATE INDEX Age ON dbo.Users(Age, DisplayName, LastAccessDate) INCLUDE (Location, EmailHash, AboutMe);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'DownVotes')
	CREATE INDEX DownVotes ON dbo.Users(DownVotes, DisplayName, LastAccessDate) INCLUDE (Location, EmailHash, AboutMe);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'Index_Reputation_Views')
	CREATE INDEX Index_Reputation_Views ON dbo.Users(Reputation, Views) INCLUDE (DisplayName, EmailHash, Location);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'Index_DownVotes')
	CREATE INDEX Index_DownVotes ON dbo.Users(DownVotes) INCLUDE (Location, EmailHash, AboutMe, DisplayName, LastAccessDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'For_Reporting')
	CREATE INDEX For_Reporting ON dbo.Users(Id) INCLUDE (AboutMe, DisplayName, Location);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'IX_Location')
	CREATE INDEX IX_Location ON dbo.Users(Location, DisplayName, LastAccessDate, EmailHash) INCLUDE (AboutMe);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'IX_DV_LAD_DN')
	CREATE INDEX IX_DV_LAD_DN ON dbo.Users(DownVotes, DisplayName, LastAccessDate);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'IX_Popular')
	CREATE INDEX IX_Popular ON dbo.Users(DisplayName) WHERE Reputation > 100;
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Users]') AND name = N'IX_Reputation_DisplayName')
	CREATE INDEX IX_Reputation_DisplayName ON dbo.Users(Reputation, DisplayName);
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[Badges]') AND name = N'IX_UserId')
	CREATE INDEX IX_UserId ON dbo.Badges(UserId);

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Comments' AND COLUMN_NAME = 'IsDeleted')
	ALTER TABLE dbo.Comments
		ADD IsDeleted BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Comments' AND COLUMN_NAME = 'IsPrivate')
	ALTER TABLE dbo.Comments
		ADD IsPrivate BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Posts' AND COLUMN_NAME = 'IsDeleted')
	ALTER TABLE dbo.Posts
		ADD IsDeleted BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Posts' AND COLUMN_NAME = 'IsPrivate')
	ALTER TABLE dbo.Posts
		ADD IsPrivate BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'IsDeleted')
	ALTER TABLE dbo.Users
		ADD IsDeleted BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Users' AND COLUMN_NAME = 'IsPrivate')
	ALTER TABLE dbo.Users
		ADD IsPrivate BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Votes' AND COLUMN_NAME = 'IsDeleted')
	ALTER TABLE dbo.Votes
		ADD IsDeleted BIT NOT NULL DEFAULT 0;
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Votes' AND COLUMN_NAME = 'IsPrivate')
	ALTER TABLE dbo.Votes
		ADD IsPrivate BIT NOT NULL DEFAULT 0;

EXEC('CREATE OR ALTER VIEW dbo.vwComments AS SELECT * FROM dbo.Comments WHERE IsDeleted = 0 AND IsPrivate = 0;');
EXEC('CREATE OR ALTER VIEW dbo.vwPosts AS SELECT * FROM dbo.Posts WHERE IsDeleted = 0 AND IsPrivate = 0;');
EXEC('CREATE OR ALTER VIEW dbo.vwUsers AS SELECT * FROM dbo.Users WHERE IsDeleted = 0 AND IsPrivate = 0;');
EXEC('CREATE OR ALTER VIEW dbo.vwVotes AS SELECT * FROM dbo.Votes WHERE IsDeleted = 0 AND IsPrivate = 0;');


UPDATE dbo.Badges 
  SET Name = CASE WHEN Name = 'Nice Answer' THEN 'Really, Really, Really Very Nice Answer'
				  WHEN Name = 'Popular Question' THEN 'Really, Really, Really Popular Question'
				  WHEN Name = 'Scholar' THEN 'Very, Very, Very, Very Smart Scholar'
			END
  WHERE Name IN('Nice Answer', 'Popular Question', 'Scholar')
  AND Id % 2 = 0;
EXEC('	CREATE OR ALTER TRIGGER Badges_Insert ON dbo.Badges
		AFTER INSERT  
		AS  
		BEGIN
		SET NOCOUNT ON
		BEGIN TRAN
		/* Update their bio to show that they earned the badge */
			UPDATE dbo.Users
				SET Reputation = Reputation + 10, 
					AboutMe = N''I just earned a badge! I earned: '' + COALESCE(i.Name, ''Unknown'')
							+ ''. It is an elite club - I am one of: '' + COALESCE(CAST((SELECT SUM(1) FROM dbo.Badges bOthers WHERE bOthers.Name = i.Name) AS NVARCHAR(20)), '' Unknown'')
			FROM inserted i
			  INNER JOIN dbo.Users u ON u.Id = i.UserId;

			/* Mark any of their reports as needing a refresh: */
			DELETE dbo.Report_BadgePopularity
				FROM inserted i
				INNER JOIN dbo.Report_BadgePopularity b ON i.Name = b.BadgeName
				WHERE b.TotalAwarded > 0;

			DELETE dbo.Report_UsersByQuestions
				FROM inserted i
				INNER JOIN dbo.Report_UsersByQuestions b ON i.UserId = b.UserId AND b.CreationDate > ''2017/01/01'';

		COMMIT

		END;  ');
END
GO  


EXEC usp_IndexLab6_Setup;
GO


CREATE OR ALTER PROC dbo.usp_Q1718 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/1718/up-vs-down-votes-by-day-of-week-of-question-or-answer */
SELECT
    CASE WHEN PostTypeId = 1 THEN 'Question' ELSE 'Answer' END As [Post Type],
    DATENAME(WEEKDAY, p.CreationDate) AS Day,
    Count(*) AS Amount,
    SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS UpVotes,
    SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS DownVotes,
    CASE WHEN SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) = 0 THEN NULL
     ELSE (CAST(SUM(CASE WHEN VoteTypeId = 2 THEN 1 ELSE 0 END) AS float) / CAST(SUM(CASE WHEN VoteTypeId = 3 THEN 1 ELSE 0 END) AS float))
    END AS UpVoteDownVoteRatio
FROM
    vwVotes v JOIN vwPosts p ON v.PostId=p.Id
WHERE
    PostTypeId In (1,2)
 AND
    VoteTypeId In (2,3)
  AND 
    UserId = @UserId
GROUP BY
    PostTypeId, DATEPART(WEEKDAY, p.CreationDate), DATENAME(WEEKDAY, p.CreationDate)
ORDER BY
    PostTypeId, DATEPART(WEEKDAY, p.CreationDate)
END
GO

CREATE OR ALTER PROC dbo.usp_Q2777 @NotUsed INT = NULL AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/2777/users-by-popular-question-ratio */
select top 100
  vwUsers.Id as [User Link],
  BadgeCount as [Popular Questions],
  QuestionCount as [Total Questions],
  CONVERT(float, BadgeCount)/QuestionCount as [Ratio]
from vwUsers
inner join (
  -- Popular Question badges for each user
  select
    UserId,
    count(Id) as BadgeCount
  from Badges
  where Name = 'Popular Question'
  group by UserId
) as Pop on vwUsers.Id = Pop.UserId
inner join (
  -- Questions by each user
  select
    OwnerUserId,
    count(Id) as QuestionCount
  from vwPosts
  where PostTypeId = 1
  group by OwnerUserId
) as Q on vwUsers.Id = Q.OwnerUserId
where BadgeCount >= 10
order by [Ratio] desc;
END
GO

CREATE OR ALTER PROC usp_Q181756 @Score INT = 1, @Gold INT = 50, @Silver INT = 10, @Bronze INT = 1 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/181756/question-asking-badges */
with user_questions as (
  select OwnerUserId, count(*) number_asked, avg(Score) avg_score
  from vwPosts
  where PostTypeId = 1
        and Score >= @Score
        and OwnerUserId is not null
  group by OwnerUserId
),

asking_badges as (
  select case 
           when number_asked >= @Gold
           then 1
         end gold,
         case
           when number_asked >= @Silver
           then 1
         end silver,
         case
           when number_asked >= @Bronze  then 1
         end bronze,
         case
           when number_asked is null  then 1
         end none
  from user_questions
       right join Users on OwnerUserId = Id
)

select count(*) users, 
       sum(gold) gold, 
       sum(silver) silver, 
       sum(bronze) bronze, 
       sum(none) none
from asking_badges;
END
GO

CREATE OR ALTER PROC usp_Q69607 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/69607/what-is-my-archaeologist-badge-progress */
SELECT COUNT(*) FROM vwPosts p
INNER JOIN vwPosts a on a.ParentId = p.Id
WHERE p.LastEditDate < DATEADD(month, -6, p.LastActivityDate)
AND( p.OwnerUserId = @UserId OR  a.OwnerUserId = @UserId);
END
GO



CREATE OR ALTER PROC usp_Q8553 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/8553/how-many-edits-do-i-have */
WITH qaedits AS (
  SELECT
  (
    SELECT COUNT(*) FROM vwPosts
    WHERE PostTypeId = 1
    AND LastEditorUserId = vwUsers.Id
  ) AS QuestionEdits,
  (
    SELECT COUNT(*) FROM vwPosts
    WHERE PostTypeId = 2
    AND LastEditorUserId = vwUsers.Id
  ) AS AnswerEdits
  FROM vwUsers
  WHERE Id = @UserId
),

edits AS (
  SELECT QuestionEdits, AnswerEdits, QuestionEdits + AnswerEdits AS TotalEdits
  FROM qaedits
)

SELECT QuestionEdits, AnswerEdits, TotalEdits,
  CASE WHEN TotalEdits >= 1 THEN 'Received' ELSE '0%' END AS EditorBadge,
  CASE WHEN TotalEdits >= 100
    THEN 'Received'
    ELSE Cast(TotalEdits AS varchar) + '%'
  END AS StrunkAndWhiteBadge,
  CASE WHEN TotalEdits >= 600
    THEN 'Received'
    ELSE Cast(TotalEdits / 6 AS varchar) + '%'
  END AS CopyEditorBadge
FROM edits
END
GO



CREATE OR ALTER PROC dbo.usp_Q10098 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/10098/how-long-until-i-get-the-pundit-badge */
SELECT TOP 20 
    vwPosts.Title, vwComments.Text, vwComments.Score, vwPosts.Id, vwPosts.ParentId
FROM vwComments
     INNER JOIN vwPosts ON vwComments.PostId = vwPosts.Id
WHERE 
    UserId = @UserId
ORDER BY Score DESC;
END
GO

CREATE OR ALTER   PROC [dbo].[usp_AcceptedAnswersByUser]
	@UserId INT AS
BEGIN
SET NOCOUNT ON
SELECT pQ.Title, pQ.Id, pA.Title, pA.Body, c.CreationDate, u.DisplayName, c.Text
FROM dbo.vwPosts pA
  INNER JOIN dbo.vwPosts pQ ON pA.ParentId = pQ.Id
			AND pA.Id = pQ.AcceptedAnswerId
  LEFT OUTER JOIN dbo.vwComments c ON pA.Id = c.PostId
			AND c.UserId <> @UserId
  LEFT OUTER JOIN dbo.Users u ON c.UserId = u.Id
WHERE pA.OwnerUserId = @UserId
ORDER BY pQ.CreationDate, c.CreationDate
END
GO


CREATE OR ALTER PROC dbo.usp_Q17321 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/17321/my-activity-by-utc-hour */
-- My Activity by UTC Hour
-- What time of day do I post questions and answers most?
SELECT
 datepart(hour,CreationDate) AS hour,
 count(CASE WHEN PostTypeId = 1 THEN 1 END) AS questions,
 count(CASE WHEN PostTypeId = 2 THEN 1 END) AS answers
FROM vwPosts
WHERE
  PostTypeId IN (1,2) AND
  OwnerUserId=@UserId
GROUP BY datepart(hour,CreationDate)
ORDER BY hour;
END
GO


CREATE OR ALTER PROC dbo.usp_Q25355 @MyId INT = 26837, @TheirId INT = 22656 AS
BEGIN
/* SOURCE http://data.stackexchange.com/stackoverflow/query/25355/have-we-met */
declare @LikeMyName nvarchar(40)
select @LikeMyName = '%' + DisplayName + '%' from Users where Id = @MyId

declare @TheirName nvarchar(40)
declare @LikeTheirName nvarchar(40)
select @TheirName = DisplayName from Users where Id = @TheirId
select @LikeTheirName = '%' + @TheirName + '%'

-- Question/Answer meetings
  select
   Questions.Id as [Post Link],  
    case
      when Questions.OwnerUserId = @TheirId then @TheirName + '''s question, my answer'
    else 'My question, ' + @TheirName + '''s answer'
    end as [What]
  from vwPosts as Questions
  inner join vwPosts as Answers
   on Questions.Id = Answers.ParentId
  where Answers.PostTypeId = 2 and Questions.PostTypeId = 1
   and ((Questions.OwnerUserId = @TheirId and Answers.OwnerUserId = @MyId )
     or (Questions.OwnerUserId = @MyId and Answers.OwnerUserId = @TheirId ))
union
  -- Comments on owned posts
  select p.Id as [Post Link],
    case
      when p.PostTypeId = 1 and p.OwnerUserId = @TheirId then @TheirName + '''s question, my comment'
      when p.PostTypeId = 1 and p.OwnerUserId = @MyId then 'My question, ' + @TheirName + '''s comment'
      when p.PostTypeId = 2 and p.OwnerUserId = @TheirId then @TheirName + '''s answer, my comment'
      when p.PostTypeId = 2 and p.OwnerUserId = @MyId then 'My answer, ' + @TheirName + '''s comment'
    end as [What]  
  from vwPosts p
  inner join vwComments c
    on p.Id = c.PostId
  where ((p.OwnerUserId = @TheirId and c.UserId = @MyId )
     or (p.OwnerUserId = @MyId and c.UserId = @TheirId ))

union
 -- @comments on posts
  select p.Id as [Post Link],
    case
      when UserId = @TheirId then @TheirName + '''s reply to my comment'
      when UserId = @MyId then 'My reply to ' + @TheirName + '''s comment'
    end as [What]  
  from vwComments c
    inner join vwPosts p on c.PostId = p.Id
  where ((UserId = @TheirId and Text like @LikeMyName )
     or (UserId = @MyId and Text like @LikeTheirName))

order by [Post Link];
END
GO


CREATE OR ALTER PROC dbo.usp_Q74873 @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/74873/how-much-reputation-are-you-getting-from-your-past-work */
-- How much reputation are you getting from your past work?
-- Take the "unexpected" reputation coming from your answers from last month.
-- Suppose now you constantly get those, and figure out how much rep per day
-- you are getting for your past work
SELECT @UserId AS [User Link], @UserId AS Id, Reputation, AgeInDays AS AccountAgeInDays,CAST(CAST(RepFromPast AS float)/AgeInDays AS int) AS OldReputationPerDay
  FROM 
      (
      SELECT @UserId AS Id, SUM(Reputation) AS RepFromPast 
        FROM (
            SELECT CASE WHEN VoteTypeId = 2 THEN 10 ELSE -2 END AS Reputation    
              FROM
                vwVotes v JOIN vwPosts p ON v.PostId=p.Id JOIN Posts parents ON p.ParentId=parents.Id
              WHERE p.PostTypeId = 2
                AND p.OwnerUserId = @UserId
                AND v.VoteTypeId In (2,3)
                AND datediff(day, p.CreationDate,v.CreationDate) > 30
                AND p.OwnerUserId != parents.OwnerUserId
          ) AS RepCounts
        ) As RepAndUserCount
      JOIN 
        (
        SELECT Id, Reputation, CONVERT(int, GETDATE() - CreationDate) as AgeInDays
          FROM vwUsers
          WHERE vwUsers.Id = @UserId
        ) AS AccountAge
      ON RepAndUserCount.Id=AccountAge.Id;
END
GO

CREATE OR ALTER PROC dbo.usp_Q9900 @UserId INT = 26837 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/9900/distribution-of-scores-on-my-answers */
-- Distribution of scores on my answers
-- Shows how often a user's answers get a specific score. Related to http://odata.stackexchange.com/stackoverflow/q/1930

DECLARE @totalAnswers DECIMAL;
SELECT @totalAnswers = COUNT(*) FROM Posts WHERE PostTypeId = 2 AND OwnerUserId = @UserId;

SELECT Score AS AnswerScore, Occurences,
  CASE WHEN Frequency < 1 THEN '<1%' ELSE Cast(Cast(ROUND(Frequency, 0) AS INT) AS VARCHAR) + '%' END AS Frequency
FROM (
  SELECT Score, COUNT(*) AS Occurences, (COUNT(*) / @totalAnswers) * 100 AS Frequency
  FROM vwPosts
  WHERE PostTypeId = 2                 -- answers
    AND OwnerUserId = 26837       -- by you
  GROUP BY Score
) AS answers
ORDER BY answers.Frequency DESC, Score;
END
GO

CREATE OR ALTER PROC usp_Q49864 @UserId INT = 26837 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/49864/my-comments-ordered-by-score-pundit-badge-progress  */
SELECT 
    c.Score,
    c.Id as [Comment Link],
    -- PostId as [Post Link],
    /*CASE 
    WHEN Q.Id is not NULL THEN CONCAT("<a href=\"http://stackoverflow.com/a/", Posts.Id, "\">", Q.Title, "</a>")
          ELSE CONCAT("<a href=\"http://stackoverflow.com/q/", Posts.Id, "\">", Posts.Title, "</a>") 
    END as QTitle,*/
    -- PostId,
    -- Posts.ParentId,
    c.CreationDate
FROM 
    vwComments c /*join Posts on Comments.PostId = Posts.Id
        left join Posts as Q on Posts.ParentId = Q.Id*/
WHERE 
    UserId = @UserId and c.Score > 0
ORDER BY 
    c.Score DESC;
END
GO



CREATE OR ALTER PROC dbo.usp_Q283566 @Keyword NVARCHAR(30) = '%graph%' AS
BEGIN
-- leading/trailing space helps match stackoverflow.com search behavior

-- Build the filter result set; contains key and unanswered 'skew' value
CREATE TABLE #unanswered (Id int primary key, Age int, UnansweredSkew int)
INSERT #unanswered
SELECT q.Id as Id, 
CAST((GETDATE() - q.CreationDate) AS INT) as Age,
CASE WHEN q.AcceptedAnswerId is null THEN -10 
     WHEN q.AcceptedAnswerId is not null THEN 0 END AS [Total]
FROM vwPosts q
WHERE ((q.Tags LIKE '%adal%')
    OR (q.Tags LIKE '%office365%')
    OR (q.Tags LIKE '%azure-active-directory%'))
AND ((LOWER(q.Body) LIKE @Keyword)
   OR(LOWER(q.Title) LIKE @Keyword))

    
-- Build the weighting result set, using the one above as driver
SELECT p.Id AS [Post Link], 
p.ViewCount, 
p.AnswerCount, 
CONVERT(VARCHAR(10), p.CreationDate, 1) as Created,
u.Age,
CASE WHEN p.AcceptedAnswerId is null THEN 'false' ELSE 'true' END AS Answered,
((p.ViewCount * .05) + (u.Age * .1) + p.AnswerCount + u.UnansweredSkew) AS Weight
FROM vwPosts p
JOIN #unanswered u ON u.Id = p.Id
ORDER BY Answered ASC, Weight DESC;
END
GO


CREATE OR ALTER PROC dbo.usp_Q66093 @UserId INT = 22656 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/66093/posts-by-jon-skeet-per-day-versus-total-badges-hes-earnt */

select CAST(p.CreationDate as Date) as PostDate, count(p.Id) as Posts,
(
select count(b.Id) / 100
  from Badges b
  where b.UserId = u.Id
  and b.Date <= CAST(p.CreationDate as Date)
  ) as BadgesEarned
from vwPosts p, vwUsers u
  where u.Id = @UserId
  and p.OwnerUserId = u.Id
  group by CAST(p.CreationDate as Date), u.Id
order by CAST(p.CreationDate as Date);
END
GO



CREATE OR ALTER PROC dbo.usp_Q40304 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/40304/colorado-c-people */
select *
from vwUsers
where 1=1
  --AND displayName like 'L%'
  AND UPPER(Location) LIKE 'BOULDER, CO'
  AND AboutMe LIKE '%C#%'
ORDER BY Reputation DESC;
END
GO

CREATE OR ALTER PROC dbo.usp_Q43336 AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/43336/who-brings-in-the-crowds */

-- Who Brings in the Crowds?
-- Users sorted by total number of views of their questions per day (softened by 30 days to keep new hot posts from skewing the results)

-- I tried removing the softener, but the results are really more useful with it
-- updated to use last database access (by a logged in user -- best we've got) instead of current_timestamp

SELECT TOP 50
  q.OwnerUserId as [User Link],
  count(q.Id) as Questions,
  sum(q.ViewCount/(30+datediff(day, q.CreationDate, datadumptime ))) AS [Question Views per Day]
FROM vwPosts AS q, (select max(LastAccessDate) as datadumptime from vwUsers) tmp
WHERE  
  q.CommunityOwnedDate is null AND
  q.OwnerUserId is NOT null AND
  q.PostTypeId=1
GROUP BY q.OwnerUserId
ORDER BY [Question Views per Day] DESC;
END
GO






CREATE OR ALTER PROC [dbo].[usp_IndexLab6] WITH RECOMPILE AS
BEGIN
/* Hi! You can ignore this stored procedure.
   This is used to run different random stored procs as part of your class.
   Don't change this in order to "tune" things.
*/
SET NOCOUNT ON

DECLARE @Id1 INT = CAST(RAND() * 10000000 AS INT) + 1;
DECLARE @Id2 INT = CAST(RAND() * 10000000 AS INT) + 1;
DECLARE @Id3 INT = CAST(RAND() * 10000000 AS INT) + 1;

IF @Id1 % 30 = 24
	EXEC dbo.usp_Q1718 @UserId = @Id1;
ELSE IF @Id1 % 30 = 23
	EXEC dbo.usp_Q2777;
ELSE IF @Id1 % 30 = 22
	EXEC dbo.usp_Q181756 @Score = @Id1, @Gold = @Id2, @Silver = @Id3;
ELSE IF @Id1 % 30 = 21
	EXEC dbo.usp_Q69607 @UserId = @Id1;
ELSE IF @Id1 % 30 = 20
	EXEC dbo.usp_Q8553 @UserId = @Id1;
ELSE IF @Id1 % 30 = 19
	EXEC dbo.usp_Q10098 @UserId = @Id1;
ELSE IF @Id1 % 30 = 18
	EXEC dbo.usp_Q17321 @UserId = @Id1;
ELSE IF @Id1 % 30 = 17
	EXEC dbo.usp_Q25355 @MyId = @Id1, @TheirId = @Id2;
ELSE IF @Id1 % 30 = 16
	EXEC dbo.usp_Q74873 @UserId = @Id1;
ELSE IF @Id1 % 30 = 15
	EXEC dbo.usp_Q9900 @UserId = @Id1;
ELSE IF @Id1 % 30 = 14
	EXEC dbo.usp_Q49864 @UserId = @Id1;
ELSE IF @Id1 % 30 = 13
	EXEC dbo.usp_Q283566;
ELSE IF @Id1 % 30 = 12
	EXEC dbo.usp_Q66093 @UserId = @Id1;
ELSE IF @Id1 % 30 = 10
	EXEC dbo.usp_SearchUsers @DisplayNameLike = 'Brent', @LocationLike = NULL, @WebsiteUrlLike = 'Google', @SortOrder = 'Age';
ELSE IF @Id1 % 30 = 9
	EXEC dbo.usp_SearchUsers @DisplayNameLike = NULL, @LocationLike = 'Chicago', @WebsiteUrlLike = NULL, @SortOrder = 'Location';
ELSE IF @Id1 % 30 = 8
	EXEC dbo.usp_SearchUsers @DisplayNameLike = NULL, @LocationLike = NULL, @WebsiteUrlLike = 'BrentOzar.com', @SortOrder = 'Reputation';
ELSE IF @Id1 % 30 = 7
	EXEC dbo.usp_SearchUsers @DisplayNameLike = 'Brent', @LocationLike = 'Chicago', @WebsiteUrlLike = 'BrentOzar.com', @SortOrder = 'DownVotes';
ELSE IF @Id1 % 30 = 6
	EXEC dbo.usp_FindInterestingPostsForUser @UserId = @Id1, @SinceDate = '2017/06/10';
ELSE IF @Id1 % 30 = 5
	EXEC dbo.usp_CheckForVoterFraud @UserId = @Id1;
ELSE IF @Id1 % 30 = 4
	EXEC dbo.usp_AcceptedAnswersByUser @UserId = @Id1;
ELSE IF @Id1 % 30 = 3
	EXEC dbo.usp_AcceptedAnswersByUser @UserId = @Id1;
ELSE IF @Id1 % 30 = 2
	EXEC dbo.usp_BadgeAward @Name = 'Loud Talker', @UserId = 26837;
ELSE IF @Id1 % 30 = 1
	EXEC dbo.usp_Q43336;
ELSE
	EXEC dbo.usp_Q40304;

WHILE @@TRANCOUNT > 0
	BEGIN
	COMMIT
	END
END
GO
------------------- 
------------------- Lab 6: Brent Does the D.E.A. (27:44)
sp_BlitzIndex


/* This table has a lot of dupes: 
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Users';

These have 0 reads, but do have writes on some:
*/
DROP INDEX dbo.Users.Age 
, dbo.Users.IX_Popular
, dbo.Users.Index_DownVotes
, dbo.Users.DownVotes 
, dbo.Users.IX_DV_LAD_DN
, dbo.Users.IX_Location;
GO
/* This has reads, but it's a subset of the clustered index: */
DROP INDEX dbo.Users.For_Reporting;
GO
/* Undo:
CREATE INDEX [Age] ON [dbo].[Users] ( [Age], [DisplayName], [LastAccessDate] ) INCLUDE ( [AboutMe], [EmailHash], [Location]) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [IX_Popular] ON [dbo].[Users] ( [DisplayName] ) WHERE ([Reputation]>(100)) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [Index_DownVotes] ON [dbo].[Users] ( [DownVotes] ) INCLUDE ( [AboutMe], [DisplayName], [EmailHash], [LastAccessDate], [Location]) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [DownVotes] ON [dbo].[Users] ( [DownVotes], [DisplayName], [LastAccessDate] ) INCLUDE ( [AboutMe], [EmailHash], [Location]) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [IX_DV_LAD_DN] ON [dbo].[Users] ( [DownVotes], [DisplayName], [LastAccessDate] ) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
ALTER TABLE [dbo].[Users] ADD CONSTRAINT [PK_Users_Id] PRIMARY KEY CLUSTERED ( [Id] ) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [For_Reporting] ON [dbo].[Users] ( [Id] ) INCLUDE ( [AboutMe], [DisplayName], [Location]) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [IX_Location] ON [dbo].[Users] ( [Location], [DisplayName], [LastAccessDate], [EmailHash] ) INCLUDE ( [AboutMe]) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [IX_Reputation_DisplayName] ON [dbo].[Users] ( [Reputation], [DisplayName] ) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
CREATE INDEX [Index_Reputation_Views] ON [dbo].[Users] ( [Reputation], [Views] ) INCLUDE ( [DisplayName], [EmailHash], [Location]) WITH (FILLFACTOR=100, ONLINE=?, SORT_IN_TEMPDB=?, DATA_COMPRESSION=?);
*/



/* This has missing indexes:
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Posts';

EQUALITY: [CommunityOwnedDate], [PostTypeId], [IsDeleted], [IsPrivate] INEQUALITY: [OwnerUserId] INCLUDES: [CreationDate], [ViewCount] 
EQUALITY: [LastEditorUserId], [PostTypeId], [IsDeleted], [IsPrivate] 
EQUALITY: [PostTypeId], [IsDeleted], [IsPrivate] INEQUALITY: [OwnerUserId] INCLUDES: [ParentId] 
EQUALITY: [PostTypeId], [IsDeleted], [IsPrivate] INCLUDES: [OwnerUserId] 
EQUALITY: [PostTypeId] INEQUALITY: [CreationDate] INCLUDES: [AcceptedAnswerId], [AnswerCount], [Body], [ClosedDate], [CommentCount], [CommunityOwnedDate], [FavoriteCount], [LastActivityDate], [LastEditDate], [LastEditorDisplayName], [LastEditorUserId], [OwnerUserId], [ParentId], [Score], [Tags], [Title], [ViewCount], [IsDeleted], [IsPrivate] 
EQUALITY: [PostTypeId], [IsDeleted], [IsPrivate] INEQUALITY: [CreationDate] INCLUDES: [Tags] 
EQUALITY: [PostTypeId], [IsDeleted], [IsPrivate] INEQUALITY: [OwnerUserId], [Score] 
*/

CREATE INDEX IX_PostTypeId_CreationDate_IsPrivate_IsDeleted 
  ON dbo.Posts(PostTypeId, CreationDate, IsDeleted, IsPrivate)
GO
/*
EQUALITY: [OwnerUserId], [IsDeleted], [IsPrivate] INEQUALITY: [PostTypeId] INCLUDES: [CreationDate] 
EQUALITY: [OwnerUserId], [IsDeleted], [IsPrivate] INCLUDES: [CreationDate] 
EQUALITY: [OwnerUserId], [IsDeleted], [IsPrivate] INCLUDES: [Body], [ParentId], [Title] 
EQUALITY: [OwnerUserId], [PostTypeId], [IsDeleted], [IsPrivate] 
EQUALITY: [OwnerUserId], [PostTypeId], [IsDeleted], [IsPrivate] INCLUDES: [CreationDate], [ParentId] 
EQUALITY: [OwnerUserId], [PostTypeId], [IsDeleted], [IsPrivate] INCLUDES: [Score] 
EQUALITY: [OwnerUserId], [PostTypeId] 
*/
CREATE INDEX IX_OwnerUserId_PostTypeId_IsDeleted_IsPrivate_Includes
  ON dbo.Posts(OwnerUserId, PostTypeId, IsDeleted, IsPrivate)
  INCLUDE (CreationDate);
GO
/*
EQUALITY: [ParentId], [IsDeleted], [IsPrivate] INCLUDES: [OwnerUserId] 
EQUALITY: [IsDeleted], [IsPrivate] INCLUDES: [OwnerUserId], [ParentId] 
EQUALITY: [IsDeleted], [IsPrivate] INCLUDES: [LastActivityDate], [LastEditDate], [OwnerUserId] 
EQUALITY: [IsDeleted], [IsPrivate] INCLUDES: [AcceptedAnswerId], [Body], [CreationDate], [Tags], [Title] 
EQUALITY: [IsDeleted], [IsPrivate] INCLUDES: [AcceptedAnswerId], [CreationDate], [Title] 
*/
CREATE INDEX IX_IsDeleted_IsPrivate_ParentId_Includes
  ON dbo.Posts(IsDeleted, IsPrivate, ParentId)
  INCLUDE (OwnerUserId, AcceptedAnswerId);
GO


/* This is a heap with forwarded fetches:
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Badges';

In a perfect world, I'd:
* Drop all foreign keys
* Drop the nonclustered primary key
* Add a clustered primary key
* Add the foreign keys back in

In a messy real world where I can't do that, I would:
* Create a unique clustered index on Id

*/
CREATE UNIQUE CLUSTERED INDEX CLIX_Id ON dbo.Badges(Id);
GO

/* This has missing indexes:
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Votes';

EQUALITY: [PostId], [UserId] 
WHERE PostId = 1234 AND UserId = 4321

EQUALITY: [UserId] INCLUDES: [PostId] 
WHERE UserId = 4321
*/
CREATE INDEX IX_UserId_PostId ON dbo.Votes(UserId, PostId);
GO











/* This table wants indexes too:
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Comments';

EQUALITY: [UserId], [IsDeleted], [IsPrivate] INCLUDES: [PostId], [Score], [Text] 
EQUALITY: [IsDeleted], [IsPrivate] INEQUALITY: [UserId] INCLUDES: [PostId] 
EQUALITY: [UserId], [IsDeleted], [IsPrivate] INEQUALITY: [Score] INCLUDES: [CreationDate] 
*/
CREATE INDEX IX_UserId_IsDeleted_IsPrivate_Score ON dbo.Comments(UserId, IsDeleted, IsPrivate, Score)
 INCLUDE (CreationDate)
GO
/*
EQUALITY: [PostId], [IsDeleted], [IsPrivate] INCLUDES: [CreationDate], [Text], [UserId] 
*/
CREATE INDEX IX_PostId_IsDeleted_IsPrivate ON dbo.Comments(PostId, IsDeleted, IsPrivate);
GO
------------------- 
------------------- Lab 6: Brent Does the T. (31:40)
sp_BlitzIndex

/* Missing index: 
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Votes';

EQUALITY: [PostId], [IsDeleted], [IsPrivate] INEQUALITY: [VoteTypeId] INCLUDES: [CreationDate] 
*/
CREATE INDEX IX_PostId_IsDeleted_IsPrivate_VoteTypeId_Includes
ON dbo.Votes(PostId, IsDeleted, IsPrivate, VoteTypeId) INCLUDE (CreationDate);
GO


/* Missing index: 
EXEC dbo.sp_BlitzIndex @DatabaseName='StackOverflow', @SchemaName='dbo', @TableName='Badges';

EQUALITY: [Name] 
EQUALITY: [Name] INCLUDES: [UserId] 
*/
CREATE INDEX IX_Name_UserId ON dbo.Badges(Name, UserId);
GO


/* #1 by reads: usp_Q61442
Uses vwPosts: WHERE IsDeleted = 0 AND IsPrivate = 0;


Wants this index:
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[Posts] ([PostTypeId],[IsDeleted],[IsPrivate],[CreationDate])
INCLUDE ([Tags])

In a perfect world, I'd do an indexec computed column on len(Tags) plus a formula, but for now:
*/
CREATE NONCLUSTERED INDEX IX_PostTypeId_IsDeleted_IsPrivate_CreationDate_Includes
ON [dbo].[Posts] ([PostTypeId],[IsDeleted],[IsPrivate],[CreationDate])
INCLUDE ([Tags])
GO
DROP INDEX dbo.Posts.IX_PostTypeId_CreationDate_IsPrivate_IsDeleted;
GO




/* #3 by reads: [usp_Q8553]

Clippy wants:
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[Posts] ([LastEditorUserId],[PostTypeId],[IsDeleted],[IsPrivate])
*/
CREATE NONCLUSTERED INDEX IX_LastEditorUserId_PostTypeId_IsDeleted_IsPrivate
ON [dbo].[Posts] ([LastEditorUserId],[PostTypeId],[IsDeleted],[IsPrivate]);
GO




/* #6 by reads, and I rewrote it to use a new computed column: */
ALTER TABLE dbo.Posts ADD CheckFor_usp_Q69607 AS CASE WHEN LastEditDate < DATEADD(month, -6, LastActivityDate) THEN 1 ELSE 0 END;
GO
CREATE INDEX IX_CheckFor_usp_Q69607 ON dbo.Posts(CheckFor_usp_Q69607, OwnerUserId);
GO

CREATE OR ALTER   PROC [dbo].[usp_Q69607] @UserId INT AS
BEGIN
/* Source: http://data.stackexchange.com/stackoverflow/query/69607/what-is-my-archaeologist-badge-progress */
SELECT COUNT(*) FROM vwPosts p
INNER JOIN vwPosts a on a.ParentId = p.Id
WHERE /* Replaced with below: p.LastEditDate < DATEADD(month, -6, p.LastActivityDate) */
p.CheckFor_usp_Q69607 = 1
AND( p.OwnerUserId = @UserId OR  a.OwnerUserId = @UserId);
END
GO