$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$Global:CidneyJobCommands = @{}
$Global:CidneyJobModules = @{}

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
    Remove-Variable CidneyJobCommands -Scope Global -Force
    Remove-Variable CidneyJobModules -Scope Global -Force
}

Export-ModuleMember -Function Pipeline:
Export-ModuleMember -Function Stage:
Export-ModuleMember -Function On:
Export-ModuleMember -Function Do:
Export-ModuleMember -Function Dsc:

Export-ModuleMember -Function Get-TfsSource

Export-ModuleMember -Function Register-JobCommand
Export-ModuleMember -Function Get-RegisteredJobCommand
Export-ModuleMember -Function Get-RegisteredJobModule
