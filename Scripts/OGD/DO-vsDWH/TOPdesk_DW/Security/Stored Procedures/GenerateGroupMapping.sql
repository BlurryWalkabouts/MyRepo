CREATE PROCEDURE [Security].[GenerateGroupMapping]
AS

SET NOCOUNT ON
	
-- This sproc inserts defaults groups

-- Clear up existing mappings
-- Using delete because of future replication
DELETE FROM [Security].AzureGroup

-- Resetting seed
DBCC CHECKIDENT ('Security.AzureGroup', RESEED, 1)

INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('D85E1D8D-EB09-4653-8B91-98C808E0D44B', 'Member-BU-Beheer-Outsourcing-Serverteam-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('E9F0B228-DA55-4A90-B0C3-E3138C927388', 'Member-BU-Beheer-Outsourcing-Serverteam2-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('2A364DAD-48EE-44A9-A90D-AA6E197F6114', 'Member-BU-Beheer-Outsourcing-Serverteam3-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('0D46596C-B4E7-4DE6-A5AF-39046DD0350D', 'Member-BU-Beheer-Outsourcing-Serverteam4-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('A36B8114-6A02-4FAF-B57C-E63195F1768C', 'Member-InterneAutomatisering-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('11B5CF61-4FBD-46E3-88A5-C7A3FDB719AB', 'Member-BU-SoftwareOntwikkeling-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES ('83EF57EC-9E69-43E6-8785-CB54305F4B6C', 'Member-BU-Beheer-Outsourcing-Netwerkteam-Medewerkers')
INSERT INTO [Security].AzureGroup ([Guid], [Name]) VALUES (NULL, 'Member-BU-Beheer-Outsourcing-Applicatieteam-Medewerkers')

-- Inserting operator group mappings
DELETE FROM [Security].AzureGroupMapping WHERE AzureGroupID IN (1,2,3,4,7,8)

INSERT INTO [Security].AzureGroupMapping (AzureGroupID, CustomerKey, OperatorGroupKey, OperatorGroupGuid)
SELECT AzureGroupID, CustomerKey, OperatorGroupKey, OperatorGroupGuid 
FROM [Security].ADtoOperatorGroupMappings

RETURN 0