/****** Object:  StoredProcedure [etl].[GenerateETLDFPipelineJson]    Script Date: 26/03/2019 16:26:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- DROP PROCEDURE [Etl].[GenerateETLDFPipelineJson]
CREATE OR ALTER PROCEDURE [etl].[GenerateETLDFPipelineJson]

AS

/*

[Etl].[GenerateETLDFPipelineJson]


*/

BEGIN	
SET NOCOUNT ON

/**** DON'T TOUCH AFTER THIS *****/

DECLARE @TableName nvarchar(255);
DECLARE @TableSchema nvarchar(255);
DECLARE @Level int;
DECLARE @LoadDependencies nvarchar(max);
DECLARE @FinalLevelLoad nvarchar(max);

DECLARE @ColumnName nvarchar(255);
DECLARE @ColumnType nvarchar(255);

DECLARE @sql nvarchar(max);


-- this is a simple stupid string to fetch name from archive db db-archive_afas-tst-euw-qdrm --> afas
DECLARE @PipeLineName varchar(32) = 'LoadArchive'+ substring(DB_NAME(),12,(len(DB_NAME())-24) )

DROP TABLE IF EXISTS #OrderedTables;
DROP TABLE IF EXISTS #FinalLevelLoad;

with fk_tables as (
	select    
		 s1.name as from_schema    
		,o1.Name as from_table    
		,s2.name as to_schema    
		,o2.Name as to_table
	from sys.foreign_keys fk    
	inner join sys.objects o1 on (fk.parent_object_id = o1.object_id)    
	inner join sys.schemas s1 on (o1.schema_id = s1.schema_id)    
	inner join sys.objects o2 on (fk.referenced_object_id = o2.object_id)    
	inner join sys.schemas s2 on (o2.schema_id = s2.schema_id)    
	/*For the purposes of finding dependency hierarchy       
		we're not worried about self-referencing tables*/
	where not (s1.name = s2.name
				and o1.name = o2.name)
)

--SELECT * FROM fk_tables /*
,ordered_tables AS 
(        
	SELECT 
		s.name as schemaName
		,t.name as tableName
		,0 AS Level
	FROM (
		select name, schema_id           
		from sys.tables                 
		where name not in('sysdiagrams')
	) t    
	INNER JOIN sys.schemas s ON (t.schema_id = s.schema_id and s.name IN ('archive'))
--	LEFT OUTER JOIN fk_tables fk ON (s.name = fk.from_schema AND t.name = fk.from_table)
--	WHERE fk.from_schema IS NULL
	UNION ALL
	SELECT 
		fk.from_schema
		,fk.from_table
		,ot.Level + 1   
	FROM fk_tables fk    
	INNER JOIN ordered_tables ot ON (fk.to_schema = ot.schemaName AND fk.to_table = ot.tableName)
)

--SELECT * FROM ordered_tables order by level asc/*
/*

        "dependsOn": [
          {"activity": "iterate tables","dependencyConditions": ["Succeeded"]}
        ],

*/
select distinct 
		[Table_Name] = ot.tableName
	,[Table_Schema] = ot.schemaName
	,ot.Level
	,LoadDependencies = COALESCE(
	STUFF((
	SELECT DISTINCT CONCAT(',', char(9),'{"activity": ', '"Load_', to_schema, '_', to_table, '","dependencyConditions": ', char(9), '["Succeeded"]}', char(9))
	FROM fk_tables
	WHERE from_schema = ot.schemaName and from_table = ot.tableName
	FOR XML PATH('')),1,1,'')
	,' {"activity": "ScaleUp","dependencyConditions":  ["Succeeded"]}')
into #OrderedTables
from ordered_tables ot
inner join (
	select 
		schemaName
		,tableName
		,MAX(Level) maxLevel        
	from ordered_tables        
	group by schemaName,tableName
) mx on (ot.schemaName = mx.schemaName and ot.tableName = mx.tableName and mx.maxLevel = ot.Level)
order by level

select * from #OrderedTables order by level,Table_Schema 

