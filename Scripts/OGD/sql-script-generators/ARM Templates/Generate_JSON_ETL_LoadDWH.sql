DECLARE @SubscriptionId nvarchar(32) = '03d914ad-63f7-4fab-b24e-7b56e7da5a56';
DECLARE @ResourceGroup nvarchar(255) = 'OGD-EUW-RGR-PRD-DO-ETL-INPLANNING-01';
DECLARE @ApplicationName nvarchar(255) = 'lift';
DECLARE @OrchestratorConnectionName nvarchar(255) = 'lift_acc_dw';

/**** DON'T TOUCH AFTER THIS *****/

DECLARE @TableName nvarchar(255);
DECLARE @TableSchema nvarchar(255);
DECLARE @Level int;
DECLARE @LoadDependencies nvarchar(max);
DECLARE @FinalLevelLoad nvarchar(max);

DECLARE @ColumnName nvarchar(255);
DECLARE @ColumnType nvarchar(255);

DECLARE @sql nvarchar(max);

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
,ordered_tables AS 
(        
	SELECT 
		s.name as schemaName
		,t.name as tableName
		,0 AS Level
	FROM (
		select name, schema_id           
		from sys.tables                 
		where name not in('sysdiagrams', 'Date')
	) t    
	INNER JOIN sys.schemas s ON (t.schema_id = s.schema_id and s.name IN ('DIM', 'Fact'))
	LEFT OUTER JOIN fk_tables fk ON (s.name = fk.from_schema AND t.name = fk.from_table)
	WHERE fk.from_schema IS NULL
	UNION ALL
	SELECT 
		fk.from_schema
		,fk.from_table
		,ot.Level + 1   
	FROM fk_tables fk    
	INNER JOIN ordered_tables ot ON (fk.to_schema = ot.schemaName AND fk.to_table = ot.tableName)
)
/*

"runAfter": {
                "Load_Dim.AbsenceReason": [
                  "Succeeded"
                ],
                "Load_Dim.ContractType": [
                  "Succeeded"
                ]
              },

*/
select distinct 
		[Table_Name] = ot.tableName
	,[Table_Schema] = ot.schemaName
	,ot.Level
	,LoadDependencies = STUFF((
	SELECT DISTINCT CONCAT(',', char(9), '"Load_', to_schema, '.', to_table, '":', char(9), '["Succeeded"]', char(9))
	FROM fk_tables
	WHERE from_schema = ot.schemaName and from_table = ot.tableName
	FOR XML PATH('')),1,1,'')
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

--select * from #OrderedTables order by Level

PRINT '{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "functions_etlSqlOrchestratorPath": {
      "type": "string"
    },
    "buildNumber": {
      "type": "string"
    }
  },
  "variables": {
    "workflowDatamartFactName": "[concat(parameters(''buildNumber''), ''etl-' + @ApplicationName + '-load-dwh-fact'')]",
    "connSqlDatamartName": "[concat(parameters(''buildNumber''), ''conn-' + @ApplicationName + '-sql-datamart'')]"
  },
  "resources": [
    {
      "comments": "Generalized from resource: ''/subscriptions/' + @SubscriptionId + '/resourceGroups/' + @ResourceGroup + '/providers/Microsoft.Logic/workflows/etl-' + @ApplicationName + '-load-dwh-fact''.",
      "type": "Microsoft.Logic/workflows",
      "name": "[variables(''workflowDatamartFactName'')]",
      "apiVersion": "2017-07-01",
      "location": "westeurope",
      "tags": {},
      "scale": null,
      "properties": {
        "state": "Enabled",
        "definition": {
          "$schema": "https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#",
          "contentVersion": "1.0.0.0",
          "parameters": {},
          "triggers": {
            "manual": {
              "type": "Request",
              "kind": "Http",
              "inputs": {
                "schema": {
                  "TimeStamp": "2018-08-20T09:34"
                }
              }
            }
          },
		  "actions": {';


DECLARE resourceCursor CURSOR FOR   
select 
	Table_Name, 
	Table_Schema, 
	Level,
	LoadDependencies
from #OrderedTables 
order by level

/************** MAGIC *************/

OPEN resourceCursor  

FETCH NEXT FROM resourceCursor   
INTO @TableName, @TableSchema, @Level, @LoadDependencies

WHILE @@FETCH_STATUS = 0  
BEGIN  
	PRINT '"Load_' + @TableSchema + '.' + @TableName + '": {
              "runAfter": {
				' + @LoadDependencies + '
			  },
              "type": "Function",
              "inputs": {
                "body": {
                  "conn": "' + @OrchestratorConnectionName + '",
                  "sproc": "[[Load].[' + @TableSchema + @TableName + ']"
                },
                "function": {
                  "id": "[parameters(''functions_etlSqlOrchestratorPath'')]"
                },
                "method": "POST"
              }

            },';


	FETCH NEXT FROM resourceCursor   
	INTO @TableName, @TableSchema, @Level, @LoadDependencies
END   
CLOSE resourceCursor;
DEALLOCATE resourceCursor;

select distinct 
	@FinalLevelLoad = STUFF((
		SELECT DISTINCT CONCAT(',', char(9), '"Load_', Table_Schema, '.', Table_Name, '":', char(9), '["Succeeded"]', char(9))
		FROM #OrderedTables ot2
		WHERE [Level] = MAX(OT.[Level])
		FOR XML PATH('')),1,1,'')
--into #FinalLevelLoad
from #OrderedTables ot
where [Level] in (SELECT MAX(Level) FROM #OrderedTables)

--select * from #FinalLevelLoad

PRINT ',
            "Response": {
              "runAfter": {
                ' + @FinalLevelLoad + '
              },
              "type": "Response",
              "kind": "Http",
              "inputs": {
                "statusCode": 200
              }
            }
          },
          "outputs": {}
        },
        "parameters": {}
      },
      "dependsOn": []
    }
  ]
}'