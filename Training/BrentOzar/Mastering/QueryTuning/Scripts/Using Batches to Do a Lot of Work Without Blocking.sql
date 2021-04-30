/*
Mastering Query Tuning - Using Batches to Avoid Lock Escalation

This script is from our Mastering Query Tuning class.
To learn more: https://www.BrentOzar.com/go/masterqueries


This demo requires:
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO



USE [StackOverflow]
GO

/* Make sure we have indexes: */
CREATE INDEX Location ON dbo.Users(Location);
GO
CREATE INDEX UserId ON dbo.Badges(UserId);
GO
CREATE INDEX UserId ON dbo.Comments(UserId);
GO
CREATE INDEX OwnerUserId ON dbo.Posts(OwnerUserId);
GO
CREATE INDEX UserId ON dbo.Votes(UserId);
GO

SET STATISTICS IO, TIME ON;
GO

/* Say we need to delete:
* All the users who live in London
* All of their rows in our related tables

v1: One way to do it would be a giant transaction: */
BEGIN TRAN;
DELETE d
	FROM dbo.Badges d
	INNER JOIN dbo.Users u ON d.UserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

DELETE d
	FROM dbo.Comments d
	INNER JOIN dbo.Users u ON d.UserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

DELETE d
	FROM dbo.Posts d
	INNER JOIN dbo.Users u ON d.OwnerUserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

DELETE d
	FROM dbo.Votes d
	INNER JOIN dbo.Users u ON d.UserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

/* No need for error checking here since it's in one tran: */
DELETE
	FROM dbo.Users
	WHERE Location = 'London, United Kingdom';

/* Commenting this out only so we can see the effects: */
--COMMIT;
--ROLLBACK;
GO
/* But while this runs, we're holding exclusive locks across all these tables.

In another window, check the locks: */
sp_WhoIsActive @get_locks = 1;
GO





/* V2: Key-Aware, But Not Batching 

Part 1: gathering the keys. No exclusive locks for this. */
DROP TABLE IF EXISTS dbo.UsersToDelete;
DROP TABLE IF EXISTS dbo.BadgesToDelete;
DROP TABLE IF EXISTS dbo.CommentsToDelete;
DROP TABLE IF EXISTS dbo.PostsToDelete;
DROP TABLE IF EXISTS dbo.VotesToDelete;

CREATE TABLE dbo.UsersToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.UsersToDelete (Id)
	SELECT Id
	FROM dbo.Users
	WHERE Location = 'London, United Kingdom';
GO

CREATE TABLE dbo.BadgesToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.BadgesToDelete (Id)
	SELECT d.Id
	FROM dbo.Badges d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.UserId;

CREATE TABLE dbo.CommentsToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.CommentsToDelete (Id)
	SELECT d.Id
	FROM dbo.Comments d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.UserId;

CREATE TABLE dbo.PostsToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.PostsToDelete (Id)
	SELECT d.Id
	FROM dbo.Posts d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.OwnerUserId;

CREATE TABLE dbo.VotesToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.VotesToDelete (Id)
	SELECT d.Id
	FROM dbo.Votes d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.UserId;

/* Everything up til now has been nearly lock-free.*

But now, the locking/outage starts: */
BEGIN TRAN;
DELETE d
	FROM dbo.Badges d
	INNER JOIN dbo.BadgesToDelete td ON d.Id = td.Id;

DELETE d
	FROM dbo.Comments d
	INNER JOIN dbo.CommentsToDelete td ON d.Id = td.Id;

DELETE d
	FROM dbo.Posts d
	INNER JOIN dbo.PostsToDelete td ON d.Id = td.Id;

DELETE d
	FROM dbo.Votes d
	INNER JOIN dbo.VotesToDelete td ON d.Id = td.Id;

DELETE d
	FROM dbo.Users d
	INNER JOIN dbo.UsersToDelete td ON d.Id = td.Id;

