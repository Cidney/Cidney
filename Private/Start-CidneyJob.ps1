function Start-CidneyJob()
{
    param
    (
        [scriptblock]
        $Script,
        [string]
        $ComputerName,
        [switch]
        $UseSSL,
        [int]
        $MaxThreads = 16,
        [int]
        $SleepTimer = 100,
        [int]
        $TimeOut = 1800, # Default TimeOut is 30 mins
        [int]
        $MaxResultTime = 120,
        [hashtable]
        $Context
    )

    $remoteScript = {
        param([string]$computer, [scriptblock]$script, [switch]$useSSL, [hashtable]$context) 

        if (-not $context.RemoteSessions.ContainsKey($computer))
        {
            $session = New-PSSession -ComputerName $computer -Credential $context.Credential -UseSSL:$useSSL
            $context.RemoteSessions.Add($computer, $session) 
        }

        $session = $context.RemoteSessions.$computer
        Invoke-Command -ScriptBlock $script -Session $session -ArgumentList $context
    }

    if (-not $Script:RsSessionState)
    {
        $Script:RsSessionState = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
        $Script:RsSessionState.ExecutionPolicy = 'RemoteSigned'
        $Script:RsSessionState.ApartmentState = 'STA'
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
        
        foreach($snapin in ($Global:CidneyAddedSnapins | Select -First 1))
        {
            $null = $Script:RsSessionState.ImportPSSnapIn($snapin, [ref]$null)
        }

        $cidneyPath = (Get-Module Cidney).Path
        $null = $Script:RsSessionState.ImportPSModule($cidneyPath)
        foreach($module in $Global:CidneyImportedModules)
        {
            $null = $Script:RsSessionState.ImportPSModule($module.Name)
        }   
    }

    if (-not $Script:RunspacePool -or $Script:RunspacePool.RunspacePoolStateInfo.State -ne 'Opened')
    {
        if (-not $MaxThreads -or $MaxThreads -eq 0)
        {
            $MaxThreads = Get-ThrottleLimit
        }

        $Script:RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads, $Script:RsSessionState, $Host)
        $Script:RunspacePool.Open()   
    }

    if ($ComputerName)
    {
        $PSThread = [powershell]::Create().AddScript($remoteScript).AddParameter('Computer', $ComputerName).AddParameter('UseSSL', $UseSSL).AddParameter('Script', $Script).AddParameter('Context', $Context)  
    }
    else
    {
        $PSThread = [powershell]::Create().AddScript($Script).AddParameter('Context', $Context) 
    }
    
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