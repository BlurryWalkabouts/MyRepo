CREATE view [metadesk].[vwLookupOperator] AS
	select distinct [operator] = COALESCE([operator], '') from metadesk.vwOverview;
GO