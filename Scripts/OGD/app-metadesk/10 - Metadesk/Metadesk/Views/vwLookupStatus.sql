create view [metadesk].[vwLookupStatus] AS
	select distinct [Status] from metadesk.vwOverview;
GO