﻿#region Pipeline configurations
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
#endregion

#region Tests
Describe '1 Stage' {
    It 'Should output Stage One' {
        Invoke-Cidney '1 Stage' | Should be 'Stage One'
    }
}

Describe '2 Stages' {
    It 'Should output Stage One Stage Two' {
        Invoke-Cidney '2 Stages' | Should be 'Stage One', 'Stage Two'
    }
}

Describe 'Embedded Pipeline in Stage' {
    It 'Should throw if pipelines are embedded inside Stage' {
        Invoke-Cidney 'Embedded Pipeline in Stage' | should Throw
    }
}

Describe 'Block before Stage' {
    It 'Pipeline should have statements before stage' {
        Invoke-Cidney 'Statements before Stage' | should be 'abc123', 'Stage One'
    }
}

Describe 'Block after Stage' {
    It 'Pipeline should have statements after stage' {
        Invoke-Cidney 'Statements after Stage' | should be 'Stage One','abc123' 
    }
}

Describe 'Invoking Pipeline in a stage' {
    It 'Pipeline with Invoke-Cidney inside a stage should work' {
        Invoke-Cidney 'Invoking Pipeline in Stage' | Should be 'Stage One'
    }
}

Describe 'Invoking multiple Pipelines in a stage' {
    It 'Pipeline with Multiple Invoke-Cidney calls inside a stage should work' {
        Invoke-Cidney 'Invoking Multiple Pipelines in Stage' | Should be 'Stage One', 'Stage One', 'Stage Two'
    }
}

Describe 'Stage in Stage' {
    It 'Pipeline should handle stages inside stages' {
        Invoke-Cidney 'Embedded Stage in Stage' | should be 'B' 
    }
}
#endregion