CREATE VIEW [HR].[AOWUitstroom]
AS

SELECT DISTINCT
	KostenplaatsKey = kpl.KostenplaatsKey
	, MedewerkerKey = m.MedewerkerKey
	, MedewerkerCode = CAST(m.MedewerkerCode AS int)
	, MedewerkerNaam = m.MedewerkerNaam
	, Geboortedatum = m.Geboortedatum
	, Geslacht = m.Geslacht
	, Instelling = kpl.Instelling
	, KostenplaatsNaam = kpl.KostenplaatsNaam
	, FunctieType = f.FunctieType
	, FunctieOmschrijving = f.FunctieOmschrijving
	, [Dienstjaren Quadraam] = ROUND(DATEDIFF(YY, m.DatumInDienst, GETDATE()),0)
	, Dienstbetrekking = dv.Dienstbetrekking
	, DatumInDienst = CAST(MIN(m.DatumInDienst) AS date)
	, DatumInDienstIvmSignalering = CAST(COALESCE(m.DatumInDienstIvmSignalering, '99991231') AS date)
	, DatumInDienstInclRechtsvoorganger = CAST(COALESCE(m.DatumInDienstInclRechtsvoorganger, '99991231') AS date)
	, DatumUitDienst = CAST(MAX(COALESCE(m.DatumUitDienst, '99991231')) AS date)
	, AOWleeftijd = COALESCE(CASE
			WHEN m.Geboortedatum >= '1956-10-01' THEN '67jr 03 mnd'
			WHEN m.Geboortedatum BETWEEN '1955-09-30' AND '1956-10-01' THEN '67jr 03 mnd'
			WHEN m.Geboortedatum BETWEEN '1954-12-31' AND '1955-10-01' THEN '67jr 03 mnd'
			WHEN m.Geboortedatum BETWEEN '1954-04-30' AND '1955-01-01' THEN '67jr'
			WHEN m.Geboortedatum BETWEEN '1953-08-31' AND '1954-05-01' THEN '66jr 08mnd'
			WHEN m.Geboortedatum BETWEEN '1952-12-31' AND '1953-09-01' THEN '66jr 04mnd'
			WHEN m.Geboortedatum BETWEEN '1952-03-31' AND '1953-01-01' THEN '66jr'
			WHEN m.Geboortedatum BETWEEN '1951-06-30' AND '1952-04-01' THEN '65jr 09mnd'
			WHEN m.Geboortedatum BETWEEN '1950-09-30' AND '1951-07-01' THEN '65jr 06mnd'
			WHEN m.Geboortedatum BETWEEN '1949-10-31' AND '1950-10-01' THEN '65jr 03mnd'
			WHEN m.Geboortedatum BETWEEN '1948-11-30' AND '1949-11-01' THEN '65jr 02mnd'
			WHEN m.Geboortedatum BETWEEN '1947-12-31' AND '1948-12-01' THEN '65jr 01mnd'
			WHEN m.Geboortedatum < '1948-01-01' THEN '65jr'
			ELSE 'abc'
		END, '')
	, AOWdatum = DATEADD(MM, COALESCE(CASE
			WHEN m.Geboortedatum >= '1956-10-01' THEN 807
			WHEN m.Geboortedatum BETWEEN '1955-09-30' AND '1956-10-01' THEN 807
			WHEN m.Geboortedatum BETWEEN '1954-12-31' AND '1955-10-01' THEN 807
			WHEN m.Geboortedatum BETWEEN '1954-04-30' AND '1955-01-01' THEN 803
			WHEN m.Geboortedatum BETWEEN '1953-08-31' AND '1954-05-01' THEN 800
			WHEN m.Geboortedatum BETWEEN '1952-12-31' AND '1953-09-01' THEN 796
			WHEN m.Geboortedatum BETWEEN '1952-03-31' AND '1953-01-01' THEN 792
			WHEN m.Geboortedatum BETWEEN '1951-06-30' AND '1952-04-01' THEN 789
			WHEN m.Geboortedatum BETWEEN '1950-09-30' AND '1951-07-01' THEN 786
			WHEN m.Geboortedatum BETWEEN '1949-10-31' AND '1950-10-01' THEN 783
			WHEN m.Geboortedatum BETWEEN '1948-11-30' AND '1949-11-01' THEN 782
			WHEN m.Geboortedatum BETWEEN '1947-12-31' AND '1948-12-01' THEN 781
			WHEN m.Geboortedatum < '1948-01-01' THEN 780
			ELSE 'abc'
		END, ''), m.Geboortedatum)
	, Leeftijd = FLOOR(DATEDIFF(DD, m.Geboortedatum, GETDATE()) / 365.25)
	, FTE_Bruto = fte.FTE_Bruto
	, FunctieKey = fte.FunctieKey

-- https://www.belastingdienst.nl/wps/wcm/connect/bldcontentnl/belastingdienst/prive/werk_en_inkomen/pensioen_en_andere_uitkeringen/wanneer_bereikt_u_de_aow_leeftijd/wanneer_bereikt_u_de_aow_leeftijd

FROM
	Dim.Functie f
	LEFT OUTER JOIN Dim.Medewerker m ON f.MedewerkerKey = m.MedewerkerKey
	LEFT OUTER JOIN Dim.Kostenplaats kpl ON f.KostenplaatsKey = kpl.KostenplaatsKey
	LEFT OUTER JOIN Dim.Dienstverband dv ON f.DienstverbandKey = dv.DienstverbandKey
	LEFT OUTER JOIN Fact.FTE fte ON f.FunctieKey = fte.FunctieKey AND fte.MaandKey = FORMAT(GETDATE(), 'yyyyMM')
WHERE 1=1
	AND FORMAT(f.EinddatumFunctie, 'yyyyMM') >= FORMAT(getdate(), 'yyyyMM') -- > GETDATE() -- functie tabel filteren op alleen actieve functies (o.b.v. einddatum functie en huidige datum)
	AND m.MedewerkerCode <> '99999'
	AND m.MedewerkerCode <> '-1'
	AND TRY_CAST(m.MedewerkerCode AS int) IS NOT NULL
GROUP BY
	kpl.KostenplaatsKey
	, m.MedewerkerKey
	, m.MedewerkerCode
	, m.MedewerkerNaam
	, m.Geboortedatum
	, m.Geslacht
	, kpl.Instelling
	, kpl.KostenplaatsNaam
	, f.FunctieType
	, f.FunctieOmschrijving
	, m.DatumInDienst
	, dv.Dienstbetrekking
	, m.DatumInDienstIvmSignalering
	, m.DatumInDienstInclRechtsvoorganger
	, m.DatumUitDienst
	, fte.FTE_Bruto
	, fte.FunctieKey