/******************************************************************************************************************
 * Script Configuration Variables
 * Alter these variables to match customer environment (default values in parentheses)
*******************************************************************************************************************
 @customerNumber          = Customer (debit)number from LIFT. Used to identify the customer
 @application             = Name of the application whose database is to be replicated
 @sourceDatabase          = Name of the database at the customer (current database)
 @sourceServerName        = Host\Instance name of the server hosting the publication database (current instance)
 @distributionServerName  = Host\Instance name of the server hosting the distribution database (current instance)
 @sourceDomain            = domain name of source and distribution servers
 @replicaServerName       = Hostname of the server hosting the subscription database
                            (ogd-replica-<customerNumber>.database.windows.net)
 @sqlPushAccount          = account used to access the target database (sa_push_<customernumber>)
 @sqlPushPassword         = Password of the account "sa_push_<customernumber>"
*******************************************************************************************************************
   On-Server configuration
*******************************************************************************************************************
 * SQLAgentAccount must have "create new files" permission on folder
   "%PROGRAMFILES%\Microsoft SQL Server\<version>\COM".
   See for details: https://support.microsoft.com/en-us/help/956032/
 * SnapshotLocation must exist (including share):
    * SQLAgentAccount must have RW permissions
*******************************************************************************************************************/
DECLARE @customerNumber nchar(6) = '<KLANTNR>';
DECLARE @application nvarchar(255) = 'topdesk';
DECLARE @sourceDatabase nvarchar(255) = DB_NAME();
DECLARE @sourceServerName nvarchar(255) = @@SERVERNAME;
DECLARE @distributionServerName nvarchar(255) = @@SERVERNAME;
DECLARE @sourceDomain nvarchar(255) = '<KLANTDOMEINNAAM>';

DECLARE @replicaServerName nvarchar(255) = CONCAT('ogd-replica-', @customerNumber, '.database.windows.net');
DECLARE @replicaDatabaseName sysname = @application;

-- Account settings
DECLARE @sqlPushAccount sysname = CONCAT('sa_push_', @customerNumber);
DECLARE @sqlPushPassword nvarchar(255) = N'<generate>';
DECLARE @replicationAccount nvarchar(255) = CONCAT('repl_ogd_', @application);
DECLARE @replicationPassword nvarchar(255) = N'<generate>';
/*************************************************************************************
 * Private Variables for scripts. Don't touch these variables as these are needed for
 * the internal operation of the script
 ************************************************************************************* 
 @snapshotLocation          = Location for initial snapshot, as \\path\to\unc
 @publication               = Name of the publication
 @syncview_postfix          = unique identifier for replication article
 @sql                       = Container for script
 *************************************************************************************/
 -- NOTE: on Failoverclusters and availability groups the @distributionServerName needs to be replaced with hardcoded hostname
DECLARE @snapshotLocation nvarchar(255) = CONCAT('\\', @distributionServerName, '.', @sourceDomain, '\SqlReplication$');
DECLARE @publication sysname = CONCAT('OGD_', @application, '_replication');
DECLARE @syncview_postfix varchar(50) = CONVERT(char(8), GetDate(),112);
DECLARE @sql nvarchar(max) = '';

