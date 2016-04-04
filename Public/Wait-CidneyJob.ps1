function Wait-CidneyJob
{
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [hashtable]
        $Context = $null
    )  

    $count = 0
    $date = Get-Date
    $jobCount = $Context.Jobs.Count
    $showprogress = $Context.ShowProgress

    if ($Context.Jobs)
    {
        try
        {
            $RunningJobs = [System.Collections.ArrayList]::new($Context.Jobs)
            do
            {               
                $job = $RunningJobs[0]
                $job.ExecutionTime = (New-TimeSpan $date).TotalSeconds
                if ($job.Handle.IsCompleted) 
                {
                    $count++
                    Write-CidneyLog "[Results] $($job.Name)"
                    if ($job.Thread)
                    {
                        if ($job.Thread -and $job.Thread.HadErrors)
                        {
                            $job.Thread.Streams.Error.ReadAll() | ForEach-Object { Write-Error $PSItem }
                        }
                    
                        $job.Thread.EndInvoke($Job.Handle)
                        $job.Thread.Dispose()
                        $job.Thread = $Null
                    }
                    $job.Handle = $Null
                    $RunningJobs.Remove($job)

                    Write-CidneyLog "[Completed] $($job.Name)"
                } 
                else 
                {
                    if($job.ExecutionTime -ge $Job.Timeout)
                    {          
                        $job.Thread.Dispose()
                        $job.Thread = $null  
                            
                        if ($job.ErrorAction -eq 'Stop')
                        {
                            Throw "$($Job.Name) Timed out"
                        }
                        else
                        {
                            Write-Verbose "$($Job.Name) Timed out"
                            Continue            
                        }     
                    }
                }

                if ($showProgress -and $jobcount -gt 0) 
                { 
                    Write-Progress -Activity "Stage $($Context.CurrentStage)" -Status 'Processing' -Id ($CidneyPipelineCount + 1) -PercentComplete ($count/$jobCount * 100)
                }

                if ($job)
                {
                    Start-Sleep -Milliseconds $Job.SleepTimer
                }
            } 
            While($RunningJobs.Count -ne 0)
        }
        finally
        {
            foreach ($job in $Context.Jobs)
            {
                if ($job.Handle) 
                {
                    if ($job.Thread)
                    {
                        $job.Thread.Dispose()
                        $job.Thread = $null
                    }

                    $job.Handle = $null
                    Write-Error "Job $($Job.Name) Failed"
                } 
            }
        }
    }
}