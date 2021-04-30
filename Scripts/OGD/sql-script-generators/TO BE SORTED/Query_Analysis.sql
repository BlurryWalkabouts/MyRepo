USE master
go
SELECT sdest.DatabaseName 
    ,sdes.session_id
    ,sdes.[host_name]
    ,sdes.[program_name]
    ,sdes.client_interface_name
    ,sdes.login_name
    ,sdes.login_time
    ,sdes.nt_domain
    ,sdes.nt_user_name
    ,sdec.client_net_address
    ,sdec.local_net_address
    ,sdest.ObjName
    ,sdest.Query
FROM sys.dm_exec_sessions AS sdes
INNER JOIN sys.dm_exec_connections AS sdec ON sdec.session_id = sdes.session_id
CROSS APPLY (
    SELECT db_name(dbid) AS DatabaseName
        ,object_id(objectid) AS ObjName
        ,ISNULL((
                SELECT TEXT AS [processing-instruction(definition)]
                FROM sys.dm_exec_sql_text(sdec.most_recent_sql_handle)
                FOR XML PATH('')
                    ,TYPE
                ), '') AS Query

    FROM sys.dm_exec_sql_text(sdec.most_recent_sql_handle)
    ) sdest
where sdes.session_id <> @@SPID 
and sdes.nt_user_name = 'sa_anywhere365' 
--and DatabaseName = 'Anywhere365_UCC'
ORDER BY sdec.session_id


SELECT        SQLTEXT.text, STATS.last_execution_time
FROM          sys.dm_exec_query_stats STATS
CROSS APPLY   sys.dm_exec_sql_text(STATS.sql_handle) AS SQLTEXT
WHERE         STATS.last_execution_time BETWEEN '2018-10-24' AND '2018-10-25'
ORDER BY      STATS.last_execution_time DESC

SELECT is_nullable
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE column_name = 'sip' AND table_name = 'UCC_AgentPresence'


exec sp_who2

SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext