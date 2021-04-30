CREATE PROCEDURE [log].[LogNewAudit]
(
	@SourceDatabaseKey int
	, @SourceName nvarchar(255)
	, @SourceType nvarchar(20)
	, @TargetName nvarchar(100)
	, @NewBatch bit = 0 -- Generate a new BatchDWKey if =1
	, @PackageGUID uniqueidentifier = NULL
	, @ExecutionGUID uniqueidentifier = NULL
	, @ServerExecutionID bigint = NULL
	, @PackageVersionGUID uniqueidentifier = NULL
	, @RowsProcessed int = 0
	, @AuditDWKey int = 0 OUTPUT
)
AS
BEGIN

-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
SET NOCOUNT ON

DECLARE @BatchNo int
DECLARE @PackageNo int

IF @NewBatch = 0
	SELECT @BatchNo = NEXT VALUE FOR dbo.BatchNo
ELSE
	SELECT @BatchNo = CONVERT(int,current_value) FROM sys.sequences WHERE [name] = 'BatchNo'

INSERT INTO
	[log].[Audit]
	(
	BatchDWKey
	, SourceDatabaseKey
	, SourceName
	, SourceType
	, TargetName
	, PackageGUID
	, PackageVersionGUID
	, ServerExecutionID
	, ExecutionID
	, StagingRowsProcessed
	)
VALUES
	(
	@BatchNo
	, @SourceDatabaseKey
	, @SourceName
	, @SourceType
	, @TargetName
	, @PackageGUID
	, @PackageVersionGUID
	, @ServerExecutionID
	, @ExecutionGUID
	, @RowsProcessed
	)
	
SELECT @AuditDWKey = CAST(SCOPE_IDENTITY() AS int)

END