$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

$Global:CidneyContext = [System.Collections.ArrayList]@()
$Global:CidneyImportModulesPreference = $false
$Global:CidneyPipelineCount = -1

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

$ExecutionContext.SessionState.Module.OnRemove = {
    Remove-Variable CidneyContext -Scope Global -Force
    Remove-Variable CidneyImportModulesPreference -Scope Global -Force
    Remove-Variable CidneyPipelineCount -Scope Global -Force
    Remove-Item $Env:CidneyStore -Force
    Remove-Item Env:CidneyStore -Force
}

Export-ModuleMember -Function Pipeline:
Export-ModuleMember -Function Stage:
Export-ModuleMember -Function On:
Export-ModuleMember -Function Do:
Export-ModuleMember -Function When:

Export-ModuleMember -Function Write-CidneyLog