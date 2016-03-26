#region When configurations
Pipeline: 'When with Stage' {
    Stage: 'Stage One' {
        When: Event1 {
             Write-output 'Stage One'
        }   
    }

    Stage: 'Stage Two' {
       Send-Event Event1
   }
}

Pipeline: 'When trigger from another pipeline' {
    Stage: 'Stage One' {
        When: Event2 {
             Write-output 'Stage One'
        }   
    }
} -Invoke

Pipeline: 'Trigger' {
    Send-Event Event2
}

Pipeline: 'Trigger 3 events' {
    Send-Event Event2
    Send-Event Event2
    Send-Event Event2
}

Pipeline: 'When with 2 Stages' {
    Stage: 'Stage One' {
        When: EventA {
             Write-output 'Stage One'
        }   
    }

    Stage: 'Stage Two' {
        When: EventB {
             Write-output 'Stage Two'
        }   
   }
} 

Pipeline: 'Trigger 4 events' {
    Stage: One {
        Send-Event EventB
        Send-Event EventA 
        Send-Event EventA 
        Send-Event EventB 
    }
}

Pipeline: 'Trigger event from Do:' {
    Do: { Send-Event EventA }
}

#endregion

#region Tests
Describe 'When Tests' {
    It 'Should output stage name' {
        Invoke-Cidney 'When with Stage' | Should be 'Stage One'
    }
    It 'Should output stage name when triggered from another pipeline' {
        Invoke-Cidney 'Trigger' | Should be 'Stage One'
    }
    It 'Should output stage name 3 times when triggered from another pipeline 3 times' {
        Invoke-Cidney 'When trigger from another pipeline'
        $result = Invoke-Cidney 'Trigger 3 events' 
        $result.count | Should be 3
        $result | should be @('Stage One','Stage One','Stage One')
    }
    It 'Should output stage name for different stages as triggered' {
        Invoke-Cidney 'When with 2 Stages' 
        $result = Invoke-Cidney 'Trigger 4 events' 
        $result.count | Should be 4
        $result | should be @('Stage Two','Stage One','Stage One', 'Stage Two')
    }
#    It 'Should output stage name from event in Do' {
#        Invoke-Cidney 'When with 2 Stages'
#        $result = Invoke-Cidney 'Trigger event from Do:'
#        $result | should be 'Stage One'
#    }

    It 'Should not have any left over jobs' {
        Get-Job | Should beNullOrEmpty
    }
    It 'Should not have any left over Events' {
        Get-Event | Should beNullOrEmpty
    }
    It 'Should not have any left over Events Subscriptions' {
        Get-EventSubscriber | Should beNullOrEmpty
    }
}
#endregion

#region Cleanup
Get-CidneyPipeline | Remove-CidneyPipeline
#endregion