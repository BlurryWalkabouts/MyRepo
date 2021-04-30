CREATE PROCEDURE [shared].[DisableForeignKeys]
(
	@db nvarchar(64)
)
AS

EXEC shared.ToggleForeignKeys @db, 0

/*
EXEC shared.DisableForeignKeys '[TOPdesk_DW]'
*/