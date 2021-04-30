BEGIN TRY

BEGIN TRANSACTION

IF EXISTS (
	SELECT
		*
	FROM sys.tables t
		LEFT OUTER JOIN [sys].[columns] c on c.object_id = t.object_id
	WHERE
		t.[name] = 'TurnoverForecast'
		AND c.[name] = 'TurnoverForecast'
		AND c.[scale] = 12
) TRUNCATE TABLE [Fact].[TurnoverForecast]

IF EXISTS (
	SELECT
		*
	FROM
		sys.tables t
		LEFT OUTER JOIN [sys].[columns] c on c.object_Id = t.object_Id
	WHERE
		t.[name] = ('Turnover')
		AND c.[name] in (
			'HoursWritten'
			, 'AvgHoursWritten'
			, 'Turnover'
			, 'AvgTurnover'
		)
		AND c.[scale] = 12
) TRUNCATE TABLE [Fact].[Turnover]

COMMIT TRANSACTION

END TRY

BEGIN CATCH

ROLLBACK TRANSACTION

END CATCH