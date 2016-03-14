function Wait-CidneyJob
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Object[]]
        $Jobs
    )  

    $count = 0
    $date = Get-Date
    $context = Get-CidneyContext
    do
    {               
        $RunningJobs = [System.Collections.ArrayList]::new()
        foreach ($job in $jobs) 
        {
            $job.ExecutionTime = (New-TimeSpan $date).TotalSeconds
            if ($job.Job.State -match 'Completed|Failed|Stopped|Suspended|Disconnected') 
            {
                $count++
                Write-CidneyLog "[Results] $($job.Job.Name)"
                $job.Job | Receive-Job 
                Write-CidneyLog "[$($Job.Job.State)] $($job.Job.Name)"
                $job.Job | Remove-Job
            } 
            else 
            {
                if($job.Timeout -and $job.ExecutionTime -ge $Job.Timeout)
                {                
	                $Job.Job | Stop-Job
                    while ((Get-Job -Id $job.Job.Id).State -ne 'Stopped')
                    {
                        Start-Sleep -Milliseconds 100
                    }

                    $Job.Job | Remove-Job    
                    Write-CidneyLog "[$($Job.Job.State)] $($job.Job.Name)"

                    if ($job.ErrorAction -eq 'Stop')
                    {
                        Throw "$($Job.Job.Name) Timed out"
                    }
                    else
                    {
                        Continue            
                    }     
                }

                [void]$RunningJobs.Add($job)
            }
        }

        if ($context.ShowProgress -and $context.Jobs -and $context.Jobs.Count -gt 0) 
        { 
            Write-Progress -Activity "Stage $Name" -Status 'Processing' -Id 1 -PercentComplete ($count/$context.Jobs.Count * 100)
        }

        $jobs = $RunningJobs
        
        Start-Sleep -Milliseconds 100
    } 
    While($jobs.Count -ne 0)
}
