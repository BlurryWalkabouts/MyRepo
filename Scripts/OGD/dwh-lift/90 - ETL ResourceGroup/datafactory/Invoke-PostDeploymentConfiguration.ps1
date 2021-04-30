#Requires -Version 3.0

[CmdletBinding()]
param(
    [parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [parameter(Mandatory=$true)]
    [hashtable] $DeploymentParameters,
    [parameter(Mandatory=$true)]
    [hashtable] $DeploymentOutput
)

Set-StrictMode -Version 3

##NOTE the indexing here is case sensitive, and Microsoft lowercases the first letter of all deployment output parameters!
$DataFactoryName = $DeploymentOutput['dataFactoryName'].Value

foreach ($file in (Get-ChildItem -ErrorAction Ignore -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'dataset') -File -Filter '*.json')) {
    Write-Verbose "Updating dataset $($file.BaseName)"
    $null = Set-AzureRmDataFactoryV2Dataset -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -Name $file.BaseName -DefinitionFile $file.FullName -Force
}

foreach ($file in (Get-ChildItem -ErrorAction Ignore -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath 'pipeline') -File -Filter '*.json')) {
    Write-Verbose "Updating pipeline $($file.BaseName)"
    $null = Set-AzureRmDataFactoryV2Pipeline -DataFactoryName $DataFactoryName -ResourceGroupName $ResourceGroupName -Name $file.BaseName -DefinitionFile $file.FullName -Force
}
