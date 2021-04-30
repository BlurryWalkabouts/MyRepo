<#
Datum: 19-01-2018
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

. ./Get-Credentials
. ./New-SPOFolder

Function DownloadFromSharePoint
{
    [CmdletBinding()]

    Param
    (
        $SiteCollectionName = "quadraam"
        , $SiteName = "/teams/projecten/dwh_beheer"
        , $ListTitle = "Forecast"
        , $LocalDestinationFolder = "F:\Forecast"
        , $Identifier = "test"
    )

    Import-Module -FullyQualifiedName ".\SPOMod\SPOMod.psm1" -Force

    $siteCollectionUrl = "https://$SiteCollectionName.sharepoint.com"
    $webUrl = "$siteCollectionUrl$SiteName"
    $listPath = "$SiteName/$ListTitle"

    $DataSource = "SharePoint"
    $Credentials = Get-Credentials -DataSource $DataSource -Identifier $Identifier

    Connect-SPOCSOM -Credential $Credentials -Url $webUrl

    # Get files (not dirs)
    # $listItems = Get-SPOFolderFiles -ServerRelativeUrl $listPath
    $listItems = Get-SPOListItems -ListTitle $ListTitle -IncludeAllProperties $true | Where {$_.FsObjType -eq 0 -and $_.FileLeafRef -like "*.xml" }
    # FsObjType: 0 = Files; 1 = Folders

    # Iteration on all files in document library
    ForEach ($item in $listItems)
    {
        [string]$sourceDirectory = $item.FileDirRef #/teams/projecten/dwh_beheer/Forecast
        [string]$sourceFileName = $item.FileLeafRef #Forecast voor DWH.XML
        [string]$sourceFileUrl = $siteCollectionUrl + $item.FileRef #/teams/projecten/dwh_beheer/Forecast/Forecast voor DWH.XML

        # Create destination directory
        [string]$destinationFolder = $LocalDestinationFolder + $sourceDirectory.Replace($listPath, "")

        $destinationFolder = $destinationFolder.Replace("/","\")
        If (!(Test-Path -Path $destinationFolder)) { New-Item -Path $destinationFolder -ItemType "directory" }

        # Download file
        [string]$destinationFilePath = "$destinationFolder\$sourceFileName"

        # https://sharepoint.stackexchange.com/questions/139309/download-page-from-sharepoint-online-using-powershell
        $wc = New-Object System.Net.WebClient
        $wc.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.UserName, $Credentials.Password)
        $wc.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
        $wc.DownloadFile($sourceFileUrl, $destinationFilePath)
        $wc.Dispose()

        Write-Host "$(Get-Date -Format FileDateTime) > $sourceFileUrl downloaded to $destinationFilePath" -ForegroundColor Green

        # Move downloaded file to Completed folder
        $FolderName = "Completed"
        New-SPOFolder -SiteUrl $webUrl -Credentials $Credentials -LibraryName $ListTitle -FolderName $FolderName

        Move-SPOFile -ServerRelativeUrl $item.FileRef -DestinationLibrary "$($item.FileDirRef)/$FolderName/" -NewName "$(Get-Date -Format yyyyMMdd_HHmmss)_$($item.FileLeafRef)"
        Write-Host "$(Get-Date -Format FileDateTime) > File $($item.FileRef) moved to $($item.FileDirRef)/$FolderName/$(Get-Date -Format yyyyMMdd_HHmmss)_$($item.FileLeafRef)" -ForegroundColor Green
    }
}