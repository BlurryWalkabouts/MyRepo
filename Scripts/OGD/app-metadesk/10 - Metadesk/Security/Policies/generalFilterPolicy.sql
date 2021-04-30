CREATE SECURITY POLICY [Security].[generalFilterPolicy] 
ADD FILTER PREDICATE [security].[fn_rlsGeneralSecurityPredicate]([CustomerKey],[OperatorGroupKey],(1)) ON [Fact].[Incident],
ADD FILTER PREDICATE [security].[fn_rlsGeneralSecurityPredicate]([CustomerKey],[OperatorGroupKey],(1)) ON [Fact].[ChangeActivity],
ADD FILTER PREDICATE [security].[fn_rlsGeneralSecurityPredicate]([CustomerKey],[OperatorGroupKey],(1)) ON [Fact].[OperationalActivity]
WITH (STATE = ON, SCHEMABINDING = OFF)
NOT FOR REPLICATION
GO