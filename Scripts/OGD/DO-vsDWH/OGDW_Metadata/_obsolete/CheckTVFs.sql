CREATE PROCEDURE [monitoring].[CheckTVFs]
AS

BEGIN

SELECT TOP 0 * FROM [$(OGDW_Staging)].TOPdesk.tvfChange(1,445)
SELECT TOP 0 * FROM [$(OGDW_Staging)].TOPdesk.tvfChangeActivity(1,445)
SELECT TOP 0 * FROM [$(OGDW_Staging)].TOPdesk.tvfIncident(1,445)
--SELECT TOP 0 * FROM [$(OGDW_Staging)].TOPdesk.tvfObject(1,445) -- tvfObject moet nog eerst gefixt worden.
SELECT TOP 0 * FROM [$(OGDW_Staging)].TOPdesk.tvfProbleem(1,445)

END