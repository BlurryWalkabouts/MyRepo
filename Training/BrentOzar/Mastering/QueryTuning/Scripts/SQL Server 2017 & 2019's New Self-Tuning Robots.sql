/*
Mastering Query Tuning:
The New Robots in SQL Server 2017 and 2019

This script is from our Mastering Query Tuning class.
To learn more: https://www.BrentOzar.com/go/masterqueries


This demo requires:
* SQL Server 2019 or newer
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack
  (but to get the exact metrics & plans I'm using in class, you need a big one)




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


This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO




/* Set sane general defaults for CTFP & MAXDOP: */
EXEC sys.sp_configure N'cost threshold for parallelism', N'50'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'8'
GO
RECONFIGURE WITH OVERRIDE
GO

/* Clear out our indexes, and start with just clustered indexes: */
USE StackOverflow;
GO
DBCC FREEPROCCACHE;
GO
SET STATISTICS TIME, IO ON;
GO

/* Create a few indexes to support our workloads: */
EXEC DropIndexes;
GO
CREATE INDEX IX_Reputation ON dbo.Users(Reputation);
CREATE INDEX IX_Location ON dbo.Users(Location);
CREATE INDEX IX_OwnerUserId ON dbo.Posts(OwnerUserId) INCLUDE (Score, Title);
CREATE INDEX IX_PostId ON dbo.Comments(PostId);
GO



/* First up, a single-table feature: batch mode on rowstore. 

Turn on actual plans, run this twice just to get a cached baseline, 
and note CPU time: */
SET STATISTICS IO, TIME ON;
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140;
GO
SELECT YEAR(v.CreationDate) AS CreationYear, MONTH(v.CreationDate) AS CreationMonth,
    COUNT(*) AS VotesCount,
    AVG(BountyAmount * 1.0) AS AvgBounty
  FROM dbo.Votes v
  GROUP BY YEAR(v.CreationDate), MONTH(v.CreationDate)
  ORDER BY YEAR(v.CreationDate), MONTH(v.CreationDate)
GO


/* Then try in 2019: */
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150;
GO
SELECT YEAR(v.CreationDate) AS CreationYear, MONTH(v.CreationDate) AS CreationMonth,
    COUNT(*) AS VotesCount,
    AVG(BountyAmount * 1.0) AS AvgBounty
  FROM dbo.Votes v
  GROUP BY YEAR(v.CreationDate), MONTH(v.CreationDate)
  ORDER BY YEAR(v.CreationDate), MONTH(v.CreationDate)
GO



/*
Reporting-style queries with grouping, aggregates, etc can go way faster with
batch mode execution on rowstore indexes - no columnstore required.
*/




/* TVF Interleaved Execution */
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 130; /* 2016 at first */
GO
CREATE OR ALTER FUNCTION dbo.getUsersByLocation ( @Location NVARCHAR(100) )
RETURNS @Out TABLE ( UserId INT )
    WITH SCHEMABINDING
AS
    BEGIN
        INSERT  INTO @Out(UserId)
        SELECT  Id
        FROM    dbo.Users
        WHERE   Location = @Location;
		RETURN;
    END;
GO


/* List the posts for the users in a specific location: */
SELECT p.*
  FROM dbo.Posts p
  WHERE p.OwnerUserId IN (SELECT UserId FROM dbo.GetUsersByLocation('London, United Kingdom'))
  ORDER BY p.Score DESC;
GO


ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140; /* Now try 2017 */
GO
SELECT p.*
  FROM dbo.Posts p
  WHERE p.OwnerUserId IN (SELECT UserId FROM dbo.GetUsersByLocation('London, United Kingdom'))
  ORDER BY p.Score DESC;
GO




/* Adaptive memory grants for rowstore tables */
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140; /* 2017 */
GO
CREATE OR ALTER PROC dbo.usp_UsersByReputation @Reputation INT AS
    SELECT TOP 100000 u.*
        FROM dbo.Users u
        WHERE u.Reputation = @Reputation
        ORDER BY u.DisplayName;
GO

/* Free the plan cache and run it for tiny data */
DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 2; /* Warns about granting too much RAM */
GO
EXEC usp_UsersByReputation @Reputation = 1; /* Spills to disk */
GO
/* Now do it in the opposite order: */
DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 1; /* Grants a ton of memory */
GO
EXEC usp_UsersByReputation @Reputation = 2; /* Leaves a ton of unused memory on the floor */
GO


ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150; /* 2019 */
GO
DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 2;
GO
EXEC usp_UsersByReputation @Reputation = 1;
GO
EXEC usp_UsersByReputation @Reputation = 1; 
/* Adaptive just kicked in, yo */
GO
EXEC usp_UsersByReputation @Reputation = 2; 
GO
EXEC usp_UsersByReputation @Reputation = 1; 
GO

/* Now do it in the opposite order: */
DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 1; /* Grants a ton of memory */
GO
EXEC usp_UsersByReputation @Reputation = 2; /* Leaves a ton of unused memory on the floor */
GO







/* Adaptive joins on rowstore tables */
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150; /* SQL Server 2019 */
GO
CREATE OR ALTER PROC dbo.usp_UsersByReputation @Reputation INT AS
    SELECT TOP 100000 u.Id, p.Title, p.Score
        FROM dbo.Users u
        JOIN dbo.Posts p ON p.OwnerUserId = u.Id
        WHERE u.Reputation = @Reputation
        ORDER BY p.Score DESC;
GO

/* And run it: */
DBCC FREEPROCCACHE;

EXEC usp_UsersByReputation @Reputation = 1;
GO



/* Check out that adaptive join:
* Adaptive threshold in tooltip
* Over threshold: do an index scan
* Under: do a seek



Try another reputation, and it chooses the seek: */
EXEC usp_UsersByReputation @Reputation = 2;
GO

/* Try the big one: */
EXEC usp_UsersByReputation @Reputation = 1;
GO


/* Moral of the story: parameter sniffing just got a LOT harder. 

Plus, check this out:
*/
DBCC FREEPROCCACHE;
GO
EXEC usp_UsersByReputation @Reputation = 1 WITH RECOMPILE; /* Gets an adaptive join */
EXEC usp_UsersByReputation @Reputation = 2 WITH RECOMPILE; 
/* Index seek on Users, no adaptive join, single threaded */
EXEC usp_UsersByReputation @Reputation = 4 WITH RECOMPILE; 
/* Index seek on Users, no adaptive join, parallel */



/*
The good news: SQL Server 2019 has more execution plan options.

The bad news: parameter sniffing just got harder to troubleshoot and fix, not easier.
*/
















ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140; /* 2017 at first */
GO




ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140; /* 2017 */
GO
DECLARE @CoolCars TABLE (Make VARCHAR(30), Model VARCHAR(30));

INSERT INTO @CoolCars (Make, Model)
  VALUES ('Porsche', '911');

SELECT * FROM @CoolCars;
GO




DECLARE @CoolCars TABLE (Make VARCHAR(30), Model VARCHAR(30));

INSERT INTO @CoolCars (Make, Model)
  VALUES ('Porsche', '911'),
         ('Audi', 'RS5'),
		 ('Dodge', 'Hellcat'),
		 ('Chevrolet', 'Corvette'),
		 ('BMW', 'M5');

SELECT * FROM @CoolCars;
GO


/* Possible solutions in the past: change the code to add recompile hint, temp tables 





Or...just switch to 2019 compatibility level:
*/
ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150; /* 2019 */
GO
DECLARE @CoolCars TABLE (Make VARCHAR(30), Model VARCHAR(30));

INSERT INTO @CoolCars (Make, Model)
  VALUES ('Porsche', '911'),
         ('Audi', 'RS5'),
		 ('Dodge', 'Hellcat'),
		 ('Chevrolet', 'Corvette'),
		 ('BMW', 'M5');

SELECT * FROM @CoolCars;
GO









/* You probably still find stored procedures with table variables: */
CREATE OR ALTER PROC dbo.usp_PostsByUserLocation @Location NVARCHAR(40) AS
BEGIN
	DECLARE @UserList TABLE (Id INT);
	INSERT INTO @UserList (Id)
	  SELECT Id FROM dbo.Users WHERE Location LIKE @Location

    SELECT TOP 1000 p.Score, p.Id, p.Title, p.Body, p.Tags, uC.DisplayName, c.Text
        FROM @UserList u
        JOIN dbo.Posts p ON p.OwnerUserId = u.Id AND p.PostTypeId = 1
		LEFT OUTER JOIN dbo.Comments c ON p.Id = c.PostId
		LEFT OUTER JOIN dbo.Users uC ON c.UserId = uC.Id
        ORDER BY p.Score DESC, c.CreationDate;
END
GO



ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 140; /* 2017 */
GO
EXEC usp_PostsByUserLocation @Location = 'United States%';
GO
/* 
SQL Server 2017:
* Underestimates rows in the table variable, 
* Which leads to single-threaded processing and a low memory grant
* Which leads to tempdb spills 
*/

ALTER DATABASE CURRENT SET COMPATIBILITY_LEVEL = 150; /* 2019 */
GO
EXEC usp_PostsByUserLocation @Location = 'United States';
GO

/* 
SQL Server 2019 is quite a bit faster because:

* It accurately estimates rows for the table variable
* Memory grant is more accurate
* No tempdb spills


Before we go on, note:
* The memory grant: 
* The number of users: 
* The number of questions: 

Then try another location: 
*/
EXEC usp_PostsByUserLocation @Location = 'Boston, MA, USA';
GO


/* 
The good news: table variables get stats.

The bad news: now they're vulnerable to parameter sniffing.
*/