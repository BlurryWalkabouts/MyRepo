CREATE PROCEDURE [etl].[EnableForeignKeys]
AS
BEGIN 

DECLARE ExecuteBatches CURSOR FOR
(
SELECT
	ForeignKey
FROM
	etl.ForeignKeys
)

DECLARE @ForeignKey nvarchar(128)

-- Voer de gegenereerde statements uit
OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @ForeignKey
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC etl.EnableForeignKey @ForeignKey
	FETCH NEXT FROM ExecuteBatches INTO @ForeignKey
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

END