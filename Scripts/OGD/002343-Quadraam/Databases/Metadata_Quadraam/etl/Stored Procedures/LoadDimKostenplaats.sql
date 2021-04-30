CREATE PROCEDURE [etl].[LoadDimKostenplaats]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Kostenplaats

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostenplaats ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Kostenplaats (KostenplaatsKey, KostenplaatsCode, KostenplaatsNaam, BRIN_Nummer, Instelling, VestigingsNummer, LogoURL)
VALUES
	(-1, '', '[Onbekend]', '', '', '', '')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostenplaats OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Kostenplaats
	(
	KostenplaatsCode
	, KostenplaatsNaam
	, BRIN_Nummer
	, Instelling
	, VestigingsNummer
	, LogoURL
	)
SELECT DISTINCT
	KostenplaatsCode = COALESCE(kpl.Nummer, '')
	, KostenplaatsNaam = CASE 
			WHEN kpl.Nummer = '1010006' THEN 'CBQ Kwaliteitszorg (t-m 2017)'
			ELSE COALESCE(kpl.Omschrijving, '') END
	, BRIN_Nummer = CASE 
			WHEN LEN(COALESCE(n2_code, '')) = 4 THEN COALESCE(n2_code, '') 
			WHEN n3_code = '4100001' THEN '08PS'
			WHEN n3_code = '4110001' THEN '12NW' 
			ELSE '' END
	, Instelling = CASE
					WHEN kpl.Nummer = '1010009' THEN 'CBQ'
					WHEN kpl.Nummer = '1010008' THEN 'CBQ'
					WHEN n3_naam = 'Maarten van Rossum' THEN 'Maarten van Rossem'
					WHEN COALESCE(o.n4_code, o.n3_code, -1) IN(5120001,5120002,5120003) THEN 'Quadraam scholen in Elst'
					WHEN kpl.Nummer = '1026131' THEN 'F&V'
					WHEN kpl.Nummer = '1026132' THEN 'F&V'
					WHEN kpl.Nummer = '1026133' THEN 'F&V'
					WHEN kpl.Nummer = '1026134' THEN 'F&V'
					WHEN kpl.Nummer = '6130003' THEN 'Liemers College'
					WHEN kpl.Nummer = '6130004' THEN 'Liemers College'
					WHEN kpl.Nummer = '6130005' THEN 'Liemers College'
					WHEN kpl.Nummer = '6130006' THEN 'Liemers College'
					WHEN kpl.Nummer = '7000000' THEN 'Project Quadraam'
					WHEN o.n4_naam IS NULL THEN o.n2_naam
					WHEN o.n4_naam IS NOT NULL THEN o.n3_naam
					ELSE '' END
	 , VestigingsNummer = CASE
	 	  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2020001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2020002  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'12')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2030001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2040001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'07')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3050001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3060000  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3060001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3060002  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'04')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3080001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'06')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4090001  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4100000  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4100001  THEN '08PS00'
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4110001  THEN '12NW00'
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5100002  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5100003  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5120002  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'04')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5120003  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'11')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130003  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'05')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130004  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'07')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130005  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'01')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130006  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140101  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'00')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140201  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'04')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140301  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'07')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2030003  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'01')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070002  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'11')
		  WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070003  AND LEN(COALESCE(n2_code, '')) = 4 THEN CONCAT(COALESCE(n2_code, ''),'10')
		  ELSE '' END
	, LogoURL = CASE
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = -1	  THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000000 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000001 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000002 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000003 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000004 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000005 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000006 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1000007 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010000 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010001 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010002 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010003 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010004 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010005 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010006 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010007 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010008 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1010009 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1020000 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1022021 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1022022 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1022031 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1022032 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1022041 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1023051 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1023061 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1023071 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1023081 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1023082 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1024101 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1024111 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1025121 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1025131 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1026131 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1026132 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1026133 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1026134 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1027141 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1027142 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 1027143 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2020001 THEN 'https://image.ibb.co/gEVxbw/lorentz.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2020002 THEN 'https://image.ibb.co/n7CzpG/rivers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2020003 THEN 'https://image.ibb.co/gEVxbw/lorentz.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2020004 THEN 'https://image.ibb.co/gEVxbw/lorentz.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2030001 THEN 'https://image.ibb.co/mf0Vww/olympuscollege.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2030002 THEN 'https://image.ibb.co/mf0Vww/olympuscollege.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2030003 THEN 'https://image.ibb.co/mf0Vww/olympuscollege.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 2040001 THEN 'https://image.ibb.co/g9AVww/maartenvanrossem.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3050001 THEN 'https://image.ibb.co/nc6QUG/sga.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3060000 THEN ''
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3060001 THEN 'https://image.ibb.co/fuF8ib/beekdal.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3060002 THEN ''
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070001 THEN 'https://image.ibb.co/bU5xbw/venster.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070002 THEN 'https://image.ibb.co/bU5xbw/venster.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070003 THEN 'https://image.ibb.co/bU5xbw/venster.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3070004 THEN 'https://image.ibb.co/bU5xbw/venster.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3080001 THEN 'https://image.ibb.co/exEqww/montessori.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 3080002 THEN 'https://image.ibb.co/exEqww/montessori.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4090001 THEN ''
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4100000 THEN 'https://image.ibb.co/ibbg3b/quadraam.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4100001 THEN 'https://image.ibb.co/jfPZOb/symbion.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 4110001 THEN 'https://image.ibb.co/kBgEOb/produs.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5100002 THEN ''
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5100003 THEN ''
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5120001 THEN 'https://i.imgur.com/dmtFPwt.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5120002 THEN 'https://image.ibb.co/iZEC9G/westeraam.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 5120003 THEN 'https://image.ibb.co/kET5UG/lyceumelst.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130001 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130002 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130003 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130004 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130005 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130006 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130101 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130201 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130301 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 6130401 THEN 'https://image.ibb.co/hOAKpG/liemers.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140001 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140002 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140003 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140004 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140005 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140101 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140201 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			WHEN COALESCE(o.n4_code, o.n3_code, -1) = 7140301 THEN 'https://image.ibb.co/i0CX9G/candea.png'
			ELSE '' END

