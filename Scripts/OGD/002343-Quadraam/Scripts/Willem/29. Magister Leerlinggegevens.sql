USE Metadata_Quadraam
GO

DECLARE @SQLString nvarchar(max)

SELECT
	@SQLString = '
CREATE TABLE
	[Staging_Quadraam].' + t.TABLE_SCHEMA + '.' + t.TABLE_NAME + '
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' ' + c.DATA_TYPE + ' NULL'
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumnDefinitions + '
	)
	
INSERT INTO
	[Staging_Quadraam].' + t.TABLE_SCHEMA + '.' + t.TABLE_NAME + '
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumns + '
	)
SELECT
	' + STUFF((
		SELECT char(10) + char(9) + ', [' + c.COLUMN_NAME + '] = ' + CASE c.DATA_TYPE
			WHEN 'bit' THEN 'CAST(NULLIF(p.value(''' + c.OriginalColumnName + '[1]'',''varchar(5)''),'''') AS ' + c.DATA_TYPE + ')'
			WHEN 'date' THEN 'p.value(''' + c.OriginalColumnName + '[1]'',''' + c.DATA_TYPE + ''')'
			ELSE 'NULLIF(p.value(''' + c.OriginalColumnName + '[1]'',''' + c.DATA_TYPE + '''),'''')'
		END
		FROM setup.vwMetadataColumns c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + t.ExtraColumns + '
FROM
	[Staging_Quadraam].setup.DataObjects j
	CROSS APPLY XMLData.nodes(''/Leerlingen/Leerling'') R(p)
WHERE 1=1
	AND j.DataSource = ''' + t.TABLE_SCHEMA + '''
	AND j.ContentType = ''Data''
	AND j.Connector LIKE ''' + t.Connector + '''' + char(10)
FROM
	setup.vwMetadataTables t
WHERE 1=1
	AND t.TABLE_SCHEMA LIKE 'Magister'
	AND t.TABLE_NAME LIKE 'leerlinggegevens'
	AND t.CREATE_SELECT = 'CREATE'

EXEC (@SQLString)

SELECT
	', [' + ColumnName + '] = ' + CASE DataType
			WHEN 'bit' THEN 'CAST(NULLIF(p.value(''' + OriginalColumnName + '[1]'',''varchar(5)''),'''') AS ' + DataType + ')'
			WHEN 'date' THEN 'p.value(''' + OriginalColumnName + '[1]'',''' + DataType + ''')'
			ELSE 'NULLIF(p.value(''' + OriginalColumnName + '[1]'',''' + DataType + '''),'''')'
		END
FROM
	Metadata_Quadraam.setup.CustomMetadata
ORDER BY
	OrdinalPosition

