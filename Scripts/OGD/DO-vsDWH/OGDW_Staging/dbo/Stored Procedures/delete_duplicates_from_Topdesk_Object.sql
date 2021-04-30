-- SELECT TOP 0 * INTO TOPdesk.object_zonder_dubbele_regels FROM TOPdesk.[object]

-- DECLARE @AuditDWKey int = 5432
-- DECLARE @DWPrevKey int = 0
-- SELECT * INTO TOPdesk.object_backup20160126 FROM TOPdesk.[object]

CREATE PROCEDURE [dbo].[delete_duplicates_from_Topdesk_Object]
(
	@AuditDWKey int = 5439
)
AS

DECLARE @SourceDatabaseKey int
SELECT @SourceDatabaseKey FROM OGDW_Metadata.[log].[Audit] WHERE AuditDWKey = @AuditDWKey

WITH NewLines AS
(
SELECT
	ref_aanspreekpuntid
	, ref_budgethouderid
	, ref_configuratieid
	, ref_groepid
	, ref_leverancier
	, ref_licentiesoortid
	, ref_plaats
	, ref_soort
	, ref_vestiging
	, statusid
	, [type]
	, unid
	, ref_ordernummer
	, ref_leasecontractnummer
	, ref_leaseperiode
	, ref_persoongroep
	, ref_aanschafdatum
	, ref_leaseaanvangsdatum
	, ref_leaseeinddatum
	, ref_aankoopbedrag
	, ref_leaseprijs
	, ref_restwaarde
	, ref_hostnaam
	, ref_ipadres
	, ref_type
	, ref_specificatie
	, ref_attentieid
	, ref_opmerking
	, ref_gebruiker
	, ref_persoon
	, ref_naam
	, ref_lokatie
	, ref_serienummer
--	, AuditDWKey
	, SourceDatabaseKey
--	, RN
FROM
	TOPdesk.[object] o1
WHERE 1=1
	AND AuditDWKey = @AuditDWKey
EXCEPT
SELECT
	ref_aanspreekpuntid
	, ref_budgethouderid
	, ref_configuratieid
	, ref_groepid
	, ref_leverancier
	, ref_licentiesoortid
	, ref_plaats
	, ref_soort
	, ref_vestiging
	, statusid
	, [type]
	, unid
	, ref_ordernummer
	, ref_leasecontractnummer
	, ref_leaseperiode
	, ref_persoongroep
	, ref_aanschafdatum
	, ref_leaseaanvangsdatum
	, ref_leaseeinddatum
	, ref_aankoopbedrag
	, ref_leaseprijs
	, ref_restwaarde
	, ref_hostnaam
	, ref_ipadres
	, ref_type
	, ref_specificatie
	, ref_attentieid
	, ref_opmerking
	, ref_gebruiker
	, ref_persoon
	, ref_naam
	, ref_lokatie
	, ref_serienummer
--	, AuditDWKey
	, SourceDatabaseKey
--	, RN
FROM
	TOPdesk.[object] o2
WHERE 1=1
	AND o2.SourceDatabaseKey = @SourceDatabaseKey
	AND AuditDWKey < @AuditDWKey
)

--SELECT * FROM NewLines

DELETE FROM
	TOPdesk.[object]
WHERE 1=1
	AND AuditDWKey = @AuditDWKey
	AND SourcedatabaseKey = @SourceDatabaseKey
	AND unid NOT IN (SELECT unid FROM NewLines)