/* Commenting this out only so we can see the effects: */
--COMMIT;
--ROLLBACK;
GO
/* That doesn't work well either. */





/* V4: Batching Through the Lists of IDs

You don't have to do Part 1 again if you already have these tables:

Part 1: gathering the keys. No exclusive locks for this. */
DROP TABLE IF EXISTS dbo.UsersToDelete;
DROP TABLE IF EXISTS dbo.BadgesToDelete;
DROP TABLE IF EXISTS dbo.CommentsToDelete;
DROP TABLE IF EXISTS dbo.PostsToDelete;
DROP TABLE IF EXISTS dbo.VotesToDelete;

CREATE TABLE dbo.UsersToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.UsersToDelete (Id)
	SELECT Id
	FROM dbo.Users
	WHERE Location = 'London, United Kingdom';
GO

CREATE TABLE dbo.BadgesToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.BadgesToDelete (Id)
	SELECT d.Id
	FROM dbo.Badges d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.UserId;

CREATE TABLE dbo.CommentsToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.CommentsToDelete (Id)
	SELECT d.Id
	FROM dbo.Comments d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.UserId;

CREATE TABLE dbo.PostsToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.PostsToDelete (Id)
	SELECT d.Id
	FROM dbo.Posts d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.OwnerUserId;

CREATE TABLE dbo.VotesToDelete (Id INT PRIMARY KEY CLUSTERED);
INSERT INTO dbo.VotesToDelete (Id)
	SELECT d.Id
	FROM dbo.Votes d
	INNER JOIN dbo.UsersToDelete u
		ON u.Id = d.UserId;

/* Everything up til now has been nearly lock-free.*

But now, the locking/outage starts - or does it?: */
DECLARE @FirstId BIGINT = -9223372036854775807;

WHILE EXISTS (
	SELECT del.Id 
	FROM dbo.BadgesToDelete td
	INNER JOIN dbo.Badges del ON td.Id = del.Id)
BEGIN
	WITH ToBeDeleted AS (
		SELECT TOP 1000 td.Id 
		FROM dbo.BadgesToDelete td
		WHERE td.Id >= @FirstId
		ORDER BY td.Id
	)
	DELETE d
		FROM ToBeDeleted tbd 
		INNER JOIN dbo.Badges d ON tbd.Id = d.Id;

	/* If our FirstId filtered out all rows, reset it, something went wrong: */
	IF @@ROWCOUNT = 0 SET @FirstId = -9223372036854775807;

	/* Reset our low key for the next pass: */
	SELECT TOP 1 @FirstId = td.Id
		FROM dbo.BadgesToDelete td
		INNER JOIN dbo.Badges del ON td.Id = del.Id
		WHERE td.Id >= @FirstId
		ORDER BY td.Id;

END;
GO





DECLARE @FirstId BIGINT = -9223372036854775807;

WHILE EXISTS (
	SELECT del.Id 
	FROM dbo.CommentsToDelete td
	INNER JOIN dbo.Comments del ON td.Id = del.Id)
BEGIN
	WITH ToBeDeleted AS (
		SELECT TOP 1000 td.Id 
		FROM dbo.CommentsToDelete td
		WHERE td.Id >= @FirstId
		ORDER BY td.Id
	)
	DELETE d
		FROM ToBeDeleted tbd 
		INNER JOIN dbo.Comments d ON tbd.Id = d.Id;

	/* If our FirstId filtered out all rows, reset it, something went wrong: */
	IF @@ROWCOUNT = 0 SET @FirstId = -9223372036854775807;

	/* Reset our low key for the next pass: */
	SELECT TOP 1 @FirstId = td.Id
		FROM dbo.CommentsToDelete td
		INNER JOIN dbo.Comments del ON td.Id = del.Id
		WHERE td.Id >= @FirstId
		ORDER BY td.Id;

END;
GO



