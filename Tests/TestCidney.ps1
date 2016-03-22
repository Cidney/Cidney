# I dont have credentials to access the appveyor machine this runs on. So instead of 
# using the On: keyword to import the modules I import them directly in the Do: block
#

Import-Module Cidney -force

pipeline: CidneyBuild {
    $Path = (Get-Module Cidney).ModuleBase
    Stage: Pester {
        Do: { Invoke-Pester -Script "$path\Tests\Pipeline.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\Stage.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\Do.Tests.ps1" }
        Do: { Invoke-Pester -Script "$path\Tests\Pipeline.Do.Tests.ps1" }
    }
} -Invoke -Verbose
