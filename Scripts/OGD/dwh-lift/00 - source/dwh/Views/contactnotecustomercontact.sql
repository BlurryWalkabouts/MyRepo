CREATE VIEW dwh.[contactnotecustomercontact] AS

SELECT
    n.[unid],
    n.[dataanmk],
    n.[datwijzig],
    n.[uidaanmk],
    n.[uidwijzig],
    cp.klantid AS [customerid],
    n.[customercontactid],
    n.[conversationdate],
    n.[contactnote_typeid] AS [typeid],
    t.[tekst] AS [type],
    n.[categorieid],
    c.[tekst] AS [categorie],
    n.[acquisition_goalid],
    ag.[tekst] AS [acquisition_goal]
FROM dbo.[contactnotecustomercontact] n
    LEFT JOIN dbo.[gespreksnotitie_type] t ON t.[unid] = n.[contactnote_typeid]
    LEFT JOIN dbo.[gespreksnotitie_categorie] c ON c.[unid] = n.[categorieid]
    LEFT JOIN dbo.[acquisition_goal] ag ON ag.[unid] = n.[acquisition_goalid]
    LEFT JOIN dbo.contactpersoon cp ON n.customercontactid = cp.unid;