CREATE VIEW [etl].[Translation_step1_Caller]
AS
SELECT
	SourceDatabaseKey
--	, CallerID = NULL
	, CallerName
	, CallerEmail = COALESCE(CallerEmail, '[Onbekend]')
	, CallerTelephoneNumber = COALESCE(CallerTelephoneNumber, '[Onbekend]')
	, CallerTelephoneNumberSTD = NULL
	, CallerMobileNumber
	, CallerMobileNumberSTD = NULL
	, CallerDepartment = COALESCE(CallerDepartment, '[Onbekend]')
	, CallerBranch = COALESCE(CallerBranch, '[Onbekend]')
	, CallerCity
	, CallerLocation
	, CallerRegion = COALESCE(T02.TranslatedValue, TD02.TranslatedValue, '[Onbekend]')
	, CallerGender = COALESCE(T01.TranslatedValue, TD01.TranslatedValue, CallerGender)
	, #CallerGender = COALESCE(T00.TranslatedValue, TD00.TranslatedValue, '[Onbekend]')
FROM
	etl.Current_Caller I
	LEFT OUTER JOIN setup.SourceDefinition SD ON SD.Code = I.SourceDatabaseKey
	LEFT OUTER JOIN setup.SourceTranslation T00 ON T00.SourceName = SD.DatabaseLabel 
		AND T00.AMAnchorName = 'Caller'
		AND T00.DWColumnName = 'CallerGenderID'
		AND ISNULL(T00.SourceValue,-1) = ISNULL(CAST(I.CallerGenderID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD00 ON TD00.SourceName = 'DEFAULT'
		AND TD00.AMAnchorName = 'Caller'
		AND TD00.DWColumnName = 'CallerGenderID'
		AND ISNULL(TD00.SourceValue,-1) = ISNULL(CAST(I.CallerGenderID AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T01 ON T01.SourceName = SD.DatabaseLabel 
		AND T01.AMAnchorName = 'Caller'
		AND T01.DWColumnName = 'CallerGender'
		AND ISNULL(T01.SourceValue,-1) = ISNULL(CAST(I.CallerGender AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD01 ON TD01.SourceName = 'DEFAULT'
		AND TD01.AMAnchorName = 'Caller'
		AND TD01.DWColumnName = 'CallerGender'
		AND ISNULL(TD01.SourceValue,-1) = ISNULL(CAST(I.CallerGender AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation T02 ON T02.SourceName = SD.DatabaseLabel
		AND T02.AMAnchorName = 'Caller'
		AND T02.DWColumnName = 'CallerLocation'
		AND ISNULL(T02.SourceValue,-1) = ISNULL(CAST(I.CallerLocation AS varchar(max)),'-1')
	LEFT OUTER JOIN setup.SourceTranslation TD02 ON TD02.SourceName = 'DEFAULT'
		AND TD02.AMAnchorName = 'Caller'
		AND TD02.DWColumnName = 'CallerLocation'
		AND ISNULL(TD02.SourceValue,-1) = ISNULL(CAST(I.CallerLocation AS varchar(max)),'-1')