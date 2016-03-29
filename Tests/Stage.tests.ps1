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
}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion