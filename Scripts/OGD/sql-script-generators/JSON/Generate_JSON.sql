DECLARE @Table nvarchar(255)
DECLARE @SQL nvarchar(max)

DECLARE resourceCursor CURSOR FOR   
SELECT [table_name]
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'

OPEN resourceCursor  

FETCH NEXT FROM resourceCursor   
INTO @table

WHILE @@FETCH_STATUS = 0  
BEGIN  
	PRINT char(9)+char(9)+char(9)+'"Load_'+@table+'": {
                "inputs": {
                    "host": {
                        "connection": {
                            "name": "@parameters(''$connections'')[''sql''][''connectionId'']"
                        }
                    },
                    "method": "post",
                    "path": "/datasets/default/procedures/@{encodeURIComponent(encodeURIComponent(''[dbo].[usp_Load_'+@table+']''))}"
                },
                "runAfter": {
                    "ExtractZipArchive": [
                        "Succeeded"
                    ]
                },
                "type": "ApiConnection"
            },'
	
	 
	FETCH NEXT FROM resourceCursor   
	INTO @table  
END   
CLOSE resourceCursor;
DEALLOCATE resourceCursor;
