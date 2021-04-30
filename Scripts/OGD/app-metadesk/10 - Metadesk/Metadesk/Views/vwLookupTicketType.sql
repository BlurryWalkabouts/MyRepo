create view [metadesk].[vwLookupTicketType] AS
	select distinct [TicketType] from metadesk.vwOverview;
GO