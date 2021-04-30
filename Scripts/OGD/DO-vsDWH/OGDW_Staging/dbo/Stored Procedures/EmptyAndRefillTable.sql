
CREATE procedure [dbo].[EmptyAndRefillTable]
		 @schema varchar(32) 
		, @table varchar(32) 
		, @status bit  
		, @debug bit = 0
as
begin

/*

This sproc can be used when adding new fields to production. 
Running it will assist  in filling all current records which use the new field.

Run this sproc before running the ssis package to empty the table, Run it againg 
with status =1 to refill the table with the old records.

Status = 0
backs up the selected table to new table_backup. And then truncates original staging table

Status = 1 
reinserts old records back to original staging table and drops old table



exec ogdw_staging.dbo.EmptyAndRefillTable 'topdesk','incident__memogeschiedenis' ,0 , @debug= 1
select DISTINCT * from ogdw_staging.topdesk.incident__memogeschiedenis


exec ogdw_staging.dbo.EmptyAndRefillTable 'topdesk','mutatie_incident' ,0 ,  @debug= 1
select * from ogdw_staging.topdesk.mutatie_incident
*/


declare @sql varchar(max)
		, @table_backup varchar(max) = @table +'_backup'

if @status = 0

begin
 
	set @sql =
	'EXEC sp_rename '''+@schema+'.'+@table+''','''+ @table_backup  + ''';
	select top 0 * into ogdw_staging.'+@schema+ '.' + @table + 
	' from ogdw_staging.' + @schema + '.'+ @table_backup  + ';
 	 '
if @debug = 1 print (@sql) else exec (@sql)
end


else
 begin

set @sql =
    '
    insert into ogdw_staging.'+@schema+ '.' + @table_backup + ' select * from ogdw_staging.'+@schema+'.'+@table + ';
    	drop table ogdw_staging.'+ @schema +'.' +@table  + ';
     EXEC sp_rename '''+@schema+'.'+@table_backup+''','''+ @table  + ''';'


	if @debug = 1 print (@sql) else exec (@sql)

 end

end