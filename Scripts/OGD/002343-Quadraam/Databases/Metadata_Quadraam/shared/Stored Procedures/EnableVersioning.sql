CREATE PROCEDURE [shared].[EnableVersioning]
(
	@db nvarchar(64)
	, @schema nvarchar(64)
	, @table nvarchar(64)
	, @debug bit = 0
)
AS

EXEC shared.ToggleVersioning @db, @schema, @table, 1, @debug