function Do:
{
    <#
        .SYNOPSIS
        Runs a scriptblock using Jobs. 
        
        .DESCRIPTION
        A Cindey Pipeline: will run each Stage: one right after the other synchronously.
        Each Do: Block found will create a Job so they can be run asyncronously or in Parallel.

        .EXAMPLE
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                Do: { Dir C:\Windows\System32 | Where Name -match '.dll' | measure }
                Do: GetService { Get-Service B* }
            }
        }

        This example will do a Dir list and count the number of dll files, and run Get-Process as separate jobs and the Stage: will complete once all jobs are finished.
        Notice that Get-Service finished first even when it was listed second in the code.

        VERBOSE: [03/06/16 4:53:39.556 PM] [Start] Pipeline HelloWorld
        VERBOSE: [03/06/16 4:53:39.591 PM] [Start] Stage One
        VERBOSE: [03/06/16 4:53:39.769 PM] [Start] Job28
        VERBOSE: [03/06/16 4:53:40.021 PM] [Start] GetService
        VERBOSE: [03/06/16 4:53:40.150 PM] [Results] GetService

        Status   Name               DisplayName                           
        ------   ----               -----------                           
        Running  BDESVC             BitLocker Drive Encryption Service    
        Running  BFE                Base Filtering Engine                 
        Running  BrokerInfrastru... Background Tasks Infrastructure Ser...
        Running  Browser            Computer Browser                      
        Running  BthHFSrv           Bluetooth Handsfree Service           
        Running  bthserv            Bluetooth Support Service             
        VERBOSE: [03/06/16 4:53:40.170 PM] [Completed] GetService
        VERBOSE: [03/06/16 4:53:40.496 PM] [Results] Job28

        Count    : 3001
        Average  : 
        Sum      : 
        Maximum  : 
        Minimum  : 
        Property : 

        VERBOSE: [03/06/16 4:53:40.499 PM] [Completed] Job28
        VERBOSE: [03/06/16 4:53:40.606 PM] [Done] Stage One
        VERBOSE: [03/06/16 4:53:40.607 PM] [Done] Pipeline HelloWorld
        .LINK
        Pipeline:
        Stage:
        Register-JobCommand
        Get-RegisteredJobCommand
        Get-RegisteredJobModule
    #>


    [cmdletbinding(DefaultParameterSetName='ScriptBlock')]
    param
    (
        [Parameter(Position = 0, ParameterSetName='Name')]
        [string]
        $Name = '',
        [Parameter(Mandatory, Position = 1, ParameterSetName='Name')]
        [Parameter(Mandatory, Position = 0, ParameterSetName='ScriptBlock')]
        [scriptblock]
        $DoBlock,
        [string[]]
        $ComputerName,
        [int]
        $TimeOut = [int]::MaxValue
#        ,
#        [PSCredential]
#        $Credential
    )

<#    if ($Global:CidneyRemoteJobCommands)
    {
        foreach($cmd in $Global:CidneyRemoteJobCommands)
        {
            Register-JobCommand $cmd
        }
    }#>
    $params = @{
        #FunctionsToLoad = Get-RegisteredJobCommand
        #ModulesToImport = Get-RegisteredJobModule
        #ThrottleLimit = Get-ThrottleLimit
        WarningAction = 'SilentlyContinue'    
    }
    
    if ($ComputerName)
    {
        foreach($computer in $ComputerName)
        {
            $job = Invoke-Command @params -ComputerName $computer -scriptBlock $DoBlock -AsJob
            if ($Name)
            {
                $job.Name = "[Job$($Job.Id)] $Name"
            }
            $job.Name += " [$computer]"
            Write-Log "[Start] $($job.Name)"
            $Global:CidneyJobs += [PSCustomObject]@{'Job' = $job; 'TimeOut' = $Timeout; 'ExecutionTime'= 0; ErrorAction = $ErrorActionPreference}
        }
    }
    else
    {
        $job = Start-Job @params -ScriptBlock $DoBlock
        if ($name)
        {
            $job.Name = "[Job$($Job.Id)] $Name"
        }
        $Global:CidneyJobs += [PSCustomObject]@{'Job' = $job; 'TimeOut' = $Timeout; 'ExecutionTime' = 0; ErrorAction = $ErrorActionPreference}
        Write-Log "[Start] $($job.Name)"
    }
}