FROM [$(Staging_Quadraam)].[Afas].[DWH_FIN_Kostenplaatsen] kpl

LEFT OUTER JOIN [$(Staging_Quadraam)].[Capisci].[Organisatieschema] o ON CAST(COALESCE(o.n4_code, o.n3_code, '') AS nvarchar(255)) = kpl.Nummer

-- WHERE kpl.Geblokkeerd = 0 -- Voorwaarde kan nu niet worden opgenomen omdat in Capisci ten onrechte begroot is op kpl 1010006 (een geblokkeerde kpl in AFAS)

UNION

-- Historische kostenplaatsen vanuit oude Exact administratie
SELECT * FROM (
VALUES  ('1000001', 'CvB - SWV (in-aktief)', '', 'CVB', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1000002', 'CVB - SE Noord (in-aktief)', '', 'CVB', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1000003', 'CVB - SE Zuid (in-aktief)', '', 'CVB', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1000004', 'CVB - SE Pro (in-aktief)', '', 'CVB', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1010000', 'CBQ Algemeen (oud in 2018)', '', 'CBQ', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1010001', 'CBQ Marketing en Communicatie (t-m 2017)', '', 'CBQ', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1010002', 'CBQ Secretariaat en Bode (t-m 2017)', '', 'CBQ', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1010007', 'CBQ Vastgoed & Inkoop (oud in 2018)', '', 'F&V', '', 'https://i.imgur.com/dmtFPwt.png'),
		('1023082', 'loc: Utrechtse weg 74', '', 'F&V', '', 'https://i.imgur.com/dmtFPwt.png'),
		('3060000', '3060000', '', 'Niet van toepassing', '', ''),
		('3060002', '3060002', '', 'Niet van toepassing', '', ''),
		('4100000', 'Pro scholen Algemeen (Oud)', '', 'Pro scholen', '', 'https://image.ibb.co/ibbg3b/quadraam.png'),
		('5100002', '5100002', '', 'Niet van toepassing', '', ''),
		('5100003', '5100003', '', 'Niet van toepassing', '', ''),
		('6130002', 'Boekenfonds/Leermiddelen 16SK', '16SK', 'Liemers College', '', 'https://image.ibb.co/hOAKpG/liemers.png'),
		('6130101', 'Lok: Heerenmaten 16SK', '16SK', 'Liemers College', '16SK00', 'https://image.ibb.co/hOAKpG/liemers.png'),
		('6130201', 'Lok: Landeweer 16SK', '16SK', 'Liemers College', '16SK05', 'https://image.ibb.co/hOAKpG/liemers.png'),
		('6130301', 'Lok: Didam 16SK', '16SK', 'Liemers College', '16SK01', 'https://image.ibb.co/hOAKpG/liemers.png'),
		('6130401', 'Lok: Zonegge 16SK', '16SK', 'Liemers College', '16SK07', 'https://image.ibb.co/hOAKpG/liemers.png'),
		('7140101', 'Lok: Saturnus I 03RR', '03RR', 'Candea College', '03RR00', 'https://image.ibb.co/i0CX9G/candea.png'),
		('7140201', 'Lok: Eltensestraat 03RR', '03RR', 'Candea College', '03RR04', 'https://image.ibb.co/i0CX9G/candea.png'),
		('7140301', 'Lok: Saturnus II 03RR', '03RR', 'Candea College', '03RR07', 'https://image.ibb.co/i0CX9G/candea.png')
		) as x(KostenplaatsCode, KostenplaatsNaam, BRIN_Nummer, Instelling, VestigingsNummer, LogoURL)

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostenplaats OFF
END CATCH
RETURN 0
END