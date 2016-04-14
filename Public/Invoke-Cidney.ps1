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
        Remove-CidneyPipeline
    #>
    
    [CmdletBinding(DefaultParameterSetName ='Name')]
    param
    (
        [parameter(ParameterSetName = 'pipeline')]
        [parameter(ValueFromPipeline)]
        [object[]]
        $InputObject = $null,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(Position = 0)]
        [string]
        $Name,
        [Parameter(ParameterSetName = 'Name')]
        [Parameter(ParameterSetName = 'pipeline')]
        [switch]
        $ShowProgress,
        [parameter(ParameterSetName = 'Reset')]
        [switch]
        $Force,
        [Parameter(ValueFromRemainingArguments)]
        $DynamicParams
    )

    begin
    {
        if ($Force)
        {
            $verbose = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')

            # Make sure we get and remove only Cidney jobs
            Get-Job | Where-Object Name -match '(CI \[Job\d+\])' | Remove-Job -Force -Verbose:$verbose
            $Global:CidneyJobCount = 0
            
            break
        }

        $oldProgressPreference = $CidneyShowProgressPreference
        $CidneyShowProgressPreference = $CidneyShowProgressPreference -or $ShowProgress
    }

    process 
    {
        $pipelineName = $PSBoundParameters.Name
        if (-not $pipelineName)
        {
            $pipelineName = $MyInvocation.BoundParameters.PipelineName
        }
        if (-not $InputObject)
        {
            $functionName = "Global:Pipeline: $PipelineName"
        }

        if ($InputObject)
        {
            $functionName = "Global:$($InputObject.Name)"
        }

        $params = Get-CidneyPipelineParams -FunctionName $functionName -DynamicParams $DynamicParams

        if ($params)
        {
            $params.ShowProgress = $CidneyShowProgressPreference

            & "$functionName" @params
        }
        else
        {
            Write-Error "Pipeline `'$FunctionName`' was not found."
        }
    } 
    
    end
    {
        $CidneyShowProgressPreference = $oldProgressPreference
    }
}