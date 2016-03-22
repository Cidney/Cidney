pipeline: CidneyBuild {
    $Path = (Get-Module Cidney).ModuleBase
    Stage: Pester {
        Do: { Import-Module 'c:\projects\Cidney\Cidney.psd1', Pester; Invoke-Pester -Script "$path\Tests\Pipeline.Tests.ps1" }
        Do: { Import-Module 'c:\projects\Cidney\Cidney.psd1', Pester; Invoke-Pester -Script "$path\Tests\Stage.Tests.ps1" }
        Do: { Import-Module 'c:\projects\Cidney\Cidney.psd1', Pester; Invoke-Pester -Script "$path\Tests\Do.Tests.ps1" }
        Do: { Import-Module 'c:\projects\Cidney\Cidney.psd1', Pester; Invoke-Pester -Script "$path\Tests\Pipeline.Do.Tests.ps1" }
    }
} -Invoke -Verbose
