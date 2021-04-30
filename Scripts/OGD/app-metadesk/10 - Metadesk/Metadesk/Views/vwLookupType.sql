create view [metadesk].[vwLookupType] AS
	select distinct [type] from metadesk.vwOverview;
GO