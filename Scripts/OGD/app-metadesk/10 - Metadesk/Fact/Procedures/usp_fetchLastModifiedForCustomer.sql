CREATE procedure [Fact].[usp_fetchLastModifiedForCustomer] (
	@CustomerNumber nvarchar(10),
	@CustomerKey int OUTPUT,
	@LastModifiedIncident datetime2 OUTPUT,
	@LastModifiedChange datetime2 OUTPUT,
	@LastModifiedChangeActivity datetime2 OUTPUT,
	@LastModifiedProblem datetime2 OUTPUT,
	@LastModifiedOperatorGroup datetime2 OUTPUT,
	@LastModifiedOperationalActivity datetime2 OUTPUT
)
WITH EXECUTE AS OWNER
AS
BEGIN
	-- Verifying format of customernumber
	IF @CustomerNumber NOT LIKE '00[0-9][0-9][0-9][0-9]' AND @CustomerNumber NOT LIKE '00[0-9][0-9][0-9][0-9].[0-9][0-9][0-9]'  BEGIN
		THROW 51000, 'Invalid customernumber, expected 00[0-9]{4} OR 00[0-9]{4}.[0-9]{3} as pattern', 1;
	END 

	-- Fetching CustomerKey based upon customernumber
	SET @CustomerKey = (SELECT CustomerKey FROM Dim.Customer WHERE CustomerNumber = @CustomerNumber)
	
	-- Fetching the LastModified dates. Here a bit of trickery is needed due to how the date/time split
	SET @LastModifiedOperatorGroup = (SELECT 
									COALESCE(MAX(ChangeDate), '1970-01-01') 
								 FROM Dim.OperatorGroup
								 WHERE CustomerKey = @CustomerKey)

	SET @LastModifiedIncident = (SELECT 
									COALESCE(MAX(ChangeDate), '1970-01-01') 
								 FROM Fact.Incident
								 WHERE CustomerKey = @CustomerKey)

	SET @LastModifiedChange = (SELECT 
									COALESCE(MAX(ChangeDate), '1970-01-01') 
								 FROM Fact.Change
								 WHERE CustomerKey = @CustomerKey)
								 
	SET @LastModifiedChangeActivity = (SELECT 
									COALESCE(MAX(ChangeDate), '1970-01-01') 
								 FROM Fact.ChangeActivity
								 WHERE CustomerKey = @CustomerKey)

	SET @LastModifiedProblem = (SELECT 
									COALESCE(MAX(ChangeDate), '1970-01-01') 
								 FROM Fact.Problem
								 WHERE CustomerKey = @CustomerKey)


	SET @LastModifiedOperationalActivity = (SELECT 
									COALESCE(MAX(ChangeDate), '1970-01-01') 
								 FROM Fact.OperationalActivity
								 WHERE CustomerKey = @CustomerKey)

	RETURN 0
END