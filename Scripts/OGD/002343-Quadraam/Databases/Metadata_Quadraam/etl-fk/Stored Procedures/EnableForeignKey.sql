CREATE PROCEDURE [etl].[EnableForeignKey]
(
	@ForeignKey nvarchar(128)
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max)

SELECT TOP 1
	@SQLString = SQLStringAdd
FROM
	etl.ForeignKeys
WHERE 1=1
	AND ForeignKey = @ForeignKey
	
EXEC (@SQLString)

DELETE FROM
	etl.ForeignKeys
WHERE 1=1
	AND ForeignKey = @ForeignKey

COMMIT TRANSACTION

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

END CATCH

END