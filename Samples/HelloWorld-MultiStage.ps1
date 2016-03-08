Pipeline: HelloWorld {
    Stage: One {
        on: $env:COMPUTERNAME {
            Do: Hi {Write-Output 'Hello World! from Stage One'}
        }
    } 
    Stage: Two {
        Write-Output 'Hello World! from Stage Two'
    } 
} -Verbose
