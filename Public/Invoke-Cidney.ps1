function Invoke-Cidney
{
<#
        .SYNOPSIS
        Invoke-Cidney will start a Cidney Pipeline.
        
        .DESCRIPTION
        To start a Pipeline you use the cmdlet Invoke-Cidney. You can specify a name or a list of one or more Pipelines returned from the 
        cmdlet Get-CidneyPipeline.

        Note: Because the Do: keyword sets up jobs some may hang around in an error state if there are errors when executing. 
        If this happens you can use the job functions in powershell to investigate and clean up. Wait-Job, Receive-Job and Remove-Job.
        But if you just want to clean up quickly and do a reset you can call Invoke-Cidney -Force and it will clean up all Cidney jobs.
         
        .EXAMPLE
        Pipeline: HelloWorld {
            Write-Output "Hello World"
        }
        Invoke-CidneyPipeline HelloWorld

        Output: 
        Hello World

        .EXAMPLE
        Pipeline: HelloWorld {
            Write-Output "Hello World"
        }
        Invoke-CidneyPipeline HelloWorld -Verbose

        Output: 
        VERBOSE: [03/15/16 4:48:46.742 PM] [Start] Pipeline HelloWorld
        Hello World
        VERBOSE: [03/15/16 4:48:46.823 PM] [Done] Pipeline HelloWorld

        .EXAMPLE
        Get-CidneyPipeline Hello* | Invoke-Cidney

        output
        VERBOSE: [03/15/16 4:48:46.742 PM] [Start] Pipeline HelloWorld
        Hello World
        VERBOSE: [03/15/16 4:48:46.823 PM] [Done] Pipeline HelloWorld        

        .LINK
        Pipeline:
        Stage:
        On:
        Do:
        When:
        Invoke-Cidney
        Remove-CidneyPipeline
    #>
    
    [CmdletBinding(DefaultParameterSetName ='Name')]
    param
    (
        [Parameter(Position = 0, ParameterSetName = 'Name')]
        [string]
        $Name,
        [parameter(ValueFromPipeline, ParameterSetName = 'pipeline')]
        [object[]]
        $InputObject,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'pipeline')]
        [switch]
        $ShowProgress,
        [parameter(ParameterSetName = 'Reset')]
        [switch]
        $Force
        <#,
        [object]
        $Context#>
    )
    begin
    {
        if ($Force)
        {
            Get-Job -Name CI* | Remove-Job -Force
            $Global:CidneyImportModulesPreference = $false
            $Global:CidneyPipelineCount = -1
        }
    }

    process 
    {
        if (-not $InputObject)
        {
            $functionName = "Global:PipeLine:$Name"
        }

        if ($InputObject)
        {
            $functionName = "Global:$($InputObject.Name)"
        }

        $result = $Global:CidneyPipelineFunctions.GetEnumerator() | Where Name -eq $functionName
        if ($result)
        {
            $params = $result | Select -ExpandProperty Value
            
            if ($params)
            {
                & $functionName @params
            }
        }
        else
        {
            Write-Error "Pipeline $Name was not found."
        }
    }    
}