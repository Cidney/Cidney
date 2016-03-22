
pipeline: CidneyBuild {
    Stage: Pester {
        #Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Pipeline.tests.ps1' -Quiet -Passthru | select -ExpandProperty TestResult | select Describe, Context, Name, Result, Time | Format-Table -AutoSize }
        #Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Stage.tests.ps1' -Quiet -Passthru | select -ExpandProperty TestResult | select Describe, Context, Name, Result, Time | Format-Table -AutoSize }
        #Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Do.tests.ps1' -Quiet -Passthru | select -ExpandProperty TestResult | select Describe, Context, Name, Result, Time | Format-Table -AutoSize }
 
#        Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Pipeline.tests.ps1' -Quiet -Passthru | Select TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount, Time| Format-Table -AutoSize }
#        Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Stage.tests.ps1' -Quiet -Passthru | Select TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount, Time| Format-Table -AutoSize }
#        Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Do.tests.ps1' -Quiet -Passthru | Select TotalCount, PassedCount, FailedCount, SkippedCount, PendingCount, Time| Format-Table -AutoSize }
        Do: { Invoke-Pester -Path 'C:\Program Files\WindowsPowerShell\Modules\Cidney\Tests\Do.tests.ps1' }
    }
} -Invoke -Verbose