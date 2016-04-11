#region Pipeline configurations
Pipeline: 'Pipeline' {
    Write-Output "$PipelineName"
} 

Pipeline: 'Pipeline With Params provided' {
    param([string]$TestParam, [int32]$TestParam2)
    
    Write-Output "$TestParam"
    Write-Output "$TestParam2"
} 

Pipeline: 'Pipeline With Params Embedded' {
    param([string]$TestParam, [int32]$TestParam2)
    
    Write-Output "$TestParam"
    Write-Output "$TestParam2"
} -TestParam DEF -TestParam2 456

Pipeline: 'Pipeline With Params Provided and Embedded' {
    param([string]$TestParam, [int32]$TestParam2)
    
    Write-Output "$TestParam"
    Write-Output "$TestParam2"
} -TestParam2 456


Pipeline: 'Pipeline with Variables' {
    $A = 'A'
    Write-Output "$A"
}

Pipeline: 'Pipeline with If (true)' {
    $A = 'A'
    if ($A -eq 'A')
    { $true} else {$false}
}

Pipeline: 'Pipeline with If (false)' {
    $A = 'A'
    if ($A -eq 'B')
    { $true} else {$false}
}

Pipeline: 'Pipeline Get-Service' {
    (Get-service Bits).DisplayName
}

Pipeline: 'Pipeline Context' {
    $context
}

Pipeline: 'Pipeline CidneyShowProgressPreference' {
    $CidneyShowProgressPreference
}

Pipeline: 'Pipeline CidneyPipelineCount' {
    $CidneyPipelineCount
}

Pipeline: 'Pipeline CidneyPipelineFunctions' {
    $CidneyPipelineFunctions
}

Pipeline: 'Pipeline CidneyPipelineCount 2 Pipelines' {
    Invoke-Cidney 'Pipeline CidneyPipelineCount'
}

# Cannot have pipelines within pipelines
Pipeline: 'Embedded Pipeline' {
    Pipeline: A { Write-Output "$PipelineName"}
    Pipeline: B { Write-Output "$PipelineName"}
    Pipeline: C { Write-Output "$PipelineName"}
}

# This is 1 of 2 correct ways to call a pipeline from inside a pipeline
Pipeline: 'Invoking Pipeline in Pipeline 1' {
    Invoke-Cidney 'Pipeline'
    Invoke-Cidney 'Pipeline with Variables'
}

# This is 2of 2 correct ways to call a pipeline from inside a pipeline
Pipeline: 'Invoking Pipeline in Pipeline 2' {
    $path = (Get-Module Cidney).ModuleBase
    & "$path\Tests\EmbeddedPipelineScript.ps1"
}
#endregion

#region Tests
Describe 'Pipeline Tests' {
    It "Pipeline should have the name 'Pipeline'" {
        Invoke-Cidney 'Pipeline' | Should be 'Pipeline'
    }
    It 'Pipeline should passthru' {

        $result = Pipeline: 'Pipeline Passthru' {
        } -PassThru

        $result.Name | Should be 'Pipeline: Pipeline Passthru'
    }
    It "Pipeline should have a variable A with value of 'A'" {
        Invoke-Cidney 'Pipeline with Variables' | Should be 'A'
    }
    It 'Pipeline should have a params TestParam and TestParam2 provided' {
        $result = Invoke-Cidney 'Pipeline with Params provided' -TestParam ABC -TestParam2 123
        $result | Should be 'ABC', 123
    }
    It 'Pipeline should have a params TestParam and TestParam2 embedded' {
        $result = Invoke-Cidney 'Pipeline with Params embedded'
        $result | Should be 'DEF', 456
    }
    It 'Pipeline should have a params TestParam and TestParam2 provided and embedded' {
        $result = Invoke-Cidney 'Pipeline with Params provided and embedded' -TestParam ABC
        $result | Should be 'ABC', 456
    }
    It 'Pipeline should have a params TestParam invoked directly' {
        $result = Pipeline: ParamTestInvoked {
            param([string]$TestParam)
    
            Write-Output "$TestParam"
        } -Invoke -TestParam Success 
        $result | Should be 'Success'
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
            $result | Should BeNullorEmpty
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
        It '$Context.ShowProgress $False' {
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
    It 'Should output from invoking pipline 1' {
        Invoke-Cidney 'Invoking Pipeline in Pipeline 1' | should be 'Pipeline', 'A'
    }
    It 'Should output from invoking pipline 2' {
        $result = Invoke-Cidney 'Invoking Pipeline in Pipeline 2'
        $result | should be 'PipelineEmbedded'
    }
    It 'Pipeline CidneyPipelineFunctions should be 22' {
        $result = Invoke-Cidney 'Pipeline CidneyPipelineFunctions' 
        $result.Count | should be 22
    }
    It 'Pipeline CidneyPipelineFunctions count should equal Get-CidneyPipeline' {
        $result1 = Invoke-Cidney 'Pipeline CidneyPipelineFunctions' 
        $result2 = Get-CidneyPipeline
        $result1.Count -eq $result2.Count | should be $true
    }
    It 'With 1 Pipeline CidneyPipelineCount should be 1' {
        Invoke-Cidney 'Pipeline CidneyPipelineCount' | should be 1
    }
    It 'With 2 Pipelines CidneyPipelineCount should be 1' {
            Invoke-Cidney 'Pipeline CidneyPipelineCount 2 Pipelines' | should be 2
    }
}

#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion