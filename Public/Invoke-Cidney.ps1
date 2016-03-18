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
    )
 
    DynamicParam 
    {
        $script = @'
            $pipeline = $_
            $pipelines = (Get-CidneyPipeline) -replace 'Pipeline: '
            if($pipelines -notcontains $pipeline) 
            { 
                throw "$pipeline is not a valid Cidney pipeline.`n`nValid Pipelines:`n$($pipelines -join ', ')"
            }
            $true
'@
        $scriptBlock = [scriptblock]::Create($script)
        $attribute = [System.Management.Automation.ParameterAttribute]::new()
        $attribute.ParameterSetName = 'Name'
        $attribute.Position = 0
        $attribute.Mandatory = $true

        $pipelines = (Get-CidneyPipeline) -join ';'
        $validateScript = [System.Management.Automation.ValidateScriptAttribute]::new($scriptBlock)
        $validateSet = [System.Management.Automation.ValidateSetAttribute]::new(($pipelines -replace 'Pipeline: ' -split ';'))
      
        $attributeCollection = [System.Collections.ObjectModel.Collection[System.Attribute]]::new()
        $attributeCollection.Add($attribute)
        $attributeCollection.Add($validateScript)
        $attributeCollection.Add($validateSet)
       
        $dynamicParam = [System.Management.Automation.RuntimeDefinedParameter]::new('PipelineName', [string], $attributeCollection)
        $newParam = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()
        $newParam.Add($dynamicParam.Name, $dynamicParam)

        return $newParam
    }

    begin
    {
        if ($Force)
        {
            $verbose = $PSCmdlet.MyInvocation.BoundParameters.ContainsKey('Verbose')

            # Make sure we get and remove only Cidney jobs
            Get-Job | Where Name -match '(CI \[Job\d+\])' | Remove-Job -Force -Verbose:$verbose
            $Script:CidneyPipelineCount = -1
            
            break
        }

        $oldProgressPreference = $Script:CidneyShowProgressPreference
        $Script:CidneyShowProgressPreference = $Script:CidneyShowProgressPreference -or $ShowProgress
    }

    process 
    {
        $pipelineName = $PSBoundParameters.PipelineName

        if (-not $InputObject)
        {
            $functionName = "Global:Pipeline: $PipelineName"
        }

        if ($InputObject)
        {
            $functionName = "Global:$($InputObject.Name)"
        }

        $result = $Script:CidneyPipelineFunctions.GetEnumerator() | Where Name -eq $functionName
        if ($result)
        {
            
            $params = $result | Select -ExpandProperty Value
            
            if ($params)
            {
                $null = $params.Remove('Passthru')
                if (-not $params.ContainsKey('ShowProgress'))
                {
                    $params.Add('ShowProgress', $CidneyShowProgressPreference)
                }
                $params.ShowProgress = $CidneyShowProgressPreference

                & $functionName @params
            }
        }
        else
        {
            Write-Error "Pipeline $PipelineName was not found."
        }
    } 
    
    end
    {
        $Script:CidneyShowProgressPreference = $oldProgressPreference
    }
} 