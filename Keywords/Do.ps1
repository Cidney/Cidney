function Do:
{
    <#
        .SYNOPSIS
        Runs a scriptblock using Jobs. 
        
        .DESCRIPTION
        A Cindey Pipeline: will run each Stage: one right after the other synchronously.
        Each Do: Block found will create a Job so they can be run asyncronously or in Parallel.

        Note: Because the Do: keyword sets up jobs some may hang around in an error state if there are errors when executing. 
        If this happens you can use the job functions in powershell to investigate and clean up. Wait-Job, Receive-Job and Remove-Job.
        But if you just want to clean up quickly and do a reset you can call Invoke-Cidney -Force and it will clean up all Cidney jobs.
        
        .EXAMPLE
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                Do: { Dir C:\Windows\System32 | Where Name -match '.dll' | measure }
                Do: GetService { Get-Service B* }
            }
        }
        Invoke-Cidney HelloWorld -verbose

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
        On:
        When:
        Invoke-Cidney
    #>


    [cmdletbinding(DefaultParameterSetName='ScriptBlock')]
    param
    (
        [Parameter(Position = 0, ParameterSetName='Name')]
        [string]
        $Name = '',
        [Parameter(Position = 1, ParameterSetName='Name')]
        [Parameter(Position = 0, ParameterSetName='ScriptBlock')]
        [scriptblock]
        $DoBlock = $(Throw 'No Do: block provided. (Did you put the open curly brace on the next line?)'),
        [int]
        $TimeOut = [int]::MaxValue,
        [int]
        $MaxThreads,
        [int]
        $SleepTimer = 100,
        [string[]]
        $ComputerName,
        [string]
        $UserName,
        [pscredential]
        $Credential,
        [switch]
        $UseSSL,
        [switch]
        $Passthru,
        [Parameter(DontShow)]
        [hashtable]
        $Context
    )

    if (-not $Context)
    {
        $Context = New-CidneyContext
    }

    $header = {
        param
        (
            [hashtable]
            $Context
        )
    }

    $DoBlock = [scriptblock]::Create(("{0}`r`n{1}" -f $header.ToString(), $DoBlock.ToString()))

    $params = @{
        WarningAction = 'SilentlyContinue'   
        Script = $DoBlock 
        Timeout = $TimeOut
        SleepTimer = $SleepTimer
        Context = $Context
    }

    if ($PSBoundParameters.ContainsKey('UserName'))
    {
        $credential = Import-Clixml (Join-Path $Env:CidneyStore "$($UserName)Credentials.xml") 
    }

    if ($PSBoundParameters.ContainsKey('Credential'))
    {
        $params.Add('Credential', $Credential)
    }
    
    if ($PSBoundParameters.ContainsKey('UseSSL'))
    {
        $params.Add('UseSSL', $UseSSL)
    }

    if ($ComputerName)
    {
        foreach($computer in $ComputerName)
        {
            $job = Start-CidneyJob @Params -ComputerName $computer 
            $job.Name = "Job$($Job.Id)"
            if ($name)
            {
                $job.Name += " $Name"
            }
            $job.Name += " ($computer)"
            Write-CidneyLog "[Start    ] $($job.Name)"
            $Context.Jobs += $job
        }
    }
    else
    {
        $job = Start-CidneyJob @Params
        $job.Name = "Job$($Job.Id)"
        if ($name)
        {
            $job.Name += " $Name"
        }
        $Context.Jobs += $job
        Write-CidneyLog "[Start    ] $($job.Name)"
    }

    if ($PassThru)
    {
        return $Context
    }
}