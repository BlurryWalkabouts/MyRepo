[cmdletbinding()]
param(
    [String] $Module
)
#Installing NuGet
Install-PackageProvider -Name NuGet -Force -Scope CurrentUser

if((Get-Module -Name "$($Module)" -ErrorAction Ignore) -ne $null) {
    # Updating Module            
    Update-Module -Name "$($Module)" -Force -Verbose -Scope CurrentUser
}
else {
    # Installing Module            
    Install-Module -Name "$($Module)" -Force -Verbose -Scope CurrentUser
}