DECLARE @FirstId BIGINT = -9223372036854775807;

WHILE EXISTS (
	SELECT del.Id 
	FROM dbo.PostsToDelete td
	INNER JOIN dbo.Posts del ON td.Id = del.Id)
BEGIN
	WITH ToBeDeleted AS (
		SELECT TOP 1000 td.Id 
		FROM dbo.PostsToDelete td
		WHERE td.Id >= @FirstId
		ORDER BY td.Id
	)
	DELETE d
		FROM ToBeDeleted tbd 
		INNER JOIN dbo.Posts d ON tbd.Id = d.Id;

	/* If our FirstId filtered out all rows, reset it, something went wrong: */
	IF @@ROWCOUNT = 0 SET @FirstId = -9223372036854775807;

	/* Reset our low key for the next pass: */
	SELECT TOP 1 @FirstId = td.Id
		FROM dbo.PostsToDelete td
		INNER JOIN dbo.Posts del ON td.Id = del.Id
		WHERE td.Id >= @FirstId
		ORDER BY td.Id;

END;
GO



DECLARE @FirstId BIGINT = -9223372036854775807;

WHILE EXISTS (
	SELECT del.Id 
	FROM dbo.VotesToDelete td
	INNER JOIN dbo.Votes del ON td.Id = del.Id)
BEGIN
	WITH ToBeDeleted AS (
		SELECT TOP 1000 td.Id 
		FROM dbo.VotesToDelete td
		WHERE td.Id >= @FirstId
		ORDER BY td.Id
	)
	DELETE d
		FROM ToBeDeleted tbd 
		INNER JOIN dbo.Votes d ON tbd.Id = d.Id;

	/* If our FirstId filtered out all rows, reset it, something went wrong: */
	IF @@ROWCOUNT = 0 SET @FirstId = -9223372036854775807;

	/* Reset our low key for the next pass: */
	SELECT TOP 1 @FirstId = td.Id
		FROM dbo.VotesToDelete td
		INNER JOIN dbo.Votes del ON td.Id = del.Id
		WHERE td.Id >= @FirstId
		ORDER BY td.Id;

END;
GO


/* Do a lightweight check to make sure no rows were missed by accident: */
SELECT COUNT(*)
	FROM dbo.Badges d
	INNER JOIN dbo.Users u ON d.UserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

SELECT COUNT(*)
	FROM dbo.Comments d
	INNER JOIN dbo.Users u ON d.UserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

SELECT COUNT(*)
	FROM dbo.Posts d
	INNER JOIN dbo.Users u ON d.OwnerUserId = u.Id
	WHERE u.Location = 'London, United Kingdom';

SELECT COUNT(*)
	FROM dbo.Votes d
	INNER JOIN dbo.Users u ON d.UserId = u.Id
	WHERE u.Location = 'London, United Kingdom';







/* And if there are no orphans, do the parent table: */
DECLARE @FirstId BIGINT = -9223372036854775807;

WHILE EXISTS (
	SELECT del.Id 
	FROM dbo.UsersToDelete td
	INNER JOIN dbo.Users del ON td.Id = del.Id)
BEGIN
	WITH ToBeDeleted AS (
		SELECT TOP 1000 td.Id 
		FROM dbo.UsersToDelete td
		WHERE td.Id >= @FirstId
		ORDER BY td.Id
	)
	DELETE d
		FROM ToBeDeleted tbd 
		INNER JOIN dbo.Users d ON tbd.Id = d.Id;

	/* If our FirstId filtered out all rows, reset it, something went wrong: */
	IF @@ROWCOUNT = 0 SET @FirstId = -9223372036854775807;

	/* Reset our low key for the next pass: */
	SELECT TOP 1 @FirstId = td.Id
		FROM dbo.UsersToDelete td
		INNER JOIN dbo.Users del ON td.Id = del.Id
		WHERE td.Id >= @FirstId
		ORDER BY td.Id;

END;
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