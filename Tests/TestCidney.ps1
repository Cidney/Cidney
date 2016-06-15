$path = 'c:\Program Files\WindowsPowershell\Modules\Cidney\'
#$path = 'c:\Projects\Cidney\'
Import-module (Join-path $path 'Cidney.psd1')
pipeline: CidneyBuild {
    $base = (Get-Module Cidney).ModuleBase
    Import-Module Pester
    Stage: Pester {
        Do: { Invoke-Pester -Script "$base\Tests\Pipeline.Tests.ps1" }
        Do: { Invoke-Pester -Script "$base\Tests\Stage.Tests.ps1" }
        Do: { Invoke-Pester -Script "$base\Tests\Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$base\Tests\Pipeline.Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$base\Tests\When.Tests.ps1" }
    }
} -Invoke -Verbose
