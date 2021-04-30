CREATE PROCEDURE [etl].[LoadDimColourSchema]
AS
BEGIN

-- ================================================
-- Create dim table for ColourSchema.
-- This is a straight copy from MDS.
-- ================================================

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM [$(OGDW)].Dim.ColourSchema

INSERT INTO
	[$(OGDW)].Dim.ColourSchema
	(
	Code
	, [Name]
	, Omschrijving
	, Inc_Aangemeld1
	, Inc_Aangemeld2
	, Inc_Aangemeld3
	, Inc_Aangemeld4
	, Inc_Afgemeld1
	, Inc_Afgemeld2
	, Inc_Afgemeld3
	, Inc_Afgemeld4
	, Inc_Openstaand1
	, Inc_Openstaand2
	, Inc_Openstaand3
	, Inc_Openstaand4
	, Inc_Gereed1
	, Inc_workload
	, Cha_Aangemeld1
	, Cha_Aangemeld2
	, Cha_Aangemeld3
	, Cha_Aangemeld4
	, Cha_Afgemeld1
	, Cha_Afgemeld2
	, Cha_Afgemeld3
	, Cha_Afgemeld4
	, Cha_Openstaand1
	, Cha_Openstaand2
	, Cha_Openstaand3
	, Cha_Openstaand4
	, Cha_Gereed1
	, Cha_workload
	, Line_target
	, Line_mean
	, DataLabel
	, DataLabelPerc
	, Call_Opgenomen
	, Call_Opgenomen1
	, Call_Opgenomen2
	, Call_Opgenomen3
	, Call_Opgenomen4
	, Call_Nietopgenomen
	, Call_workload
)
SELECT 
	Code
	, [Name]
	, Omschrijving
	, Inc_Aangemeld1
	, Inc_Aangemeld2
	, Inc_Aangemeld3
	, Inc_Aangemeld4
	, Inc_Afgemeld1
	, Inc_Afgemeld2
	, Inc_Afgemeld3
	, Inc_Afgemeld4
	, Inc_Openstaand1
	, Inc_Openstaand2
	, Inc_Openstaand3
	, Inc_Openstaand4
	, Inc_Gereed1
	, Inc_workload
	, Cha_Aangemeld1
	, Cha_Aangemeld2
	, Cha_Aangemeld3
	, Cha_Aangemeld4
	, Cha_Afgemeld1
	, Cha_Afgemeld2
	, Cha_Afgemeld3
	, Cha_Afgemeld4
	, Cha_Openstaand1
	, Cha_Openstaand2
	, Cha_Openstaand3
	, Cha_Openstaand4
	, Cha_Gereed1
	, Cha_workload
	, Line_target
	, Line_mean
	, DataLabel
	, DataLabelPerc
	, Call_Opgenomen
	, Call_Opgenomen1
	, Call_Opgenomen2
	, Call_Opgenomen3
	, Call_Opgenomen4
	, Call_nietopgenomen
	, Call_workload
FROM
	[$(MDS)].mdm.ColourSchema

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END