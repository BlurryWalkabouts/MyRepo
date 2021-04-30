/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view Dim.vwTelefoniestoringen as

-- StartDatum en EindDatum retourneren nu NULL. Dit zou nog gefixed moeten worden, maar als het goed is wordt deze view overbodig.
SELECT
	Code
	, [Name]
	, Classificatie_Name
	, Oorzaak_Name
	, StartDatum = NULL
	, EindDatum = NULL
	, [Start]
	, Eind
FROM
	Fact.Telefoniestoringen
/*
SELECT 
      [Code]
      ,[Name]
      ,[Classificatie_Name]
      ,[Oorzaak_Name]
	  ,[StartDatum]
	  ,[EindDatum]
      ,Dateadd(Minute,Datepart(minute,cast(Starttijd as time)),DATEADD(Hour,Datepart(hour,cast(Starttijd as time)),StartDatum)) as Start --Gedaan om de velden Startdatum en Starttijd samen te voegen , MDS ondersteund geen datumtijd veld
      ,Dateadd(Minute,Datepart(minute,cast(Eindtijd as time)),DATEADD(Hour,Datepart(hour,cast(EindTijd as time)),EindDatum)) as Eind --Gedaan om de velden Startdatum en Starttijd samen te voegen , MDS ondersteund geen datumtijd veld

  FROM [$(MDS)].[mdm].[DimTelefonieStoringen]
*/


