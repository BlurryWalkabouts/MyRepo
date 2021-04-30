CREATE VIEW dwh.[checklistcustomerlink] AS 
SELECT	
	unid
    , checkid
    , customerid
    , gebruikerid
    , gechecked
    , dataanmk
FROM dbo.[checklistcustomerlink];