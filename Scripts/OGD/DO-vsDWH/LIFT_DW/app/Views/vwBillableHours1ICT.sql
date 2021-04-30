CREATE VIEW [app].[vwBillableHours1ICT]
AS

SELECT
	p.ProjectKey
	, p.ProjectNumber
	, p.ProjectName
	, p.CustomerKey
	, p.ProductGroup
	, p.Product
	, p.ProjectGroupNumber
	, p.ProjectGroupName
	, p.ProjectStatus
	, p.ProjectStartDate
	, p.ProjectEndDate
	, p.ProjectAcceptDate
	, c.CustomerDebitNumber
	, c.CustomerFullname
	, c.CustomerActive
	, h.HourTypeKey
	, h.ServiceKey
	, h.[Hours]
	, h.[Day]
	, h.Rate
	, ProductNomination = NULL
	, ht.[Percentage]
	, ht.Billable
	, ht.RateName
FROM
	Fact.[Hour] h
	LEFT OUTER JOIN Dim.Project p ON h.ProjectKey = p.ProjectKey
	LEFT OUTER JOIN Dim.Customer c ON c.CustomerKey = p.CustomerKey
	LEFT OUTER JOIN Dim.HourType ht ON h.HourTypeKey = ht.HourTypeKey
WHERE 1=1
	AND p.ProductGroup LIKE '%1%ict%'
	AND ht.Billable = 1