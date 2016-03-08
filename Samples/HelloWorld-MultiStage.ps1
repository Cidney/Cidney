Pipeline: HelloWorld {
    Stage: One {
        on: $env:COMPUTERNAME {
            Do: {Write-Output 'Hello World! from Stage One'}
        }
    } 
    Stage: Two {
        Write-Output 'Hello World! from Stage Two'
    } 
} -Verbose