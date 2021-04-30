CREATE PROCEDURE [setup].[CreateBatchFileXMLbcp]
AS
BEGIN

--********************************************************************************************************
--***  Export 
--********************************************************************************************************

DECLARE @table sysname
DECLARE @schema sysname
DECLARE @fulltablename sysname

PRINT ':: Setup variables, NO SPACES AT END!!'
PRINT ':: folder where the output will be stored, must end with \'
PRINT 'set folder=c:\temp\data\'
PRINT ':: name of TOPdesk database '
PRINT 'set db=Topdesk5punt2sp2'
PRINT ':: server, credentials. e.g. "connection=-S localhost -T" for trusted connection or "connection=-S servername\instancename –Uaccountname –Ppassword"'
PRINT 'set connection=-S localhost -T'
PRINT ''

--SELECT DISTINCT build FROM [$(MDS)].mdm.TOPdesk_Tables

DECLARE T CURSOR FOR 
SELECT TABLE_SCHEMA, TABLE_NAME
FROM [$(MDS)].mdm.TOPdesk_Tables
WHERE import = 1 AND build = '5.7.0-release3-20151029-1605'
ORDER BY TABLE_SCHEMA, TABLE_NAME

OPEN T
FETCH NEXT FROM T INTO @table, @schema
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @fulltablename = QUOTENAME(@schema) + '.' + QUOTENAME(@table)
	PRINT 'bcp %db%.' + @fulltablename + ' format nul -N -f "%folder%' + @table + '.format.xml" %connection% -x'
	PRINT 'bcp %db%.' + @fulltablename + ' out "%folder%' + @table + '.dat" -f "%folder%' + @table + '.format.xml" %connection%'
	FETCH NEXT FROM T INTO @table, @schema
END
CLOSE T
DEALLOCATE T

/*
--********************************************************************************************************
--***  Import [NB: ONDERSTAANDE IS NIET MEER NODIG]
--********************************************************************************************************

DECLARE @table sysname
DECLARE @schema sysname
DECLARE @fulltablename sysname

PRINT ':: Setup variables, NO SPACES AT END!!'
PRINT ':: folder where the output will be stored, must end with \'
PRINT 'set folder=c:\temp\data\'
PRINT ':: name of the database where the data will be imported'
PRINT 'set db=OGDW_Staging'
PRINT ':: schema where the data will be imported'
PRINT 'set importschema=[GVB_TOPdesk5.2.1]'
PRINT ':: server, credentials. e.g. "connection=-S localhost -T" for trusted connection or "connection=-S servername\instancename –Uaccountname –Ppassword"'
PRINT 'set connection=-S localhost -T'
PRINT ''

DECLARE T CURSOR FOR 
SELECT TABLE_SCHEMA, TABLE_NAME
FROM [$(MDS)].mdm.TOPdesk_Tables
WHERE import = 1 AND build = '5.7.0-release3-20151029-1605'
ORDER BY TABLE_SCHEMA, TABLE_NAME

OPEN T
FETCH NEXT FROM T INTO @table, @schema
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'bcp %db%.%importschema%.' + QUOTENAME(@table) + ' in "%folder%' + @table + '.dat" -f "%folder%' + @table +'.format.xml" %connection%'
	FETCH NEXT FROM T INTO @table, @schema
END
CLOSE T
DEALLOCATE T
*/

END