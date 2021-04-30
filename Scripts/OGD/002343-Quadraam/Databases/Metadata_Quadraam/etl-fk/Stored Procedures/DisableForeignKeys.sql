CREATE PROCEDURE [etl].[DisableForeignKeys]
AS
BEGIN 

DECLARE ExecuteBatches CURSOR FOR
(
SELECT
	ForeignKey = [name]
FROM
	[$(DWH_Quadraam)].sys.foreign_keys
)

DECLARE @ForeignKey nvarchar(128)

-- Voer de gegenereerde statements uit
OPEN ExecuteBatches
FETCH NEXT FROM ExecuteBatches INTO @ForeignKey
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC etl.DisableForeignKey @ForeignKey
	FETCH NEXT FROM ExecuteBatches INTO @ForeignKey
END
CLOSE ExecuteBatches
DEALLOCATE ExecuteBatches

END