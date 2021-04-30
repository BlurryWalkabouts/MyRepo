CREATE SECURITY POLICY [Security].[problemFilterPolicy] 
ADD FILTER PREDICATE [security].[fn_rlsProblemSecurityPredicate]([CustomerKey],[OperatorGroupKey],(1)) ON [Fact].[Problem]
WITH (STATE = ON, SCHEMABINDING = OFF)
NOT FOR REPLICATION
GO