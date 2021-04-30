USE [msdb]
GO

/****** Object:  Job [00 - Backup - Full Backup]    Script Date: 5/1/2017 8:11:29 PM ******/
EXEC msdb.dbo.sp_delete_job @job_id=N'ade8ae05-8ece-493b-80dd-0ab24e9e9657', @delete_unused_schedule=1
GO

/****** Object:  Job [00 - Backup - Full Backup]    Script Date: 5/1/2017 8:11:29 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 5/1/2017 8:11:29 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'00 - Backup - Full Backup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Database]    Script Date: 5/1/2017 8:11:29 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Database', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @name VARCHAR(50) -- database name  
DECLARE @path VARCHAR(256) -- path for backup files 
DECLARE @fileName VARCHAR(256) -- filename for backup  
DECLARE @mediaName NVARCHAR(255)

-- please change the set @path = ''change to your backup location''. for example,  
-- SET @path = ''C:\backup\'' 
-- or SET @path = ''O:\sqlbackup\'' if you using remote drives
-- note that remotedrive setup is extra step you have to perform in sql server in order to backup your dbs to remote drive 
-- you have to chnage you sql server accont to a network account and add that user to have full access to the network drive you are backing up to

SET @path = N''https://ogdeuwstabirsqlbck01.blob.core.windows.net/bak01/''

DECLARE db_cursor CURSOR FOR  
	SELECT name 
	FROM master.dbo.sysdatabases 
	WHERE name NOT IN (''master'',''model'',''msdb'',''tempdb'')  

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @name   

WHILE @@FETCH_STATUS = 0   
BEGIN   
	   SET @fileName = @path + @name + ''_Full_'' + REPLACE (REPLACE (REPLACE (CONVERT (VARCHAR (40), GETDATE (), 120), ''-'',''''),'':'', ''''),'' '', '''') + ''.bak''
	   SET @mediaName = @name + ''-Full Database Backup''
       BACKUP DATABASE @name 
		TO URL = @fileName
		WITH 
			CREDENTIAL = ''AzureBlobBackup'',
			FORMAT, 
			INIT,  
			MEDIANAME = @name,  
			NAME = @name, 
			SKIP, 
			NOREWIND, 
			NOUNLOAD, 
			COMPRESSION, 
			ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = [BackupEncryptionCertificate]),  
			STATS = 10, 
			CHECKSUM 

       FETCH NEXT FROM db_cursor INTO @name   
END   

CLOSE db_cursor   
DEALLOCATE db_cursor 
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily Backup at 00:00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170501, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c5ebe55e-3936-459c-9f2a-68fba60f2ef7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


