CREATE VIEW dwh.[werknemerdiploma] AS
SELECT
    wd.[diplomaid],
    d.[tekst] AS [diploma],
    wd.[expiration_date],
    wd.[unid],
    wd.[werknemerid]
FROM dbo.[werknemerdiploma] wd
    LEFT JOIN dbo.[diploma] d ON d.[unid] = wd.[diplomaid];
