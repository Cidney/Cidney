Pipeline: HelloWorld {
    Stage: One {
        Do: { Write-Output '1. Hello World! from Stage One' }
        Do: { Write-Output '2. Hello World! from Stage One' }
        Do: { Write-Output '3. Hello World! from Stage One' }
    } 
    Stage: Two {
        Do: { Get-NetIPAddress -AddressFamily IPv4 }
        Do: { Find-Package *tfs* | Select-Object Name,Version,Summary }
        Do: { Get-Service | Where-Object Status -eq 'Running'}
    } 
} -Verbose -Invoke -ShowProgress