/*
select * from dbo.[Permission]

select * from tmp.[Permission] S
LEFT JOIN dbo.[Permission] T ON (T.[Role ID] = S.[Role ID] AND T.[Object Type] = S.[Object Type] AND T.[Object ID] = S.[Object ID])
WHERE T.[Role ID] IS NOT NULL
*/

BEGIN TRAN

MERGE dbo.[Permission] T
USING tmp.[BACKUP_Permission] S
	ON (T.[Role ID] = S.[Role ID] AND T.[Object Type] = S.[Object Type] AND T.[Object ID] = S.[Object ID])
	/*
WHEN MATCHED THEN
	UPDATE SET 
		T.[Read Permission] = S.[Read Permission],
		T.[Insert Permission] = S.[Insert Permission],
		T.[Modify Permission] = S.[Modify Permission],
		T.[Delete Permission] = S.[Delete Permission],
		T.[Execute Permission] = S.[Execute Permission],
		T.[Security Filter] = CAST(S.[Security Filter] AS VARBINARY)
*/
WHEN NOT MATCHED THEN
	INSERT ([Role ID], [Object Type], [Object ID], [Read Permission], [Insert Permission], [Modify Permission], [Delete Permission], [Execute Permission], [Security Filter])
	VALUES (S.[Role ID], S.[Object Type], S.[Object ID], S.[Read Permission], S.[Insert Permission], S.[Modify Permission], S.[Delete Permission], S.[Execute Permission], CAST(S.[Security Filter] AS VARBINARY))
--WHEN NOT MATCHED BY SOURCE THEN
--	DELETE
	

OUTPUT
   $action,
   inserted.*,
   deleted.*;

select count(*) from dbo.[Permission]

select count(*) from tmp.[Permission]

/*
INSERT INTO [dbo].[Permission] ([Role ID], [Object Type], [Object ID], [Read Permission], [Insert Permission], [Modify Permission], [Delete Permission], [Execute Permission], [Security Filter])
select [Role ID], [Object Type], [Object ID], [Read Permission], [Insert Permission], [Modify Permission], [Delete Permission], [Execute Permission], [Security Filter] from tmp.[BACKUP_Permission] where [Role ID] in ('FIN-BANK BOEKEN', 'FIN-TELEBANKIEREN')
*/

ROLLBACK;

select * from dbo.[Permission] WHERE [Object ID] = '1270'