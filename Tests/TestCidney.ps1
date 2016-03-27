#$path = 'c:\Program Files\WindowsPowershell\Modules\Cidney\'
$path = 'c:\Projects\Cidney\'
Import-module (Join-path $path 'Cidney.psd1')
pipeline: CidneyBuild {
    Import-Module Pester
    Stage: Pester {
        Do: { Invoke-Pester -Script "$path\Tests\Pipeline.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\Stage.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\Pipeline.Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\When.Tests.ps1" }
    }
} -Invoke -Verbose
