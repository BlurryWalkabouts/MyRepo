CREATE SECURITY POLICY [Security].[changeFilterPolicy] 
ADD FILTER PREDICATE [security].[fn_rlsChangeSecurityPredicate]([CustomerKey],[CoordinatorGroupKey],(1)) ON [Fact].[Change]
WITH (STATE = ON, SCHEMABINDING = OFF)
NOT FOR REPLICATION
GO