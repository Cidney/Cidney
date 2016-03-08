Pipeline: HelloWorld {
    Stage: One {
        Do: { Get-ChildItem C:\Windows\System32 | Where-Object Name -match '.dll' | Measure-Object }
        Do: GetService { Get-Service B* }
    }
} -Verbose -ShowProgress
