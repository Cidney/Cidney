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
             Write-Output 'Stage One'
        }   
    }

    Stage: 'Stage Two' {
        When: EventB {
             Write-Output 'Stage Two'
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

pipeline: TimerTest {
    $Timer =[timers.timer]::new()
    $timerCount = 1
    When: Timer.Done {
        $Global:TimerResult = 'Timer Elapsed'
    }

    Stage: StartTimer {
        $timer.Interval = 2000
        $timer.AutoReset = $true

        $job = Register-ObjectEvent -InputObject $timer -EventName elapsed –SourceIdentifier ATimer -Action { 
            Send-Event Timer.Done 
        }  

        $timer.start()
        Sleep -Seconds 3

        $Timer.Stop()
        $Timer.Dispose()
        Unregister-Event ATimer
        Get-Job ATimer | Remove-Job -Force

        Unregister-Event Timer.Done
        Get-Job Timer.Done | Remove-Job -Force
    }
} 

# Cannot trigger events from Do since it is a separate runspace and the message pump is not the same
<#Pipeline: 'Trigger event from Do:' {
    Do: { Send-Event EventA }
}

#>#endregion

#region Tests
Describe 'When Tests' -Tag When {
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
<#    It 'Should output stage name from event in Do' {
        Invoke-Cidney 'When with 2 Stages'
        $result = Invoke-Cidney 'Trigger event from Do:'
        $result | should be 'Stage One'
    }#>

    It 'Should do complex Events like Timer' {
        $Global:TimerResult = ''
        Invoke-Cidney TimerTest 
        $Global:TimerResult | Should be 'Timer Elapsed' 
    }
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