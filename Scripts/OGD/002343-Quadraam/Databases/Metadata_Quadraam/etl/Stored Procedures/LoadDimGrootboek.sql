CREATE PROCEDURE [etl].[LoadDimGrootboek]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Grootboek

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Grootboek ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Grootboek (GrootboekKey, GrootboekRekeningCode, GrootboekRekeningNaam)
VALUES
	(-1, -1, '[Onbekend]')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Grootboek OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Grootboek
	(
	GrootboekRekeningCode
	, GrootboekRekeningNaam
	, RekeningType
	, RekeningSubtype
	, Balanszijde
	, CategorieCode
	, CategorieNaam
	, EFJ_HoofdrubriekCode
	, EFJ_HoofdrubriekNaam
	, EFJ_RubriekCode
	, EFJ_RubriekNaam
	, EFJ_SubrubriekCode
	, EFJ_SubrubriekNaam
	, HRM_SubrubriekCode
	, HRM_SubrubriekNaam
	)
SELECT
	GrootboekRekeningCode = COALESCE(LTRIM(RTRIM(gb2.Nummer)), LTRIM(RTRIM(gb1.reknr)))
	, GrootboekRekeningNaam = COALESCE(gb2.Omschrijving, gb1.oms25_0, '')

	, RekeningType = COALESCE(t1.[Description],'')
	, RekeningSubtype = COALESCE(t2.[Description],'')
	, Balanszijde = COALESCE(t3.[Description],'')

	, CategorieCode = COALESCE(gb2.Categoriecode, LEFT(NULLIF(gb1.Class_01,'<none>'),1))
	, CategorieNaam = COALESCE(gb2.Categorienaam, CASE LEFT(NULLIF(gb1.Class_01,0),1)
			WHEN 1 THEN 'Activa'
			WHEN 2 THEN 'Passiva'
			WHEN 3 THEN 'Opbrengsten'
			WHEN 4 THEN 'Kosten'
			WHEN 5 THEN 'Financiële baten en lasten'
			WHEN 9 THEN 'Buitengewoon resultaat'
			WHEN 0 THEN 'Onbekend'
		END, '')

	, EFJ_HoofdrubriekCode	= CASE 
								WHEN gb2.Nummer = '99999' THEN '9'
								ELSE COALESCE(NULLIF(gb1.Class_01,'<none>'), REPLACE(gb2.Hoofdverdichting_code,'.','')) END
	, EFJ_HoofdrubriekNaam	= CASE 
								WHEN COALESCE(gb2.Hoofdrubriek, ac1.Description_0,'') = 'Personele lasten' THEN 'Personeelslasten' 
								WHEN COALESCE(gb2.Hoofdrubriek, ac1.Description_0,'') = 'Overige instellingslasten' THEN 'Overige lasten' 
								ELSE COALESCE(gb2.Hoofdrubriek, ac1.Description_0,'') END
	, EFJ_RubriekCode		= CASE
								WHEN COALESCE(LTRIM(RTRIM(gb2.Nummer)), LTRIM(RTRIM(gb1.reknr))) = 99999 THEN 9
								ELSE COALESCE(NULLIF(gb1.Class_02,'<none>'), REPLACE(gb2.Verdichtingscode_code,'.','')) END
	, EFJ_RubriekNaam		= CASE 
								WHEN COALESCE(gb2.Rubriek, ac2.Description_0,'') = 'Overige huisvesting' THEN 'Overige (huisvestingslasten)'
								WHEN COALESCE(gb2.Rubriek, ac2.Description_0,'') = 'Ouderbijdrage' THEN 'Ouderbijdragen'
								ELSE COALESCE(gb2.Rubriek, ac2.Description_0,'') END
	, EFJ_SubrubriekCode	= NULLIF(gb1.Class_03,'<none>')
	, EFJ_SubrubriekNaam	= NULLIF(ac3.Description_0,'')
	, HRM_SubrubriekCode	= NULLIF(gb1.Class_04,'<none>')
	, HRM_SubrubriekNaam	= NULLIF(ac4.Description_0,'')
FROM
	[$(Exact)].dbo.grtbk gb1
	LEFT OUTER JOIN [$(Exact)].dbo.AccountClasses ac1 ON gb1.Class_01 = ac1.AccountClassCode AND ac1.ClassID = 1
	LEFT OUTER JOIN [$(Exact)].dbo.AccountClasses ac2 ON gb1.Class_02 = ac2.AccountClassCode AND ac2.ClassID = 2
	LEFT OUTER JOIN [$(Exact)].dbo.AccountClasses ac3 ON gb1.Class_03 = ac3.AccountClassCode AND ac3.ClassID = 3
	LEFT OUTER JOIN [$(Exact)].dbo.AccountClasses ac4 ON gb1.Class_04 = ac4.AccountClassCode AND ac4.ClassID = 4
	LEFT OUTER JOIN [$(Exact)].dbo.DDTests t1 ON gb1.bal_vw = t1.DatabaseChar AND t1.Tablename = 'grtbk' AND t1.FieldName = 'bal_vw'
	LEFT OUTER JOIN [$(Exact)].dbo.DDTests t2 ON gb1.omzrek = t2.DatabaseChar AND t2.Tablename = 'grtbk' AND t2.FieldName = 'omzrek'
	LEFT OUTER JOIN [$(Exact)].dbo.DDTests t3 ON gb1.debcrd = t3.DatabaseChar AND t3.Tablename = 'grtbk' AND t3.FieldName = 'debcrd'
	FULL OUTER JOIN [$(Staging_Quadraam)].Afas.DWH_FIN_Grootboek gb2 ON LTRIM(RTRIM(gb1.reknr)) = LTRIM(RTRIM(gb2.Nummer))

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Grootboek OFF
END CATCH
RETURN 0
END