CREATE OR ALTER PROCEDURE [metadesk].[usp_fetchOperatorGroups] 
(
	@LastModified datetime2,
	@JsonSerializedResult nvarchar(max) OUTPUT
)
AS
BEGIN 

SET @JsonSerializedResult = (
SELECT TOP 1500
	 -- Identifier
	 [OperatorGroupGuid] = [unid]
	,[OperatorGroup] = [naam]
	,[ChangeDate] = [datwijzig]
	,[CustomerKey] = NULL
	,[CustomerNumber] = NULL
FROM [dbo].[actiedoor]
where naam != '' AND datwijzig >= @LastModified
ORDER BY ChangeDate ASC
FOR JSON PATH 
)
  RETURN 0
END
GO