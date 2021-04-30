[cmdletbinding()]
param(
    [parameter(mandatory=$true)]
    [String] $AdoGalleryUser,
    [parameter(mandatory=$true)]
    [String] $AdoGalleryUserPat,
    [parameter(mandatory=$true)]
    [String] $Path,
    [parameter(mandatory=$true)]
    [String] $BuildNumber,
    [parameter(mandatory=$false)]
    [String] $packageFeedUrl = "https://ogd.pkgs.visualstudio.com/_packaging/DataOffice.Packages/nuget/v2/",
    [parameter(mandatory=$false)]
    [String] $packageFeedName = "OgdDataOffice"
)
# RUN THIS ON VSTS HOSTED AGENTS!

#Setting Credentials
$password = ConvertTo-SecureString "$($AdoGalleryUserPat)" -AsPlainText -Force
$AdoCredential = New-Object System.Management.Automation.PSCredential($AdoGalleryUser, $password)
#$nugetPath = "C:\Users\$($env:UserName)\AppData\Local\Microsoft\Windows\PowerShell\PowerShellGet\NuGet.exe"

#Installing NuGet
#Write-Output "Installing NuGet"
#Install-PackageProvider -Name 'NuGet' -ForceBootstrap -Scope CurrentUser -Force

#Updating Modules
#Write-Output "Updating modules."
#Install-Module PowershellGet -Force -Scope CurrentUser
            
# Check if Repository is already registered
Write-Output "Checking if package feed exists."
if((Get-PSRepository -Name "$($packageFeedName)" -ErrorAction Ignore) -ne $null) {
    # Removing and reregister
    Write-Output "Package feed exists. Removing."
    Unregister-PSRepository -Name "$($packageFeedName)"
}            
# Setting the Data Office package feed
Write-Output "Creating package feed."
Register-PSRepository -Name "$($packageFeedName)" -SourceLocation $packageFeedUrl -PublishLocation $packageFeedUrl -InstallationPolicy Trusted -Credential $AdoCredential -Verbose -PackageManagementProvider "NuGet"

Write-Output "Adding to NuGet sources"
& nuget.exe sources add -name "$($packageFeedName)" -Source $packageFeedUrl -UserName "$($AdoGalleryUser)" -Password "$($AdoGalleryUserPat)"
& nuget.exe sources List

# Setting BuildNumber as version number.
Write-Output "Updating Manifest File."
$ModuleManifestPath = (Get-ChildItem -Path "$($Path)\*.psd1")
Update-ModuleManifest -Path $ModuleManifestPath -ModuleVersion "$($BuildNumber)"

# Copying files to module directory
Write-Output "Copying binaries and manifest to manifest folder"
$module = ($ModuleManifestPath | Select BaseName).BaseName
Write-Output "Module: $($module)"

Copy-Item -Path "$($Path)\*.*" -Destination (New-Item "$($Path)\$($module)" -Type container -Force) -Force

Write-Output "Publishing module to package feed." 
Publish-Module -Path "$($Path)\$($module)" -Repository "$($packageFeedName)" -Credential $AdoCredential -NuGetApiKey 'VSTS' -Verbose -Force

#Publish-Module -Path "$($Path)\$($module)" -Repository "$($packageFeedName)" -NuGetApiKey 'VSTS' -Verbose -Force