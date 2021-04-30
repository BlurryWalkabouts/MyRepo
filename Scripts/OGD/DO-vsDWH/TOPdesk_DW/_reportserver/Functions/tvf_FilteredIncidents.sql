-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [dbo].[tvf_FilteredIncidents]
(	
	-- Add the parameters for the function here
	@Customer AS varchar(max)
	, @SourceDatabaseKey AS varchar(max)
	, @IncIsMajorIncident AS varchar(max)
	, @IncSlaAchievedFlag AS varchar(max)
	, @IncHandledByOgdFlag AS varchar(max)

	, @IncCategory AS varchar(max)
	, @IncEntryType AS varchar(max)
	, @IncEntryTypeSTD AS varchar(max)
	, @IncImpact AS varchar(max)
	, @IncLine AS varchar(max)
	, @ObjectID AS varchar(max)
	, @IncPriority AS varchar(max)
	, @IncPrioritySTD AS varchar(max)
	, @IncSLA AS varchar(max)
	, @IncStandardSolution AS varchar(max)
	, @IncStatus AS varchar(max)
	, @IncStatusSTD AS varchar(max)
	, @IncSubcategory AS varchar(max) 
	, @IncSupplier AS varchar(max)
	, @IncType AS varchar(max)
	, @IncTypeSTD AS varchar(max)

	, @CustomerGroup AS varchar(max)
	, @EndUserServiceType AS varchar(max)
	, @SysAdminServiceType AS varchar(max)
	, @SlaCustomer AS varchar(max)

	, @CallerBranch AS varchar(max)
	, @CallerCity AS varchar(max)
	, @Department AS varchar(max)

	, @OperatorGroup AS varchar(max)
	, @OperatorGroupSTD AS varchar(max)
	, @EntryOperatorGroup AS varchar(max)
	, @EntryOperatorGroupSTD AS varchar(max)

	, @ReportDate AS date
	, @ReportInterval AS nvarchar(50)
	, @ReportPeriod AS int
)
RETURNS TABLE
AS
RETURN
(
SELECT
	I.Incident_Id
	, I.IncidentNumber
	, I.IncidentDescription

	, I.IncidentDate
	, I.IncidentTime
	, I.CreationDate
	, I.CreationTime
	, I.CompletionDate
	, I.ClosureDate
	, I.ClosureTime
	, I.TargetDate

	, I.CustomerKey
	, I.SourceDatabaseKey
	, I.IsMajorIncident
	, I.SlaAchievedFlag
	, HandledByOgdFlag = 0 --logica toevoegen in fact-table
	, I.DurationAdjustedActualCombi

	, I.Category
	, I.EntryType
	, I.EntryTypeSTD
	, I.Impact
	, I.Line
	, I.ObjectID
	, I.[Priority]
	, I.PrioritySTD
	, I.Sla AS IncSLA
	, I.SlaTargetDate
	, I.StandardSolution
	, I.[Status]
	, I.StatusSTD
	, I.Subcategory
	, I.Supplier
	, I.IncidentType
	, I.IncidentTypeSTD

	, C.Fullname
	, C.CustomerGroup
	, C.EndUserServiceType
	, C.SysAdminServiceType
	, C.SLA
	, C.SupportWindow_ID
	, C.SupportWeekend

	, CA.CallerName
	, CA.CallerBranch
	, CA.CallerCity
	, CA.Department

	, OG.OperatorGroup
	, OG.OperatorGroupSTD
	, EntryOperatorGroup = '' --logica toevoegen in fact-table
	, EntryOperatorGroupSTD = 'Servicedesk' --logica toevoegen in fact-table
FROM
	Fact.Incident I
	LEFT OUTER JOIN Dim.Customer C ON I.CustomerKey = C.CustomerKey
	LEFT OUTER JOIN Dim.OperatorGroup AS OG ON I.OperatorGroupKey = OG.OperatorGroupKey
	LEFT OUTER JOIN Dim.[Caller] CA ON CA.CallerKey = I.CallerKey
WHERE 1=1
	AND (I.CustomerKey IN(SELECT * FROM [fn_CSVToTable](@Customer))) --@Customer of @CustomerKey?
	AND (@SourceDatabaseKey = -99 OR I.SourceDatabaseKey IN(SELECT * FROM [fn_CSVToTable](@SourceDatabaseKey))) --@SourceDatabase of @SourceDatabaseKey?
--	AND (I.IsMajorIncident IN(@IncIsMajorIncident)) -- Bit. Where-filter moet nog worden uitgedacht
--	AND (I.SlaAchievedFlag IN(@IncSlaAchievedFlag)) -- Bit. Where-filter moet nog worden uitgedacht

	AND ('All' IN(@IncCategory) OR I.Category IN(SELECT * FROM [fn_CSVToTable](@IncCategory)))
	AND ('All' IN(@IncEntryType) OR I.EntryType IN(SELECT * FROM [fn_CSVToTable](@IncEntryType)))
	AND ('All' IN(@IncEntryTypeSTD) OR I.EntryTypeSTD IN(SELECT * FROM [fn_CSVToTable](@IncEntryTypeSTD)))
	AND ('All' IN(@IncImpact) OR I.Impact IN(SELECT * FROM [fn_CSVToTable](@IncImpact)))
	AND ('All' IN(@IncLine) OR I.Line IN(SELECT * FROM [fn_CSVToTable](@IncLine)))
	AND ('All' IN(@ObjectID) OR I.ObjectID IN(SELECT * FROM [fn_CSVToTable](@ObjectID))) --@ObjectID of @IncObjectID?
	AND ('All' IN(@IncPriority) OR I.Priority IN(SELECT * FROM [fn_CSVToTable](@IncPriority)))
	AND ('All' IN(@IncPrioritySTD) OR I.PrioritySTD IN(SELECT * FROM [fn_CSVToTable](@IncPrioritySTD)))
	AND ('All' IN(@IncSLA) OR I.Sla IN(SELECT * FROM [fn_CSVToTable](@IncSLA)))
	AND ('All' IN(@IncStandardSolution) OR I.StandardSolution IN(SELECT * FROM [fn_CSVToTable](@IncStandardSolution)))
	AND ('All' IN(@IncStatus) OR I.Status IN(SELECT * FROM [fn_CSVToTable](@IncStatus)))
	AND ('All' IN(@IncStatusSTD) OR I.StatusSTD IN(SELECT * FROM [fn_CSVToTable](@IncStatusSTD)))
	AND ('All' IN(@IncSubcategory) OR I.Subcategory IN(SELECT * FROM [fn_CSVToTable](@IncSubcategory)))
	AND ('All' IN(@IncSupplier) OR I.Supplier IN(SELECT * FROM [fn_CSVToTable](@IncSupplier)))
	AND ('All' IN(@IncType) OR I.IncidentType IN(SELECT * FROM [fn_CSVToTable](@IncType)))
	AND ('All' IN(@IncTypeSTD) OR I.IncidentTypeSTD IN(SELECT * FROM [fn_CSVToTable](@IncTypeSTD)))

	AND ('All' IN(@CustomerGroup) OR C.CustomerGroup IN(SELECT * FROM [fn_CSVToTable](@CustomerGroup)))
	AND ('All' IN(@EndUserServiceType) OR C.EndUserServiceType IN(SELECT * FROM [fn_CSVToTable](@EndUserServiceType)))
	AND ('All' IN(@SysAdminServiceType) OR C.SysAdminServiceType IN(SELECT * FROM [fn_CSVToTable](@SysAdminServiceType)))
	AND ('All' IN(@SlaCustomer) OR C.SLA IN(SELECT * FROM [fn_CSVToTable](@SlaCustomer)))

	AND ('All' IN(@CallerBranch) OR CA.CallerBranch IN(SELECT * FROM [fn_CSVToTable](@CallerBranch)))
	AND ('All' IN(@CallerCity) OR CA.CallerCity IN(SELECT * FROM [fn_CSVToTable](@CallerCity)))
	AND ('All' IN(@Department) OR CA.Department IN(SELECT * FROM [fn_CSVToTable](@Department)))

	AND ('All' IN(@OperatorGroup) OR OG.OperatorGroup IN(SELECT * FROM [fn_CSVToTable](@OperatorGroup)))
	AND ('All' IN(@OperatorGroupSTD) OR OG.OperatorGroupSTD	IN(SELECT * FROM [fn_CSVToTable](@OperatorGroupSTD)))

	AND (ClosureDate >= dbo.ReportStartDate(@ReportDate,@ReportPeriod,@ReportInterval) OR ClosureDate IS NULL)
	AND IncidentDate <= DATEADD(MI,-1,DATEADD(day,1,CAST(@ReportDate AS smalldatetime)))
)

--SELECT * FROM dbo.tvf_FilteredIncidents('33','-99','1','1','1','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','All','20160522','Month','13')

--SELECT * FROM dbo.tvf_FilteredIncidents(@Customer,@SourceDatabase,@IncIsMajor,@IncSlaAchievedFlag,@IncHandledByOgdFlag,@IncCategory,@IncEntryType,@IncEntryTypeSTD,@IncImpact,@IncLine,@ObjID,@IncPriority,@IncPrioritySTD,@IncSLA,@IncStandardSolution,@IncStatus,@IncStatusSTD,@IncSubcategory,@IncSupplier,@IncType,@IncTypeSTD,@CustomerGroup,@EndUserService,@SysAdminService,@CustomerSLA,@CallerBranch,@CallerCity,@CallerDepartment,@OperatorGroup,@OperatorGroupSTD,@EntryOperatorGroup,@EntryOperatorGroupSTD,@ReportDate,@ReportInterval,@ReportPeriod)
