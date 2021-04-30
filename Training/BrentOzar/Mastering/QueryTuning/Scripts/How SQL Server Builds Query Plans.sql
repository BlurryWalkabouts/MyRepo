/*
Mastering Query Tuning - How SQL Server Builds Query Plans

This script is from our Mastering Query Tuning class.
To learn more: https://www.BrentOzar.com/go/masterqueries


This demo requires:
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack




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




/* Start with SQL Server's out-of-the-box defaults: */
EXEC sys.sp_configure N'cost threshold for parallelism', N'5'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO

/* Clear out our indexes, and start with just clustered indexes: */
USE StackOverflow;
GO
EXEC DropIndexes;
GO
DBCC FREEPROCCACHE;
GO
SET STATISTICS TIME, IO ON;
GO

/* Get the estimated plan for this: */

SELECT TOP 50 *
  FROM dbo.Users
  WHERE Reputation = 2;
GO



/* More trivial plans: */
SELECT *
  FROM dbo.Users
  WHERE 1 = 0;

SELECT *
  FROM dbo.Users
  WHERE Id IS NULL;

SELECT *
  FROM dbo.Users
  WHERE Reputation IS NULL;
GO




/* Full optimization: */

SELECT TOP 50 *
  FROM dbo.Users
  WHERE Reputation = 2
    AND Location = 'San Diego';
GO




/* Compare the cost of these two: */
SELECT TOP 50 *
  FROM dbo.Users
  WHERE Reputation = 2;
GO

SELECT TOP 50 *
  FROM dbo.Users
  WHERE Reputation = 2
    AND Location = 'San Diego';
GO



/* This column doesn't contain nulls: */
SELECT COUNT(*)
  FROM dbo.Users
  WHERE AccountId IS NULL;
GO


/* But the architect doesn't know it's not nullable, so we get a table scan: */
SELECT *
  FROM dbo.Users
  WHERE AccountId IS NULL;
GO



/* Full optimization with a join. How many rows come back? */
SELECT u1.* 
  FROM dbo.Users u1
  INNER JOIN dbo.Users u2 ON u2.Id = u1.Id
  WHERE u1.Reputation = -1;
GO


