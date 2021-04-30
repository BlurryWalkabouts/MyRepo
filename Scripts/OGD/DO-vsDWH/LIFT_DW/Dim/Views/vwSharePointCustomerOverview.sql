CREATE VIEW [Dim].[vwSharePointCustomerOverview]
AS

SELECT
	c.CustomerFullname
	, c.CustomerKey
	, cp.ContactPerson
	, cp.Mail
	, cp.Telephone_1
	, cp.Telephone_2
	, c.ServiceDeliveryManager
	, ProductGroups = REPLACE(REPLACE(STUFF(
		(
			SELECT DISTINCT '; ' + p.ProductGroup
			FROM Dim.Project p
			WHERE p.CustomerKey = c.CustomerKey
			FOR XML PATH('')
		), 1, 2, ''), '&amp;', '&'), 'amp;', '')
FROM
	Dim.Customer c
	LEFT OUTER JOIN Dim.ContactPerson cp ON c.CustomerKey = cp.CustomerKey
WHERE 1=1
	AND c.CustomerActive = 1
	AND cp.# = 1