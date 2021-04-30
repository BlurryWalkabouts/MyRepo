CREATE VIEW [setup].[DimCustomer]
AS
SELECT
	Code
	, [Name]
	, Fullname
	, CustomerGroup = CustomerGroup_Name
FROM
	[$(MDS)].mdm.DimCustomer