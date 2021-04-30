CREATE VIEW dwh.[werknemer_activiteitgroep_link] AS
SELECT
    wal.[unid],
    wal.[werknemerid],
    wal.[activiteitgroepid]
FROM dbo.[werknemer_activiteitgroep_link] wal;
