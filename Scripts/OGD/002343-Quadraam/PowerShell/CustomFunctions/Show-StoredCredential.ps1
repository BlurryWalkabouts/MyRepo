Function Show-StoredCredential{
    <#
    .synopsis
        extremely basic function to show which .cred files are in a location.
    .example
        Show-StoredCredential
    .example
        Show-StoredCredential -path c:\temp
    .parameter path
        Path to the location of your *.cred files that you want to see
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [string]$Path = 'C:\_automation\credentials'
    )
    $files = Get-ChildItem $Path -filter '*.cred'
    foreach($file in $files){       
        $Object = Get-Content -Path $file.FullName -Raw |ConvertFrom-Json
        $Object |Add-Member -name 'FullName' -value $file.FullName -MemberType NoteProperty
        $Object |Add-Member -name 'path' -value $file.directoryname -MemberType NoteProperty
        $Object |Add-Member -name 'filename' -value $file.basename -MemberType NoteProperty
        $Object.PSObject.TypeNames.Insert(0,'OGD.CustomView.StoredCredential')
        $Object 
    }
}