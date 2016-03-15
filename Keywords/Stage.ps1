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
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $StageBlock,
        [hashtable]
        $Context
    )
    
    Initialize-CidneyVariables -ScriptBlock $StageBlock -Context $Context
    $Context.LocalVariables += (Get-Variable -Name StageName)
    $Context.Add('Jobs', @())

    if ($Context.ShowProgress) 
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
            Invoke-Command -Command $block -ArgumentList $Context.LocalVariables

            $count++ 
            if ($Context.ShowProgress -and $Context.Jobs.Count -eq 0) 
            { 
                Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id 1 -PercentComplete ($count/$blocks.Count * 100)
            }
        }

        Wait-CidneyJob -Context $Context
        foreach ($job in $Context.Jobs)
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
        foreach($var in $Context.LocalVariables)
        {
            Get-Variable -Name $var -Scope Local -ErrorAction SilentlyContinue | Remove-Variable -ErrorAction SilentlyContinue
        }

        $Context.Remove('LocalVariables')
        $Context.Remove('Jobs')
    }

    if ($Context.ShowProgress) 
    { 
        Write-Progress -Activity "Stage $StageName" -Status 'Completed' -Id 1 -Completed 
    }       
    Write-CidneyLog "[Done] Stage $StageName"
}

