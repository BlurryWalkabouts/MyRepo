alter PROCEDURE Finance.HourFlow AS BEGIN
	-- Setting first date of week to Monday
	SET DATEFIRST 1

	-- Cleaning up temporary tables
	DROP TABLE IF EXISTS #HoursActiveContractPerWeek;
	DROP TABLE IF EXISTS #HoursAssignmentPlanned;
	DROP TABLE IF EXISTS #HoursWrittenPerWeek;

	-- Selecting data into temporary tables.
	-- This is WAY faster than joins in this case
	SELECT * INTO #HoursActiveContractPerWeek FROM Finance.HoursActiveContractPerWeek
	SELECT * INTO #HoursAssignmentPlanned FROM Finance.HoursAssignmentPlanned

	-- Pre summarize
	select 
		 [Year]
		,[Week]
		,[Year-Week]
		,[BusinessUnit]
		,[Team]
		,[EmployeeId]
		,[AssignmentId]
		,[ProjectId]
		,IsSubmitted = MAX(IsSubmitted)
		,IsApproved = MAX(IsApproved)
		,IsInvoiced = MAX(CAST(IsInvoiced AS INT))
		,IsAssignedToInvoice = MAX(IsAssignedToInvoice)
		,[Hour] = SUM(uur)
		,[Turnover] = SUM(Turnover)
	INTO #HoursWrittenPerWeek
	FROM finance.HoursWritten a
	GROUP BY [Year]
		,[Week]
		,[Year-Week]
		,[BusinessUnit]
		,[Team]
		,[EmployeeId]
		,[AssignmentId]
		,[ProjectId]

	-- The end result:
	SELECT
		 HAP.[Year-Week]
		,HAC.[BusinessUnit]
		,HAC.[Team]
		,[Customer]
		,HAP.Project
		,[Hours] = COALESCE(HAW.[Hour], HAP.[HoursExpected], HAC.[Hour])
		,[Turnover] = COALESCE(HAW.[Turnover], HAP.[TurnoverExpected], HAC.[TurnoverAdvisedMax])
		,[Phase] = 
		CASE 
			WHEN HAW.Turnover IS NULL AND HAP.TurnOverExpected IS NULL THEN '0 - Niet Ingepland'
			WHEN HAW.Turnover IS NULL AND HAP.TurnoverExpected IS NOT NULL THEN '1 - Gepland'
			WHEN HAW.Turnover IS NOT NULL THEN
				CASE 
					WHEN IsInvoiced = 1 OR IsAssignedToInvoice = 1 THEN '5- Gefactureerd'
					WHEN IsApproved = 1 THEN '4 - Goedgekeurd'
					WHEN IsSubmitted = 1 THEN '3 - Ingediend'
					ELSE '2 - Geschreven'
				END
		END
	FROM
		#HoursActiveContractPerWeek HAC
		LEFT JOIN #HoursAssignmentPlanned HAP ON (HAC.[EmployeeId] = HAP.[EmployeeId]
														 AND HAC.[Year-Week] = HAP.[Year-Week]
														 AND HAP.HoursExpected > 0)
		LEFT JOIN #HoursWrittenPerWeek HAW ON (HAW.[Year-Week] = HAP.[Year-Week] 
											   AND HAW.[AssignmentId] = HAP.[AssignmentId])

	END