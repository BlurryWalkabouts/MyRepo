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