#Get public function definition files.
$PublicFunctions  = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($PublicFunctions)){
    Try{
        if($import.fullname -notlike "*.tests.*"){
                . $import.fullname 
        }
    }
    Catch{
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Here I might...
# Read in or create an initial config file and variable
# Export Public functions ($Public.BaseName) for WIP modules
# Set variables visible to the module and its functions only
foreach($PublicFunction in $PublicFunctions){
    if($PublicFunction.fullname -notlike "*.tests.*"){
        Export-ModuleMember -Function $PublicFunction.Basename
    }
}