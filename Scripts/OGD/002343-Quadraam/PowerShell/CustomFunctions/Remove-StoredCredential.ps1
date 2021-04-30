Function Remove-StoredCredential{
    <#
    .synopsis
        Can be used to delete a stored credential from disk
    .example
        Remove-StoredCredential -filename c:\_automation\credentials\test.cred
    .example
        Remove-StoredCredential | where-object{$_.username -eq 'test'} | Remove-StoredCredential
    .parameter FullName
        FullName Path to the credential file. Either specify FullName or FileName and Path.
    .parameter FileName
        FileName of the credential file. Specify together with Path.
    .parameter Path
        Path to the credential file. Specify together with FileName.

    #>
    [CmdletBinding(supportsshouldprocess=$true,ConfirmImpact='Medium')]
    param(
        [parameter(Mandatory=$false, position=0,ParameterSetName='Parameter Set 1', ValueFromPipelineByPropertyName=$true)]
        $FullName = $null,
        [parameter(Mandatory=$false,ParameterSetName='Parameter Set 2')]
        [string]$Path = $env:USERPROFILE,
        [parameter(Mandatory=$false,ParameterSetName='Parameter Set 2')]
        [string]$FileName
    )
    process{
    if($null -eq $FullName){
        $FullName = join-Path -Path $path -ChildPath $filename
    }
    remove-item $FullName

    }
}