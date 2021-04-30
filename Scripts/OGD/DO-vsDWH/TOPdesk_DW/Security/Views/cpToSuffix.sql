-- Generates a suffix mapping list based upon contactperson email
CREATE VIEW [Security].[cpToSuffix]
AS

SELECT DISTINCT
	c.CustomerKey
	, Customer = c.Fullname
	, Suffix = RIGHT(CP.Mail, LEN(CP.Mail) - CHARINDEX('@', CP.Mail))
FROM
	Dim.Customer c
	INNER JOIN syn.lift_dw_dim_customer LC ON LC.CustomerDebitNumber = C.DebitNumber
	INNER JOIN syn.lift_dw_dim_contactperson CP ON CP.CustomerKey = LC.CustomerKey
WHERE 1=1
	AND RIGHT(CP.Mail, LEN(CP.Mail) - CHARINDEX('@', CP.Mail)) <> ''