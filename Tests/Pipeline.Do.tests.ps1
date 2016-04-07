#region Pipeline configurations
Pipeline: 'Pipeline' {
    Do: {
        $Context.PipelineName
    }
}

Pipeline: 'Pipeline with Variables' {
    Do: {
        $A = 'A'
        Write-Output "$A"
    }
}

Pipeline: 'Pipeline with If (true)' {
    Do: {
        $A = 'A'
        if ($A -eq 'A')
        { $true} else {$false}
    }
}

Pipeline: 'Pipeline with If (false)' {
    Do: {
        $A = 'A'
        if ($A -eq 'B')
        { $true} else {$false}
    }
}

Pipeline: 'Pipeline Get-Service' {
    Do: {
        (Get-service Bits).DisplayName
    }
}

Pipeline: 'Pipeline Context' {
    Do: {
        $context
    }
}

Pipeline: 'Pipeline Context and Variable' {
    Do: {
        $a = 'Test'
        $context
    }
}

Pipeline: 'Pipeline ShowProgress variable' {
    Do: {
        $Context.ShowProgress
    }
}

Pipeline: 'Pipeline CidneyShowProgressPreference' {
    Do: {
        $CidneyShowProgressPreference
    }
}

Pipeline: 'Pipeline CidneyPipelineCount' {
    Do: {
        $CidneyPipelineCount
    }
}

Pipeline: 'Pipeline CidneyPipelineFunctions' {
    Do: {
        $CidneyPipelineFunctions
    }
}

Pipeline: 'Pipeline CidneyPipelineCount 2 Pipelines' {
    Do: {
        Invoke-Cidney 'Pipeline CidneyPipelineCount'
    }
}

# Cannot have pipelines within pipelines
Pipeline: 'Embedded Pipeline' {
    Do: {
        Pipeline: A { Write-Output "$PipelineName"}
    }
}

# This is the correct way to call a pipeline from inside a pipeline
Pipeline: 'Invoking Pipeline in Pipeline' {
    Do: {
        Invoke-Cidney 'Pipeline' 
        Invoke-Cidney 'Pipeline with Variables'
    }
}
#endregion

#region Tests
Describe 'Pipeline-Do Tests' {
    It "Pipeline should have the name 'Pipeline'" {
        $result = Invoke-Cidney 'Pipeline' 
        $result | Should be 'Pipeline'
    }
    It "Pipeline should have a variable A with value of 'A'" {
        Invoke-Cidney 'Pipeline with Variables' | Should be 'A'
    }
    It 'Pipeline if test should be $True' {
        Invoke-Cidney 'Pipeline with If (true)' | Should be $true
    }
    It 'Pipeline if test should be $False' {
        Invoke-Cidney 'Pipeline with If (false)' | Should be $false
    }
    It 'Pipeline should output Service Description for BITS service' {
        Invoke-Cidney 'Pipeline Get-Service' | Should be 'Background Intelligent Transfer Service'
    }
    Context 'Context' {
       $result = Invoke-Cidney 'Pipeline Context'
        It 'Pipeline should have a Context that is not null' {
            $result | Should not BeNullOrEmpty
        }
        It 'Pipeline should have a Context with 9 entries' {
            $result.Count | Should be 9
        }
    }
    Context 'CurrentStage' {
       $result = (Invoke-Cidney 'Pipeline Context').CurrentStage
        It 'Pipeline Context should have an empty CurrentStage' {
            $result | Should BeNullorEmpty
        }
    }
    Context 'Jobs' {
       $result = (Invoke-Cidney 'Pipeline Context').Jobs
        It 'Pipeline Context should have Jobs Entry' {
            $result | Should not BeNullorEmpty
        }
        It 'Pipeline Context job entry should be CI [Job1]' {
            $result.Name.Trim() | should be 'CI [Job1]'
        }
        
    }
    Context 'CredentialStore' {
       $result = (Invoke-Cidney 'Pipeline Context').CredentialStore
        It 'Pipeline Context should have an empty CredentialStore' {
            $result | Should BeNullorEmpty
        }
    }
    Context 'Pipeline' {
        $result = (Invoke-Cidney 'Pipeline Context').Pipeline
        It 'Pipeline Context should have a Pipeline entry' {
            $result | Should not BeNullorEmpty
        }
    }
    Context 'ShowProgress' {
        It '$Pipeline Context ShowProgress $False' {
            $result = (Invoke-Cidney 'Pipeline Context').ShowProgress
            $result | should be $false
        }

        $result = Invoke-Cidney 'Pipeline CidneyShowProgressPreference' -ShowProgress        
        
        It '$CidneyShowProgressPreference should be $True' {
            $result | Should be $true
        }

        $result = Invoke-Cidney 'Pipeline CidneyShowProgressPreference' 
        
        It '$CidneyShowProgressPreference should be $false' {
            $result | Should be $false
        }
    }
    Context 'RemoteSessions' {
        $result = (Invoke-Cidney 'Pipeline Context').RemoteSessions
        It 'Pipeline Context should have a RemoteSessions Entry' {
            $result | Should BeNullorEmpty
        }
    }
    Context 'PipelineName' {
        $result = (Invoke-Cidney 'Pipeline Context').PipelineName
        It 'Pipeline Context should have a PipelineName entry' {
            $result | Should not BeNullorEmpty
        }
        It 'Pipeline Context should PipelineName = Pipeline Context' {
            $result | Should be 'Pipeline Context'
        }
    }
    Context 'Modules' {
        $result = (Invoke-Cidney 'Pipeline Context').Modules
        It 'Pipeline Context should have a Modules entry' {
            $result | Should Not beNullOrEmpty
        }
        It 'Pipeline Context should have Cidney in the Modules list' {
            $cidneyModule = Get-Module Cidney
            $result -contains $cidneyModule | Should be $true
        }
    }
    Context 'CurrentPath' {
        $result = (Invoke-Cidney 'Pipeline Context').CurrentPath
        It 'Pipeline Context should have a CurrentPath Entry' {
            $result | Should Not beNullOrEmpty
        }
    }
    It 'Should not have embedded pipelines' {
        Invoke-Cidney 'Embedded Pipeline' | should throw
    }
    It 'With 1 Pipeline CidneyPipelineCount should be 0' {
        $result = Invoke-Cidney 'Pipeline CidneyPipelineCount' 
        $result | should be 1
    }

    It 'Pipeline CidneyPipelineFunctions should be 14' {
        $result = Invoke-Cidney 'Pipeline CidneyPipelineFunctions' 
        $result.Count | should be 14
    }
    It 'Pipeline CidneyPipelineFunctions count should equal Get-CidneyPipeline' {
        $result1 = Invoke-Cidney 'Pipeline CidneyPipelineFunctions' 
        $result2 = Get-CidneyPipeline
        $result1.Count -eq $result2.Count | should be $true
    }
    It 'Should output No Stage and Stage One' {
        $result = Invoke-Cidney 'Invoking Pipeline in Pipeline'
        $result | should be 'Pipeline', 'A'
    }
    It 'With 2 Pipelines CidneyPipelineCount should be 2' {
        Invoke-Cidney 'Pipeline CidneyPipelineCount 2 Pipelines' | should be 2
    }
}

#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion