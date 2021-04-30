/* Schemas */
CREATE SCHEMA [OGD_Maintenance];
GO

CREATE SCHEMA [OGD_Security];
GO

CREATE SCHEMA [OGD_Documentation];
GO
/*****
Contributor: Is allowed to make ddl changes, read/write/execute data.
******/
create role [contributor];
GO

ALTER ROLE [db_datareader] add member [contributor];
ALTER ROLE [db_datawriter] add member [contributor]; 
ALTER ROLE [db_ddladmin] add member [contributor];
GO

-- DB permissions:
GRANT VIEW DEFINITION TO [contributor];
GRANT SHOWPLAN TO [contributor];
GRANT EXECUTE TO [contributor];

-- Revoke
REVOKE DELETE ON SCHEMA::[OGD_Security] TO [contributor];
REVOKE UPDATE ON SCHEMA::[OGD_Security] TO [contributor];
REVOKE INSERT ON SCHEMA::[OGD_Security] TO [contributor];
REVOKE EXECUTE ON SCHEMA::[OGD_Security] TO [contributor];
REVOKE ALTER ON SCHEMA::[OGD_Security] TO [contributor];

REVOKE DELETE ON SCHEMA::[OGD_Maintenance] TO [contributor];
REVOKE UPDATE ON SCHEMA::[OGD_Maintenance] TO [contributor];
REVOKE INSERT ON SCHEMA::[OGD_Maintenance] TO [contributor];
REVOKE EXECUTE ON SCHEMA::[OGD_Maintenance] TO [contributor];
REVOKE ALTER ON SCHEMA::[OGD_Maintenance] TO [contributor];

REVOKE DELETE ON SCHEMA::[OGD_Documentation] TO [contributor];
REVOKE UPDATE ON SCHEMA::[OGD_Documentation] TO [contributor];
REVOKE INSERT ON SCHEMA::[OGD_Documentation] TO [contributor];
REVOKE EXECUTE ON SCHEMA::[OGD_Documentation] TO [contributor];
REVOKE ALTER ON SCHEMA::[OGD_Documentation] TO [contributor];
GO

/****
DBA Schema and tools
****/

CREATE TABLE [OGD_Maintenance].[AzureSQLMaintenanceLog](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[OperationTime] [datetime2](7) NULL,
	[command] [varchar](4000) NULL,
	[ExtraInfo] [varchar](4000) NULL,
	[StartTime] [datetime2](7) NULL,
	[EndTime] [datetime2](7) NULL,
	[StatusMessage] [varchar](1000) NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [OGD_Maintenance].[AzureSQLMaintenance]
	(
		@operation nvarchar(10) = null,
		@mode nvarchar(10) = 'smart',
		@LogToTable bit = 1
	)
as
begin
	set nocount on
	declare @msg nvarchar(max);
	declare @minPageCountForIndex int = 40;
	declare @OperationTime datetime2 = sysdatetime();
	declare @KeepXOperationInLog int =3;

	/* make sure parameters selected correctly */
	set @operation = lower(@operation)
	set @mode = lower(@mode)
	
	if @mode not in ('smart','dummy')
		set @mode = 'smart'

	if @operation not in ('index','statistics','foreignkeys','all') or @operation is null
	begin
		raiserror('@operation (varchar(10)) [mandatory]',0,0)
		raiserror(' Select operation to perform:',0,0)
		raiserror('     "index" to perform index maintenance',0,0)
		raiserror('     "statistics" to perform statistics maintenance',0,0)
		raiserror('     "foreignkeys" to perform statistics maintenance',0,0)
		raiserror('     "all" to perform indexes and statistics maintenance',0,0)
		raiserror(' ',0,0)
		raiserror('@mode(varchar(10)) [optional]',0,0)
		raiserror(' optionaly you can supply second parameter for operation mode: ',0,0)
		raiserror('     "smart" (Default) using smart decition about what index or stats should be touched.',0,0)
		raiserror('     "dummy" going through all indexes and statistics regardless thier modifications or fragmentation.',0,0)
		raiserror(' ',0,0)
		raiserror('@LogToTable(bit) [optional]',0,0)
		raiserror(' Logging option: @LogToTable(bit)',0,0)
		raiserror('     0 - (Default) do not log operation to table',0,0)
		raiserror('     1 - log operation to table',0,0)
		raiserror('		for logging option only 3 last execution will be kept by default. this can be changed by easily in the procedure body.',0,0)
		raiserror('		Log table will be created automatically if not exists.',0,0)
	end
	else 
	begin
		/*Write operation parameters*/
		raiserror('-----------------------',0,0)
		set @msg = 'set operation = ' + @operation;
		raiserror(@msg,0,0)
		set @msg = 'set mode = ' + @mode;
		raiserror(@msg,0,0)
		set @msg = 'set LogToTable = ' + cast(@LogToTable as varchar(1));
		raiserror(@msg,0,0)
		raiserror('-----------------------',0,0)
	end
	
	/* Prepare Log Table */
	if object_id('OGD_Maintenance.AzureSQLMaintenanceLog') is null 
		begin
			create table [OGD_Maintenance].[AzureSQLMaintenanceLog] (id bigint primary key identity(1,1), OperationTime datetime2, command varchar(4000),ExtraInfo varchar(4000), StartTime datetime2, EndTime datetime2, StatusMessage varchar(1000));
		end

	if @LogToTable=1 insert into [OGD_Maintenance].[AzureSQLMaintenanceLog] values(@OperationTime,null,null,sysdatetime(),sysdatetime(),'Starting operation: Operation=' +@operation + ' Mode=' + @mode + ' Keep log for last ' + cast(@KeepXOperationInLog as varchar(10)) + ' operations' )	

	create table #cmdQueue (txtCMD nvarchar(max),ExtraInfo varchar(max))


	if @operation in('index','all')
	begin
		raiserror('Get index information...(wait)',0,0) with nowait;
		/* Get Index Information */
		select 
			i.[object_id]
			,ObjectSchema = OBJECT_SCHEMA_NAME(i.object_id)
			,ObjectName = object_name(i.object_id) 
			,IndexName = idxs.name
			,i.avg_fragmentation_in_percent
			,i.page_count
			,i.index_id
			,i.partition_number
			,i.index_type_desc
			,i.avg_page_space_used_in_percent
			,i.record_count
			,i.ghost_record_count
			,i.forwarded_record_count
			,null as OnlineOpIsNotSupported
		into #idxBefore
		from sys.dm_db_index_physical_stats(DB_ID(),NULL, NULL, NULL ,'limited') i
		left join sys.indexes idxs on i.object_id = idxs.object_id and i.index_id = idxs.index_id
		where idxs.type in (1/*Clustered index*/,2/*NonClustered index*/) /*Avoid HEAPS*/
		order by i.avg_fragmentation_in_percent desc, page_count desc


		-- mark indexes XML,spatial and columnstore not to run online update 
		update #idxBefore set OnlineOpIsNotSupported=1 where [object_id] in (select [object_id] from #idxBefore where index_id >=1000)
		
		
		raiserror('---------------------------------------',0,0) with nowait
		raiserror('Index Information:',0,0) with nowait
		raiserror('---------------------------------------',0,0) with nowait

		select @msg = count(*) from #idxBefore 
		set @msg = 'Total Indexes: ' + @msg
		raiserror(@msg,0,0) with nowait

		select @msg = avg(avg_fragmentation_in_percent) from #idxBefore where page_count>@minPageCountForIndex
		set @msg = 'Average Fragmentation: ' + @msg
		raiserror(@msg,0,0) with nowait

		select @msg = sum(iif(avg_fragmentation_in_percent>=5 and page_count>@minPageCountForIndex,1,0)) from #idxBefore 
		set @msg = 'Fragmented Indexes: ' + @msg
		raiserror(@msg,0,0) with nowait

				
		raiserror('---------------------------------------',0,0) with nowait

			
			
			
		/* create queue for update indexes */
		insert into #cmdQueue
		select 
		txtCMD = 
		case when avg_fragmentation_in_percent>5 and avg_fragmentation_in_percent<30 and @mode = 'smart' then
			'ALTER INDEX [' + IndexName + '] ON [' + ObjectSchema + '].[' + ObjectName + '] REORGANIZE;'
			when OnlineOpIsNotSupported=1 then
			'ALTER INDEX [' + IndexName + '] ON [' + ObjectSchema + '].[' + ObjectName + '] REBUILD WITH(ONLINE=OFF,MAXDOP=1);'
			else
			'ALTER INDEX [' + IndexName + '] ON [' + ObjectSchema + '].[' + ObjectName + '] REBUILD WITH(ONLINE=ON,MAXDOP=1);'
		end
		, ExtraInfo = 'Current fragmentation: ' + format(avg_fragmentation_in_percent/100,'p')
		from #idxBefore
		where 
			index_id>0 /*disable heaps*/ 
			and index_id < 1000 /* disable XML indexes */
			--
			and 
				(
					page_count> @minPageCountForIndex and /* not small tables */
					avg_fragmentation_in_percent>=5
				)
			or
				(
					@mode ='dummy'
				)
	end

	if @operation in('statistics','all')
	begin 
		/*Gets Stats for database*/
		raiserror('Get statistics information...',0,0) with nowait;
		select 
			ObjectSchema = OBJECT_SCHEMA_NAME(s.object_id)
			,ObjectName = object_name(s.object_id) 
			,StatsName = s.name
			,sp.last_updated
			,sp.rows
			,sp.rows_sampled
			,sp.modification_counter
		into #statsBefore
		from sys.stats s cross apply sys.dm_db_stats_properties(s.object_id,s.stats_id) sp 
		where OBJECT_SCHEMA_NAME(s.object_id) != 'sys' and (sp.modification_counter>0 or @mode='dummy')
		order by sp.last_updated asc

		
		raiserror('---------------------------------------',0,0) with nowait
		raiserror('Statistics Information:',0,0) with nowait
		raiserror('---------------------------------------',0,0) with nowait

		select @msg = sum(modification_counter) from #statsBefore
		set @msg = 'Total Modifications: ' + @msg
		raiserror(@msg,0,0) with nowait
		
		select @msg = sum(iif(modification_counter>0,1,0)) from #statsBefore
		set @msg = 'Modified Statistics: ' + @msg
		raiserror(@msg,0,0) with nowait
				
		raiserror('---------------------------------------',0,0) with nowait




		/* create queue for update stats */
		insert into #cmdQueue
		select 
		txtCMD = 'UPDATE STATISTICS [' + ObjectSchema + '].[' + ObjectName + '] (['+ StatsName +']) WITH FULLSCAN;'
		, ExtraInfo = '#rows:' + cast([rows] as varchar(100)) + ' #modifications:' + cast(modification_counter as varchar(100)) + ' modification percent: ' + format((1.0 * modification_counter/ rows ),'p')
		from #statsBefore
	end

	if @operation in('foreignkeys','all')
	begin
		raiserror('Get constraint information...(wait)',0,0) with nowait;
		/* Get Index Information */
		select 
			 [Table]     = o2.name, 
			 [Constraint] = o.name, 
			 [Enabled]   = case when ((C.Status & 0x4000)) = 0 then 1 else 0 end,
			 'Enable' = 'ALTER TABLE [' + o2.name + '] CHECK CONSTRAINT ' + o.name + ';'
		into #fkBefore
		from sys.sysconstraints C
			 inner join sys.sysobjects o on  o.id = c.constid -- and o.xtype='F'
			 inner join sys.sysobjects o2 on o2.id = o.parent_obj
		--WHERE (case when ((C.Status & 0x4000)) = 0 then 1 else 0 end) = 0
		
		raiserror('---------------------------------------',0,0) with nowait
		raiserror('Constraint Information:',0,0) with nowait
		raiserror('---------------------------------------',0,0) with nowait

		select @msg = count(*) from #fkBefore 
		set @msg = 'Total Foreign Keys: ' + @msg
		raiserror(@msg,0,0) with nowait

		select @msg = count(*) from #fkBefore where [enabled]=0
		set @msg = 'Total Disabled Foreign Keys: ' + @msg
		raiserror(@msg,0,0) with nowait
		
		raiserror('---------------------------------------',0,0) with nowait

		/* create queue for update indexes */
		insert into #cmdQueue
		select 
			 txtCMD = 'ALTER TABLE [' + o2.name + '] CHECK CONSTRAINT ' + o.name + ';'
			,ExtraInfo = ''
		from sys.sysconstraints C
			 inner join sys.sysobjects o on  o.id = c.constid -- and o.xtype='F'
			 inner join sys.sysobjects o2 on o2.id = o.parent_obj
		WHERE (case when ((C.Status & 0x4000)) = 0 then 1 else 0 end) = 0
	end

	if @operation in('statistics','index','foreignkeys','all')
	begin 
		/* iterate through all stats */
		raiserror('Start executing commands...',0,0) with nowait
		declare @SQLCMD nvarchar(max);
		declare @ExtraInfo nvarchar(max);
		declare @T table(txtCMD nvarchar(max),ExtraInfo nvarchar(max));
		while exists(select * from #cmdQueue)
		begin
			delete top (1) from #cmdQueue output deleted.* into @T;
			select top (1) @SQLCMD = txtCMD, @ExtraInfo=ExtraInfo from @T
			raiserror(@SQLCMD,0,0) with nowait
			if @LogToTable=1 insert into [OGD_Maintenance].[AzureSQLMaintenanceLog] values(@OperationTime,@SQLCMD,@ExtraInfo,sysdatetime(),null,'Started')
			begin try
				exec(@SQLCMD)	
				if @LogToTable=1 update [OGD_Maintenance].[AzureSQLMaintenanceLog] set EndTime = sysdatetime(), StatusMessage = 'Succeeded' where id=SCOPE_IDENTITY()
			end try
			begin catch
				raiserror('cached',0,0) with nowait
				if @LogToTable=1 update [OGD_Maintenance].[AzureSQLMaintenanceLog] set EndTime = sysdatetime(), StatusMessage = 'FAILED : ' + CAST(ERROR_NUMBER() AS VARCHAR(50)) + ERROR_MESSAGE() where id=SCOPE_IDENTITY()
			end catch
			delete from @T
		end
	end
	
	/* Clean old records from log table */
	if @LogToTable=1
	begin
		delete from [OGD_Maintenance].[AzureSQLMaintenanceLog] 
		from 
			[OGD_Maintenance].[AzureSQLMaintenanceLog] L join 
			(select distinct OperationTime from [OGD_Maintenance].[AzureSQLMaintenanceLog] order by OperationTime desc offset @KeepXOperationInLog rows) F
				ON L.OperationTime = F.OperationTime
		insert into [OGD_Maintenance].[AzureSQLMaintenanceLog] values(@OperationTime,null,cast(@@rowcount as varchar(100))+ ' rows purged from log table because number of operations to keep is set to: ' + cast( @KeepXOperationInLog as varchar(100)),sysdatetime(),sysdatetime(),'Cleanup Log Table')
	end

	raiserror('Done',0,0)
	if @LogToTable=1 insert into [OGD_Maintenance].[AzureSQLMaintenanceLog] values(@OperationTime,null,null,sysdatetime(),sysdatetime(),'End of operation')
end
GO

/***
Security views
***/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [OGD_Security].[vwLoginPermissions] AS (
	SELECT 
		 [DatabaseRoleName] = DP1.name
		,[DatabaseUserName] = COALESCE(DP2.name, 'No members')
		,[DatabaseUserType] = 
		CASE DP2.[Type]
			WHEN 'A' THEN 'Application role'
			WHEN 'C' THEN 'User mapped to a certificate'
			WHEN 'E' THEN 'External user from Azure Active Directory'
			WHEN 'G' THEN 'Windows group'
			WHEN 'K' THEN 'User mapped to an asymmetric key'
			WHEN 'R' THEN 'Database role'
			WHEN 'S' THEN 'SQL user'
			WHEN 'U' THEN 'Windows user'
			WHEN 'X' THEN 'External group from Azure Active Directory group or applications'
			ELSE COALESCE(DP2.Type_Desc, 'No type')
		END
	 FROM sys.database_role_members AS DRM  
	 RIGHT OUTER JOIN sys.database_principals AS DP1  
	   ON DRM.role_principal_id = DP1.principal_id  
	 LEFT OUTER JOIN sys.database_principals AS DP2  
	   ON DRM.member_principal_id = DP2.principal_id  
	 WHERE DP1.type = 'R'
)
GO

/****** Object:  View [OGD_Security].[vwTablePermissions]    Script Date: 2018-11-09 13:13:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [OGD_Security].[vwTablePermissions] AS (
	--List all access provisioned to a sql user or windows user/group through a database or application role
	-- Based on: https://stackoverflow.com/questions/7048839/sql-server-query-to-find-all-permissions-access-for-all-users-in-a-database
	SELECT  
		[DatabaseUserName] = memberprinc.[name],
		[DatabaseUserType] = CASE memberprinc.[type]
				WHEN 'A' THEN 'Application role'
				WHEN 'C' THEN 'User mapped to a certificate'
				WHEN 'E' THEN 'External user from Azure Active Directory'
				WHEN 'G' THEN 'Windows group'
				WHEN 'K' THEN 'User mapped to an asymmetric key'
				WHEN 'R' THEN 'Database role'
				WHEN 'S' THEN 'SQL user'
				WHEN 'U' THEN 'Windows user'
				WHEN 'X' THEN 'External group from Azure Active Directory group or applications'
					 END, 
		[DatabaseRoleName] = roleprinc.[name],      
		[PermissionType] = CASE roleprinc.[name]
			WHEN 'db_datareader' THEN 'SELECT'
			WHEN 'db_owner' THEN 'ALL'
			WHEN 'db_datawriter' THEN 'INSERT, UPDATE, DELETE'
			ELSE perm.[permission_name]
		END,     
		[PermissionState] = CASE 
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN 'GRANT' 
			ELSE perm.[state_desc]
		END,       
		[ObjectType] = CASE
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN '{ALL TYPES}' 
			ELSE obj.type_desc
		END,   
		[ObjectName] = CASE
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN '{ALL OBJECTS}' 
			ELSE OBJECT_NAME(perm.major_id)
		END,
		[ColumnName] = CASE
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN '{ALL COLUMNS}' 
			ELSE col.[name]
		END
	FROM    
		--Role/member associations
		sys.database_role_members members
	JOIN
		--Roles
		sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
	JOIN
		--Role members (database users)
		sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
	LEFT JOIN        
		--Permissions
		sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
	LEFT JOIN
		--Table columns
		sys.columns col on col.[object_id] = perm.major_id 
						AND col.[column_id] = perm.[minor_id]
	LEFT JOIN
		sys.objects obj ON perm.[major_id] = obj.[object_id]
	UNION
	--List all access provisioned to the public role, which everyone gets by default
	SELECT  
		[UserName] = '{All Users}',
		[UserType] = '{All Users}',     
		[RoleName] = roleprinc.[name],      
		[PermissionType] = perm.[permission_name],       
		[PermissionState] = perm.[state_desc],       
		[ObjectType] = obj.type_desc,--perm.[class_desc],  
		[ObjectName] = OBJECT_NAME(perm.major_id),
		[ColumnName] = col.[name]
	FROM    
		--Roles
		sys.database_principals roleprinc
	LEFT JOIN        
		--Role permissions
		sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
	LEFT JOIN
		--Table columns
		sys.columns col on col.[object_id] = perm.major_id 
						AND col.[column_id] = perm.[minor_id]                   
	JOIN 
		--All objects   
		sys.objects obj ON obj.[object_id] = perm.[major_id]
	WHERE
		--Only roles
		roleprinc.[type] = 'R' AND
		--Only public role
		roleprinc.[name] = 'public' AND
		--Only objects of ours, not the MS objects
		obj.is_ms_shipped = 0
		/*
	ORDER BY
		DatabaseUserType,
		DataabaseUserName,
		PermissionType,
		PermissionState,
		ObjectType,
		ObjectName,
		ColumnName
		*/
)
GO

/***
Documentation
***/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [OGD_Documentation].[vwTableRelationship] AS (
	SELECT   
	    [FromTableName] = CONCAT(OBJECT_SCHEMA_NAME(f.parent_object_id), '.', OBJECT_NAME(f.parent_object_id))
	   ,[FromColumnName] = COL_NAME(fc.parent_object_id, fc.parent_column_id) 
	   ,[ToTable] = CONCAT(OBJECT_SCHEMA_NAME(f.referenced_object_id), '.', OBJECT_NAME (f.referenced_object_id))
	   ,[ToColumnName] = COL_NAME(fc.referenced_object_id, fc.referenced_column_id)  
	   ,[RelationshipName] = f.name
	   ,[IsActive] = CASE WHEN is_disabled = 1 THEN 0 ELSE 1 END
	   ,[ActionOnDeleteInReferencedTable] = delete_referential_action_desc  
	   ,[ActionOnUpdateInReferencedTable] = update_referential_action_desc  
	FROM sys.foreign_keys AS f  
	INNER JOIN sys.foreign_key_columns AS fc   
	   ON f.object_id = fc.constraint_object_id
);
GO