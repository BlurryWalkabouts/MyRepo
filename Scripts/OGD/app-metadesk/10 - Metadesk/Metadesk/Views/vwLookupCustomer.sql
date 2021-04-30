create view [metadesk].[vwLookupCustomer] AS
	select distinct [customer] from metadesk.vwOverview;
GO