function Register-JobCommand
{
    <#
    .Synopsis
       Registers a cmdlet or function to be used in a Cidney Pipeline:

    .DESCRIPTION
       Registers a cmdlet or function to be used in a Cidney Pipeline: 
       It needs to be called before the Do: block of Pipeline: is run.
       You can call it outside of the Pipeline:, inside the Pipeline: 
       or inside Stage: blocks

    .EXAMPLE
    >
    #Register-JobCommand Test

    Pipeline: HelloWorld {
        Stage: One {
            Do: { Test }
        } 
    } -Verbose 

    function Test 
    {
        Write-Output 'Test - Success'
    }

    A function we want to call inside a pipeline is not recognized by PoshRSJob
    since it will be running in a separate runspace. For this you will need to 
    Register the cmdlet or function by calling Register-JobCommand

    Run this sample first and see that the error that is returned:

    WriteStream : The term 'Test' is not recognized as the name of a cmdlet, 
    function, script file, or operable program. Check the spelling of the name, 
    or if a path was included, verify that the path is correct and try again.
    At C:\Program Files\WindowsPowerShell\Modules\PoshRSJob\1.5.5.3\Public\Receive-RSJob.ps1:90 char:18
    +             $_ | WriteStream
    +                  ~~~~~~~~~~~
        + CategoryInfo          : NotSpecified: (:) [Write-Error], WriteErrorException
        + FullyQualifiedErrorId : Microsoft.PowerShell.Commands.WriteErrorException,WriteStream


    Uncomment out the Register-JobCommand above and run again.

    VERBOSE: [03/06/16 4:00:47.672 PM] [Start] Pipeline HelloWorld
    VERBOSE: [03/06/16 4:00:47.719 PM] [Start] Stage One
    VERBOSE: [03/06/16 4:00:47.997 PM] [Start] Job14
    VERBOSE: [03/06/16 4:00:48.098 PM] [Results] Job14
    Test - Success
    VERBOSE: [03/06/16 4:00:48.113 PM] [Completed] Job14
    VERBOSE: [03/06/16 4:00:48.230 PM] [Done] Stage One
    VERBOSE: [03/06/16 4:00:48.230 PM] [Done] Pipeline HelloWorld

    .EXAMPLE
    >
    You can call the Register-JobCommand function inside the Pipeline:
    It only needs to happen before the Do: block

    Pipeline: HelloWorld {
        Register-JobCommand Test

        Stage: One {
            Do: { Test }
        } 
    } -Verbose 

    function Test 
    {
        Write-Output 'Test - Success'
    }

    VERBOSE: [03/06/16 4:00:47.672 PM] [Start] Pipeline HelloWorld
    VERBOSE: [03/06/16 4:00:47.719 PM] [Start] Stage One
    VERBOSE: [03/06/16 4:00:47.997 PM] [Start] Job14
    VERBOSE: [03/06/16 4:00:48.098 PM] [Results] Job14
    Test - Success
    VERBOSE: [03/06/16 4:00:48.113 PM] [Completed] Job14
    VERBOSE: [03/06/16 4:00:48.230 PM] [Done] Stage One
    VERBOSE: [03/06/16 4:00:48.230 PM] [Done] Pipeline HelloWorld

    .EXAMPLE
    >
    You can call the Register-JobCommand function inside a Stage Block:
    
    Pipeline: HelloWorld {
        Stage: One {
            Register-JobCommand Test

            Do: { Test }
        } 
    } -Verbose 
    
    function Test 
    {
        Write-Output 'Test - Success'
    }

    VERBOSE: [03/06/16 4:00:47.672 PM] [Start] Pipeline HelloWorld
    VERBOSE: [03/06/16 4:00:47.719 PM] [Start] Stage One
    VERBOSE: [03/06/16 4:00:47.997 PM] [Start] Job14
    VERBOSE: [03/06/16 4:00:48.098 PM] [Results] Job14
    Test - Success
    VERBOSE: [03/06/16 4:00:48.113 PM] [Completed] Job14
    VERBOSE: [03/06/16 4:00:48.230 PM] [Done] Stage One
    VERBOSE: [03/06/16 4:00:48.230 PM] [Done] Pipeline HelloWorld
        
    .LINK
    Pipeline:
    Stage:
    Do:
    Get-RegisteredJobCommand
    Get-RegisteredJobModule
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param
    (
        [Parameter(Mandatory, Position = 0)] 
        [string[]]
        $Name
    )

    foreach($item in $name)
    {
        $command = Get-Command $item -ErrorAction SilentlyContinue
        if ($command)
        {
            if (-not $Global:CidneyJobCommands.ContainsKey($item))
            {
                $Global:CidneyJobCommands.Add($item, $command)
            }
            if (-not $Global:CidneyJobModules.ContainsKey($item))
            {
                $Global:CidneyJobModules.Add($item, $command.Module)
            }
        }
        else
        {
            $Global:CidneyRemoteJobCommands += $item
        }
    }
}

function Get-RegisteredJobCommand
{
    <#
    .Synopsis
       Returns a list of cmdlets or functions registered to be used in a Cidney Pipeline:
    .DESCRIPTION
       Returns a list of cmdlets or functions registered to be used in a Cidney Pipeline:
    .EXAMPLE
    c:\>.\HelloWorld.ps1

    Register-JobCommand Test

    Pipeline: HelloWorld {
        Stage: One {
            Do: { Test }
        } 
    } -Verbose 

    function Test 
    {
        Write-Output 'Test - Success'
    }
        
    A function we want to call inside a pipeline is not recognized by PoshRSJob
    since it will be running in a separate runspace. For this you will need to 
    Register the cmdlet or function by calling Register-JobCommand

    Get-RegisteredJobCommands 

    CommandType     Name               Version    Source  
    -----------     ----               -------    ------  
    Function        Test                                                                  

    .LINK
    Pipeline:
    Stage:
    Do:
    Register-JobCommand
    Get-RegisteredJobModule
    #>

    $Global:CidneyJobCommands.Values
}

function Get-RegisteredJobModule
{
    <#
    .Synopsis
       Returns a list of Modules from the cmdlets or functions registered to be used in a Cidney Pipeline:
    .DESCRIPTION
       Returns a list of Modules from the cmdlets or functions registered to be used in a Cidney Pipeline:
    .LINK
    Pipeline:
    Stage:
    Do:
    Register-JobCommand
    Get-RegisteredJobCommand
    #>
    $Global:CidneyJobModules.Values
}  