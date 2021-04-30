$WebCams = (Get-PnpDevice -FriendlyName "GENERAL WEBCAM").InstanceId 
$WebCams += (Get-PnpDevice -PresentOnly -Class "Media"| where { $_.FriendlyName -like "*rift*"} ).InstanceId 

IF((Get-PnpDevice $WebCams).Status -ccontains "OK") {
    Disable-PnpDevice -InstanceId $WebCams -Confirm:$False
}
ELSE{
   Enable-PnpDevice -InstanceId $WebCams -Confirm:$False  
}

IF((Get-PnpDevice -InstanceId $WebCams).Status -eq "OK"){
Write-Host "Camera ON" -ForegroundColor Green
}
ELSE {
Write-Host  "Camera OFF" -ForegroundColor Red
}
Start-Sleep -s 1
