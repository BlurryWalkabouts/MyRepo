CREATE PROCEDURE [etl].[LoadDimDatum]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Datum

SET XACT_ABORT ON

INSERT INTO
	[$(DWH_Quadraam)].Dim.Datum (DatumKey, MaandKey, JaarKey, Datum, JaarNum, MaandNum, MaandNaam, MaandNaamKort, DagNum, DagNaam, DagNaamKort, WeekNum, Feestdag, Schoolvakantie)
VALUES
	(-1, -1, -1, '19000101', 1900, 1, 'januari', 'jan', 1, 'maandag', 'ma', 1, 0, 0)

SET DATEFIRST 1

DECLARE @StartDate date = DATEFROMPARTS(2005/*YEAR((SELECT MIN(docdate) FROM [$(Exact)].dbo.gbkmut))*/,1,1)
DECLARE @EndDate date = DATEADD(YY,5,DATEFROMPARTS(YEAR(GETUTCDATE()),12,31))

;WITH Datums AS 
(
SELECT
	Datum = @StartDate
UNION ALL
SELECT
	Datum = DATEADD(DD,1,Datum)
FROM
	Datums
WHERE
	Datum < @EndDate
)

--SELECT * FROM Datums

INSERT INTO
	[$(DWH_Quadraam)].Dim.Datum
	(
	DatumKey
	, MaandKey
	, JaarKey
	, Datum
	, JaarNum
	, MaandNum
	, MaandNaam
	, MaandNaamKort
	, DagNum
	, DagNaam
	, DagNaamKort
	, WeekNum
	, Feestdag
	, Schoolvakantie
	)
SELECT
	DatumKey = CAST(CAST(YEAR(Datum) AS nvarchar) + RIGHT('0' + CAST(MONTH(Datum) AS nvarchar), 2) + RIGHT('0' + CAST(DAY(Datum) AS nvarchar), 2) AS int)
	, MaandKey = CAST(YEAR(Datum) AS nvarchar) + CASE WHEN MONTH(Datum) > 9 THEN CAST(MONTH(Datum) AS nvarchar) ELSE '0' + CAST(MONTH(Datum) AS nvarchar) END
	, JaarKey = YEAR(Datum)
	, Datum
	, JaarNum = YEAR(Datum)
--	, KwartaalJaar = CEILING((MONTH(Datum)+2)/3)
	, MaandNum = MONTH(Datum)
	, MaandNaam = CASE MONTH(Datum)
			WHEN 1 THEN 'januari'
			WHEN 2 THEN 'februari'
			WHEN 3 THEN 'maart'
			WHEN 4 THEN 'april'
			WHEN 5 THEN 'mei'
			WHEN 6 THEN 'juni'
			WHEN 7 THEN 'juli'
			WHEN 8 THEN 'augustus'
			WHEN 9 THEN 'september'
			WHEN 10 THEN 'oktober'
			WHEN 11 THEN 'november'
			WHEN 12 THEN 'december'
		END
	, MaandNaamKort = CASE MONTH(Datum)
			WHEN 1 THEN 'jan'
			WHEN 2 THEN 'feb'
			WHEN 3 THEN 'mrt'
			WHEN 4 THEN 'apr'
			WHEN 5 THEN 'mei'
			WHEN 6 THEN 'jun'
			WHEN 7 THEN 'jul'
			WHEN 8 THEN 'aug'
			WHEN 9 THEN 'sep'
			WHEN 10 THEN 'okt'
			WHEN 11 THEN 'nov'
			WHEN 12 THEN 'dec'
		END
--	, DagJaar = DATEPART(DAYOFYEAR,Datum)
	, DagNum = DAY(Datum)
--	, DagWeek = DATEPART(DW,Datum)
	, DagNaam = CASE DATEPART(DW,Datum)
			WHEN 1 THEN 'maandag'
			WHEN 2 THEN 'dinsdag'
			WHEN 3 THEN 'woensdag'
			WHEN 4 THEN 'donderdag'
			WHEN 5 THEN 'vrijdag'
			WHEN 6 THEN 'zaterdag'
			WHEN 7 THEN 'zondag'
		END
	, DagNaamKort = CASE DATEPART(DW,Datum)
			WHEN 1 THEN 'ma'
			WHEN 2 THEN 'di'
			WHEN 3 THEN 'wo'
			WHEN 4 THEN 'do'
			WHEN 5 THEN 'vr'
			WHEN 6 THEN 'za'
			WHEN 7 THEN 'zo'
		END
/*
	, WeekJaar = DATEPART(WW,Datum)
	, WeekJaarStartDatum = CASE DATEPART(DW,Datum)
			WHEN 1 THEN DATEADD(DD,0,Datum)
			WHEN 2 THEN DATEADD(DD,-1,Datum)
			WHEN 3 THEN DATEADD(DD,-2,Datum)
			WHEN 4 THEN DATEADD(DD,-3,Datum)
			WHEN 5 THEN DATEADD(DD,-4,Datum)
			WHEN 6 THEN DATEADD(DD,-5,Datum)
			WHEN 7 THEN DATEADD(DD,-6,Datum)
		END
	, WeekJaarStartJaar = CASE DATEPART(DW,Datum)
			WHEN 1 THEN YEAR(DATEADD(DD,0,Datum))
			WHEN 2 THEN YEAR(DATEADD(DD,-1,Datum))
			WHEN 3 THEN YEAR(DATEADD(DD,-2,Datum))
			WHEN 4 THEN YEAR(DATEADD(DD,-3,Datum))
			WHEN 5 THEN YEAR(DATEADD(DD,-4,Datum))
			WHEN 6 THEN YEAR(DATEADD(DD,-5,Datum))
			WHEN 7 THEN YEAR(DATEADD(DD,-6,Datum))
		END
*/
	, WeekNum = (DATEDIFF(DD,CASE
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0))))/7)*7,-53690) <= Datum THEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0))))/7)*7,-53690)
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0)))/7)*7,-53690) <= Datum THEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0)))/7)*7,-53690)
			ELSE DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,-1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0))))/7)*7,-53690)
		END, Datum)/7) + 1
/*
	, WeekNrJaar = CASE
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(YY,1,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0))))/7)*7,-53690) <= Datum THEN YEAR(Datum) + 1
			WHEN DATEADD(DD,(DATEDIFF(DD,-53690,DATEADD(DD,3,DATEADD(YY,DATEDIFF(YY,0,Datum),0)))/7)*7,-53690) <= Datum THEN YEAR(Datum)
			ELSE YEAR(Datum) - 1
		END
*/
	, Feestdag = 0
	, Schoolvakantie = 0
FROM
	Datums
OPTION (MAXRECURSION 0)

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
END CATCH

RETURN 0
END