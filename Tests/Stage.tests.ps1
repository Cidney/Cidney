#region Pipeline configurations
Pipeline: '1 Stage' {
    Stage: 'Stage One' {
       Write-Output "$Stagename"
    }    
}

Pipeline: '2 Stages' {
    Stage: 'Stage One' {
        Write-Output "$Stagename"
    }    
    Stage: 'Stage Two' {
        Write-Output "$Stagename"
    }    
}

Pipeline: 'Statements before Stage' {
    $a = 'abc'
    $b = 123

    Write-Output $a$b

    Stage: 'Stage One' {
        Write-Output "$Stagename"
    }    
}

Pipeline: 'Statements after Stage' {
    Stage: 'Stage One' {
        Write-Output "$Stagename"
    }    

    $a = 'abc'
    $b = 123

    Write-Output $a$b
}

Pipeline: 'Stage Context' {
    Stage: One {
        $context
    }
}

Pipeline: 'Stage CidneyShowProgressPreference' {
    Stage: One {
        $CidneyShowProgressPreference
    }
}

Pipeline: 'Stage CidneyPipelineCount' {
    Stage: One {
        $CidneyPipelineCount
    }
}

Pipeline: 'Stage CidneyPipelineFunctions' {
    Stage: One {
        $CidneyPipelineFunctions
    }
}

Pipeline: 'Stage CidneyPipelineCount 2 Pipelines' {
    Stage: One {
        Invoke-Cidney 'Stage CidneyPipelineCount'
    }
}

Pipeline: '3 Stage CidneyPipelineCount 2 Pipelines' { # After Stage One there are 2 pipelines at this scope
    Stage: One { #Another pipeline but at the stage scope its still 1
        Invoke-Cidney 'Stage CidneyPipelineCount'
    }
    Stage: Two { #Only 1 pipeline in the stage scope
        $CidneyPipelineCount
    }
    Stage: Three { #Still Only 1 pipeline in the stage scope
        $CidneyPipelineCount
    }
}

Pipeline: 'Embedded Pipeline in Stage' {
    Stage: 'A' {
        Pipeline: A { Write-Output "$PipelineName"}
        Pipeline: B { Write-Output "$PipelineName"}
        Pipeline: C { Write-Output "$PipelineName"}
    }
}

Pipeline: 'Invoking Pipeline in Stage' {
    Stage: 'A' {
        Invoke-Cidney '1 Stage'
    }
}

Pipeline: 'Invoking Multiple Pipelines in Stage' {
    Stage: 'A' {
        Invoke-Cidney '1 Stage'
        Invoke-Cidney '2 Stages'
    }
}

Pipeline: 'Embedded Stage in Stage' {
    Stage: 'A' {
        Stage: 'B' { Write-Output 'B'}
    }
}

Pipeline: 'Stage with Variable outside stage' {
    $Stage_A = 'A'
    Stage: One {
        Write-Output "$Stage_A"
    }
}

Pipeline: 'Stage with Variable inside stage' {
    Stage: One {
        $Stage_B = 'B'
        Write-Output "$Stage_B"
    }
}
#endregion

