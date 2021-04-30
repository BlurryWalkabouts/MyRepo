EXEC sp_addlinkedserver
	@server = N'REPLICA_001013_henk'
	, @srvproduct = N'SQL Server'
	, @provider = N'SQLNCLI11'
	, @datasrc = N'ogd-replica-001013.database.windows.net'
	, @catalog=N'lift'
	, @provstr = N'ApplicationIntent=ReadOnly';
GO