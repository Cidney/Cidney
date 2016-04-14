function Remove-CidneyPipeline
{
<#
        .SYNOPSIS
        Remove-CidneyPipeline will remove the specified Cidney Pipelines compiled from Pipeline: configurations.
        .DESCRIPTION
        When you first create a Cidney Pipeline: configuration you are actually creating a definition or a configuration of a pipeline. 
        It is basically a global function which is stored in the Function: provider with the the name 'Pipeline:<Name of pipeline>'

        Remove-CidneyPipeline is a utility function that will search for and remove defined Cidney Pipelines.


        .EXAMPLE
        Get-CidneyPipeline | Remove-CidneyPipeline

        .EXAMPLE
        Remove-CidneyPipeline Hello*      

        .EXAMPLE
        Remove-CidneyPipeline HelloWorld -Verbose
        
        Pipeline:HelloWorld removed. 

        .LINK
        Pipeline:
        Stage:
        On:
        Do:
        When:
        Invoke-Cidney
        Get-CidneyPipeline
    #>

   [CmdletBinding(DefaultParameterSetName ='Name')]
    param
    (
        [parameter(ValueFromPipeline, ParameterSetName = 'pipeline')]
        [object[]]
        $InputObject = $null,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(Position = 0)]
        [string]
        $Name
    )

    begin
    {
        $Name = $PSBoundParameters.Name

        if ($Name)
        {
            # if remove 'Pipeline:' from name in case it was added by user. We will add it back in later
            $Name = $Name.Replace('Pipeline: ','')
        }
    }
    
    process
    {
        if (-not $InputObject)
        {
            $InputObject = Get-item "Function:\Global:Pipeline: $Name"
        }
    
        $functionName = "$($InputObject.Name)"
        if ($InputObject)
        {
            $InputObject | Remove-Item -Force -Verbose:($PSBoundParameters.Verbose -eq $true)
            $CidneyPipelineFunctions.Remove("Global:$functionName")
            Write-Verbose "$($InputObject.Name) Removed"
        }
    }
}    
