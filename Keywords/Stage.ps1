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
        $Name,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $StageBlock
    )
    
    Initialize-CidneyVariables -ScriptBlock $StageBlock -scope Local

    $Global:CidneySession.Add('Jobs', @())

    if ($Global:CidneySession.ShowProgress) { Write-Progress -Activity "Stage $Name" -Status 'Starting' -Id 1 }
    Write-Log "[Start] Stage $Name"

    try
    {
        $blocks = Get-CidneyBlocks -ScriptBlock $stageBlock -BoundParameters $PSBoundParameters

        $count = 0
        foreach($block in $blocks)
        {
            Invoke-Command -Command $block

            $count++ 
            if ($Global:CidneySession.ShowProgress -and $Global:CidneyJobs.Count -eq 0) { Write-Progress -Activity "Stage $Name" -Status 'Processing' -Id 1 -PercentComplete ($count/$blocks.Count * 100)}
         }

        Wait-CidneyJob -Jobs $Global:CidneySession.Jobs
        foreach ($job in $Global:CidneySession.Jobs)
        {
            if ($job.Job.State -match 'Failed|Stopped|Suspended|Disconnected') 
            {
                Write-Warning "Job $($Job.Job.Name) timed out"
                $job | Select-Object -ExpandProperty Job
                Write-Output ''
            } 
        }  
    }
    finally
    {
        foreach($var in $Global:CidneySession.LocalVariables)
        {
            Get-Variable -Name $var -Scope Local -ErrorAction SilentlyContinue | Remove-Variable -ErrorAction SilentlyContinue
        }

        $Global:CidneySession.Remove('LocalVariables')
        $Global:CidneySession.Remove('Jobs')
    }

    if ($Global:CidneySession.ShowProgress) { Write-Progress -Activity "Stage $Name" -Status 'Completed' -Id 1 -Completed }       
    Write-Log "[Done] Stage $Name"
}

