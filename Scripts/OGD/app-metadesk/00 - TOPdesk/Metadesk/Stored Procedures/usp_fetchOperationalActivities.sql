CREATE OR ALTER PROCEDURE [metadesk].[usp_fetchOperationalActivities] 
(
	@LastModified datetime2,
	@JsonSerializedResult nvarchar(max) OUTPUT
)
AS
BEGIN 

SET @JsonSerializedResult = (
SELECT TOP 1500
	 -- Identifier
	   [Guid] = OA.[unid]
      ,[OperationalSeriesNumber] = COALESCE(R.[Nummer], OA.ref_seriesnumber)
      ,[OperationalSeriesName] = COALESCE(R.[Naam], OA.ref_seriesname)
	  ,[OperationalActivityNumber] = OA.[nummer]
      ,[Description] = OA.[naam]
      ,[DetailedDescription] = OA.[verzoek]
	  ,[OperatorGroupKey] = NULL
      ,[OperatorGroupGuid] = [operatorgroupid]
	  ,[OperatorGroup] = AD.Naam
	  ,[OperatorKey] = NULL
      ,[OperatorGuid] = [behandelaarid]
      ,[Operator] = [ref_behandelaarnaam]
      ,[StatusID] = OA.[status]
      ,[Status] = OA.[ref_statusnaam]
      ,[CreationDate] = OA.[dataanmk]
      ,[ChangeDate] = OA.[datwijzig]
      ,[PlannedStartDate] = [startdatumgepland]
      ,[PlannedCompletionDate] = [einddatumgepland]
      ,[CompletionDate] = [datumafgemeld]
      ,[Completed] = [afgemeld]
	  ,[Skipped] = [overgeslagen]
FROM [dbo].[om_activiteit] OA
INNER JOIN [dbo].[actiedoor] AD ON (AD.unid = OA.operatorgroupid)
LEFT JOIN [dbo].[om_reeks] R ON (R.unid = OA.reeksid AND R.[Status] > 0)
WHERE 
	OA.datwijzig >= @LastModified 
	-- Exclude Archived
	AND OA.[Status] > 0
ORDER BY ChangeDate ASC
FOR JSON PATH 
)
  RETURN 0
END
GO