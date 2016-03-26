function Import-Module
{
    [CmdletBinding(DefaultParameterSetName='Name')]
    param(
        [Parameter(ParameterSetName='Name', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string[]]
        ${Name},

        [Parameter(ParameterSetName='FullyQualifiedName', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Parameter(ParameterSetName='FullyQualifiedNameAndPSSession', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [Microsoft.PowerShell.Commands.ModuleSpecification[]]
        ${FullyQualifiedName},

        [Parameter(ParameterSetName='Assembly', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [System.Reflection.Assembly[]]
        ${Assembly},

        [ValidateNotNull()]
        [string[]]
        ${Function},

        [ValidateNotNull()]
        [string[]]
        ${Cmdlet},

        [ValidateNotNull()]
        [string[]]
        ${Variable},

        [ValidateNotNull()]
        [string[]]
        ${Alias},

        [switch]
        ${Force},

        [switch]
        ${AsCustomObject},

        [Parameter(ParameterSetName='Name')]
        [Alias('Version')]
        [version]
        ${MinimumVersion},

        [Parameter(ParameterSetName='Name')]
        [string]
        ${MaximumVersion},

        [Parameter(ParameterSetName='Name')]
        [version]
        ${RequiredVersion},

        [Parameter(ParameterSetName='ModuleInfo', Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [psmoduleinfo[]]
        ${ModuleInfo},

        [Alias('Args')]
        [System.Object[]]
        ${ArgumentList},

        [switch]
        ${DisableNameChecking},

        [Alias('NoOverwrite')]
        [switch]
        ${NoClobber}
        )

    begin
    {
        $WarningPreference = 'stop'
        $oldVerbosePreference = $VerbosePreference
        $VerbosePreference = $PSBoundParameters['Verbose']
    Write-host "Using Import-Module Proxy: $Name"
        try 
        {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Core\Import-Module', [System.Management.Automation.CommandTypes]::Cmdlet)
            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } 
        catch 
        {
            throw
        }
    }

    process
    {
        try 
        {
            $steppablePipeline.Process($_)
        } 
        catch 
        {
            throw
        }
    }

    end
    {
        $VerbosePreference = $oldVerbosePreference
        try 
        {
            $steppablePipeline.End()
            $module = Get-Module $Name
            $hasModule = $Global:CidneyImportedModules | Where Name -eq $module.Name
            if (-not $hasModule)
            {
                $null = $Global:CidneyImportedModules += $module
            }
        } 
        catch 
        {
            throw
        }
    }
}
