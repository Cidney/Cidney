function Stage:
{
    <#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
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
        Invoke-Cidney HelloWorld -Verbose

        .LINK
        Pipeline:
        On:
        Do:
        Invoke-Cidney
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $StageName,
        [Parameter(Position = 1)]
        [scriptblock]
        $StageBlock  = $(Throw 'No Stage: block provided. (Did you put the open curly brace on the next line?)'),
        [hashtable]
        $Context
    )
    
    try
    {        
        if (-not $Context.ContainsKey('Jobs'))   
        {
            $Context.Add('Jobs', @())
        }

        if ($Context.ShowProgress) 
        { 
            Write-Progress -Activity "Stage $StageName" -Status 'Starting' -Id ($CidneyPipelineCount + 1) 
        }
        $Context.CurrentStage = $StageName

        Write-CidneyLog "[Start] Stage $StageName"

        $blocks = Get-Cidneystatements -ScriptBlock $stageBlock -BoundParameters $PSBoundParameters
        $count = 0
        foreach($block in $blocks)
        {
            if ($Context.ShowProgress) 
            { `
                Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id ($CidneyPipelineCount + 1)
            }

            Invoke-CidneyBlock -ScriptBlock $block -Context $Context

            $count++ 
            if ($Context.ShowProgress -and $Context.Jobs.Count -eq 0) 
            { 
                Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id ($CidneyPipelineCount + 1) -PercentComplete ($count/$blocks.Count * 100)
            }
        }
        
        Wait-CidneyJob -Context $Context  
    }
    finally
    {
        $Context.Remove('Jobs')
        
        if ($Script:RunspacePool -and $Script:RunspacePool.RunspacePoolStateInfo.State -ne 'Closed')
        {
            $Script:RsSessionState = $null
            $null = $Script:RunspacePool.Close()
            $null = $Script:RunspacePool.Dispose()
            #[gc]::Collect()
        }
    }

    if ($Context.ShowProgress) 
    { 
        Write-Progress -Activity "Stage $StageName" -Status 'Completed' -Id ($CidneyPipelineCount + 1) -Completed 
    }       
    Write-CidneyLog "[Done] Stage $StageName"
}

