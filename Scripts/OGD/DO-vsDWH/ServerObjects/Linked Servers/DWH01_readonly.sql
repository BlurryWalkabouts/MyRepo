EXEC sp_addlinkedserver
	@server = N'DWH01_readonly'
	, @srvproduct = N'SQL Server'
	, @provider = N'SQLNCLI11'
	, @datasrc = N'DWH01'
	, @provstr = N'ApplicationIntent=ReadOnly'
GO