#region Pipeline configurations
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
#endregion

#region Tests
#About 250ms per thread to setup seconds for setup so add (250 * 16) to result
Describe 'Performance Tests' {
    It 'should take less than 9 seconds to run 16 Threads sleeping for 5 seconds each' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 16 Threads' }
        $result.Seconds -le 5 + 4 | should be $true
    }    
    It 'should take less than 14 seconds to run 32 threads sleeping for 5 seconds each' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 32 Threads' }
        $result.Seconds -le (5*(32/16)) + 4 | should be $true
    }
    It 'should take less than 20 seconds to run 128 threads sleeping for 2 seconds each' {
        $result = Measure-Command { Invoke-Cidney 'Do Timing 128 Threads' }
        $result.Seconds -le (2*(128/16)) + 4 | should be $true
    }
}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion