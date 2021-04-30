#$myInstance = "localhost\SQLSERVER2016" #replace with your own, e.g. localhost\MSSQLSERVER2016
$myInstance = "localhost" #replace with your own, e.g. localhost\SQLSERVER2016
Write-Host "Changing all connectionstrings to " $myInstance

#Publish files:
Write-Host "Publish files:"
$configFiles = Get-ChildItem . *.publish.xml -Recurse 
ForEach ($file in $configFiles)
{
	Write-Host $file.FullName
	(Get-Content $file.PSPath) | ForEach-Object { $_ -Replace "Data Source=(.*?);", "Data Source=$myInstance;"} | Set-Content $file.PSPath -Encoding "UTF8"
}

#Schema-compare files are all in one folder:
Write-Host "Schema-Compare files:"
$configFiles = Get-ChildItem . *.scmp -Recurse
ForEach ($file in $configFiles)
{
	Write-Host $file.FullName
	(Get-Content $file.PSPath) | ForEach-Object { $_ -Replace "Data Source=(.*?);", "Data Source=$myInstance;"} | Set-Content $file.PSPath -Encoding "UTF8"
}