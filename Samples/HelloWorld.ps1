$ErrorActionPreference = 'stop'

$var = 'ABC'
Pipeline: HelloWorld {
    $Test = 'ONE'
    Stage: One {
        Write-Output "Hello World! from [Stage $Stagename] [$Test] [$var]"
    } 

    Stage: Two {
        $var = 'def'
        $test = 'TWO'
    #    on: $env:COMPUTERNAME {
    #        Do: Something {
                Write-Output "Hello World! from [Stage $($Context.CurrentStage)] [$Test] [$var]"
    #        } 
    #    }
    }

    Stage: Three {
        $test = 'THREE'
        Write-Output "Hello World! from [Stage $Stagename] [$Test] [$var]" 
    }
    
} -Invoke
