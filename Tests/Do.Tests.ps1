#region Pipeline configurations
Pipeline: 'Do Global Variable' {
    Stage: One {
        Do: { Write-Output $ABC }
    }
}

Pipeline: 'Do Local Variable in Pipeline' {
    $Abc = 'abc'
    Stage: One {
        Do: { Write-Output $ABC }
        }
}

Pipeline: 'Do Local Variable in Stage' {
    Stage: One {
        $Abc = 'abc'
        Do: { Write-Output $ABC }
        }
}

Pipeline: 'Do Local Variable in Do' {
    Stage: One {
        Do: { $Abc = 'abc'; Write-Output $ABC }
        }
}

Pipeline: 'Do Get-Service' {
    Stage: One {
        Do: { Get-Variable }
    }
}

Pipeline: 'Do Get-Service' {
    Stage: One {
        on: $env:COMPUTERNAME {
        Do: { Get-Service BITS }
    }}
}

Pipeline: 'Do WriteHost' {
    Stage: One {
        Do: { Write-Host 'Host'}
    }
}

Pipeline: 'Do WriteOutput' {
    Stage: One {
        Do: { Write-Output 'Output'}
        Do: { 'Another output' }
    }
}

Pipeline: 'Do WriteError' {
    Stage: One {
        Do: { Write-Error 'error'}
    }
}

Pipeline: 'Do Get-Service 32 times' {
    Stage: One {
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
        Do: { Get-Service BITS }
    }
}


Pipeline: 'Do Get-Service 64 times in Foreach' {
    Stage: One {
        Foreach($num in 1..64)
        {
            Do: { Get-Service BITS } -Context $Context
        }
    } 
}

Pipeline: 'Do Get-Service with Timeout' {
    Stage: One {
            Do: { Sleep 5 } -TimeOut 4
    } 
}

Pipeline: 'Do Invoke-Pipeline' {
    Stage: One: {
        Do: { 
           Pipeline: 'Do Get-Service' {
              Stage: One {
               on: $env:COMPUTERNAME {
                   Do: { Get-Service BITS }
                   }
               }
           } -Invoke           
        }
    }
}
Pipeline: 'Do Invoke-Pipeline 2' {
    Stage: One: {
        Do: { 
           & 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\EmbeddedPipelineScript.ps1'
        }
    }
}
#endregion

#region Tests
Describe 'Do Tests' {
<#   context 'Global' {
        Remove-Variable ABC -Scope Global -ErrorAction SilentlyContinue
        $Global:Abc = 'ABC'
        It 'should return global variable' {
            Invoke-Cidney 'Do Global Variable' | should be 'ABC'
        }
        Remove-Variable ABC -Scope Global -ErrorAction SilentlyContinue
    }#>
    context 'Local' {
        It 'should return local variable from Pipeline' {
            Invoke-Cidney 'Do Local Variable in Pipeline' | should be 'ABC'
        }
        It 'should return local variable from Stage' {
            Invoke-Cidney 'Do Local Variable in Stage' | should be 'ABC'
        }
        It 'should return local variable from Do' {
            Invoke-Cidney 'Do Local Variable in do' | should be 'ABC'
        }
    }
 <#   It 'should return the BITS Service' {
        $result = Invoke-Cidney 'Do Get-Service' 
        $result.Name | should be 'BITS'
    }

    It 'should not return console output' {
        $result = Invoke-Cidney 'Do WriteHost' 
        $result | should  BeNullOrEmpty
    }

    It 'should return Write-Output' {
        $result = Invoke-Cidney 'Do WriteOutput' 
        $result.Count | should be 2
        $result[0] | should be 'Output'
        $result[1] | should be 'Another output'
    }
    It 'should return an error in call' {
        $result = Invoke-Cidney 'Do WriteError' 
        $result | should throw
    }
    It 'should return the BITS Service from 32 different Do Blocks' {
        $result = Invoke-Cidney 'Do Get-Service 32 Times' 
        $result.Name[0] | should be 'BITS'
        $result.Count | should be 32
    }
    It 'should return the BITS Service from 64 different Do Blocks' {
        $result = Invoke-Cidney 'Do Get-Service 64 Times in Foreach' 
        $result.Name[0] | should be 'BITS'
        $result.Count | should be 64
    }
    It 'should time out when ExecutionTime is greater than Timeout (4 seconds)' {
        $result = Invoke-Cidney 'Do Get-Service with Timeout' 
        $result | should throw
    }
     It 'should return the BITS Service from Invoked Pipeline' {
        $result = Invoke-Cidney 'Do Invoke-Pipeline' 
        $result.Name | should be 'BITS'
    }
    It 'should return the pipleline name from Invoked Pipeline 2' {
        $result = Invoke-Cidney 'Do Invoke-Pipeline 2' 
        $result | should be 'Pipeline'
    }#>
}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion