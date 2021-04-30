CREATE VIEW dwh.[contactnotecustomer] AS
SELECT
    n.[unid],
    n.[dataanmk],
    n.[datwijzig],
    n.[customerid],
    n.[conversationdate],
    n.[contactnote_typeid] AS [typeid],
    t.[tekst] AS [type],
    n.[categorieid],
    c.[tekst] AS [categorie],
    n.[acquisition_goalid],
    ag.[tekst] AS [acquisition_goal],
	CAST(NULL AS uniqueidentifier) AS [customercontactid],
	n.uidaanmk,
	n.uidwijzig
FROM dbo.[contactnotecustomer] n
    LEFT JOIN dbo.[gespreksnotitie_type] t ON t.[unid] = n.[contactnote_typeid]
    LEFT JOIN dbo.[gespreksnotitie_categorie] c ON c.[unid] = n.[categorieid]
    LEFT JOIN dbo.[acquisition_goal] ag ON ag.[unid] = n.[acquisition_goalid];

