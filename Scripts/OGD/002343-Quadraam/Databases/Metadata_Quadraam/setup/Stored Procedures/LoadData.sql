CREATE PROCEDURE [setup].[LoadData]
(
	@patDataSource varchar(64)
	, @patConnector varchar(64)
	, @debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRANSACTION

EXEC setup.LoadMetadataSub @patDataSource = @patDataSource, @patConnector = @patConnector
--EXEC setup.CreateStagingTables @patDataSource = @patDataSource, @patConnector = @patConnector, @debug = @debug
EXEC setup.LoadDataIntoStaging @patDataSource = @patDataSource, @patConnector = @patConnector, @debug = @debug

IF @debug = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

END