-- Json header
PRINT '{
  "name": "'+ @PipeLineName + '",
  "properties": {
    "activities": [';

-- Scale DB Up
PRINT '{
                "name": "ScaleUp",
                "type": "WebActivity",
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "typeProperties": {
                    "url": {
                        "value": "@concat(''https://management.azure.com/subscriptions/'', pipeline().parameters.SubscriptionID, ''/resourceGroups/'', pipeline().parameters.ResourceGroupName, ''/providers/Microsoft.Sql/servers/'',pipeline().parameters.AzureSQLServerName,''/databases/'',pipeline().parameters.AzureSQLDatabaseName,''?api-version=2017-10-01-preview'')",
                        "type": "Expression"
                    },
                    "method": "PUT",
                    "headers": {
                        "Content-Type": "application/json"
                    },
                    "body": {
                        "value": "@json(concat(''{\"sku\":{\"name\":\"'', pipeline().parameters.ComputeSizeUp, ''\",\"tier\":\"'', pipeline().parameters.ServiceTier, ''\"}, \"location\": \"'', pipeline().parameters.AzureRegionName, '' \"}'' ) )",
                        "type": "Expression"
                    },
                    "authentication": {
                        "type": "MSI",
                        "resource": "https://management.azure.com/"
                    }
			}
       },'


DECLARE resourceCursor CURSOR FOR   
select 
	Table_Name, 
	Table_Schema, 
	Level,
	LoadDependencies
from #OrderedTables 
order by level,Table_Schema

/************** MAGIC *************/

OPEN resourceCursor  

FETCH NEXT FROM resourceCursor   
INTO @TableName, @TableSchema, @Level, @LoadDependencies

WHILE @@FETCH_STATUS = 0  
BEGIN  

 PRINT 
 '{
        "name": "Load_' + @TableSchema + '_' + @TableName + '",
        "type": "SqlServerStoredProcedure",
        "dependsOn": [
          ' + @LoadDependencies + '
        ],
        "policy": {
          "timeout": "1:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
        },
        "typeProperties": {
          "storedProcedureName": "[Etl].[Load' + @TableSchema + @TableName + ']",
          "storedProcedureParameters": {
          }
        },
        "linkedServiceName": {
          "referenceName": "'+ replace(db_name(),'_','-')+ '",
          "type": "LinkedServiceReference"
        }
      },';


	FETCH NEXT FROM resourceCursor   
	INTO @TableName, @TableSchema, @Level, @LoadDependencies
END   
CLOSE resourceCursor;
DEALLOCATE resourceCursor;

select distinct 
	@FinalLevelLoad = STUFF((
		SELECT DISTINCT CONCAT(',', char(9),'{"activity": ', '"Load_', Table_Schema, '_', Table_Name, '","dependencyConditions": ', char(9), '["Succeeded"]}', char(9))
		FROM #OrderedTables ot2
		WHERE [Level] = MAX(OT.[Level])
		FOR XML PATH('')),1,1,'')
--into #FinalLevelLoad
from #OrderedTables ot
where [Level] in (SELECT MAX(Level) FROM #OrderedTables)

/*
--select * from #FinalLevelLoad
PRINT
'{
        "name": "Load_PostLoadDatamart",
        "type": "SqlServerStoredProcedure",
        "dependsOn": [
          ' + @FinalLevelLoad + '
        ],
        "policy": {
          "timeout": "1:00:00",
          "retry": 0,
          "retryIntervalInSeconds": 30,
          "secureOutput": false,
          "secureInput": false
        },
        "typeProperties": {
          "storedProcedureName": "[Etl].[PostLoadDatamart]",
          "storedProcedureParameters": {
          }
        },
        "linkedServiceName": {
          "referenceName": "<linkedServiceName>",
          "type": "LinkedServiceReference"
        }
    },'
*/

-- Scale DB down
PRINT '{
                "name": "ScaleDown",
                "type": "WebActivity",
				"dependsOn": [
				  ' + @FinalLevelLoad + '
				],
                "policy": {
                    "timeout": "7.00:00:00",
                    "retry": 0,
                    "retryIntervalInSeconds": 30,
                    "secureOutput": false,
                    "secureInput": false
                },
                "typeProperties": {
                    "url": {
                        "value": "@concat(''https://management.azure.com/subscriptions/'', pipeline().parameters.SubscriptionID, ''/resourceGroups/'', pipeline().parameters.ResourceGroupName, ''/providers/Microsoft.Sql/servers/'',pipeline().parameters.AzureSQLServerName,''/databases/'',pipeline().parameters.AzureSQLDatabaseName,''?api-version=2017-10-01-preview'')",
                        "type": "Expression"
                    },
                    "method": "PUT",
                    "headers": {'

-- kept truncating output
PRINT '
                        "Content-Type": "application/json"
                    },
                    "body": {
                        "value": "@json(concat(''{\"sku\":{\"name\":\"'', pipeline().parameters.ComputeSizeDown, ''\",\"tier\":\"'', pipeline().parameters.ServiceTier, ''\"}, \"location\": \"'', pipeline().parameters.AzureRegionName, '' \"}'' ) )",
                        "type": "Expression"
                    },
                    "authentication": {
                        "type": "MSI",
                        "resource": "https://management.azure.com/"
                    }
			}
       },'

-- Scaling paramaters
PRINT '],
		  	"parameters": {
            "ServiceTier": {
                "type": "String",
                "defaultValue": "Standard"
            },
            "ComputeSizeDown": {
                "type": "String",
                "defaultValue": "S0"
            },
            "ComputeSizeUp": {
                "type": "String",
                "defaultValue": "S1"
            },
            "AzureSQLServerName": {
                "type": "String",
                "defaultValue": "<AzureSQLServerName>"
            },
            "AzureSQLDatabaseName": {
                "type": "String",
                "defaultValue": "'+db_name()+'"
            },
            "SubscriptionID": {
                "type": "String",
                	  "defaultValue": "<SubscriptionID>"
            },
            "ResourceGroupName": {
                "type": "String",
                "defaultValue": "<ResourceGroupName>"
            },
            "AzureRegionName": {
                "type": "String",
                "defaultValue": "<AzureRegionName>"
            }
		}
	}	  
}'

--*/
--*/
RETURN 0
END