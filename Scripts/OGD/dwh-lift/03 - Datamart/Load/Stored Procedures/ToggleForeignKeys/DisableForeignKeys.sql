CREATE PROCEDURE [Load].[DisableForeignKeys]
(
	@WriteLog bit = 0
)
AS
BEGIN

EXEC [Load].ToggleForeignKeys @enable = 0, @WriteLog = @WriteLog

END