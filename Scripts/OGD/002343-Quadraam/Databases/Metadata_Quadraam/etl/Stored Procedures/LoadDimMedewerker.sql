CREATE PROCEDURE [etl].[LoadDimMedewerker]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Medewerker

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Medewerker ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Medewerker (MedewerkerKey, MedewerkerCode, MedewerkerNaam, Geslacht, Geboortedatum, DatumInDienst)
VALUES
	(-1, -1, '[Onbekend]', '', '19000101', '19000101')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Medewerker OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Medewerker
	(
	MedewerkerCode
	, MedewerkerNaam
	, Geslacht
	, Geboortedatum     
	, Woonplaats
	, Email
	, DatumInDienst 
	, DatumInDienstIvmSignalering
	, DatumInDienstInclRechtsvoorganger
	, DatumUitDienst
	)
SELECT DISTINCT
	MedewerkerCode = CAST(m.Medewerker AS int)
	, MedewerkerNaam = COALESCE(m.Naam, '')
	, Geslacht = COALESCE(CASE WHEN m.Geslacht = 'Man' THEN 'M' ELSE 'V' END, '')
	, Geboortedatum = DATEFROMPARTS(m.Geboortejaar, m.Geboortemaand, m.Geboortedag)
	, Woonplaats = COALESCE(m.Woonplaats, '')
	, Email = COALESCE(m.Email_werk, '')
	, DatumInDienst = CAST(MIN(dv.Datum_in_dienst) AS DATE)
	, DatumInDienstIvmSignalering = CAST(COALESCE(m.In_dienst_ivm_signalering, '99991231') AS DATE)
	, DatumInDienstInclRechtsvoorganger = CAST(COALESCE(m.In_dienst_incl_rechtsvoorganger, '99991231') AS DATE)
	, DatumUitDienst = CAST(MAX(COALESCE(dv.Datum_uit_dienst, '99991231')) AS DATE)
FROM
	[$(Staging_Quadraam)].Afas.DWH_HR_Medewerkers m
	LEFT OUTER JOIN [$(Staging_Quadraam)].Afas.DWH_HR_Dienstverbanden dv ON dv.Medewerker = m.Medewerker
WHERE 1=1
	AND m.Medewerker <> '99999'
	AND TRY_CAST(m.Medewerker AS int) IS NOT NULL
GROUP BY
	m.Medewerker
	, m.Naam
	, m.Geslacht
	, m.Geboortejaar
	, m.Geboortemaand
	, m.Geboortedag
	, m.Woonplaats
	, m.Email_werk
	, m.In_dienst_ivm_signalering
	, m.In_dienst_incl_rechtsvoorganger

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Medewerker OFF
END CATCH
RETURN 0
END