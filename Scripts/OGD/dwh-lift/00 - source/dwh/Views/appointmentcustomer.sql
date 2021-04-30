CREATE VIEW dwh.[appointmentcustomer] AS
SELECT
    a.[unid],
    a.[dataanmk],
    a.[datwijzig],
    a.[uidaanmk],
    a.[uidwijzig],
    a.[status],
    a.[behandelaarid],
    a.[doorstuurid],
    a.[budgethouderid],
    a.[resultaatid],
    ar.[tekst] AS [resultaat],
    a.[wfcategorieid],
    wc.[tekst] AS [wfcategorie],
    a.[acquisition_goalid],
    ag.[tekst] AS [acquisition_goal],
    a.[afspraaktijd],
    a.[onderwerp],
    a.[customerid]
FROM dbo.[appointmentcustomer] a
    LEFT JOIN dbo.[acquisition_goal] ag ON ag.[unid] = a.[acquisition_goalid]
    LEFT JOIN dbo.[afspraak_resultaat] ar ON ar.[unid] = a.[resultaatid]
    LEFT JOIN dbo.[wfcategorie] wc ON wc.[unid] = a.[wfcategorieid];