#region Tests
Describe 'Stage Tests' {
    It 'Should output Stage One' {
        Invoke-Cidney '1 Stage' | Should be 'Stage One'
    }
    It 'Should output Stage One Stage Two' {
        Invoke-Cidney '2 Stages' | Should be 'Stage One', 'Stage Two'
    }
    Context 'Context' {
        $result = Invoke-Cidney 'Stage Context'
        It 'Stage should have a Context that is not null' {
            $result | Should not BeNullOrEmpty
        }
        It 'Stage should have a Context with 8 entries' {
            $result.Count | Should be 8
        }
    }
    Context 'CurrentStage' {
       $result = (Invoke-Cidney 'Stage Context').CurrentStage
        It 'Stage Context should have CurrentStage Entry' {
            $result | Should be 'One'
        }
    }
    Context 'Jobs' {
       $result = (Invoke-Cidney 'Stage Context').Jobs
        It 'Stage Context should have Jobs Entry' {
            $result | Should BeNullorEmpty
        }
    }
    Context 'CredentialStore' {
       $result = (Invoke-Cidney 'Stage Context').CredentialStore
        It 'Stage Context should have an empty CredentialStore Entry' {
            $result | Should BeNullorEmpty
        }
    }
    Context 'ShowProgress' {
        It '$Context.ShowProgress $False' {
            $result = (Invoke-Cidney 'Stage Context').ShowProgress
            $result | should be $false
        }

        $result = Invoke-Cidney 'Stage CidneyShowProgressPreference' -ShowProgress        
        
        It '$CidneyShowProgressPreference should be $True' {
            $result | Should be $true
        }

        $result = Invoke-Cidney 'Stage CidneyShowProgressPreference' 
        
        It '$CidneyShowProgressPreference should be $false' {
            $result | Should be $false
        }
    }
    Context 'RemoteSessions' {
        $result = (Invoke-Cidney 'Stage Context').RemoteSessions
        It 'Stage Context should have a RemoteSessions Entry' {
            $result | Should BeNullorEmpty
        }
    }
    Context 'PipelineName' {
        $result = (Invoke-Cidney 'Stage Context').PipelineName
        It 'Stage Context should have a PipelineName entry' {
            $result | Should not BeNullorEmpty
        }
        It 'Stage Context should PipelineName = Stage Context' {
            $result | Should be 'Stage Context'
        }
    }
    Context 'Modules' {
        $result = (Invoke-Cidney 'Stage Context').Modules
        It 'Stage Context should have a Modules entry' {
            $result | Should Not BeNullOrEmpty
        }
        It 'Stage Context should have Cidney in the Modules list' {
            $cidneyModule = Get-Module Cidney
            $result -contains $cidneyModule | Should be $true
        }
    }
    Context 'CurrentPath' {
        $result = (Invoke-Cidney 'Stage Context').CurrentPath
        It 'Stage Context should have a CurrentPath Entry' {
            $result | Should Not BeNullOrEmpty
        }
    }
    It 'With 1 Pipeline and 1 Stage CidneyPipelineCount should be 1' {
        Invoke-Cidney 'Stage CidneyPipelineCount' | should be 1
    }
    It 'With 2 Pipelines and 1 Stage CidneyPipelineCount should be 2' {
        Invoke-Cidney 'Stage CidneyPipelineCount 2 Pipelines' | should be 2
    }
    It 'With 2 Pipelines and 3 Stages CidneyPipelineCount should be 2, 1, 1' {
        $result = Invoke-Cidney '3 Stage CidneyPipelineCount 2 Pipelines' 
        $result | should be 2, 1, 1
    }
    It 'Should throw if pipelines are embedded inside Stage' {
        Invoke-Cidney 'Embedded Pipeline in Stage' | should Throw
    }
    It 'Pipeline should have statements before stage' {
        Invoke-Cidney 'Statements before Stage' | should be 'abc123', 'Stage One'
    }
    It 'Pipeline should have statements after stage' {
        Invoke-Cidney 'Statements after Stage' | should be 'Stage One','abc123' 
    }
    It 'Pipeline with Invoke-Cidney inside a stage should work' {
        Invoke-Cidney 'Invoking Pipeline in Stage' | Should be 'Stage One'
    }
    It 'Pipeline with Multiple Invoke-Cidney calls inside a stage should work' {
        Invoke-Cidney 'Invoking Multiple Pipelines in Stage' | Should be 'Stage One', 'Stage One', 'Stage Two'
    }
    It 'Pipeline should handle stages inside stages' {
        Invoke-Cidney 'Embedded Stage in Stage' | should be 'B' 
    }
    It "Stage should have a variable Stage_A with value of 'A'" {
        $result = Invoke-Cidney 'Stage with Variable outside Stage' 
        $result | Should be 'A'
    }
    It "Stage should have a variable Stage_B with value of 'B'" {
        $result = Invoke-Cidney 'Stage with Variable Inside Stage' 
        $result | Should be 'B'
    }
    It 'Stage CidneyPipelineFunctions should be 19' {
        $result = Invoke-Cidney 'Stage CidneyPipelineFunctions' 
        $result.Count | should be 19
    }
    It 'Stage CidneyPipelineFunctions count should equal Get-CidneyPipeline' {
        $result1 = Invoke-Cidney 'Stage CidneyPipelineFunctions' 
        $result2 = Get-CidneyPipeline
        $result1.Count -eq $result2.Count | should be $true
    }}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion