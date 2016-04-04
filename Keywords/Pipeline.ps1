function Pipeline:
{
    <#
        .SYNOPSIS
        Cidney Pipeline:
        .DESCRIPTION
        Cidney Pipeline:
        .EXAMPLE
        .\HelloWorld.ps1
                
        Pipeline HelloWorld {
            Stage One {
                Do: { Get-Process }
            }
        }

        .EXAMPLE
        .\HelloWorld.ps1
        
        Pipeline HelloWorld {
            Stage One {
                Do: { Get-Process | Where Status -eq 'Running' }
            }
        }
        .LINK
        Pipeline:
        Stage:
        Do:
        On:
        When:
        Invoke-Cidney
    #>

    [cmdletbinding(DefaultParameterSetName = 'Pipeline')]
    param
    (
        [Parameter(Mandatory, Position = 0, ParameterSetName = 'pipeline')]
        [string]
        $PipelineName = '',
        [Parameter(Position = 1, ParameterSetName = 'pipeline')]
        [scriptblock]
        $PipelineBlock= $(Throw 'No Pipeline: block provided. (Did you put the open curly brace on the next line?)'),
        [Parameter(ParameterSetName = 'pipeline')]
        [switch]
        $Invoke,
        [Parameter(ParameterSetName = 'pipeline')]
        [switch]
        $ShowProgress,
        [Parameter(ParameterSetName = 'pipeline')]
        [switch]
        $PassThru,
        # Added so that the adavanced parameters like Verbose wont be shown. -Verbose is passed 
        # via cmdlet Invoke-Cidney 
        [Parameter(DontShow)]
        [switch]
        $Dummy
    )
    
    $CidneyPipelineCount = -1
    $CidneyPipelineFunctions = @{}

    $functionName = "Global:Pipeline: $PipelineName"
    if ($CidneyPipelineFunctions.ContainsKey($functionName))
    {
        $CidneyPipelineFunctions.Remove($functionName)
    }
    $CidneyPipelineFunctions.Add($functionName, $PSBoundParameters)

    $functionScript = {
        [CmdletBinding()]
        param
        (
            [string]
            $PipelineName,
            [scriptblock]
            $PipelineBlock,
            [switch]
            $ShowProgress,
            [hashtable]
            $Context
        )

        $CidneyPipelineCount++
        $context = New-CidneyContext
        $context.Add('ShowProgress', $ShowProgress)
        $context.Add('CurrentStage', '')
        $Context.Add('PipelineName', $PipelineName)

        $Global:CidneyEvents = @()

        if ($ShowProgress) 
        { 
            Write-Progress -Activity "Pipeline $PipelineName" -Status 'Starting' -Id 0 
        }

        Write-CidneyLog "[Start] Pipeline $PipelineName" 

        if ($ShowProgress) 
        { 
            Write-Progress -Activity "Pipeline $PipelineName" -Status 'Processing' -Id 0 
        }
        
        try
        {
            $stages = Get-CidneyStatement -ScriptBlock $PipelineBlock -BoundParameters $PSBoundParameters 

            $count = 0
            foreach($stage in $stages)
            {
                if ($ShowProgress) 
                { 
                    Write-Progress -Activity "Pipeline $PipelineName" -Status 'Processing' -Id 0 -PercentComplete ($count / $stages.Count * 100) 
                }
                $count++           
    
                Invoke-CidneyBlock -ScriptBlock $stage -Context $Context
            }  
                
            Wait-CidneyJob -Context $Context    
        }
        finally
        {
            foreach($cred in $context.CredentialStore.GetEnumerator())
            {
                Remove-Item $cred.Value -Force -ErrorAction SilentlyContinue
            }

            foreach($session in $Context.RemoteSessions.Values)
            {
                Remove-PSSession $session
            }

            $removeKeys = @()
            foreach($output in $Global:CidneyEventOutput.GetEnumerator())
            {
                $output.Value
                $removeKeys += $output.Key
            }

            foreach($key in $removeKeys)
            {
                $Global:CidneyEventOutput.Remove($key)
            }

            foreach($event in $Global:CidneyEvents)
            {
               $job = Get-Job -Name $event.SourceIdentifier -ErrorAction SilentlyContinue

                if ($job)
                {                    
                    Remove-Job $job -Force
                }
            }

            foreach($event in $Global:CidneyEventSubscribers)
            {
                $event | Unregister-Event -Force -ErrorAction SilentlyContinue
            }
            
            $Global:CidneyEventSubscribers = @()

            $CidneyPipelineCount--
        }   

        if ($Script:RunspacePool -and $Script:RunspacePool.RunspacePoolStateInfo.State -ne 'Closed')
        {
            $Script:RsSessionState = $null
            $null = $Script:RunspacePool.Close()
            $null = $Script:RunspacePool.Dispose()
            [gc]::Collect()
        }
        
        $Global:CidneyJobCount = 0
        $Context = $null
        Write-CidneyLog "[Done] Pipeline $PipelineName" 
    }

    $result = New-item Function:\$functionName -Value $functionScript -Force

    if ($PassThru)
    {
        $result
    }
    
    if ($Invoke)
    {
        $result | Invoke-Cidney -ShowProgress:$ShowProgress
    }
}