/* Add a few more joins and check the optimization level: */
SELECT u1.*
FROM dbo.Users u1
INNER JOIN dbo.Users u2 ON u2.Id = u1.Id 
INNER JOIN dbo.Users u3 ON u3.Id = u2.Id 
INNER JOIN dbo.Users u4 ON u4.Id = u3.Id 
INNER JOIN dbo.Users u5 ON u5.Id = u4.Id 
INNER JOIN dbo.Users u6 ON u6.Id = u5.Id 
INNER JOIN dbo.Users u7 ON u7.Id = u6.Id 
INNER JOIN dbo.Users u8 ON u8.Id = u7.Id 
INNER JOIN dbo.Users u9 ON u9.Id = u8.Id 
INNER JOIN dbo.Users u10 ON u10.Id = u9.Id 
INNER JOIN dbo.Users u11 ON u11.Id = u10.Id 
INNER JOIN dbo.Users u12 ON u12.Id = u11.Id 
INNER JOIN dbo.Users u13 ON u13.Id = u12.Id 
INNER JOIN dbo.Users u14 ON u14.Id = u13.Id 
INNER JOIN dbo.Users u15 ON u15.Id = u14.Id 
INNER JOIN dbo.Users u16 ON u16.Id = u15.Id 
INNER JOIN dbo.Users u17 ON u17.Id = u16.Id 
INNER JOIN dbo.Users u18 ON u18.Id = u17.Id 
INNER JOIN dbo.Users u19 ON u19.Id = u18.Id 
INNER JOIN dbo.Users u20 ON u20.Id = u19.Id 
INNER JOIN dbo.Users u21 ON u21.Id = u20.Id 
INNER JOIN dbo.Users u22 ON u22.Id = u21.Id 
INNER JOIN dbo.Users u23 ON u23.Id = u22.Id 
INNER JOIN dbo.Users u24 ON u24.Id = u23.Id 
INNER JOIN dbo.Users u25 ON u25.Id = u24.Id 
INNER JOIN dbo.Users u26 ON u26.Id = u25.Id 
INNER JOIN dbo.Users u27 ON u27.Id = u26.Id 
INNER JOIN dbo.Users u28 ON u28.Id = u27.Id 
INNER JOIN dbo.Users u29 ON u29.Id = u28.Id 
INNER JOIN dbo.Users u30 ON u30.Id = u29.Id 
INNER JOIN dbo.Users u31 ON u31.Id = u30.Id 
INNER JOIN dbo.Users u32 ON u32.Id = u31.Id 
INNER JOIN dbo.Users u33 ON u33.Id = u32.Id 
INNER JOIN dbo.Users u34 ON u34.Id = u33.Id 
INNER JOIN dbo.Users u35 ON u35.Id = u34.Id 
INNER JOIN dbo.Users u36 ON u36.Id = u35.Id 
INNER JOIN dbo.Users u37 ON u37.Id = u36.Id 
INNER JOIN dbo.Users u38 ON u38.Id = u37.Id 
INNER JOIN dbo.Users u39 ON u39.Id = u38.Id 
INNER JOIN dbo.Users u40 ON u40.Id = u39.Id 
INNER JOIN dbo.Users u41 ON u41.Id = u40.Id 
INNER JOIN dbo.Users u42 ON u42.Id = u41.Id 
INNER JOIN dbo.Users u43 ON u43.Id = u42.Id 
INNER JOIN dbo.Users u44 ON u44.Id = u43.Id 
INNER JOIN dbo.Users u45 ON u45.Id = u44.Id 
INNER JOIN dbo.Users u46 ON u46.Id = u45.Id 
INNER JOIN dbo.Users u47 ON u47.Id = u46.Id 
INNER JOIN dbo.Users u48 ON u48.Id = u47.Id 
INNER JOIN dbo.Users u49 ON u49.Id = u48.Id 
INNER JOIN dbo.Users u50 ON u50.Id = u49.Id 
INNER JOIN dbo.Users u51 ON u51.Id = u50.Id 
INNER JOIN dbo.Users u52 ON u52.Id = u51.Id 
INNER JOIN dbo.Users u53 ON u53.Id = u52.Id 
INNER JOIN dbo.Users u54 ON u54.Id = u53.Id 
INNER JOIN dbo.Users u55 ON u55.Id = u54.Id 
INNER JOIN dbo.Users u56 ON u56.Id = u55.Id 
INNER JOIN dbo.Users u57 ON u57.Id = u56.Id 
INNER JOIN dbo.Users u58 ON u58.Id = u57.Id 
INNER JOIN dbo.Users u59 ON u59.Id = u58.Id 
INNER JOIN dbo.Users u60 ON u60.Id = u59.Id 
INNER JOIN dbo.Users u61 ON u61.Id = u60.Id 
INNER JOIN dbo.Users u62 ON u62.Id = u61.Id 
INNER JOIN dbo.Users u63 ON u63.Id = u62.Id 
INNER JOIN dbo.Users u64 ON u64.Id = u63.Id 
INNER JOIN dbo.Users u65 ON u65.Id = u64.Id 
INNER JOIN dbo.Users u66 ON u66.Id = u65.Id 
INNER JOIN dbo.Users u67 ON u67.Id = u66.Id 
INNER JOIN dbo.Users u68 ON u68.Id = u67.Id 
INNER JOIN dbo.Users u69 ON u69.Id = u68.Id 
INNER JOIN dbo.Users u70 ON u70.Id = u69.Id 
INNER JOIN dbo.Users u71 ON u71.Id = u70.Id 
INNER JOIN dbo.Users u72 ON u72.Id = u71.Id 
INNER JOIN dbo.Users u73 ON u73.Id = u72.Id 
INNER JOIN dbo.Users u74 ON u74.Id = u73.Id 
INNER JOIN dbo.Users u75 ON u75.Id = u74.Id 
INNER JOIN dbo.Users u76 ON u76.Id = u75.Id 
INNER JOIN dbo.Users u77 ON u77.Id = u76.Id 
INNER JOIN dbo.Users u78 ON u78.Id = u77.Id 
INNER JOIN dbo.Users u79 ON u79.Id = u78.Id 
INNER JOIN dbo.Users u80 ON u80.Id = u79.Id 
INNER JOIN dbo.Users u81 ON u81.Id = u80.Id 
INNER JOIN dbo.Users u82 ON u82.Id = u81.Id 
INNER JOIN dbo.Users u83 ON u83.Id = u82.Id 
INNER JOIN dbo.Users u84 ON u84.Id = u83.Id 
INNER JOIN dbo.Users u85 ON u85.Id = u84.Id 
INNER JOIN dbo.Users u86 ON u86.Id = u85.Id 
INNER JOIN dbo.Users u87 ON u87.Id = u86.Id 
INNER JOIN dbo.Users u88 ON u88.Id = u87.Id 
INNER JOIN dbo.Users u89 ON u89.Id = u88.Id 
INNER JOIN dbo.Users u90 ON u90.Id = u89.Id 
INNER JOIN dbo.Users u91 ON u91.Id = u90.Id 
INNER JOIN dbo.Users u92 ON u92.Id = u91.Id 
INNER JOIN dbo.Users u93 ON u93.Id = u92.Id 
INNER JOIN dbo.Users u94 ON u94.Id = u93.Id 
INNER JOIN dbo.Users u95 ON u95.Id = u94.Id 
INNER JOIN dbo.Users u96 ON u96.Id = u95.Id 
INNER JOIN dbo.Users u97 ON u97.Id = u96.Id 
INNER JOIN dbo.Users u98 ON u98.Id = u97.Id 
INNER JOIN dbo.Users u99 ON u99.Id = u98.Id 
INNER JOIN dbo.Users u100 ON u100.Id = u99.Id 
WHERE u1.Reputation = -1
GO