/*
Fundamentals of TempDB: How to Monitor TempDB
v1.0 - 2020-12-06
https://www.BrentOzar.com/go/tempdbfun


This demo requires:
* SQL Server 2016 or newer
* Any Stack Overflow database: https://www.BrentOzar.com/go/querystack

This first RAISERROR is just to make sure you don't accidentally hit F5 and
run the entire script. You don't need to run this:
*/
RAISERROR(N'Oops! No, don''t just hit F5. Run these demos one at a time.', 20, 1) WITH LOG;
GO
USE StackOverflow2013;
GO
/* Does TempDB have enough capacity?
If not, what's using the space? */
SELECT SUM(total_page_count * 8.0 / 1024 / 1024) AS size_gb,
	SUM(unallocated_extent_page_count * 8.0 / 1024 / 1024) AS free_space_gb,
	SUM(COALESCE(version_store_reserved_page_count,0) * 8.0 / 1024 / 1024) AS version_store_gb,
	SUM(COALESCE(user_object_reserved_page_count,0) * 8.0 / 1024 / 1024) AS user_object_gb,
	SUM(COALESCE(internal_object_reserved_page_count,0) * 8.0 / 1024 / 1024) AS internal_object_gb
FROM tempdb.sys.dm_db_file_space_usage;


/* Are the TempDB pages in memory fast enough?
Look for PAGELATCH waits in your top 10 waits: */
sp_BlitzFirst @SinceStartup = 1


/* If we're having PAGELATCH waits, how many
data files do we have? Are they equally sized? */
SELECT type_desc, name, physical_name, 
	size * 8.0 / 1024 AS size_mb
	FROM tempdb.sys.database_files
	ORDER BY type_desc DESC;
GO

/* Which queries are waiting on latches? */
EXEC sp_WhoIsActive;
WAITFOR DELAY '00:00:01'
GO 10

/* Are the TempDB pages on disk fast enough?
Do they show up in your top files by write
wait times? */
sp_BlitzFirst @SinceStartup = 1;
GO

sp_BlitzFirst @OutputDatabaseName = 'DBAtools',
	@OutputSchemaName = 'dbo',
	@OutputTableName_FileStats = 'BlitzFirst_FileStats'
GO
SELECT TOP 100 CheckDate, DatabaseName, FileLogicalName,
	io_stall_write_ms, num_of_writes, io_stall_write_ms_average,
	megabytes_written
	FROM DBAtools.dbo.BlitzFirst_FileStats_Deltas
	ORDER BY io_stall_write_ms DESC;
GO

/* Which queries have been spilling the most? */
sp_BlitzCache @SortOrder = 'spills';
GO
/* And scroll across to the Total Spills column. */



/*
License: Creative Commons Attribution-ShareAlike 4.0 Unported (CC BY-SA 4.0)
More info: https://creativecommons.org/licenses/by-sa/4.0/

You are free to:
* Share - copy and redistribute the material in any medium or format
* Adapt - remix, transform, and build upon the material for any purpose, even 
  commercially

Under the following terms:
* Attribution - You must give appropriate credit, provide a link to the license, 
  and indicate if changes were made. You may do so in any reasonable manner, 
  but not in any way that suggests the licensor endorses you or your use.
* ShareAlike - If you remix, transform, or build upon the material, you must
  distribute your contributions under the same license as the original.
* No additional restrictions — You may not apply legal terms or technological 
  measures that legally restrict others from doing anything the license permits.
*/