<#
Datum: 19-01-2018
Auteur: Willem van der Steen (OGD)

http://www.sharepointdiary.com/2016/08/sharepoint-online-create-folder-using-powershell.html
https://blog.blksthl.com/2015/02/24/office-365-guide-series-manage-files-and-folders-with-powershell-and-csom/
http://www.sharepointnutsandbolts.com/2013/12/Using-CSOM-in-PowerShell-scripts-with-Office365.html
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Function New-SPOFolder
{
    [CmdletBinding()]

    Param
    (
        [Parameter(Mandatory=$true)][string]$SiteUrl
        , [Parameter(Mandatory=$false)][System.Management.Automation.PSCredential] $Credentials
        , [Parameter(Mandatory=$true)][string]$LibraryName
        , [Parameter(Mandatory=$true)][string]$FolderName
    )

    Try
    {
        # Set up the context
        $Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
        $Context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.UserName, $Credentials.Password)

        # Get the library by name
        $List = $Context.Web.Lists.GetByTitle($LibraryName)

        # Check if folder already exists
        $Folders = $List.RootFolder.Folders
        $Context.Load($Folders)
        $Context.ExecuteQuery()
        $FolderNames = $Folders | Select -ExpandProperty Name

        If ($FolderNames -contains $FolderName)
        {
            Write-Host "Folder '$FolderName' in library '$LibraryName' exists already!" -ForegroundColor Yellow
        }
        Else
        {
            # Create new subfolder
            $NewFolder = $List.RootFolder.Folders.Add($FolderName)
            $Context.ExecuteQuery()
            Write-Host "Folder '$FolderName' in library '$LibraryName' created successfully!" -ForegroundColor Green
        }
    }
    Catch
    {
        Write-Host "Error creating folder '$FolderName' in library '$LibraryName'!" $_.Exception.Message -ForegroundColor Red
    }
}