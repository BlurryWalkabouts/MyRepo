/*
Mastering Query Tuning - Cardinality Estimation

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



CREATE INDEX IX_Location ON dbo.Users(Location);
GO


CREATE OR ALTER PROC dbo.usp_UsersInTopLocation AS
BEGIN
DECLARE @TopLocation NVARCHAR(100);

SELECT TOP 1 @TopLocation = Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC;

SELECT *
  FROM dbo.Users
  WHERE Location = @TopLocation
  ORDER BY DisplayName;
END
GO

EXEC usp_UsersInTopLocation
GO

CREATE OR ALTER PROC dbo.usp_UsersInTopLocation_CTE AS
BEGIN
WITH TopLocation AS (SELECT TOP 1 Location
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

EXEC usp_UsersInTopLocation_CTE
GO




CREATE OR ALTER PROC dbo.usp_UsersInTopLocation_Subquery AS
BEGIN
SELECT *
  FROM dbo.Users u
  WHERE Location = (SELECT TOP 1 Location
					  FROM dbo.Users
					  WHERE Location <> ''
					  GROUP BY Location
					  ORDER BY COUNT(*) DESC)
  ORDER BY DisplayName;
END
GO

EXEC usp_UsersInTopLocation_Subquery
GO


/* Recompile at the statement level */
CREATE OR ALTER PROC dbo.usp_UsersInTopLocation AS
BEGIN
DECLARE @TopLocation NVARCHAR(100);

SELECT TOP 1 @TopLocation = Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC;

SELECT *
  FROM dbo.Users
  WHERE Location = @TopLocation
  ORDER BY DisplayName
  OPTION (RECOMPILE);
END
GO

EXEC usp_UsersInTopLocation
GO


/* Recompile at the proc level */
CREATE OR ALTER PROC dbo.usp_UsersInTopLocation WITH RECOMPILE AS
BEGIN
DECLARE @TopLocation NVARCHAR(100);

SELECT TOP 1 @TopLocation = Location
  FROM dbo.Users
  WHERE Location <> ''
  GROUP BY Location
  ORDER BY COUNT(*) DESC;

SELECT *
  FROM dbo.Users
  WHERE Location = @TopLocation
  ORDER BY DisplayName;
END
GO

EXEC usp_UsersInTopLocation
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