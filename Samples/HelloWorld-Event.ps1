Import-Module Cidney -Force

Pipeline: HelloWorld {
    Stage: One {
        When: MyEvent {
            Write-Host 'HelloWorld from Stage One'
           # Start-Process C:\Windows\System32\notepad.exe
        } -Wait -Timeout 10
    }
     
    Stage: Two {
        Write-Output 'Stage Two'
        $null = New-Event MyEvent
    }
} -Verbose -ShowProgress


