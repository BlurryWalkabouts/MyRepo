/*
CREATE MASTER KEY;
GO

CREATE DATABASE SCOPED CREDENTIAL [LiftMasterDataCredential] WITH IDENTITY = 'sa_MasterDataReader',
SECRET = 'xqj8932r8g67fbivnlbogypq2983r7129412471256285!313131241!!341242425@#$@%345tf43t4!';
GO

CREATE DATABASE SCOPED CREDENTIAL [LiftActiveDirectoryManagerCredential] WITH IDENTITY = 'sa_ActiveDirectoryManager', 
SECRET = 'poker-GK9Wmtr$LJMcT^*3P-jw3t@vrPzZCpmqcCKAXXD7VQnfseeNRAB39#Nv4uh'

CREATE EXTERNAL DATA SOURCE [LiftActiveDirectoryManagement] WITH (TYPE = RDBMS, LOCATION = N'ogd-replica-001013.database.windows.net', CREDENTIAL = [LiftActiveDirectoryManagerCredential], DATABASE_NAME = N'lift');

CREATE EXTERNAL DATA SOURCE [LiftMasterData] WITH (TYPE = RDBMS, LOCATION = N'ogd-replica-001013.database.windows.net', CREDENTIAL = [LiftMasterDataCredential], DATABASE_NAME = N'lift');
GO
*/
IF OBJECT_ID('ActiveDirectoryManagement.EmployeesDisabled') IS NOT NULL DROP EXTERNAL TABLE [ActiveDirectoryManagement].[EmployeesDisabled]
GO
CREATE EXTERNAL TABLE [ActiveDirectoryManagement].[EmployeesDisabled]
(
	[Name] [nvarchar](6)  NOT NULL,
	[DateDisabled] [datetime]NULL,
	[Disabled] [bit] NOT NULL,
	[Reason] [nvarchar](MAX) NULL,
	[DisabledBy_Code] [uniqueidentifier]NULL,
	[DisabledBy_Name] [nvarchar](6) NULL,
	[DisabledBy_Desc] [nvarchar](40) NULL
)
WITH (DATA_SOURCE = [LiftActiveDirectoryManagement], Schema_name='ActiveDirectoryManagement', object_name='EmployeesDisabled')
GO

IF OBJECT_ID('ActiveDirectoryManagement.EmployeesAuditLastModified') IS NOT NULL DROP EXTERNAL TABLE [ActiveDirectoryManagement].[EmployeesAuditLastModified]
GO
CREATE EXTERNAL TABLE [ActiveDirectoryManagement].[EmployeesAuditLastModified]
(
	[Name] [nvarchar](6)  NOT NULL,
	[DateModified] [datetime]NULL,
	[ModifiedBy_Code] [uniqueidentifier] NOT NULL,
	[ModifiedBy_Name] [nvarchar](6)  NOT NULL,
	[ModifiedBy_Desc] [nvarchar](40)  NOT NULL
)
WITH (DATA_SOURCE = [LiftActiveDirectoryManagement], Schema_name='ActiveDirectoryManagement', object_name='EmployeesAuditLastModified')
GO

IF OBJECT_ID('HumanResources.Employee') IS NOT NULL DROP EXTERNAL TABLE [HumanResources].[Employee]
GO
CREATE EXTERNAL TABLE [HumanResources].[Employee]
(
	[Name] [nvarchar](6)  NOT NULL,
	[Code] [uniqueidentifier] NOT NULL,
	[FirstName] [nvarchar](20) NULL,
	[LastName] [nvarchar](30) NULL,
	[LastNamePrefixes] [nvarchar](10) NULL,
	[Initals] [nvarchar](10) NULL,
	[PostalCode] [nvarchar](4) NULL,
	[City] [nvarchar](30)  NOT NULL,
	[Gender] [int] NOT NULL,
	[YearOfBirth] [int]NULL,
	[EmailAddress] [nvarchar](75)  NOT NULL,
	[TelephoneNumber] [nvarchar](4000) NULL,
	[BusinessUnit_Code] [uniqueidentifier]NULL,
	[BusinessUnit_Name] [nvarchar](35) NULL,
	[Team_Code] [uniqueidentifier]NULL,
	[Team_Name] [nvarchar](35) NULL,
	[Function_Code] [uniqueidentifier]NULL,
	[Function_Name] [nvarchar](40) NULL,
	[FunctionLevel_Code] [uniqueidentifier]NULL,
	[FunctionLevel_Name] [nvarchar](35) NULL,
	[Manager_Code] [uniqueidentifier]NULL,
	[Manager_Name] [nvarchar](35) NULL,
	[CareerAdvisor_Code] [uniqueidentifier]NULL,
	[CareerAdvisor_Name] [nvarchar](35) NULL,
	[CareerAdvisorDateNextAppointment] [date]NULL,
	[EmployeeAvailability] [int] NOT NULL,
	[ContractAvailability] [money]NULL,
	[ContractAvailabilityPercentage] [money]NULL,
	[ContractType] [nvarchar](30) NULL,
	[EmployeeHasInternalAssignment_Code] [int] NOT NULL,
	[ContractHasReturnedSignedCopy_Code] [int]NULL,
	[ContractAdvisedExternalHourlyRate] [money]NULL,
	[CarHasDriversLicense_Code] [bit] NOT NULL,
	[CarIsOwner_Code] [bit] NOT NULL,
	[IsArchived_Code] [int] NOT NULL,
	[Hash] [varbinary](8000) NULL,
	[LIFTLastModifiedBy_Code] [uniqueidentifier]NULL,
	[LIFTLastModifiedBy_Name] [nvarchar](6) NULL,
	[LIFTLastModifiedBy_Desc] [nvarchar](40) NULL
)
WITH (DATA_SOURCE = [LiftMasterData], Schema_name='MasterData', object_name='Employee')