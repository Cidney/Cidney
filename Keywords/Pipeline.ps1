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
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $PipelineName,
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $PipelineBlock,
        [switch]
        $ShowProgress
    )

    $Global:CidneyPipelineCount++

    if ($ShowProgress) { Write-Progress -Activity "Pipeline $PipelineName" -Status 'Starting' -Id 0 }

    Write-CidneyLog "[Start] Pipeline $PipelineName" 

    $currentPipeline = 'Pipeline:'+[guid]::NewGuid()
    $Global:CidneySession.Insert(0, ([PSCustomObject]@{'Name'=$currentPipeline; 'Pipeline'=@{}}))
    $Global:CidneySession[0].Pipeline.Add('Modules', (Get-Module))
    $Global:CidneySession[0].Pipeline.Add('CredentialStore', @{})
    $Global:CidneySession[0].Pipeline.Add('ShowProgress', $ShowProgress)

    if ($ShowProgress) { Write-Progress -Activity "Pipeline $PipelineName" -Status 'Processing' -Id 0 }
        
    try
    {
        Initialize-CidneyVariables -ScriptBlock $PipelineBlock
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
        foreach($cred in $Global:CidneySession[0].Pipeline.CredentialStore.GetEnumerator())
        {
            Remove-Item $cred.Value -Force -ErrorAction SilentlyContinue
        }
        
        foreach($var in $Global:CidneySession[0].Pipeline.GlobalVariables)
        {
            Remove-Variable -Name $var.Name -Scope Global
        }
        
        $Global:CidneySession.RemoveAt(0)
    }   
    
    Write-CidneyLog "[Done] Pipeline $PipelineName" 
    if ($ShowProgress) { Write-Progress -Activity "Pipeline $PipelineName" -Status 'Completed' -ID 0 -Completed }

    $Global:CidneyPipelineCount--
}