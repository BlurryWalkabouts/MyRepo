CREATE PROCEDURE [etl].[LoadFactSalarissen]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Fact.Salarissen

SET XACT_ABORT ON

INSERT INTO
	[$(DWH_Quadraam)].Fact.Salarissen
	(
	FunctieKey
	, DienstverbandKey
	, MedewerkerKey
	, KostenplaatsKey
	, KostendragerKey
	, Volgnummer_contract
	, Schaal_code
	, Schaal
	, Parttime_percentage
	, Werkgever
	, Medewerker
	, Cao
	, Begindatum_salaris
	, Einddatum_salaris
	, Volgnummer_dienstverband
	, Trede
	, Dienstverband
	, Salaris
	, Caotype
	, Omschrijving
	, Soort_onderwijs_code
	, Soort_onderwijs
	, Bovenschoolse_functie
	, Meenemen_in_GGL_PO		
	)
SELECT
	FunctieKey = COALESCE(f.FunctieKey, -1)
	, DienstverbandKey = COALESCE(dv.DienstverbandKey, -1)
	, MedewerkerKey = COALESCE(m.MedewerkerKey, -1)
	, KostenplaatsKey = COALESCE(f.KostenplaatsKey, -1)
	, KostendragerKey = COALESCE(f.KostendragerKey, -1)
	, s.Volgnummer_contract
	, s.Schaal_code
	, s.Schaal
	, s.Parttime_percentage
	, s.Werkgever
	, s.Medewerker
	, s.Cao
	, s.Begindatum_salaris
	, Einddatum_salaris = CASE WHEN s.Einddatum_salaris IS NULL THEN CAST('9999-12-31' AS date) ELSE s.Einddatum_salaris END
	, s.Volgnummer_dienstverband
	, s.Trede
	, s.Dienstverband
	, Salaris = s.Salaris * f.FunctiePercentage
	, s.Caotype
	, s.Omschrijving
	, s.Soort_onderwijs_code
	, s.Soort_onderwijs
	, s.Bovenschoolse_functie
	, s.Meenemen_in_GGL_PO
FROM
	[$(Staging_Quadraam)].Afas.DWH_HR_Salarissen s
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Medewerker m ON s.Medewerker = m.MedewerkerCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Dienstverband dv ON 1=1
		AND m.MedewerkerKey = dv.MedewerkerKey
		AND dv.Dienstverband = s.Dienstverband
		AND s.Begindatum_salaris >= dv.BegindatumContract
		AND CASE WHEN s.Einddatum_salaris IS NULL THEN CAST('9999-12-31' AS date) ELSE [Einddatum_salaris] END <= dv.EinddatumContract
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Functie f ON 1=1
		AND m.MedewerkerKey = f.MedewerkerKey
		AND dv.DienstverbandKey = f.DienstverbandKey
		AND s.Begindatum_salaris >= f.BegindatumFunctie
		AND CASE WHEN s.Einddatum_salaris IS NULL THEN CAST('9999-12-31' AS date) ELSE [Einddatum_salaris] END <= f.EinddatumFunctie
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats k ON f.KostenplaatsKey = k.KostenplaatsKey
WHERE 1=1
	AND s.Medewerker <> 'WF01'
	AND s.Medewerker <> '99999'

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Fact.LeerlingaantalBegroot OFF
END CATCH
RETURN 0
END