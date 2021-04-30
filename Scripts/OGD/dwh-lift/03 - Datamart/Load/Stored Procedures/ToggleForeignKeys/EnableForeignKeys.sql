CREATE PROCEDURE [Load].[EnableForeignKeys]
(
	@WriteLog bit = 1
)
AS
BEGIN

EXEC [Load].ToggleForeignKeys @enable = 1, @WriteLog = @WriteLog

END