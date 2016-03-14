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
        .LINK
        Pipeline:
        Do:
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $StageName,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $StageBlock
    )
    
    Initialize-CidneyVariables -ScriptBlock $StageBlock -scope Local
    
    $context = Get-CidneyContext
    $context.Add('Jobs', @())

    if ($context.ShowProgress) 
    { 
        Write-Progress -Activity "Stage $StageName" -Status 'Starting' -Id 1 
    }
    Write-CidneyLog "[Start] Stage $StageName"

    try
    {
        $blocks = Get-CidneyBlocks -ScriptBlock $stageBlock -BoundParameters $PSBoundParameters

        $count = 0
        foreach($block in $blocks)
        {
            Invoke-Command -Command $block

            $count++ 
            if ($context.ShowProgress -and $context.Jobs.Count -eq 0) 
            { 
                Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id 1 -PercentComplete ($count/$blocks.Count * 100)
            }
        }

        Wait-CidneyJob -Jobs $context.Jobs
        foreach ($job in $context.Jobs)
        {
            if ($job.Job.State -match 'Failed|Stopped|Suspended|Disconnected') 
            {
                Write-Warning "Job $($Job.Job.Name) timed out"
                $job | Select-Object -ExpandProperty Job
            } 
        }  
    }
    finally
    {
        foreach($var in $context.LocalVariables)
        {
            Get-Variable -Name $var -Scope Local -ErrorAction SilentlyContinue | Remove-Variable -ErrorAction SilentlyContinue
        }

        $context.Remove('LocalVariables')
        $context.Remove('Jobs')
    }

    if ($context.ShowProgress) 
    { 
        Write-Progress -Activity "Stage $StageName" -Status 'Completed' -Id 1 -Completed 
    }       
    Write-CidneyLog "[Done] Stage $StageName"
}

