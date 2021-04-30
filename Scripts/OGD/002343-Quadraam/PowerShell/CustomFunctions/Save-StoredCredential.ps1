Function Save-StoredCredential {
    <#
    .synopsis
        converts from a credential object from a secure string to a encrypted format and stores a credential file on the disk
    .example
        Save-StoredCredential
    .example
        Save-StoredCredential -Credential $office365credential -Filename office365credential
    .example
        Save-StoredCredential -Filename domainadministrator -Path c:\credential
    .parameter FullName
        FullName (Path + filename + extension) to the file you want to read the credential from
    .parameter Path
        Path that - together with the (auto-generated) filename forms the FullName (if not specified)
    .parameter Notes 
        Optional Notes that go - together with the credential (username + password) - in the credential file. E.g. the resource that the credential is used for.
    .parameter force
        Specifying the Force switch will overwrite any existing credential file that may already exist at FullName.
    #>
    [CmdletBinding(supportsshouldprocess=$true)]
    param(
        [parameter(ValueFromPipelineByPropertyName=$true)]
        $FullName = $null,
        [string]$Path = 'C:\_automation\credentials',
        $Filename = $null,
        $Notes = $null,
        [parameter(mandatory=$true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,
        [switch]$force
    )

    if($null -eq $filename){ # automatic filename creation
        $filename = "$($credential.UserName)-$($env:COMPUTERNAME)"
        [IO.Path]::GetinvalidFileNameChars() | ForEach-Object {$Filename = $Filename.Replace($_,'_')}  
    }
    if($null -eq $FullName){
        $FullName = join-Path -Path $path -ChildPath "$filename.cred"
    }
    $password = $credential.Password | Convertfrom-SecureString 
    $StoredCredential = [pscustomobject]@{
        UserName = $credential.UserName
        Password = $password
        'encrypted on ComputerName' = $env:COMPUTERNAME
        'encrypted with UserName' = $env:username
        'information' = 'this credential file can only be decrypted with both the username and on the computer specified in this object'
        notes = $notes
    }
    
    if(Test-Path $FullName){
        if($force){ #adding force support
            $StoredCredential | ConvertTo-Json | Out-File $FullName -Confirm:$false -Force
        }
        elseif($PSCmdlet.Shouldcontinue("file $FullName already exists, do you want to overwrite the file", 'Overwrite')){ # adding confirm support
            $StoredCredential | ConvertTo-Json | Out-File $FullName -Force
        }
        else{
            Write-Warning "not overwriting the file $FullName"
        }

    }
    if(-not(Test-Path $FullName)){
        $StoredCredential | ConvertTo-Json | out-file $FullName -Force
    }
}