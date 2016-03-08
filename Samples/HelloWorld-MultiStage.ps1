#TODO: get variables working inside jobs
Pipeline: HelloWorld {
    $A = '123'
    Stage: One {
        on: $env:COMPUTERNAME {
            Do: Hi { Write-Output "Hello World! from Stage One $A" }
        }
    } 
    Stage: Two {
        Write-Output "Hello World! from Stage Two $A"
    } 
} -Verbose
