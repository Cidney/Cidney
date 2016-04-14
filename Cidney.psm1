$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

$Global:CidneyJobCount = 0
$Global:CidneyEventSubscribers = @()
$Global:CidneyEventOutput = @{}
$Global:CidneyImportedModules = @()
$Global:CidneyAddedSnapins = @()
$CidneyPipelineFunctions = [hashtable]::Synchronized(@{})


$Env:CidneyStore = Join-Path $env:LOCALAPPDATA 'Cidney'
New-Item $Env:CidneyStore -ItemType Directory -Force

#region Load Public DSL Keywords
try 
{
    Get-ChildItem (Join-Path $ScriptPath 'Keywords') -Filter *.ps1 | Select-Object -ExpandProperty FullName | 
		ForEach-Object {
			$Keyword = Split-Path $PSItem -Leaf
			. $PSItem
		}
	}
catch 
{
    Write-Warning ('{0}: {1}' -f $Keyword, $PSItem.Exception.Message)
    Continue
}
#endregion

#region Load Public Files
try 
{
    Get-ChildItem (Join-Path $ScriptPath 'Public') -Filter *.ps1 | Select-Object -ExpandProperty FullName | 
		ForEach-Object {
			$File = Split-Path $PSItem -Leaf
			. $PSItem
		}
} 
catch 
{
    Write-Warning ('{0}: {1}' -f $File, $PSItem.Exception.Message)
    Continue
}
#endregion

#region Load Private Files
try 
{
    Get-ChildItem (Join-Path $ScriptPath 'Private') -Filter *.ps1 | Select-Object -ExpandProperty FullName | 
		ForEach-Object {
			$File = Split-Path $PSItem -Leaf
			. $PSItem
		}
} 
catch 
{
    Write-Warning ('{0}: {1}' -f $File, $PSItem.Exception.Message)
    Continue
}
#endregion

#region ArgumentCompleter
$completionScriptBlock = {
    $Pipelines = (Get-CidneyPipeline) -replace 'Pipeline: '
    foreach($pipeline in $Pipelines)
    {
        $completionText = $pipeline
        if ($completionText -match '\s')
        {
            $completionText = "'$completionText'"
        }
        $functionName = "Global:Pipeline: $pipeline"
        $pipelineParams = Get-CidneyPipelineParams $functionName

        $toolTip = $completionText
        $showProgress = ''
        $additionalParams = ''
        if ($pipelineParams)
        {
            $params = $pipelineParams.Params
            if ($pipelineParams.ShowProgress)
            {
                $showProgress = '-ShowProgress '
            }

            foreach($item in $params.GetEnumerator())
            {
                $key = $item.Key
                $value = $item.Value
                if ($value -match '\s')
                {
                    $value = "'$value'"
                }
                $additionalParams += "-$key $value "
            }
            $toolTip = "Pipeline: $completionText {`t$($pipelineParams.PipelineBlock)} $showProgress $additionalParams"
        }

        New-Object System.Management.Automation.CompletionResult($completionText, $pipeline, 'ParameterValue', $toolTip)
    }
}

Register-ArgumentCompleter -CommandName Invoke-Cidney -ParameterName Name -ScriptBlock $completionScriptBlock
Register-ArgumentCompleter -CommandName Remove-CidneyPipeline -ParameterName Name -ScriptBlock $completionScriptBlock
#endregion

$ExecutionContext.SessionState.Module.OnRemove = {
    Remove-Variable -Name CidneyPipelineCount -Force -ErrorAction SilentlyContinue
    Remove-Variable -Name CidneyPipelineFunctions -Force -ErrorAction SilentlyContinue
    Remove-Variable -Name CidneyImportedModules -Scope Global -Force -ErrorAction SilentlyContinue
    Remove-Variable -Name CidneyAddedSnapins -Scope Global -Force -ErrorAction SilentlyContinue

    Remove-Item $Env:CidneyStore -Force
}

Export-ModuleMember -Function Pipeline:
Export-ModuleMember -Function Stage:
Export-ModuleMember -Function On:
Export-ModuleMember -Function Do:
Export-ModuleMember -Function When:

Export-ModuleMember -Function Write-CidneyLog
Export-ModuleMember -Function Invoke-Cidney 
Export-ModuleMember -Function Get-CidneyPipeline
Export-ModuleMember -Function Remove-CidneyPipeline
Export-ModuleMember -Function Wait-CidneyJob
Export-ModuleMember -Function Send-Event