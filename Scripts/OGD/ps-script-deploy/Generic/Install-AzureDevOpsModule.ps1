[cmdletbinding()]
param(
    [parameter(mandatory=$true)]
    [String] $AdoGalleryUser,
    [parameter(mandatory=$true)]
    [String] $AdoGalleryUserPat,
    [parameter(mandatory=$true)]
    [String] $Module,
    [parameter(mandatory=$false)]
    [String] $packageFeedUrl = "https://ogd.pkgs.visualstudio.com/_packaging/DataOffice.Packages/nuget/v2/",
    [parameter(mandatory=$false)]
    [String] $packageFeedName = "OgdDataOffice"
)

#Setting Credentials
$password = ConvertTo-SecureString "$($AdoGalleryUserPat)" -AsPlainText -Force
$AdoCredential = New-Object System.Management.Automation.PSCredential($AdoGalleryUser, $password)
          
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

if((Get-Module -Name "$($Module)" -ErrorAction Ignore) -ne $null) {
    # Updating Module            
    Update-Module -Name "$($Module)" -Force -Verbose -Scope CurrentUser -Repository "$($packageFeedName)" -Credential $AdoCredential
}
else {
    # Installing Module            
    Install-Module -Name "$($Module)" -Force -Verbose -Scope CurrentUser -Repository "$($packageFeedName)" -Credential $AdoCredential
}