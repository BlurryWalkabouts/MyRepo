#Requires -Version 3.0

param(
    [parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [string] $ResourceGroupLocation = $null,
    [string[]] $Template = $null,
    [string] $Environment = $null,
    [switch] $UploadArtifacts,
    [switch] $ValidateOnly
)

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(' ','_'), '3.0.0')
} catch { }

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

function Format-ValidationOutput {
    param ($ValidationOutput, [int] $Depth = 0)
    Set-StrictMode -Off
    return @($ValidationOutput | Where-Object { $_ -ne $null } | ForEach-Object { @('  ' * $Depth + ': ' + $_.Message) + @(Format-ValidationOutput @($_.Details) ($Depth + 1)) })
}

#region parameter file parsing functions
function Add-ParametersFromJson {
    param(
        [System.IO.FileInfo] $File,
        [System.Collections.Hashtable] $Store
    )
    # parse the json file
    $JsonParameters = Get-Content $File -Raw | ConvertFrom-Json
    # skip the toplevel parameters{} key if it exists (if not, it's probably a regular JSON key-value store and we import all keys)
    if ($null -ne ($JsonParameters | Get-Member -Type NoteProperty 'parameters')) {
        $JsonParameters = $JsonParameters.parameters
    }
    foreach ($JsonParameter in ($JsonParameters | Get-Member -Type NoteProperty)) {
        # .name field can be retrieved directly, but .value field is overridden by powershell and requires gymnastics :(
        $key = $JsonParameter.name
        $value = $JsonParameters | Select-Object -ExpandProperty $key | Select-Object -ExpandProperty 'value'
        $Store.Set_Item($key, $value)
    }
}

function Get-TemplateParameters {
    param(
        [System.IO.FileInfo] $ParameterFile,
        [System.IO.FileInfo] $EnvironmentFile
    )
    $TemplateParameters = @{}

    # the environment file should override the generic parameter file, so parse generic first
    if ($ParameterFile) {
        Add-ParametersFromJson -File $ParameterFile -Store $TemplateParameters
    }
    if ($EnvironmentFile) {
        Add-ParametersFromJson -File $EnvironmentFile -Store $TemplateParameters
    }
    return $TemplateParameters
}
#endregion


#region script parameter parsing
# check if template directories were explicitly provided, otherwise scan all subdirectories
if (-not $Template) {
    $TemplateDirs = Get-ChildItem -LiteralPath $PSScriptRoot -Directory
} else {
    $TemplateDirs = $Template |
        ForEach-Object { Get-Item -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath $_) -ErrorAction Ignore } |
        Where-Object { $_ -is [System.IO.DirectoryInfo] }
}

$TemplatesToDeploy = @()
foreach ($TemplateDir in $TemplateDirs) {
    # naturally, if you use Join-Path on a DirectoryInfo object instead of a String object,
    # you get a relative path instead of a full path. So resolve to FullName first.
    $FullDir = $TemplateDir.FullName
    try {
        $TemplateFile = Get-Item -LiteralPath (Join-Path -Path $FullDir -ChildPath 'template.json')
        $ParameterFile = Get-Item -LiteralPath (Join-Path -Path $FullDir -ChildPath 'parameters.json') -ErrorAction Ignore
        $PreDeployScript = Get-Item -LiteralPath (Join-Path -Path $FullDir -ChildPath 'Invoke-PreDeploymentConfiguration.ps1') -ErrorAction Ignore
        $PostDeployScript = Get-Item -LiteralPath (Join-Path -Path $FullDir -ChildPath 'Invoke-PostDeploymentConfiguration.ps1') -ErrorAction Ignore
        if ($Environment) {
            $EnvironmentFile = Get-Item -LiteralPath (Join-Path -Path $FullDir -ChildPath "${Environment}.parameters.json") -ErrorAction Ignore
        } else {
            $EnvironmentFile = $null
        }
        $TemplatesToDeploy += @{
            Name = $TemplateDir.Name
            TemplateFile = $TemplateFile
            ParameterFile = $ParameterFile
            EnvironmentFile = $EnvironmentFile
            PreDeployScript = $PreDeployScript
            PostDeployScript = $PostDeployScript
            }
    } catch [System.Management.Automation.ItemNotFoundException] {
        #skip directories without template.json
    }
}

if ($TemplatesToDeploy.Length -eq 0) {
    Write-Error 'No templates available to deploy'
} else {
    Write-Verbose "Deploying template(s) $($TemplatesToDeploy.Name -join ',')"
}
#endregion


#region create or update the resource group
$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Ignore
if ($ResourceGroup) {
    $ResourceGroupLocation = $resourceGroup.Location
} else {
    if (-not $ResourceGroupLocation) {
	Write-Error "ResourceGroup ${ResourceGroupName} doesn't exist yet and no ResourceGroupLocation given"
	exit
    }
    # Create or update the resource group using the specified template file and template parameters file
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force
}
#endregion


#region prepare deployment artifacts
if ($UploadArtifacts) {
}
#endregion


#region deploy resource group template
foreach ($TemplateInfo in $TemplatesToDeploy) {
    $DeploymentParameters = @{
        ResourceGroupName = $ResourceGroupName
        TemplateFile = $TemplateInfo.TemplateFile
        TemplateParameterObject = Get-TemplateParameters -ParameterFile $TemplateInfo.ParameterFile -EnvironmentFile $TemplateInfo.EnvironmentFile
    }
    if ('location' -in $DeploymentParameters.TemplateParameterObject.keys) {
        $DeploymentParameters.TemplateParameterObject.Set_Item('location', $ResourceGroupLocation)
    }
    if (-not [String]::IsNullOrEmpty($Environment) -and 'environment' -in $DeploymentParameters.TemplateParameterObject.Keys) {
        $DeploymentParameters.TemplateParameterObject.Set_Item('environment', $Environment)
    }

    if (-not $ValidateOnly -and $UploadArtifacts -and $TemplateInfo.PreDeployScript) {
        & $TemplateInfo.PreDeployScript -ResourceGroupName $ResourceGroupName -DeploymentParameters $DeploymentParameters
        #TODO merge predeploy output (if any) back in parameters file
    }

    if ($ValidateOnly) {
        $ErrorMessages = Format-ValidationOutput -ValidationOutput (Test-AzureRmResourceGroupDeployment @DeploymentParameters)
        if ($ErrorMessages) {
            Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
        } else {
            Write-Output '', 'Template is valid.'
        }
        $DeploymentResult = $null
    } else {
        $DeploymentName = "$($TemplateInfo.Name)-$((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmm'))"
        $DeploymentResult = New-AzureRmResourceGroupDeployment @DeploymentParameters -Mode Incremental -Name $DeploymentName -Force -Verbose -ErrorVariable ErrorMessages
        if ($ErrorMessages) {
            Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
        }
    }

    if (-not $ValidateOnly -and $UploadArtifacts -and $TemplateInfo.PostDeployScript) {
        & $TemplateInfo.PostDeployScript -ResourceGroupName $ResourceGroupName -DeploymentParameters $DeploymentParameters -DeploymentOutput $DeploymentResult.Outputs
    }
}
#endregion

#region perform post-deployment configuration
if ($UploadArtifacts) {
}
#endregion
