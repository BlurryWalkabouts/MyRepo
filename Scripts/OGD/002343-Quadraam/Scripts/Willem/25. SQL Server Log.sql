DBCC TRACEON(1204,-1)
DBCC TRACEON(1222,-1)
DBCC TRACESTATUS (1204, -1)
DBCC TRACESTATUS (1222, -1)
DBCC TRACEOFF(1204,-1)
DBCC TRACEOFF(1222,-1)

EXEC sys.xp_readerrorlog
EXEC sys.xp_readerrorlog 0, 1, N'Login failed'

CREATE TABLE #ReadErrorLog
(
	LogDate datetime2
	, ProcessInfo varchar(10)
	, Text nvarchar(max)
)

INSERT INTO
	#ReadErrorLog
EXEC sys.xp_readerrorlog

SELECT * FROM #ReadErrorLog WHERE ProcessInfo <> 'Logon'
DROP TABLE #ReadErrorLog