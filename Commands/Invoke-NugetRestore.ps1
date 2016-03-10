function Invoke-NugetRestore
{
    <#
        .SYNOPSIS
        Does a Nuget Package restore using the supplied path
        
        .DESCRIPTION
        Does a Nuget Package restore using the supplied path
        Requires Nuget.exe to be on the computer this is being run and the location set in the $env:NugetPath environment variable
        or or supplied in the parameters 

        Download Nuget: https://dist.nuget.org/index.html

        .EXAMPLE
        Invoke-NugetRestore -Path c:\Projects\MyProject -Source http://nuget.example.com/nuget 

        Restores Nuget packages from private source http://nuget.example.com/nuget 

        .PARAMETER Path
        Path to the project or solution 

        .PARAMETER Sources
        Source to nuget packages. By default this is set to $env:NugetSource. Using this parameter will replace the default 
        if this parameter is not supplied and $env:NugetSource is empty it will default to https://www.nuget.org/api/v2
        
        .PARAMETER NugetPath
        Defaults to $Env:NugetPath. Use this parameter to select a different location


        .LINK
        https://www.nuget.org/
        
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Path,
        [string[]]
        $Source,
        [string]
        $NugetPath = $env:NugetPath
    )

    $nugetNotFoundMessage =@"
Nuget.exe path was not supplied. Please set environment variable NugetPath or use the -NugetPath parameter to supply the location for Nuget.exe
Nuget.exe can be downloaded from https://dist.nuget.org/index.html
"@
    if (-not $NugetPath)
    {
        Write-Warning $nugetNotFoundMessage
        return
    }

    if (-not $Source)
    {
        $Source = $env:NugetSource
        if (-not $Source)
        {
            $Source = @('https://www.nuget.org/api/v2')
        }
    }

    $source = $source -join ';'

    $oldDebugPreference = $DebugPreference
    $DebugPreference = 'Continue'
    
    Write-Verbose 'Starting Package Restore'
    $NugetRestore = "$NugetPath  restore -source `"$source`" -NonInteractive"
    Write-Debug "Nuget command line: $NugetRestore"
    
    Invoke-Expression $NugetRestore -ErrorAction SilentlyContinue 
    $DebugPreference = $oldDebugPreference
    
    Write-Verbose 'Done Package Restore'
}