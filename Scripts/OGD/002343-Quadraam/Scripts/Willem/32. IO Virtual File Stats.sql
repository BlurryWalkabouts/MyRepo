SELECT
	[database_name] = DB_NAME(database_id)
	, *
FROM
	sys.dm_io_virtual_file_stats(NULL, NULL)
ORDER BY
	[file_id]
	, num_of_bytes_written DESC