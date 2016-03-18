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
    It 'Should output from three pipelines inside Stage' {
        Invoke-Cidney 'Embedded Pipeline in Stage' | should Throw
    }
}

Describe 'Block before Stage' {
    It 'Pipeline should have a statements before stage' {
        Invoke-Cidney 'Statements before Stage' | should be 'abc123', 'Stage One'
    }
}

Describe 'Block after Stage' {
    It 'Pipeline should have a statements after stage' {
        Invoke-Cidney 'Statements after Stage' | should be 'Stage One','abc123' 
    }
}
#endregion