SELECT
	[DatumEersteAanmelding] = p.value('datum1eaanmelding[1]','date')
	, [Stamnummer] = NULLIF(p.value('Stamnr[1]','char(6)'),'')
	, [ExterneUitstromer] = CAST(NULLIF(p.value('Aanmelding.Externe_uitstromer[1]','varchar(5)'),'') AS bit)
	, [ExterneInstromer] = CAST(NULLIF(p.value('Aanmelding.Externe_instromer[1]','varchar(5)'),'') AS bit)
	, [Zittenblijver] = CAST(NULLIF(p.value('Aanmelding.Zittenblijver[1]','varchar(5)'),'') AS bit)
	, [NietMeetellenMetOfficieleTellingen] = CAST(NULLIF(p.value('Aanmelding.Niet_meetellen_met_officile_tellingen[1]','varchar(5)'),'') AS bit)
	, [BerekendeIltCode] = NULLIF(p.value('Aanmelding.Iltberek[1]','varchar(4)'),'')
	, [LWOO_indicatie] = CAST(NULLIF(p.value('Aanmelding.LWOOindicatie[1]','varchar(5)'),'') AS bit)
	, [PRO_indicatie] = CAST(NULLIF(p.value('Aanmelding.PRO_indicatie[1]','varchar(5)'),'') AS bit)
	, [Einddatum] = p.value('Aanmelding.Einddatum[1]','date')
	, [Vertrekdatum] = p.value('Aanmelding.Vertrekdatum[1]','date')
	, [Begindatum] = p.value('Aanmelding.Begindatum[1]','date')
	, [VertrekredenVSV] = CAST(NULLIF(p.value('Vertrekreden.VSV[1]','varchar(5)'),'') AS bit)
	, [Klas] = NULLIF(p.value('Klas[1]','varchar(12)'),'')
	, [Vertrekreden] = NULLIF(p.value('Vertrekreden.Omschrijving[1]','varchar(30)'),'')
	, [Vooropleiding] = NULLIF(p.value('Vooropleiding.Omschrijving[1]','varchar(1)'),'')
	, [Studie] = NULLIF(p.value('Studie[1]','varchar(16)'),'')
	, [Leerjaar] = NULLIF(p.value('Leerfase.Leerjaar[1]','varchar(1)'),'')
	, [LesperiodeOmschrijving] = NULLIF(p.value('Lesperiode.Korte_omschrijving[1]','varchar(1)'),'')
	, [BRINnummer] = NULLIF(p.value('Administratieve_eenheid.BRIN[1]','varchar(4)'),'')
	, [CodeNevenvestiging] = NULLIF(p.value('Administratieve_eenheid.Officile_code_nevenvestiging[1]','varchar(2)'),'')
	, [Basisschool] = NULLIF(p.value('sis_rsch0.sis_rsch0.sis_rsch0__naam[1]','varchar(45)'),'')
	, [Bevorderingsresultaat] = NULLIF(p.value('sis_bvrd0.sis_bvrd0.sis_bvrd0__omschr[1]','varchar(15)'),'')
	, [BehaaldBevorderingsresultaat] = CAST(NULLIF(p.value('sis_bvrd0.sis_bvrd0.sis_bvrd0__behaald[1]','varchar(5)'),'') AS bit)
	, [Relatieschooltype] = NULLIF(p.value('Relatieschooltype.Omschrijving[1]','varchar(29)'),'')
	, [OnderwijssoortVorigeOpleidingOmschrijving] = NULLIF(p.value('sis_blpe0.sis_blpe0.sis_blpe0__omschr_k[1]','varchar(1)'),'')
	, [OnderwijssoortOmschrijving] = NULLIF(p.value('Onderwijssoort.Omschrijving[1]','varchar(20)'),'')
	, [OnderwijssoortCode] = NULLIF(p.value('Onderwijssoort.Code[1]','varchar(2)'),'')
