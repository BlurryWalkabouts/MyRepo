/*
SELECT *
FROM 'InPlanning/Extracted/20180814/hist_account.json'
WITH ( DATA_SOURCE = 'InplanningBlobStorage');
*/
/*
SELECT j.*
FROM OPENROWSET(
	BULK 'inplanning/extracted/20180816/hist_account.json', 
	DATA_SOURCE = 'InPlanningBlobStorage', 
	SINGLE_CLOB
) AS data
CROSS APPLY OPENJSON(BulkColumn)
WITH (
	 id int
	,changed datetime2
	,version int
	,resource_id int
	,labourhist_id int
	,resourcegroup_id int
	,rosterdate date
	,account_id int
	,valuetype int
	,value numeric(10,6)
	,remark nvarchar(max)
) j
*/
SELECT j.*
FROM OPENROWSET(
	BULK 'inplanning/extracted/20180816/ref_attribute.json', 
	DATA_SOURCE = 'InPlanningBlobStorage', 
	SINGLE_CLOB
) AS data
CROSS APPLY OPENJSON(BulkColumn)
WITH (
	 id int
	,changed datetime2
	,version int
	,deleted int
	,uname nvarchar(255)
	,name nvarchar(255)
	,description nvarchar(max)
) j