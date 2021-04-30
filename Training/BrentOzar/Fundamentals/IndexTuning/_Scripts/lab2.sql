*
Fundamentals of Index Tuning: WHERE + ORDER BY Lab
v1.2 - 2020-11-12
https://www.BrentOzar.com/go/indexfund
This demo requires:
* Any supported version of SQL Server
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack
This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO
DropIndexes;
GO
/* It leaves clustered indexes in place though. */
/* ****************************************************************************
FIRST LAB CHALLENGE: design the right index for this:
*/
SELECT TOP 100 DisplayName, Location, WebsiteUrl, Reputation, Id
  FROM dbo.Users
  WHERE Location <> ''
    AND WebsiteUrl <> ''
  ORDER BY Reputation DESC;
GO
--  logical reads 45184
set statistics io on

SELECT count(*)
FROM dbo.Users
  WHERE Location <> ''
  -- 572362
SELECT count(*)
FROM dbo.Users
  WHERE WebsiteUrl <> ''
  -- 339977
SELECT TOP 100 *
FROM dbo.Users
ORDER BY Reputation DESC;
-- many have urls and locations filled in

create index Location_WebsiteUrl_Reputation
  on dbo.users(Location,WebsiteUrl,Reputation)
  include (DisplayName)
  -- 6552

  create index Reputation_WebsiteUrl
  on dbo.users(Reputation,WebsiteUrl)
  include (DisplayName,Location)
  -- reads 38

    create index Reputation
  on dbo.users(Reputation)
  include (WebsiteUrl,Location,DisplayName)
  -- 17
/* ****************************************************************************
NEXT UP: We want to start encouraging people to review other folks' work and
upvote it. To do that, let's find the most recently created users who haven't
cast an UpVote yet. Then, build the right index for it.
You write the query. Go for it!
*/
select top 100 u.DisplayName
from users u
where u.UpVotes = 0
order by u.CreationDate desc
-- 45184

select count(*)
from users u
where u.UpVotes = 0
-- 1782780

  create index CreationDate
  on dbo.users(CreationDate)
  -- 7773

    create index CreationDate_UpVotes
  on dbo.users(CreationDate,UpVotes)
  -- 341

      create index UpVotes_CreationDate_D
  on dbo.users(UpVotes,CreationDate)
  include (displayName)
  -- 3
/* ****************************************************************************
NEXT CHALLENGE: User Id #22656 is lonely. Let's build a dating service query to
find all of the people who live in his country. He'll probably want to find
friendly people, so let's filter for a few things:
*/
SELECT DisplayName, Location, Reputation, WebsiteUrl, Id
  FROM dbo.Users
  WHERE Age > 21
    AND (Location LIKE '%United Kingdom%' OR Location LIKE '%UK%')
    AND DownVotes < 1000
    AND UpVotes > 1
  ORDER BY Reputation DESC, Location;
  -- 45184

  select count(*) from dbo.users
  WHERE Age > 21
  --0

    select count(*) from dbo.users
  WHERE DownVotes < 1000
  --2464327

      select count(*) from dbo.users
  WHERE  UpVotes > 1
  --621154


  create index Reputation_Location_downvotes
    on dbo.Users
	(Reputation,Location,downvotes)
	include (DisplayName,WebsiteUrl)
  -- 45184

  create index Age_Location_DownVotes_UpVotes
    on dbo.Users
	(Age,Location,DownVotes,UpVotes)
	include (DisplayName,WebsiteUrl)
	-- can count 1, logical reads 3,

SELECT DisplayName, Location, Reputation, WebsiteUrl, Id
  FROM dbo.Users -- with(index=Location_Reputation_downvotes)
  WHERE Age > 21
    AND (Location LIKE '%United Kingdom%' OR Location LIKE '%UK%')
    AND DownVotes < 1000
    AND UpVotes > 1
  ORDER BY Reputation DESC, Location;

GO
/* ****************************************************************************
NEXT EXERCISE: a while back, we found the one-and-done users: people who
created an account, but then never logged in again. Just out of curiosity, did
any of them earn reputation points in that one brief login? Design an index for
this query - but before you do, take a look at the plan it's using now, and the
number of logical reads it's doing:
*/
SELECT TOP 100 CreationDate, LastAccessDate, DisplayName, Reputation, Id
  FROM dbo.Users
  WHERE CreationDate = LastAccessDate
    AND Reputation <> 1
  ORDER BY Reputation DESC;
GO


-- logical reads 45184
create index CreationDate_LastAccessDate_Reputation_D
on dbo.Users (CreationDate,LastAccessDate,Reputation)
include (displayname)
--  logical reads 16576,

create index Reputation_CreationDate_LastAccessDate
on dbo.Users (Reputation,CreationDate,LastAccessDate)
include (displayname)
--  logical reads 607,


/* Huh. Interesting. Alright, your turn! Build the right index and prove it. */
/* ****************************************************************************
BONUS QUESTION: you've created a few indexes so far. Now, looking at those
indexes, try to craft a query that could maybe use those indexes, but won't.
For example, try to write one where the index doesn't quite cover, and make
SQL Server choose between an index seek + key lookup, versus a table scan, and
choose your filters carefully to make SQL Server think it's going to find so
much data that it's better off just scanning the clustered index instead.
*/

SELECT TOP 100 CreationDate, LastAccessDate, DisplayName, Reputation, Id
  FROM dbo.Users
  where id = 1
  order by CreationDate
/* ****************************************************************************
BONUS QUESTION: write a query to find users who average the highest reputation
points gained per day. Who's rocketing up the fastest? Our report needs to show
their DisplayName, Location, and Reputation for the top 100 users in this
category, and sort them by the average highest points gained per day, desc.
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