CREATE VIEW dwh.[checklistcustomer] AS 
SELECT	
	unid
    , archief 
    , rang
    , tekst
    , showforPotentialCustomer
    , showforCustomer
    , afkorting = NULL
FROM dbo.[checklistcustomer];