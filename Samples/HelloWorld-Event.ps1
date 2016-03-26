Import-Module Cidney -Force

Pipeline: HelloWorld {
    Stage: One {
        When: MyEvent1 {
            Write-Host 'HelloWorld from Stage One'
            Write-Output 'HelloWorld from Stage One'
        } 
    }
    Stage: Two {
        When: MyEvent2 {
            Write-Host 'HelloWorld from Stage Two'
            Write-Output 'HelloWorld from Stage Two'
        } 
    }
} -Verbose -Invoke


Pipeline: HelloWorld2 {
    Stage: One {
        Write-Output 'Helloworld2'
        Send-Event MyEvent2
        Send-Event MyEvent1
        Send-Event MyEvent1
        Send-Event MyEvent2
    }
} -Verbose -Invoke

