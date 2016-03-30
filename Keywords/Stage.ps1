function Stage:
{
    <#
        .SYNOPSIS
        Short Description
        .DESCRIPTION
        Detailed Description
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
        Invoke-Cidney HelloWorld -Verbose

        .LINK
        Pipeline:
        On:
        Do:
        Invoke-Cidney
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $StageName,
        [Parameter(Position = 1)]
        [scriptblock]
        $StageBlock  = $(Throw 'No Stage: block provided. (Did you put the open curly brace on the next line?)'),
        [Parameter(DontShow)]
        [hashtable]
        $Context
    )
    
    try
    {        
    $paramHeader = @'
param([hashtable]$__context__)

if ($__context__ -and $__context__.LocalVariables)
{
    foreach($__var__ in $__context__.LocalVariables)
    {
        if (-not (Get-Variable $__var__.Name -ErrorAction SilentlyContinue))
        {
            New-Variable -Name $__var__.Name -Value $__var__.Value
        }
        else
        {
            Set-Variable -Name -Name $__var__.Name -Value $__var__.Value 
        }
    }
}

'@
        if (-not $Context)
        {
            $Context = New-CidneyContext
        }
        
        if ($Context.ShowProgress) 
        { 
            Write-Progress -Activity "Stage $StageName" -Status 'Starting' -Id ($CidneyPipelineCount + 1) 
        }
        $Context.CurrentStage = $StageName

        Write-CidneyLog "[Start] Stage $StageName"
        $blocks = Get-Cidneystatements -ScriptBlock $stageBlock -BoundParameters $PSBoundParameters
        $count = 0
        foreach($block in $blocks)
        {
            $block = $block.ToString().Trim()
            $block = [scriptblock]::Create("$paramHeader`r`n$block")

            if ($Context.ShowProgress) 
            { 
                Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id ($CidneyPipelineCount + 1)
            }

            Invoke-CidneyBlock -ScriptBlock $block -Context $Context

            $count++ 
            if ($Context.ShowProgress -and $Context.Jobs.Count -eq 0) 
            { 
                Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id ($CidneyPipelineCount + 1) -PercentComplete ($count/$blocks.Count * 100)
            }
        }
        
        Wait-CidneyJob -Context $Context  
    }
    finally
    {
        $Context.Jobs = @()
        $removeKeys = @()
        foreach($output in $Global:CidneyEventOutput.GetEnumerator())
        {
            $output.Value
            $removeKeys += $output.Key
        }

        foreach($key in $removeKeys)
        {
            $Global:CidneyEventOutput.Remove($key)
        }

        if ($Script:RunspacePool -and $Script:RunspacePool.RunspacePoolStateInfo.State -ne 'Closed')
        {
            $Script:RsSessionState = $null
            $null = $Script:RunspacePool.Close()
            $null = $Script:RunspacePool.Dispose()
            #[gc]::Collect()
        }
    }

    if ($Context.ShowProgress) 
    { 
        Write-Progress -Activity "Stage $StageName" -Status 'Completed' -Id ($CidneyPipelineCount + 1) -Completed 
    }       
    Write-CidneyLog "[Done] Stage $StageName"
}

