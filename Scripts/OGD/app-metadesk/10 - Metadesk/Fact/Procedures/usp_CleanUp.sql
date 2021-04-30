CREATE PROCEDURE [Fact].[usp_CleanUp]
AS
BEGIN
	-- This stored procedure removes closed tickets from the database.
	-- The views only display the open tickets, so they can be used to remove the closed tickets.
	DELETE FROM Fact.Incident WHERE IncidentNumber NOT IN (SELECT TicketNumber FROM Metadesk.vwIncident)
	DELETE FROM Fact.Change WHERE ChangeNumber NOT IN (SELECT TicketNumber FROM Metadesk.vwChange)
	DELETE FROM Fact.ChangeActivity WHERE ActivityNumber NOT IN (SELECT TicketNumber FROM Metadesk.vwChangeActivity)
	DELETE FROM Fact.Problem WHERE ProblemNumber NOT IN (SELECT TicketNumber FROM Metadesk.vwProblem)
	DELETE FROM Fact.OperationalActivity WHERE OperationalActivityNumber NOT IN (SELECT TicketNumber FROM Metadesk.vwOperationalActivity)
END