function Start-CidneyJob()
{
    param
    (
        [scriptblock]
        $Script,
        [int]
        $MaxThreads = 16,
        [int]
        $SleepTimer = 100,
        [int]
        $TimeOut = 100,
        [int]
        $MaxResultTime = 120,
        [hashtable]
        $Context
    )

    if (-not $Script:RsSessionState)
    {
        $Script:RsSessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()

        foreach($globalVar in (Get-Variable -Scope Global))
        {
            $sessionVar = $Script:RsSessionState.Variables.Item($globalVar.Name)
            if ((-not $sessionvar -and $globalVar.Name -ne 'null') -and ($globalVar.Options -eq [System.Management.Automation.ScopedItemOptions]::None))
            {
                $Script:RsSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($globalVar.Name, $globalVar.Value, $null)))
            }
        }

        foreach($localVar in $Context.LocalVariables)
        {
            $sessionVar = $Script:RsSessionState.Variables.Item($localVar.Name)
            if ((-not $sessionvar -and $localVar.Name -ne 'null') -and ($localVar.Options -eq [System.Management.Automation.ScopedItemOptions]::None))
            {
                $Script:RsSessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry($localVar.Name, $localVar.Value, $null)))
            }
        }
        
        $Script:RsSessionState.ImportPSModule((Get-Module Cidney))
    }

    if (-not $Script:RunspacePool -or $Script:RunspacePool.RunspacePoolStateInfo.State -ne 'Opened')
    {
        if (-not $MaxThreads -or $MaxThreads -eq 0)
        {
            $MaxThreads = Get-ThrottleLimit
        }
        $Script:RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads, $Script:RsSessionState, $Host)
        $Script:RunspacePool.ApartmentState = 'STA'
        $Script:RunspacePool.Open()   
    }

    $PSThread = [powershell]::Create().AddScript($Script).AddParameter('Context', $Context) 
    
    $null = $PSThread.RunspacePool = $Script:RunspacePool
    $job = [PSCustomObject]@{
        Thread = $PSThread
        Handle = $PSThread.BeginInvoke()
        Id = ++$Global:CidneyJobCount
        Name = 'Job'+$Global:CidneyCount
        ExecutionTime = 0
        Timeout = $TimeOut #todo: Review This
        SleepTimer = $SleepTimer
        ErrorAction = $ErrorActionPreference
    }
    
    return $Job
}