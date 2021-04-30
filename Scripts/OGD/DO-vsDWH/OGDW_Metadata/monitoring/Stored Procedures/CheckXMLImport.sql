CREATE PROCEDURE [monitoring].[CheckXMLImport]
(
	@sdk int
	, @folder nvarchar(256)
	, @sendmail bit = 0
)
AS
BEGIN

SET NOCOUNT ON

/************************************************************
EXEC monitoring.CheckXMLImport 324, 'Beweging3_SFTP'
EXEC monitoring.CheckXMLImport 318, 'GVBLokaal'

-- Enable advanced options 
EXEC sp_configure 'show advanced options', 1
GO
-- Update the currently configured value for advanced options.
RECONFIGURE
GO

-- Enable the feature
EXEC sp_configure 'xp_cmdshell', 1
GO
-- Update the currently configured value for this feature.
RECONFIGURE
GO
************************************************************/

CREATE TABLE #XmlRecCount
(
	DWDateCreated          datetime
	, AuditDWKey           int
	, SourceDatabaseKey    int
	, DatabaseLabel        varchar(64)
	, TABLE_NAME           varchar(32)
	, rec_cnt              int
	, LastModifiedDate     datetime
	, MaxLastModifiedDate  datetime
	, LastModifiedFileDate datetime
)

/*********************************************************************************************
************************** Query most recent imported records ********************************
*********************************************************************************************/

DECLARE @LatestBatch int = (SELECT AuditDWKey = MAX(AuditDWKey) FROM [log].[Audit] WHERE SourceDatabaseKey = @sdk)
DECLARE @SQLString nvarchar(max) = ''

SELECT
	@SQLString += '
	INSERT INTO
		#XmlReccount
		(
		DWDateCreated
		, AuditDWKey
		, SourceDatabaseKey
		, DatabaseLabel
		, TABLE_NAME
		, rec_cnt
		, LastModifiedDate
		)
	SELECT
		a.DWDateCreated
		, a.AuditDWKey
		, a.SourceDatabaseKey
		, sd.DatabaseLabel
		, TABLE_NAME = ''' + t.TABLE_NAME + '''
		, rec_cnt = COUNT(*)
		, LastModifiedDate = MAX(datwijzig)
	FROM
		[$(OGDW_Staging)].TOPdesk.' + t.TABLE_NAME + ' x
		INNER JOIN [log].[Audit] a ON x.AuditDWKey = a.AuditDWKey
		LEFT OUTER JOIN setup.SourceDefinition sd ON a.SourceDatabaseKey = sd.Code
	WHERE 1=1
		AND a.AuditDWKey = ' + CAST(@LatestBatch AS char(6)) + '
	GROUP BY
		a.DWDateCreated
		, a.AuditDWKey
		, a.SourceDatabaseKey
		, sd.DatabaseLabel'
