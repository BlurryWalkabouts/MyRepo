CREATE PROCEDURE [etl].[RecreateFK]
AS
BEGIN
	
DECLARE @print nvarchar(max)
DECLARE @newStartDate datetime
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Dim.[Object]
ADD CONSTRAINT FK_Object_CallerKey FOREIGN KEY (CallerKey)
REFERENCES [$(OGDW)].Dim.[Caller] (CallerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Object_CallerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Object_CallerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Dim.[Object]
ADD CONSTRAINT FK_Object_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES [$(OGDW)].Dim.Customer (CustomerKey)
	
EXEC [log].[Log]
	@Message = 'Creating FK_Object_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Object_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Incident
ADD CONSTRAINT FK_Incident_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES [$(OGDW)].Dim.Customer (CustomerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID
END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Incident
ADD CONSTRAINT FK_Incident_ObjectKey FOREIGN KEY (ObjectKey)
REFERENCES [$(OGDW)].Dim.[Object] (ObjectKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_ObjectKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_ObjectKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Incident
ADD CONSTRAINT FK_Incident_CallerKey FOREIGN KEY (CallerKey)
REFERENCES [$(OGDW)].Dim.[Caller] (CallerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_CallerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_CallerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Incident
ADD CONSTRAINT FK_Incident_OperatorGroupKey FOREIGN KEY (OperatorGroupKey)
REFERENCES [$(OGDW)].Dim.OperatorGroup (OperatorGroupKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_OperatorGroupKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Incident_OperatorGroupKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Problem
ADD CONSTRAINT FK_Problem_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES [$(OGDW)].Dim.Customer (CustomerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Problem_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Problem_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Problem
ADD CONSTRAINT FK_Problem_OperatorKey FOREIGN KEY (OperatorKey)
REFERENCES [$(OGDW)].Dim.[Caller] (CallerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Problem_OperatorKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FFK_Problem_OperatorKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Problem
ADD CONSTRAINT FK_Problem_OperatorGroupKey FOREIGN KEY (OperatorGroupKey)
REFERENCES [$(OGDW)].Dim.OperatorGroup (OperatorGroupKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Problem_OperatorGroupKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Problem_OperatorGroupKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Change
ADD CONSTRAINT FK_Change_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES [$(OGDW)].Dim.Customer (CustomerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Change_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()
EXEC [log].[Log]
	@Message = 'Creating FK_Change_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Change
ADD CONSTRAINT FK_Change_CallerKey FOREIGN KEY (CallerKey)
REFERENCES [$(OGDW)].Dim.[Caller] (CallerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Change_CallerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Change_CallerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.Change
ADD CONSTRAINT FK_Change_OperatorGroupKey FOREIGN KEY (OperatorGroupKey)
REFERENCES [$(OGDW)].Dim.OperatorGroup (OperatorGroupKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Change_OperatorGroupKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Change_OperatorGroupKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.[Call]
ADD CONSTRAINT FK_Call_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES [$(OGDW)].Dim.Customer (CustomerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_Call_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_Call_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/*****************************

Tabel is verwijderd

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE Fact.CallCountPerHalfHour
ADD CONSTRAINT FK_CallCountPerHalfHour_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES Dim.Customer (CustomerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_CallCountPerHalfHour_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_CallCountPerHalfHour_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.ChangeActivity
ADD CONSTRAINT FK_ChangeActivity_ChangeKey FOREIGN KEY (ChangeKey)
REFERENCES [$(OGDW)].Fact.Change (Change_Id)

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivity_ChangeKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivity_ChangeKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.ChangeActivity
ADD CONSTRAINT FK_ChangeActivity_CustomerKey FOREIGN KEY (CustomerKey)
REFERENCES [$(OGDW)].Dim.Customer (CustomerKey)

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivity_CustomerKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivity_CustomerKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.ChangeActivity
ADD CONSTRAINT FK_ChangeActivity_OperatorGroupKey FOREIGN KEY (OperatorGroupKey)
REFERENCES [$(OGDW)].Dim.OperatorGroup (OperatorGroupKey)

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivity_OperatorGroupKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivity_OperatorGroupKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.ChangeActivityWithPrevious
ADD CONSTRAINT FK_ChangeActivityWithPrevious_ChangeKey FOREIGN KEY (ChangeKey)
REFERENCES [$(OGDW)].Fact.Change (Change_Id)

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivityWithPrevious_ChangeKey successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivityWithPrevious_ChangeKey FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

BEGIN TRY 

SET @newStartDate = GETDATE()

ALTER TABLE [$(OGDW)].Fact.ChangeActivityWithPrevious
ADD CONSTRAINT FK_ChangeActivityWithPrevious_ChangeActivity_ID FOREIGN KEY (ChangeActivity_Id)
REFERENCES [$(OGDW)].Fact.ChangeActivity (ChangeActivity_Id)

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivityWithPrevious_ChangeActivity_ID successful...'
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END TRY
BEGIN CATCH

PRINT ERROR_MESSAGE()

EXEC [log].[Log]
	@Message = 'Creating FK_ChangeActivityWithPrevious_ChangeActivity_ID FAILED...'
	, @Success = 0
	, @StartDate = @newStartDate
	, @SessionID = @newSessionID
	, @ObjectID = @newObjectID

END CATCH

/******************************/

END