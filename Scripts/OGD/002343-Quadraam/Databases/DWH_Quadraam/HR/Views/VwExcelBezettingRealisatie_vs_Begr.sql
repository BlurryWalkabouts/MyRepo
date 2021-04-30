CREATE VIEW [HR].[VwExcelBezettingRealisatie_vs_Begr]
AS

SELECT
	KostenplaatsCode
	, KostenplaatsNaam
	, MedewerkerCode
	, MedewerkerNaam
	, JaarNum
	, MaandNum
	, [Source] = 1
	, Bruto_FTE = FTE_Bruto
	, Dienstbetrekking
	, AFD = LEFT(KostenplaatsCode,3)
	, VervangtMedewerkerNaam
	, FunctieOmschrijving
	, FunctieType
	, FTE_BAPO
	, FTE_Spaar_BAPO
	, FTE_Detachering
	, FTE_Spaarverlof
	, FTE_Ouderschapsverlof
	, FTE_Zwangerschapsverlof
	, FTE_Onbetaald_Verlof
	, FTE_TU
	, Realkst = SaldoWerkgeverskosten
	, Budgkst = 0
FROM
	HR.VwExcelBezettingRealisatie_maandv2

UNION ALL

SELECT
	KostenplaatsCode
	, KostenplaatsNaam
	, MedewerkerCode
	, MedewerkerNaam
	, JaarNum
	, MaandNum
	, [Source] = 0
	, Bruto_FTE = BegroteFTE_bruto
	, Dienstbetrekking
	, AFD = LEFT(KostenplaatsCode,3)
	, VervangtMedewerkerNaam = ''
	, FunctieOmschrijving
	, FunctieType
	, FTE_Bapo = 0
	, FTE_Spaar_BAPO = 0
	, FTE_Detachering = 0
	, FTE_Spaarverlof = 0
	, FTE_Ouderschapsverlof = 0
	, FTE_Zwangerschapsverlof = 0
	, FTE_Onbetaald_Verlof = 0
	, FTU_TU = 0
	, Realkst = 0
	, Budgkst = LoonkostenBudget
FROM
	Fin.VwExcelBezettingBegroot_maand