/*
	, [Aanmelding.Aanmelding.sis_aanm__idAanm] = NULLIF(p.value('Aanmelding.Aanmelding.sis_aanm__idAanm[1]','varchar(5)'),'')
	, [Vertrekreden.Vertrekreden.sis_bvrt__idBvrt] = NULLIF(p.value('Vertrekreden.Vertrekreden.sis_bvrt__idBvrt[1]','varchar(8)'),'')
	, [Klas.Klas.sis_bgrp__idBgrp] = NULLIF(p.value('Klas.Klas.sis_bgrp__idBgrp[1]','varchar(5)'),'')
	, Leerling_vooropleiding.Leerling_vooropleiding.llvooropleiding__idLlvooropleiding
	, Vooropleiding.Vooropleiding.vooropleiding__idVooropleiding
	, [Studie.Studie.sis_stud__idStud] = NULLIF(p.value('Studie.Studie.sis_stud__idStud[1]','varchar(4)'),'')
	, [Leerfase.Leerfase.sis_blfa__idBlfa] = NULLIF(p.value('Leerfase.Leerfase.sis_blfa__idBlfa[1]','varchar(3)'),'')
	, Lesperiode.Lesperiode.sis_blpe__idBlpe
	, [Administratieve_eenheid.Administratieve_eenheid.sis_blok__idBlok] = NULLIF(p.value('Administratieve_eenheid.Administratieve_eenheid.sis_blok__idBlok[1]','varchar(2)'),'')
	, [sis_rsch0.sis_rsch0.sis_rsch0__idRsch] = NULLIF(p.value('sis_rsch0.sis_rsch0.sis_rsch0__idRsch[1]','char(6)'),'')
	, [sis_bvrd0.sis_bvrd0.sis_bvrd0__idBvrd] = NULLIF(p.value('sis_bvrd0.sis_bvrd0.sis_bvrd0__idBvrd[1]','varchar(4)'),'')
	, Relatieschooltype.Relatieschooltype.sis_rtyp__idRtyp
	, [RVCaanvraag.RVCaanvraag.leerrvc__idLeerrvc] = NULLIF(p.value('RVCaanvraag.RVCaanvraag.leerrvc__idLeerrvc[1]','varchar(64)'),'')
	, [sis_blpe0.sis_blpe0.sis_blpe0__idBlpe] = NULLIF(p.value('sis_blpe0.sis_blpe0.sis_blpe0__idBlpe[1]','varchar(1)'),'')
	, [sis_bins0.sis_bins0.sis_bins0__idBins] = NULLIF(p.value('sis_bins0.sis_bins0.sis_bins0__idBins[1]','varchar(4)'),'')
	, [Onderwijssoort.Onderwijssoort.onderwijssoort__idOnderwijssoort] = NULLIF(p.value('Onderwijssoort.Onderwijssoort.onderwijssoort__idOnderwijssoort[1]','varchar(1)'),'')

--	, [Vooropleiding] = NULLIF(p.value('Leerling_vooropleiding.IBGvooropleiding[1]','varchar(100)'),'') --*
--	, [ZoeknaamBasisschool] = NULLIF(p.value('sis_rsch0.sis_rsch0.sis_rsch0__zoeknaam[1]','varchar(43)'),'') --*
--	, [OnderwijssoortVorigeOpleiding] = NULLIF(p.value('sis_prof0.sis_prof0.sis_prof0__omschr[1]','varchar(15)'),'') --*
--	, [VertrekredenOfficieelInschrijving] = NULLIF(p.value('hrnvertrekreden0.hrnvertrekreden0.hrnvertrekreden0__Omschr[1]','varchar(15)'),'') --*
--	, Inschrijving.Inschrijving.inschrijving__idInschrijving
--	, sis_prof0.sis_prof0.sis_prof0__idProf
*/
--INTO
--	Magister.leerlinggegevens
FROM
	Staging_Quadraam.setup.DataObjects
	CROSS APPLY XMLData.nodes('/Leerlingen/Leerling') R(p)
WHERE 1=1
	AND DataSource = 'Magister'

SELECT
	Begindatum
	, Einddatum
	, Vertrekdatum
	, BerekendeIltCode
	, ExterneInstromer
	, ExterneUitstromer
	, LWOO_indicatie
	, NietMeetellenMetOfficieleTellingen
	, PRO_indicatie
	, Zittenblijver
	, BRINnummer = COALESCE(BRINnummer,BRINnummer2)
	, CodeNevenvestiging
	, DatumEersteAanmelding
	, Klas
	, Leerjaar
	, LesperiodeOmschrijving
	, TypeVervolgschool
	, BehaaldBevorderingsresultaat
	, Bevorderingsresultaat
	, Basisschool
	, Stamnummer
	, Studie
	, Vertrekreden
	, VertrekredenVSV
	, Vooropleiding
	, LocatieOmschrijving
	, TypeBasisschool
	, TypeVorigeschool
	, LocatieCode
FROM
	Staging_Quadraam.Magister.leerlinggegevens
WHERE 1=1
	AND DatumEersteAanmelding > '2013-12-31'
	AND Stamnummer = 26018
ORDER BY
	BRINnummer