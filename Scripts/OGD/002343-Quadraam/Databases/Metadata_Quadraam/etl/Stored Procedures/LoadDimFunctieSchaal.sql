CREATE PROCEDURE [etl].[LoadDimFunctieSchaal]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.FunctieSchaal

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.FunctieSchaal ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.FunctieSchaal (FunctieSchaalKey, DienstverbandKey, [MedewerkerKey], [SchaalCode], [Trede], [IsBovenschools], BegindatumSalaris, EinddatumSalaris, FunctiePercentage, Salaris)
VALUES
	(-1, -1, -1, '', 0.0, 0, '19000101', '99991231', 0, 0)
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.FunctieSchaal OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.FunctieSchaal
	(
	DienstverbandKey
	, [MedewerkerKey]
	, [SchaalCode]
	, [Trede]
	, [IsBovenschools]
	, BegindatumSalaris
	, EinddatumSalaris
	, FunctiePercentage
	, Salaris		
	)
SELECT
	DienstverbandKey		= COALESCE(dv.[DienstverbandKey], -1)
	, [MedewerkerKey]		= COALESCE(m.MedewerkerKey, -1)
	, [SchaalCode]			= COALESCE(s.Schaal_code, '')
	, [Trede]				= COALESCE(s.Trede, 0.0)
	, [IsBovenschools]		= COALESCE(s.Bovenschoolse_functie, 0)
	, [BegindatumSalaris]	= CAST(Begindatum_salaris AS DATE)
	, [EinddatumSalaris]	= CAST(COALESCE(Einddatum_salaris, '99991231') AS DATE)
	, [FunctiePercentage]	= CAST(COALESCE(s.[Parttime_percentage] / 100, 0) AS DECIMAL(5,4))
	, [Salaris]				= CAST(COALESCE(s.Salaris, 0) AS DECIMAL(10,3))


FROM [$(Staging_Quadraam)].[Afas].[DWH_HR_Salarissen] s

LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON s.Medewerker = m.MedewerkerCode
LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON
		m.MedewerkerKey = dv.MedewerkerKey
	AND s.Dienstverband = dv.Dienstverband
	AND s.Volgnummer_contract = dv.ContractVolgnummer

WHERE 1=1
	AND s.Medewerker <> '99999'
	AND TRY_CAST(s.Medewerker AS int) IS NOT NULL

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dienstverband OFF
END CATCH
RETURN 0
END