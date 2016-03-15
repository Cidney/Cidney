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
        On:
        When:
        Invoke-Cidney
    #>

    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $PipelineName,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $PipelineBlock,
        [switch]
        $PassThru
    )

    $functionName = "Global:Pipeline:$PipelineName"
    if ($Global:CidneyPipelineFunctions.ContainsKey($functionName))
    {
        $Global:CidneyPipelineFunctions.Remove($functionName)
    }
    $Global:CidneyPipelineFunctions.Add($functionName, $PSBoundParameters)

    $functionScript = {
        [CmdletBinding()]
        param
        (
            [string]
            $PipelineName,
            [scriptblock]
            $PipelineBlock,
            [switch]
            $ShowProgress
        )

        $Global:CidneyPipelineCount++
        $context = New-CidneyContext
        $context.Add('ShowProgress', $ShowProgress)

        if ($ShowProgress) 
        { 
            Write-Progress -Activity "Pipeline $PipelineName" -Status 'Starting' -Id 0 
        }

        Write-CidneyLog "[Start] Pipeline $PipelineName" 

        if ($ShowProgress) 
        { 
            Write-Progress -Activity "Pipeline $PipelineName" -Status 'Processing' -Id 0 
        }
        
        try
        {
            Initialize-CidneyVariables -ScriptBlock $PipelineBlock -Context $context
            $stages = Get-CidneyBlocks -ScriptBlock $PipelineBlock -BoundParameters $PSBoundParameters 
            $count = 0
            foreach($stage in $stages)
            {
                if ($ShowProgress) 
                { 
                    Write-Progress -Activity "Pipeline $PipelineName" -Status 'Processing' -Id 0 -PercentComplete ($count / $stages.Count * 100) 
                }
                $count++           
    
                Invoke-Command -Command $stage
            }    
        }
        finally
        {
            foreach($cred in $context.CredentialStore.GetEnumerator())
            {
                Remove-Item $cred.Value -Force -ErrorAction SilentlyContinue
            }
        
            foreach($var in $context.LocalVariables)
            {
                Remove-Variable -Name $var.Name -Scope Local -ErrorAction SilentlyContinue
            }
        }   
    
        Write-CidneyLog "[Done] Pipeline $PipelineName" 
        if ($ShowProgress) 
        { 
            Write-Progress -Activity "Pipeline $PipelineName" -Status 'Completed' -ID 0 -Completed 
        }

        $Global:CidneyPipelineCount--
    }

    $result = New-item Function:\$functionName -Value $functionScript -Options AllScope, ReadOnly -Force

    if ($PassThru)
    {
        $result
    }
}