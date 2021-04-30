CREATE PROCEDURE [Load].[PreLoadDatamart]
AS

BEGIN

/********************************************************************************
Drop foreign keys
********************************************************************************/

PRINT 'Drop foreign keys'
EXEC [Load].DisableForeignKeys

/********************************************************************************
Insert dates into Dim.Date
********************************************************************************/

PRINT 'Inserting dates into Dim.Date'
EXEC [Load].LoadDimDate

END