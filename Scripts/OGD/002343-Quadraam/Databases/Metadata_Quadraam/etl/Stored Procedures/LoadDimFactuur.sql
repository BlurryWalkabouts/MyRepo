CREATE PROCEDURE [etl].[LoadDimFactuur]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Factuur

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Factuur ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Factuur ([FactuurKey], [FactuurNummer], [FactuurNummerExtern], [FactuurDatum], [FactuurOmschrijving], [FactuurURL])
VALUES
	(-1, 'nvt', '', '99991231', '[Onbekend]', '')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Factuur OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Factuur
	(					
	[FactuurNummer]
	, [FactuurNummerExtern]			
	, [FactuurDatum]					
	, [FactuurOmschrijving]			
	, [FactuurURL]					
	)
SELECT DISTINCT
	[FactuurNummer]			= m.InvoiceId
	, [FactuurNummerExtern] = f.FactuurNummerExtern
	, [FactuurDatum] = f.FactuurDatum
	, [FactuurOmschrijving] = f.FactuurOmschrijving
	, [FactuurURL] = f.FactuurURL
FROM
	[$(Staging_Quadraam)].Afas.DWH_FIN_Mutaties m

	-- Een enkele factuur heeft in AFAS meerdere records. Deze hebben soms meerdere factuurdata. We zijn alleen geinteresseerd in de eerste.
	-- Ook bevatten niet alle records in AFAS de url naar de factuur. We halen met deze apply ook meteen de juiste url op.
	OUTER APPLY (
		SELECT TOP 1
			FactuurNummerExtern = COALESCE(m2.VoucherNo, '')
			, FactuurDatum = COALESCE(TRY_CAST(m2.VoucherDate AS date), '99991231')
			, FactuurOmschrijving = COALESCE(m2.Omschrijving, '')
			, FactuurURL = COALESCE(m2.[Link_naar_factuur], '')
		FROM
			[$(Staging_Quadraam)].Afas.DWH_FIN_Mutaties m2
		WHERE 1=1
			AND m.InvoiceId = m2.InvoiceId
		ORDER BY
			FactuurNummerExtern DESC
			, FactuurDatum
			, FactuurOmschrijving DESC
			, FactuurURL DESC
		) f

WHERE 1=1
	AND m.InvoiceId IS NOT NULL

EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF 
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dagboek OFF
END CATCH
RETURN 0
END