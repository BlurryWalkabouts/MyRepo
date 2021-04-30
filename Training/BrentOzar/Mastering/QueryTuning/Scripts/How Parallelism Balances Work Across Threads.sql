/*
Mastering Query Tuning - How Parallelism Works

This script is from our Mastering Query Tuning class.
To learn more: https://www.BrentOzar.com/go/masterqueries


This demo requires:
* 8 (or more) CPU cores
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO



USE [StackOverflow]
GO
EXEC sys.sp_configure N'cost threshold for parallelism', N'50'
EXEC sys.sp_configure N'max degree of parallelism', N'0'
GO
RECONFIGURE
GO
DropIndexes;
GO
CREATE INDEX Location ON dbo.Users(Location);
CREATE INDEX OwnerUserId ON dbo.Posts(OwnerUserId);
GO

/* If I need to find all the users in one location: */
SELECT u.Id
  FROM dbo.Users u
  WHERE u.Location = N'London, United Kingdom';
GO

/* Add a key lookup: */
SELECT u.Id, u.DisplayName
  FROM dbo.Users u
  WHERE u.Location = N'London, United Kingdom';

/* Things to discuss:
* Did the plan go parallel now?
* Did it REALLY go parallel?
* How many threads got data?
* How many threads did key lookups?
* What was the wait type for the other inactive threads?
*/



/* Add an order by: */
SELECT u.Id, u.DisplayName
  FROM dbo.Users u
  WHERE u.Location = N'London, United Kingdom'
  ORDER BY u.DisplayName;
GO
/* Things to discuss:
* How many threads did sorting?
* How was the memory divided across threads?
* Did some threads spill and not others?
* What was the top wait while this query ran?
* Does this really matter at this scale?
* Would it matter if you ran this query 1000s of times per second?
*/


/* Can we reduce CXPACKET waits & inactive threads with a hint? */
SELECT u.Id, u.DisplayName
  FROM dbo.Users u
  WHERE u.Location = N'London, United Kingdom'
  ORDER BY u.DisplayName
  OPTION(MAXDOP 4);
GO
/* Things to discuss:
* Does that hint rebalance the rows differently?
* Does that hint rebalance memory differently?
* Do we still spill to disk?
* Do we have less CXPACKET waits?

How does this affect:
* Max Degree of Parallelism settings?
* Cost Threshold for Parallelism settings?
*/


/* Add a join to this index: */
CREATE INDEX OwnerUserId ON dbo.Posts(OwnerUserId);
GO
SELECT u.Id, u.DisplayName, p.Id AS PostId
  FROM dbo.Users u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  WHERE u.Location = N'London, United Kingdom'
  ORDER BY u.DisplayName;
GO
/* Things to discuss:
* Note that we're back at MAXDOP 0
* Where is the parallelism operator in the plan?
* How is work divided across the threads?
* How many threads did index seeks?
*/


/* Add a key lookup to get more fields from Posts: */
SELECT u.Id, u.DisplayName, p.Id AS PostId, p.Score, p.Title
  FROM dbo.Users u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  WHERE u.Location = N'London, United Kingdom'
  ORDER BY u.DisplayName;
/* Things to discuss:
* Did the parallelism issue fix itself?
* Is the query faster?
*/

/* Add a sort, which will increase CPU work required: */
SELECT u.Id, u.DisplayName, p.Id AS PostId, p.Title, p.Score
  FROM dbo.Users u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  WHERE u.Location = N'London, United Kingdom'
  ORDER BY p.Score DESC, u.DisplayName;
GO
/* Things to discuss:
* Is the parallelism problem back?
* Is work evenly divided across cores?
* Is memory evenly divided across cores?
* What's the top wait type during this query?
* How can we reduce that wait type?

Philosophically:
* Is this a parallelism problem?
* Will the query go faster with less threads?
* Will the query go faster with better allocations of resources?

And back to reality:
* How will parameterization affect this?
*/
CREATE OR ALTER PROC dbo.usp_RptTopPostsByLocation @Location NVARCHAR(100) AS
BEGIN
SELECT u.Id, u.DisplayName, p.Id AS PostId, p.Title, p.Score
  FROM dbo.Users u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  WHERE u.Location = @Location
  ORDER BY p.Score DESC, u.DisplayName;
END
GO

/* Put London in cache: */
EXEC usp_RptTopPostsByLocation N'London, United Kingdom';
GO
/* Is the parallelism balanced?

Now try a smaller location: */
EXEC usp_RptTopPostsByLocation N'San Diego, CA, USA';
GO
/* Things to discuss: 
* Did it really go parallel?
* How much CXPACKET waits did we have?
* How are CXPACKET waits compared to the prior queries?
* Is this a concern?


Free the plan from cache and put a really small one in first: */
EXEC sp_recompile 'usp_RptTopPostsByLocation'
GO
EXEC usp_RptTopPostsByLocation N'Near Stonehenge';
GO
/* Did the plan go parallel?

Now run the bigger location: */
EXEC usp_RptTopPostsByLocation N'London, United Kingdom';
GO
/* Things to discuss: 
* Did we have a parallelism problem?
* What problem DID we have?
* If we were going to get one plan, what's worse:

* The tiny plan, single threaded, low estimates
* The big plan, multi-threaded (but imbalanced), high estimates
*/



/* Back to the big query. Before:

Can I get SQL Server to rebalance the work across threads
by changing the query? 
*/
SELECT u.Id, u.DisplayName, p.Id AS PostId, p.Title, p.Score
  FROM dbo.Users u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  WHERE u.Location = N'London, United Kingdom'
  ORDER BY p.Score DESC, u.DisplayName;
GO



/* First, try a CTE: */
WITH MatchingUsers AS (
	SELECT u.Id, u.DisplayName
	FROM dbo.Users u
	WHERE u.Location = N'London, United Kingdom'
)
SELECT u.Id, u.DisplayName, p.Id AS PostId, p.Title, p.Score
  FROM MatchingUsers u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  ORDER BY p.Score DESC, u.DisplayName;
GO


/* What if I force the CTE to execute first with a hack? */
WITH MatchingUsers AS (
	SELECT TOP 2147483647 u.Id, u.DisplayName
	FROM dbo.Users u
	WHERE u.Location = N'London, United Kingdom'
	ORDER BY u.DisplayName
)
SELECT u.Id, u.DisplayName, p.Id AS PostId, p.Title, p.Score
  FROM MatchingUsers u
  INNER JOIN dbo.Posts p ON u.Id = p.OwnerUserId
  ORDER BY p.Score DESC, u.DisplayName;
GO
/* Things to discuss:
* Did the query run faster?
* Did the parallelism operators change?
* Where was work rebalanced & redistributed?
* At what points of the plan was the work evenly distributed?
* At what points was it imbalanced?
* Is it worth the rewrite to do this? At what scale?


For bonus learning:
* Put the naturally written version into a stored procedure
* Show how tiny params inherit the "parallel" plan
* Show how "parallel" plans aren't really parallel, especially for tiny values

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