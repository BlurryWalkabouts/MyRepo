create procedure ReadFile (
	@basepath varchar(255) = 'D:\temp\' ,
	@filename varchar(255) = '20150720 120124 wijzigingen(Unive).xls', --'test.xlsx' 
	@sheetname varchar(255) = 'uitgebreide wijziging', --'Sheet1' --'eerstelijns melding'
	@destinationtable sysname = null  --optional destinationtable (schema.tablename)
	)
as 
begin

--check destinationtable 
if @destinationtable is not null
begin
	if @destinationtable like '%;%' throw 50003, 'Posible sql inject', 1;  --dit is geen heel geavanceerde check, maar het vangt de simpelste injects af
	if object_id(@destinationtable) is not null throw 50002, 'Destination table already exists', 1;  --de procedure die de aanroep doet moet ervoor zorgen dat de filenaam uniek is
end


declare @fullfilename varchar(max) = @basepath + @filename
declare @ext varchar(5)  --extension

--get extension from filename:
select @ext = (case when @filename like '%.%'
              then reverse(left(reverse(@filename), charindex('.', reverse(@filename)) - 1))
              else ''
         end) 

--providerstring depends on extension:
declare @providerstring varchar(max) = ''
if @ext = 'xls' set @providerstring = 'Excel 8.0;IMEX=1;HDR=YES;'
if @ext = 'xlsx' set @providerstring = 'Excel 12.0;IMEX=1;HDR=YES;'

if @providerstring = '' throw 50001, 'Unsupported file-extension', 1;


--remove existing linked server:
if exists (select * from sys.servers where name = 'Excelserver') 
EXEC sp_dropserver
    @server = N'ExcelServer',
    @droplogins='droplogins'


--create new linked server:
EXEC sp_addlinkedserver
    @server = 'ExcelServer',
    @srvproduct = 'Excel',
    @provider = 'Microsoft.ACE.OLEDB.12.0',
    @datasrc = @fullfilename,
    @provstr = @providerstring	
	

--deze methode werkt ook met spaties in sheetname!!:
declare @into nvarchar(max) = coalesce('into ' + @destinationtable,'')

declare @sql nvarchar(max) = 'SELECT * ' + @into +' FROM OPENQUERY(ExcelServer, ''SELECT * FROM [' + @sheetname + '$]'')' 

exec sp_executesql @sql --exec werkt niet met parameter @sheetname, sp_executesql werkt bovendien sneller

end
