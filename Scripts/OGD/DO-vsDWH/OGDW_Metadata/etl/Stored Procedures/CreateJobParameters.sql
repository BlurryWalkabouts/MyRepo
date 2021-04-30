CREATE PROCEDURE [etl].[CreateJobParameters]
AS
BEGIN
	DROP TABLE IF EXISTS etl.TOPdesk_DW_JobParameters

	CREATE TABLE etl.TOPdesk_DW_JobParameters (
		dbName nvarchar(64)
	)

	INSERT INTO etl.TOPdesk_DW_JobParameters (dbName) VALUES ('[$(OGDW)]')
END
