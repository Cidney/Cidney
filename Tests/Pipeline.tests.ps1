#region Pipeline configurations
Pipeline: 'Pipeline' {
    Write-Output "$PipelineName"
}

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

Pipeline: 'Pipeline Context and Variable' {
    $a = 'Test'
    $context
}

Pipeline: 'Pipeline CidneyShowProgressPreference' {
    $Script:CidneyShowProgressPreference
}

Pipeline: 'Pipeline CidneyPipelineCount' {
    $CidneyPipelineCount
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

# This is the correct way to calla pipeline from inside a pipeline
Pipeline: 'Calling Embedded Pipeline' {
    Invoke-Cidney 'Pipeline'
    Invoke-Cidney 'Pipeline with Variables'
}
#endregion

#region Tests
Describe 'Pipeline' {
    It "Pipeline should have the name 'Pipeline'" {
        Invoke-Cidney 'Pipeline' | Should be 'Pipeline'
    }
}

Describe 'Pipeline with Variables' {
    It "Pipeline should have a variable A with value of 'A'" {
        Invoke-Cidney 'Pipeline with Variables' | Should be 'A'
    }
}

Describe 'Pipeline with If (true)' {
    It 'Pipeline if test should be $True' {
        Invoke-Cidney 'Pipeline with If (true)' | Should be $true
    }
}

Describe 'Pipeline with If (false)' {
    It 'Pipeline if test should be $False' {
        Invoke-Cidney 'Pipeline with If (false)' | Should be $false
    }
}

Describe 'Pipeline Get-Service' {
    It 'Pipeline should output Service Description for BITS service' {
        Invoke-Cidney 'Pipeline Get-Service' | Should be 'Background Intelligent Transfer Service'
    }
}

Describe 'Pipeline Context' {
    Context 'Context' {
       $result = Invoke-Cidney 'Pipeline Context'
        It 'Pipeline should have a Context that is not null' {
            $result | Should not BeNullOrEmpty
        }
        It 'Pipeline should have a Context with 7 entries' {
            $result.Count | Should be 7
        }
     }

    Context 'CurrentStage' {
       $result = (Invoke-Cidney 'Pipeline Context').CurrentStage
        It 'Pipeline Context should have an empty CurrentStage' {
            $result | Should BeNullorEmpty
        }
     }

    Context 'CredentialStore' {
       $result = (Invoke-Cidney 'Pipeline Context').CredentialStore
        It 'Pipeline Context should have an empty CredentialStore' {
            $result | Should BeNullorEmpty
        }
    }
    
    Context 'ShowProgress' {
        $result = Invoke-Cidney 'Pipeline Context' -ShowProgress        
        Write-Progress -Activity "Pipeline $PipelineName" -Id 0 -Completed 
        It 'Pipeline Context should have ShowProgressEntry $true' {
            $result.ShowProgress | Should be $true
        }
        
        $result = Invoke-Cidney 'Pipeline Context'        
        It 'Pipeline Context should have ShowProgressEntry $false' {
            (Invoke-Cidney 'Pipeline Context').ShowProgress | Should be $false
        }
    }
     
    Context 'Pipeline' {
        $result = (Invoke-Cidney 'Pipeline Context').Pipeline
        It 'Pipeline Context should have a Pipeline entry' {
            $result | Should not BeNullorEmpty
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

    Context 'LocalVaribles' {
        $result = (Invoke-Cidney 'Pipeline Context and Variable')
        It 'Context.LocalVariables is not empty' {
            $result.LocalVariables | Should not BeNullOrEmpty 
        }
        It 'Context should have 1 variables' {
            $result.LocalVariables.Count| Should be 1
        }
        It "Context should have Var = 'Test'" {
            $result.LocalVariables[0].Value | Should be 'Test'
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

}

Describe 'CidneyShowProgressPreference' {
    Context 'ShowProgress' {
        $result = Invoke-Cidney 'Pipeline CidneyShowProgressPreference' -ShowProgress        
        Write-Progress -Activity "Pipeline $PipelineName" -Id 0 -Completed 
        
        It '$Script:CidneyShowProgressPreference should be $True' {
            $result | Should be $true
        }

        $result = Invoke-Cidney 'Pipeline CidneyShowProgressPreference' 
        
        It '$Script:CidneyShowProgressPreference should be $false' {
            $result | Should be $false
        }
    }
}

Describe 'Embedded Pipeline' {
    It 'Should not have embedded pipelines' {
        Invoke-Cidney 'Embedded Pipeline' | should throw
    }
}

Describe 'Calling Embedded Pipeline' {
    It 'Should output No Stage and Stage One' {
        Invoke-Cidney 'Calling Embedded Pipeline' | should be 'Pipeline', 'A'
    }
}

Describe 'CidneyPipelineCount' {
    It 'With 1 Pipeline CidneyPipelineCount should be 0' {
        Invoke-Cidney 'Pipeline CidneyPipelineCount' | should be 0
    }
}

Describe 'CidneyPipelineCount' {
    It 'With 2 Pipelines CidneyPipelineCount should be 1' {
            Invoke-Cidney 'Pipeline CidneyPipelineCount 2 Pipelines' | should be 1
    }
}

#endregion

#region Cleanup
#Get-CidneyPipeline | Remove-CidneyPipeline
#endregion