CREATE PROCEDURE [etl].[AddExistingCallsToNewCustomer]
AS
BEGIN

-- =============================================
-- Author: Koen Ubbink
-- Create date: 12-09-2016
-- Description: Corrects unknown CustomerKeys after changes to mappings of calls.
-- =============================================

SET NOCOUNT ON

;WITH keys AS
(
SELECT
	SkillChosen
	, CustomerKey
FROM
	[$(OGDW)].Fact.[Call]
WHERE 1=1
	AND CustomerKey > 0
GROUP BY
	SkillChosen
	, CustomerKey
)

UPDATE
	c
SET
	CustomerKey = k.CustomerKey
FROM
	[$(OGDW)].Fact.[Call] c
	INNER JOIN keys k ON c.SkillChosen = k.SkillChosen
WHERE 1=1
	AND c.CustomerKey = -1

END