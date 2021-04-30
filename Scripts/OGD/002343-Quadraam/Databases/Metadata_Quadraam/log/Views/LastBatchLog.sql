CREATE VIEW [log].[LastBatchLog]
WITH SCHEMABINDING
	AS SELECT TOP 1000
			[Batch]
			, [Starttijd]
			, [Eindtijd]
			, [Script]
			, [IsGeslaagd]
			, [Melding]
			, [Duration]
		FROM [log].ProcedureLog
		WHERE [Batch] = (SELECT MAX([Batch]) FROM [log].ProcedureLog)
		ORDER BY [Eindtijd]
