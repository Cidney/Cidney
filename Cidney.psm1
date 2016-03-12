$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$Global:CidneySession = @{}
$Global:CidneySession.Add('JobCommands', @{})
$Global:CidneySession.Add('JobModules', @{})
$Global:CidneySession.Add('CredentialStore', @{})

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
#endregion Load Public Functions

#region Load Command Files
try 
{
    Get-ChildItem (Join-Path $ScriptPath 'Commands') -Filter *.ps1 | Select-Object -ExpandProperty FullName | 
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
#endregion Load Command Functions

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
#endregion Load Private Functions

$ExecutionContext.SessionState.Module.OnRemove = {
    Remove-Variable CidneySession -Scope Global -Force
}

New-Alias -Name GetSource -Value Get-TfsSource -Description 'Simplified command name to that it looks cleaner in Pipeline:' -Force
New-Alias -Name RestorePackages -Value Invoke-NugetRestore -Description 'Simplified command name to that it looks cleaner in Pipeline:' -Force

Export-ModuleMember -Function Pipeline:
Export-ModuleMember -Function Stage:
Export-ModuleMember -Function On:
Export-ModuleMember -Function Do:
Export-ModuleMember -Function Dsc:

Export-ModuleMember -Function Get-TfsSource -Alias GetSource
Export-ModuleMember -Function Invoke-NugetRestore -Alias RestorePackages

Export-ModuleMember -Function Register-JobCommand
Export-ModuleMember -Function Get-RegisteredJobCommand
Export-ModuleMember -Function Get-RegisteredJobModule
Export-ModuleMember -Function New-TfsWorkspace
Export-ModuleMember -Function Remove-TfsWorkspace
