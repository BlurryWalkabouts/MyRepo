
Mastering Query Tuning - Cardinality Estimation

This script is from our Mastering Query Tuning class.
To learn more httpswww.BrentOzar.comgomasterqueries


This demo requires
 Any supported version of SQL Server
 Any Stack Overflow database httpswww.BrentOzar.comgoquerystack

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this

RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO



USE [StackOverflow]
GO
DropIndexes;
GO


 Turn on actual execution plans 
 Sometimes, inaccurate estimates don't matter much 
CREATE OR ALTER PROC dbo.usp_UsersWithManyVotes AS
BEGIN
SELECT 
FROM dbo.Users v1
INNER JOIN dbo.Users v2 ON v1.Id = v2.Id
WHERE (v1.UpVotes + v1.DownVotes)  1000000;
END
GO

EXEC usp_UsersWithManyVotes;
GO

 
Things to think about when looking at a bad estimate

  Are there joins to other tables
  Is there a decision about index seek vs scan
  Is there a sort that would have big memory grant implications
  Are there any row-by-row processes like functions that would scale poorly
  Does the query run quickly despite the bad estimate
  Would users ever raise a flag about this query being a problem
  How often does the query run







SELECT Location, COUNT()
  FROM dbo.Users
  GROUP BY Location
  ORDER BY COUNT() DESC
  OPTION (MAXDOP 1);
GO





License Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)
More info httpscreativecommons.orglicensesby-sa3.0

You are free to
 Share - copy and redistribute the material in any medium or format
 Adapt - remix, transform, and build upon the material for any purpose, even 
  commercially

Under the following terms
 Attribution - You must give appropriate credit, provide a link to the license,
  and indicate if changes were made.
 ShareAlike - If you remix, transform, or build upon the material, you must
  distribute your contributions under the same license as the original.

