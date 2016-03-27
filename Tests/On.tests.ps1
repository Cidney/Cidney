#region On configurations
Pipeline: 'On Test with Stage' {
    Stage: 'Stage One' {
        On: localhost {
            Do: { Write-Output $env:COMPUTERNAME }
        }   
    }
}

Pipeline: 'On Test with without Stage' {
    On: localhost {
        Do: { Write-Output $env:COMPUTERNAME }
    }   
}


Pipeline: 'On Test get-service' {
    On: localhost {
        Do: { get-service | where Status -eq 'Running' }
    }   
} 
#endregion

#region Tests
Describe -Tag Credentials 'On Tests' {
    It 'Should output local computer name' {
        Invoke-Cidney 'On Test with Stage' | Should be $env:COMPUTERNAME
    }
    It 'Should output local computer name no stage' {
        Invoke-Cidney 'On Test with without Stage' | Should be $env:COMPUTERNAME
    }
    It 'Should output localhost for PSComputerName in service listing' {
        $result = Invoke-Cidney 'On Test get-service' 
        $result[0].PSComputerName | Should be 'localhost'
    }
}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion