function Pipeline:
{
    <#
        .SYNOPSIS
        Cidney Pipeline:
        .DESCRIPTION
        Cidney Pipeline:
        .EXAMPLE
        .\HelloWorld.ps1
                
        Pipeline HelloWorld {
            Stage One {
                Do: { Get-Process }
            }
        }

        .EXAMPLE
        .\HelloWorld.ps1
        
        Pipeline HelloWorld {
            Stage One {
                Do: { Get-Process | Where Status -eq 'Running' }
            }
        }
        .LINK
        Pipeline:
        Stage:
        Do:
        Register-JobCommand
        Get-RegisteredJobCommand
        Get-RegisteredJobModule
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $PipelineBlock,
        [switch]
        $ShowProgress,
        [hashtable]
        $ConfigurationData
    )

    if ($ShowProgress) { Write-Progress -Activity "Pipeline $Name" -Status 'Starting' -Id 0 }

    Write-Output ''
    Write-Log "[Start] Pipeline $Name"     

    $Global:CidneyVariables = @()
    $Global:CidneyShowProgress = $ShowProgress

    if ($ShowProgress) { Write-Progress -Activity "Pipeline $Name" -Status 'Processing' -Id 0 }
        
    try
    {
        Initialize-CidneyVariables($PipelineBlock)
        $stages = Get-CidneyBlocks -ScriptBlock $PipelineBlock -BoundParameters $PSBoundParameters 
        $count = 0
        foreach($stage in $stages)
        {
            if ($ShowProgress) { Write-Progress -Activity "Pipeline $Name" -Status 'Processing' -Id 0 -PercentComplete ($count / $stages.Count * 100) }
            $count++           
    
            #$stage = [scriptBlock]::Create("$stage")
            Invoke-Command -Command $stage -ArgumentList $ConfigurationData
        }    
    }
    finally
    {
        $Global:CidneyVariables | Remove-Variable -Scope Global -Force
    }   
    
    Write-Log "[Done] Pipeline $Name" 
    Write-Output ''
    if ($ShowProgress) { Write-Progress -Activity "Pipeline $Name" -Status 'Completed' -ID 0 -Completed }
        
    Remove-Variable -Name CidneyVariables -Scope Global -Force
}

