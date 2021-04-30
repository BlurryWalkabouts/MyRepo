


CREATE view [Dim].[vwDateTimeMovedtoMetadata] as 
(
select 
	cast( cast(D.[Date] as char(10)) + ' ' + cast(T.[Time] as char(8)) as datetime2(3)) as [DateTime]
	,D.[Date]
	,T.[Time]
from Dim.[Date] D
cross join Dim.[Time] T
)