FROM
	[$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES t
	INNER JOIN [$(OGDW_Staging)].INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME AND c.COLUMN_NAME = 'datwijzig'
WHERE 1=1
	AND t.TABLE_TYPE = 'BASE TABLE'
	AND t.TABLE_SCHEMA = 'TOPdesk'

EXEC (@SQLString)

/*******************************************************************************
************************** Read from filesystem ********************************
*******************************************************************************/

-- Source folder of the data files
DECLARE @dir varchar(64) = '$(ETL_Path)\$(DB_Exports)\'
-- Complete path for the command shell
DECLARE @fullpath varchar(128) = @dir + @folder + '\*.dat'
-- Command to be executed
DECLARE @Command varchar(256) = 'dir "' + @fullpath + '" /A:-D /T:W | find ".dat"'

-- Declare a table to store the command line raw results
DECLARE @files table ([output] nvarchar(256) NULL)
INSERT INTO @files EXEC xp_cmdshell @Command

-- Use a cte to convert raw data 
;WITH Parted_Metadata AS
(
SELECT 
	folder = @folder
	, [filename] = REPLACE(RIGHT([output], CHARINDEX(' ',REVERSE([output]))-1),'.dat','')
	, LastModifiedFileDate = CAST(SUBSTRING([output], 1, 20) AS datetime)
FROM
	@files
WHERE 1=1
	AND [output] IS NOT NULL
)

-- Update existing table with file mod date per tabel
UPDATE
	rec
SET
	rec.MaxLastModifiedDate = (SELECT MAX(LastModifiedDate) FROM #XmlRecCount)
	, rec.LastModifiedFileDate = pm.LastModifiedFileDate
FROM
	#XmlRecCount rec
	INNER JOIN Parted_Metadata pm ON pm.[filename] = rec.TABLE_NAME
 
/************************************************************************************
***************************** Email the problems ************************************
************************************************************************************/

-- @periodext: Op zondag mag de laatste import 48 uur oud zijn, op maandag 72 uur, op andere dagen 24 uur
SET DATEFIRST 1
DECLARE @period int = 24
DECLARE @periodext int = @period + CASE DATEPART(DW, GETDATE()) WHEN 7 THEN 1 WHEN 1 THEN 2 ELSE 0 END * @period

DECLARE @recordCount int

SELECT 
	@recordCount = COALESCE(COUNT(*),0)
FROM
	#XmlRecCount
WHERE 1<>1
	OR rec_cnt = 0
	OR DATEDIFF(HH, LastModifiedFileDate, DWDateCreated) > @period
	OR DATEDIFF(HH, MaxLastModifiedDate, DWDateCreated) > @period
	OR DATEDIFF(HH, DWDateCreated, GETDATE()) > @periodext

IF @sendmail = 1
BEGIN
	IF @recordCount > 0
	BEGIN
		-- Als er rijen worden gevonden, wordt de body van het mailbericht opgebouwd als HTML
		DECLARE @subject nvarchar(64) = 'Unsuccessful SFTP/XML Import'
		DECLARE @recipients nvarchar(max) = (SELECT STUFF((SELECT ';' + Recipient FROM monitoring.Recipients WHERE [Subject] = @subject ORDER BY Recipient FOR XML PATH('')), 1, 1, ''))
		DECLARE @body nvarchar(max)

		SET @subject = @subject + ' ' + CAST(@sdk AS nvarchar(5))
		SET @body = '
		<H1>' + @subject + '</H1>
		<table cellpadding="5" cellspacing="0" border="1">
			<tr>
				<th width="100">DWDateCreated</th>
				<th>AuditDWKey</th>
				<th>SDK</th>
				<th>DatabaseLabel</th>
				<th>Table</th>
				<th>rec_cnt</th>
				<th>LastModifiedDate</th>
				<th>LastModifiedFileDate</th>
			</tr>
			' + (
			SELECT
				td = DWDateCreated
				, td = AuditDWKey
				, td = SourceDatabaseKey
				, td = DatabaseLabel
				, td = TABLE_NAME
				, td = rec_cnt
				, td = LastModifiedDate
				, td = LastModifiedFileDate
			FROM
				#XmlRecCount
			WHERE 1<>1
				OR rec_cnt = 0
				OR DATEDIFF(HH, LastModifiedFileDate, DWDateCreated) > @period
				OR DATEDIFF(HH, MaxLastModifiedDate, DWDateCreated) > @period
				OR DATEDIFF(HH, DWDateCreated, GETDATE()) > @periodext
			ORDER BY
				AuditDWKey
				, TABLE_NAME
			FOR XML RAW('tr'), ELEMENTS
			) + '
		</table>'

		IF @recipients IS NOT NULL
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'DBA Alerts', @recipients = @recipients, @subject = @subject, @body = @body, @body_format = 'HTML'
	END
END
ELSE
BEGIN
	SELECT
		*
	FROM
		#XmlRecCount
	WHERE 1<>1
		OR rec_cnt = 0
		OR DATEDIFF(HH, LastModifiedFileDate, DWDateCreated) > @period
		OR DATEDIFF(HH, MaxLastModifiedDate, DWDateCreated) > @period
		OR DATEDIFF(HH, DWDateCreated, GETDATE()) > @periodext
END

DROP TABLE #XmlRecCount

END