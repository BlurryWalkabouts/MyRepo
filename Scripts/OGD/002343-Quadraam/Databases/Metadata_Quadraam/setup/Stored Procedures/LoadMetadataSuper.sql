CREATE PROCEDURE [setup].[LoadMetadata]
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

IF @debug = 0
	COMMIT TRANSACTION
ELSE
	ROLLBACK TRANSACTION

END