#region Pipeline configurations
Pipeline: 'Do baseline' {
    Stage: One: {
        Do: {} 
    }
}
Pipeline: 'Do baseline 16' {
    Stage: One: {
        foreach ($num in 1..16)
        {
            Do: {} -Context $Context 
        }   
    }
}
Pipeline: 'Do Timing 16 threads' {
    Stage: One: {
        foreach ($num in 1..16)
        {
            Do: { Sleep 5 } -Context $Context 
        }   
    }
}
Pipeline: 'Do Timing 32 threads' {
    Stage: One: {
        foreach ($num in 1..32)
        {
            Do: { Sleep 5 } -Context $Context 
        }   
    }
}
Pipeline: 'Do Timing 128 threads' {
    Stage: One: {
        foreach ($num in 1..128)
        {
            Do: { Sleep 2 } -Context $Context 
        }   
    }
}
Pipeline: 'Do Timing 1024 threads' {
    Stage: One: {
        foreach ($num in 1..1024)
        {
            Do: { if (($num  % 10) -eq 0){ Write-Output "Test:$num"} } -Context $Context 
        }   
    }
}
#endregion

#region Tests
#About 250ms per thread to setup seconds for setup so add (250 * 16) to result
Describe -Tag Performance 'Performance Tests' {
    It 'Should take less than 500ms to do an empty Do: block' {
        $baseTime = [int](Measure-Command { Invoke-Cidney 'Do baseline' }).TotalMilliseconds
        Write-Host $baseTime
        $baseTime -le 500 | should be $true
    }

    It 'Should take less than avg 155ms to do 16 empty Do: block' {
        $baseTimeAvg = [int](((Measure-Command { Invoke-Cidney 'Do baseline 16' }).TotalMilliseconds) / 16)
        Write-Host $baseTimeAvg
        $baseTimeAvg -le 155 | should be $true
    }

    It 'should take less than 10 seconds to run 16 Threads sleeping for 5 seconds each' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 16 Threads' }
        Write-host $result.TotalSeconds
        ([int]$result.TotalSeconds) -le 10 | should be $true
    }    
    It 'should take less than 15 seconds to run 32 threads sleeping for 5 seconds each' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 32 Threads' }
        Write-host $result.TotalSeconds
        ([int]$result.TotalSeconds) -le 15 | should be $true
    }
    It 'should take less than 20 seconds to run 128 threads sleeping for 2 seconds each' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 128 Threads' }
        Write-host $result.TotalSeconds
        ([int]$result.TotalSeconds) -le 20 | should be $true
    }
    It 'should take less than 120 seconds to run 1024 threads' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 1024 Threads' }
        Write-host $result.TotalSeconds
        ([int]$result.TotalSeconds) -le 120 | should be $true
    }
    It 'should be faster than PowerShell Jobs' {
        $result1 = Measure-Command { Invoke-Cidney 'Do Timing 16 Threads' }
        $result2 = Measure-Command { foreach($num in 1..16) { Invoke-Command { Sleep 5 } -asJob -ComputerName localhost }; Get-job | Receive-Job -Wait -AutoRemoveJob}
        Write-Host "Cidney : $($result1.TotalSeconds)"
        Write-Host "PS Jobs: $($result2.TotalSeconds)"
        Write-Host ('Cidney {0:p} faster' -f  (1-($($result1.TotalSeconds) / $($result2.TotalSeconds))))
        $result1.TotalSeconds -le $result2.TotalSeconds | should be $true
    }
}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion