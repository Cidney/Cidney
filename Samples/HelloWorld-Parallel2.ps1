$ErrorActionPreference = 'stop'
Pipeline: HelloWorld {
    Stage: One {
        On: $env:COMPUTERNAME -Credential (Get-Credential hic\rkozak) {
            Do: { Get-ChildItem C:\Windows\System32 | Where-Object Name -match '.dll' | Measure-Object }
            Do: GetService { Get-Service B* }
        }
    }
} -Verbose -ShowProgress
