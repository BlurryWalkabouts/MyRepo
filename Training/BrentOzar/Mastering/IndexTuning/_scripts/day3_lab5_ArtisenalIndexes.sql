1% - niche cases that create problems 

filtered indexes 
- works on 5% of table (isemployee on user table)
- filtered column needs to be in index
- sql creates safe query plans, needs special treatment , for example using child quries or dyunamic sql
- problems with merge statements

indexed views
- with schemabinding helps
- indexed views does not need to be quried, to be used
- alter view , recreates view and deletes indexes
- add groupings to an index, for ssum()
- comes at a cost, dui need to handle indexed view incl locking
- corruption requires additional param to find, dbcc checkdb EXTENDED_LOGICAL_CHECKS 

computed columns
- ltrim rtrim substring upper/lowercase
- same magic as for indexed views, can automatically relate to computed column even if its not specifcally used 
- indexing on copmuted colomns works for selecting the non computed column (app does not need to be changed). But need to be EXACT

partitioned tables
- queries need to have partion key for getting the partition elimiation, if not everything needs to be scaned (where saldate = '2018-09-30')
- needs to be in same db, same filegroup 

-- lab 5 Artisanal, Hand-Crafted, Specialized Index Types
/* 
Brents demo 

usp_ixreport1
- looks like clustered index scan
generally we want a to put index on column
yellow bang , implicit conversion
sql converts rows up to align with query, (we would like it to convert query down, but not the case )
add computed column , with index on it

usp_ixreport2

usp_ixreport3


*/


/*
CREATE OR ALTER PROC [dbo].[usp_IXReport1] @DisplayName NVARCHAR(40)
AS
BEGIN
SELECT *
  FROM dbo.Report_UsersByQuestions
  WHERE DisplayName = @DisplayName;
END;
GO

-- before 
Table 'Report_UsersByQuestions'. Scan count 5, logical reads 61234, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

-- after
Table 'Report_UsersByQuestions'. Scan count 1, logical reads 590, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

*/
set statistics io on 

exec dbo.usp_IXReport1 @DisplayName = 'arnold' 

alter table Report_UsersByQuestions
add displayname_nvarchar as cast(displayname as nvarchar(40))

create index displayname_nvarchar 
on Report_UsersByQuestions (displayname_nvarchar)
WITH (ONLINE = OFF, MAXDOP = 0);

/*

CREATE OR ALTER PROC [dbo].[usp_IXReport2] @LastActivityDate DATETIME, @Tags NVARCHAR(150) AS
BEGIN
/* Sample parameters: @LastActivityDate = '2017-07-17 23:16:39.037', @Tags = '%<indexing>%' */
SELECT TOP 100
	u.DisplayName
	, u.Id AS UserId
	, u.Location
	, p.Id AS PostId
	, p.LastActivityDate
	, p.Body
  FROM dbo.Posts p
    INNER JOIN dbo.Users u ON p.OwnerUserId = u.Id
  WHERE p.Tags LIKE '%<sql-server>%'
    AND p.Tags LIKE @Tags
    AND p.LastActivityDate > @LastActivityDate
 ORDER BY u.DisplayName
END
GO


-- before (without order)
Table 'Posts'. Scan count 5, logical reads 5921223, physical reads 6614, page server reads 0, read-ahead reads 379953, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.


-- after
*/

[dbo].[usp_IXReport2] @LastActivityDate = '2018-04-01' , @Tags='%<indexing>%'

exec dbautils.dbo.sp_blitzindex @getalldatabases = 1

select count(*) FROM dbo.Posts p where tags is not null

[dbo].[usp_IXReport2] @LastActivityDate = '2018-04-01' , @Tags='%<indexing>%'

CREATE INDEX Tags3 ON dbo.Posts 
	(Tags,LastActivityDate)
	include (Body)
	WHERE Tags is not null


/*
CREATE OR ALTER PROC [dbo].[usp_IXReport3] @SinceLastAccessDate DATETIME2 AS
BEGIN
SELECT TOP 200 r.DisplayName, r.UserId, r.CreationDate, r.LastAccessDate, u.AboutMe, r.Questions, r.Answers, r.Comments
  FROM dbo.Report_UsersByQuestions r
  INNER JOIN dbo.Users u ON r.UserId = u.Id AND r.DisplayName = u.DisplayName
  WHERE r.LastAccessDate > @SinceLastAccessDate
  ORDER BY r.LastAccessDate
END
GO

-- before 
Table 'Users'. Scan count 0, logical reads 3827, physical reads 1, page server reads 0, read-ahead reads 819, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Report_UsersByQuestions'. Scan count 5, logical reads 61218, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

--after 
Table 'Users'. Scan count 0, logical reads 633, physical reads 0, page server reads 0, read-ahead reads 180, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.
Table 'Report_UsersByQuestions'. Scan count 1, logical reads 637, physical reads 0, page server reads 0, read-ahead reads 0, page server read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob page server reads 0, lob read-ahead reads 0, lob page server read-ahead reads 0.

*/

[dbo].[usp_IXReport3] @SinceLastAccessDate = '2018-04-01'

create index LastAccessDate
on Report_UsersByQuestions
(LastAccessDate)
