#$BasePath = 'c:\Program Files\WindowsPowershell\Modules\Cidney\'
$BasePath = 'c:\Projects\Cidney\'
Import-module (Join-path $BasePath 'Cidney.psd1')
pipeline: CidneyBuild {
    Import-Module Pester
    Stage: Pester {
        Do: { Invoke-Pester -Script "$BasePath\Tests\Pipeline.Tests.ps1" }
        Do: { Invoke-Pester -Script "$BasePath\Tests\Stage.Tests.ps1" }
        Do: { Invoke-Pester -Script "$BasePath\Tests\Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$BasePath\Tests\Pipeline.Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$BasePath\Tests\When.Tests.ps1" }
    }
} -Invoke -Verbose