-- enable the database for replication
SET @sql += 'EXEC sp_replicationdboption @dbname = N''' + @sourceDatabase + ''', @optname = N''publish'', @value = N''true'';' + char(10);

-- create the logreader job, using a local Windows account (per MS recommended practices)
SET @sql += 'USE ' + QUOTENAME(@sourceDatabase) + ';' + char(10);
SET @sql += 'EXEC sp_addlogreader_agent @publisher_security_mode = 1;' + char(10);

-- create the publication: replicate schema changes, set publication active, but do not perform immediate sync
SET @sql += 'EXEC sp_addpublication @publication = N'''+@publication+''', @description = N''OGD - Transactional publication of database [ '+ @sourceDatabase +'  ] for reporting purposes (rapportages@ogd.nl).'', @sync_method = N''concurrent'', @retention = 0, @allow_push = N''true'', @allow_pull = N''false'', @allow_anonymous = N''false'', @enabled_for_internet = N''false'', @snapshot_in_defaultfolder = N''false'', @alt_snapshot_folder = ''' +@snapshotLocation+ ''', @compress_snapshot = N''false'', @allow_subscription_copy = N''false'', @repl_freq = N''continuous'', @status = N''active'', @independent_agent = N''true'', @immediate_sync = N''false'', @allow_sync_tran = N''false'', @autogen_sync_procs = N''false'', @allow_queued_tran = N''false'', @allow_dts = N''false'', @replicate_ddl = 1, @allow_initialize_from_backup = N''false'', @enabled_for_p2p = N''false'', @enabled_for_het_sub = N''false'';' + char(10);

-- create the snapshot agent job
SET @sql += 'EXEC sp_addpublication_snapshot @publication = N'''+@publication+''', @frequency_type = 1, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @publisher_security_mode = 1;' + char(10);

-- print generated code so far
PRINT @sql;
-- reset variable
SET @sql = '';

DECLARE @schema_name sysname;
DECLARE @table_name sysname;
DECLARE @column_name sysname;
DECLARE @object_id int;

-- iterate over all tables needed for replication
DECLARE T CURSOR FOR
    SELECT t.[name], s.[name], t.[object_id]
    FROM sys.tables t
        INNER JOIN sys.schemas s
        ON s.[schema_id] = t.[schema_id]
    WHERE t.[is_ms_shipped] = 0
        AND EXISTS (
            SELECT 1
            FROM ##articles a
            WHERE 1=1
                AND a.[schema] = s.[name] COLLATE SQL_Latin1_General_CP1_CI_AI
                AND a.[table] = t.[name] COLLATE SQL_Latin1_General_CP1_CI_AI
        );
OPEN T;

FETCH NEXT FROM T INTO @table_name, @schema_name, @object_id;
WHILE @@FETCH_STATUS = 0
BEGIN

    -- generate table article
    SET @sql = 'EXEC sp_addarticle @publication = N'''+@publication+''', @article = N'''+@table_name+''', @source_owner = N''dbo'', @source_object = N'''+@table_name+''', @type = N''logbased'', @description = null, @creation_script = null, @pre_creation_cmd = N''drop'', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N''manual'', @destination_table = N'''+@table_name+''', @destination_owner = N''dbo'', @vertical_partition = N''true'', @ins_cmd = N''CALL [sp_MSins_' + @schema_name + @table_name + ']'', @del_cmd = N''CALL [sp_MSdel_' + @schema_name + @table_name + ']'', @upd_cmd = N''SCALL [sp_MSupd_' + @schema_name + @table_name + ']'';';
    PRINT @sql;

    -- iterate over all columns needed for replication
    DECLARE C CURSOR FOR
        SELECT c.[name]
        FROM sys.columns c
        WHERE c.[object_id] = @object_id
            AND EXISTS (
                SELECT 1
                FROM ##articles a
                WHERE 1=1
                    AND a.[schema] = @schema_name COLLATE SQL_Latin1_General_CP1_CI_AI
                    AND a.[table] = @table_name COLLATE SQL_Latin1_General_CP1_CI_AI
                    AND (a.[column] = c.[name] COLLATE SQL_Latin1_General_CP1_CI_AI OR a.[column] IS NULL)
            );
    OPEN C;

    -- add the article's partition column(s)
    FETCH NEXT FROM C INTO @column_name;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'EXEC sp_articlecolumn @publication = N'''+@publication+''', @article = N'''+@table_name+''', @column = N'''+@column_name+''', @operation = N''add'', @force_invalidate_snapshot = 1, @force_reinit_subscription = 1;';
        PRINT @sql;
        FETCH NEXT FROM C INTO @column_name;
    END;
    CLOSE C;
    DEALLOCATE C;

    -- add the article synchronization object
    SET @sql = 'EXEC sp_articleview @publication = N'''+@publication+''', @article = N'''+@table_name+''', @view_name = N''SYNC_'+@table_name+'_'+@syncview_postfix+ ''', @filter_clause = null, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1;' + char(10);
    PRINT @sql;

FETCH NEXT FROM T INTO @table_name, @schema_name, @object_id;
END;

CLOSE T;
DEALLOCATE T;


SET @sql = '';

-- add subscription
SET @sql += 'EXEC sp_addsubscription @publication = N''' + @publication + ''', @subscriber = N''' + @replicaServerName + ''', @destination_db = N''' + @replicaDatabaseName + ''', @sync_type = N''Automatic'', @subscription_type = N''push'', @update_mode = N''read only'';' + char(10)
SET @sql += 'EXEC sp_addpushsubscription_agent @publication = N''' + @publication + ''', @subscriber = N''' + @replicaServerName + ''', @subscriber_db = N''' + @replicaDatabaseName + ''', @subscriber_security_mode = 0, @subscriber_login = N''' + @sqlPushAccount + ''', @subscriber_password = N''' + @sqlPushPassword + ''';' + char(10);

-- set publication jobs' owner to SA
SET @sql += 'DECLARE @LogJob uniqueidentifier = (SELECT job_id FROM distribution.dbo.MSlogreader_agents WHERE publisher_db = N''' + @sourceDatabase + ''');' + char(10);
SET @sql += 'DECLARE @SnapJob uniqueidentifier = (SELECT job_id FROM distribution.dbo.MSsnapshot_agents WHERE publication = N''' + @publication + ''');' + char(10);
SET @sql += 'DECLARE @PushJob uniqueidentifier = (SELECT job_id FROM distribution.dbo.MSdistribution_agents WHERE publication = N''' + @publication + ''');' + char(10);
SET @sql += 'EXEC msdb.dbo.sp_update_job @job_id=@LogJob, @owner_login_name=N''sa'';' + char(10);
SET @sql += 'EXEC msdb.dbo.sp_update_job @job_id=@SnapJob, @owner_login_name=N''sa'';' + char(10);
SET @sql += 'EXEC msdb.dbo.sp_update_job @job_id=@PushJob, @owner_login_name=N''sa'';' + char(10);

-- kickstart the snapshot agent
SET @sql += 'EXEC sp_startpublication_snapshot @publication = N''' + @publication + ''';' + char(10);
PRINT @sql;
SET @sql = '';
