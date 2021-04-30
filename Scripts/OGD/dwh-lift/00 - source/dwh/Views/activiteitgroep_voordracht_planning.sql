CREATE VIEW dwh.[activiteitgroep_voordracht_planning] AS
SELECT
    avp.[unid],
    avp.[activiteitgroep_voordrachtid],
    avp.[startdatum],
    [einddatum] = LEAD(avp.[startdatum],1,av.[einddatum_groep]) OVER (PARTITION BY avp.[activiteitgroep_voordrachtid] ORDER BY avp.[startdatum] ASC, avp.[aantal]),
	avp.[aantal]
	FROM dbo.[activiteitgroep_voordracht_planning] avp
	INNER JOIN dbo.[activiteitgroep_voordracht] av on avp.[activiteitgroep_voordrachtid] = av.[unid];