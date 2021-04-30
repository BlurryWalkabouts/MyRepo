CREATE PROCEDURE [shared].[EnableForeignKeys]
(
	@db nvarchar(64)
)
AS

EXEC shared.ToggleForeignKeys @db, 1

/*
EXEC shared.EnableForeignKeys '[TOPdesk_DW]'
*/