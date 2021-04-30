CREATE view [metadesk].[vwLookupOperatorGroup] AS
	select distinct [operatorgroup] = COALESCE([operatorgroup], '') from metadesk.vwOverview;
GO