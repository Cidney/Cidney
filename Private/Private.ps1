#Import-Module PoshRSJob

function Get-ThrottleLimit
{
    $property = 'numberOfCores', 'NumberOfLogicalProcessors'
    $cpuInfo = Get-WmiObject -class win32_processor -Property $property | Select-Object -Property $property
    $suggestedThreads = ($cpuInfo.numberOfLogicalProcessors * $cpuInfo.NumberOfCores)
    $throttle = [int32]$suggestedThreads;

    return $throttle
}

function Initialize-CidneyVariables([scriptblock]$ScriptBlock, [string]$Scope = 'Global')
{
    if (-not $Global:CidneySession.Contains("$($Scope)Variables"))
    {
        $Global:CidneySession.Add("$($Scope)Variables", @())
    }
    
    if ($ScriptBlock.ToString().Trim())
    {
        $newVariables = @()
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptBlock.ToString(), [ref] $null, [ref] $null);

        $assignments = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.AssignmentStatementAst]}, $false) 
        foreach($assignment in $assignments)
        {
            $item = $assignment
            $name = $item.Left.VariablePath.UserPath
            $value = Invoke-Expression -Command $item.Right.Expression

            if (-not (Get-Variable -Name $name -Scope $Scope -ErrorAction SilentlyContinue))
            {
                New-Variable -Name $name -Value $value -Scope $Scope -Force -ErrorAction SilentlyContinue
             #   $Global:CidneySession["$($Scope)Variables"] += Get-Variable -Name $name -Scope $Scope              
             $newVariables += Get-Variable -Name $name -Scope $Scope              
            }
            else
            {
                Set-Variable -Name $name -Value $value -Scope $Scope -Force -ErrorAction SilentlyContinue
            }                 
        } 

        if ($newVariables.Count -gt 0)
        {
            $Global:CidneySession["$($Scope)Variables"] += $newVariables              
        }
    }
}

function Get-CidneyBlocks([scriptblock]$ScriptBlock, [object]$BoundParameters)
{
    $blocks = @()

    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        
        $commands = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.ScriptBlockAst]}, $false) 
        foreach($command in $commands)
        { 
            $commonParams = ''
            if ($command.EndBlock.Statements[0] -is [System.Management.Automation.Language.PipelineAst])
            {
                if ($command.EndBlock.Statements[0].PipelineElements[0].CommandElements[0] -match 'Pipeline:|Stage:|Do:|On:|Dsc:|When:|At:')
                {
                    $params = Get-CommonParameters -BoundParameters $BoundParameters
                    foreach($param in $params.Trim().Split(' '))
                    { 
                        if ($command.ToString().Trim() -notmatch $param)
                        {
                            $commonParams += ' {0}' -f $param
                        }
                    }
                }
            }
            $blocks += [ScriptBlock]::Create("$command $commonParams")
        }
    }

    return $blocks
}

function IsDoBlock([scriptblock]$ScriptBlock)
{
    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        $commands = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $false) 
        
        return ($commands[0].CommandElements[0].Value -eq 'Do:')
    }
}    


function Get-CommonParameters([object]$BoundParameters)
{
    $commonParams = ''
    
    if ($BoundParameters)
    {
        if ($BoundParameters['Verbose'] -and $($BoundParameters['Verbose'].ToString() -eq 'True'))
        {
            $commonParams += ' -Verbose'
        }
        if ($BoundParameters['Debug'] -and $($BoundParameters['Debug'].ToString() -eq 'True'))
        {
            $commonParams += ' -Debug'
        }
        if ($BoundParameters['ErrorAction'])
        {
            $commonParams += " -ErrorAction $($BoundParameters['ErrorAction'].ToString())"
        }
        if ($BoundParameters['InformationAction'])
        {
            $commonParams += " -InformationAction $($BoundParameters['InformationAction'].ToString())"
        }
        if ($BoundParameters['WarningAction'])
        {
            $commonParams += " -WarningAction $($BoundParameters['WarningAction'].ToString())"
        }
    }

    return $commonParams
}

function Wait-CidneyJob
{
    [CmdletBinding()]
    param
    (
        [Parameter()]
        [System.Object[]]
        $Jobs
    )  

    $count = 0
    $date = Get-Date
    do
    {               
        $RunningJobs = [System.Collections.ArrayList]::new()
        foreach ($job in $jobs) 
        {
            $job.ExecutionTime = (New-TimeSpan $date).TotalSeconds
            if ($job.Job.State -match 'Completed|Failed|Stopped|Suspended|Disconnected') 
            {
                $count++
                Write-Log "[Results] $($job.Job.Name)"
                $job.Job | Receive-Job 
                Write-Log "[$($Job.Job.State)] $($job.Job.Name)"
                $job.Job | Remove-Job
            } 
            else 
            {
                if($job.Timeout -and $job.ExecutionTime -ge $Job.Timeout)
                {                
	                $Job.Job | Stop-Job
                    while ((Get-Job -Id $job.Job.Id).State -ne 'Stopped')
                    {
                        Start-Sleep -Milliseconds 100
                    }

                    $Job.Job | Remove-Job    
                    Write-Log "[$($Job.Job.State)] $($job.Job.Name)"

                    if ($job.ErrorAction -eq 'Stop')
                    {
                        Throw "$($Job.Job.Name) Timed out"
                    }
                    else
                    {
                        Continue            
                    }     
                }

                [void]$RunningJobs.Add($job)
            }
        }

        if ($Global:CidneyShowProgress -and $Global:CidneyJobs -and $Global:CidneyJobs.Count -gt 0) { Write-Progress -Activity "Stage $Name" -Status 'Processing' -Id 1 -PercentComplete ($count/$Global:CidneyJobs.Count * 100)}
        $jobs = $RunningJobs
        
        Start-Sleep -Milliseconds 100
    } 
    While($jobs.Count -ne 0)
}

function Write-Log([parameter(ValueFromPipeline)][string]$Message)
{
    $Date = "[$(Get-Date -Format 'MM/dd/yy h:mm:ss.fff tt')] "
    
    Write-Verbose "$Date$Message" 
}

