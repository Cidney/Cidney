function Get-CidneyPipeline
{
 <#
        .SYNOPSIS
        Get-CidneyPipeline will return a list of all Cidney Pipelines compiled from Pipeline: configurations.
        .DESCRIPTION
        When you first create a Cidney Pipeline: configuration you are actually creating a definition or a configuration of a pipeline. 
        It is basically a global function which is stored in the Function: provider with the the name 'Pipeline:<Name of pipeline>'

        Get-CidneyPipeline is a utility function that will search for an return a list of defined Cidney Pipelines.

        To start a Pipeline you use the cmdlet Invoke-Cidney.

        .EXAMPLE
        Get-CidneyPipeline

        CommandType     Name                                               Version    Source                                                                        
        -----------     ----                                               -------    ------                                                                        
        Function        Pipeline:HelloWorld                                0.9.5.0    cidney                                                                        
        Function        Pipeline:HelloWorld2                               0.9.5.0    cidney      

        .LINK
        Pipeline:
        Stage:
        On:
        Do:
        When:
        Invoke-Cidney
    #>

   [CmdletBinding()]
    param
    (
        [string]
        $Name = '*'
    )

    $functionName = "Pipeline:$Name"

    # Return the list of Pipeline functions except for the Pipeline: keyword
    Get-item "Function:$functionName" -ErrorAction SilentlyContinue | Where Name -ne 'Pipeline:' 
}    
