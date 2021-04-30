CREATE VIEW [etl].[Translated_Caller]
AS
SELECT
	SourceDatabaseKey
--	, CallerID
	, CallerName
	, CallerEmail
	, CallerTelephoneNumber
	, CallerTelephoneNumberSTD
	, CallerMobileNumber
	, CallerMobileNumberSTD
	, CallerDepartment
	, CallerBranch
	, CallerCity
	, CallerLocation
	, CallerRegion
	, CallerGender = CASE SD.SourceType WHEN 'FILE' THEN CallerGender
			WHEN 'ExcelToDB' THEN CallerGender
			WHEN 'MSSQL' THEN #CallerGender
			WHEN 'XML' THEN #CallerGender
			ELSE '[Geen vertaling aanwezig voor SourceType]'
		END
	
FROM
	etl.Translation_step1_Caller T
	LEFT OUTER JOIN setup.SourceDefinition SD on SD.Code = T.SourceDatabaseKey