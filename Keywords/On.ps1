function On:
{
    <#
        .SYNOPSIS
        ON: command for Cidney Pipelines. Used between Stage: and Do:
        The ON: command lets you specify a computer(s) that you will run its script block against 
        
        .DESCRIPTION
        ON: command for Cidney Pipelines. Used between Stage: and Do: 
        The ON: command lets you specify a computer(s) that you will run its script block against 
        
        .EXAMPLE
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                On: Server1 {
                    Do: { Ipconfig}
                }
            }
        }
        Invoke-Cidney HelloWorld -Verbose

        Run ipconfig against Server1

        .EXAMPLE
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                On: Server1,Server2 {
                    Do: { Write-Output $Env:ComputerName }
                }
            }
        }
        Invoke-Cidney HelloWorld -Verbose

        Outputs the computer names of Server1 and Server2

        .LINK
        Pipeline:
        Stage:
        Do:
        When:
        Invoke-Cidney
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string[]]
        $ComputerName,       
        [Parameter(Position = 1)]
        [scriptblock]
        $OnBlock = $(Throw 'No On: block provided. (Did you put the open curly brace on the next line?)'),
        [PSCredential]
        $Credential,
        [switch]
        $UseSSL,
        [int]
        $TimeOut,
        [int]
        $MaxThreads,
        [int]
        $SleepTimer,
        [Parameter(DontShow)]
        [hashtable]
        $Context
    )

    $doBlocks = Get-CidneyBlocks -ScriptBlock $OnBlock 

    $invokeBlocks = @()
                
    foreach($doBlock in $doBlocks)
    {
        $params = "-MaxThreads $MaxThreads"
        if ($ComputerName)
        {
            $computerNames = $ComputerName -Join ','
            $params += " -ComputerName $ComputerNames"
        }
        if ($Credential)
        {
            $userName = $Credential.UserName -replace '\\', '_' 
            $credPath = Join-Path $Env:CidneyStore "$($userName)Credentials.xml"
            $Credential | Export-Clixml $credPath

            $params += " -UserName $userName"
            $Context.CredentialStore.Add($userName, $credPath)
        }
        if ($UseSSL)
        {
            $params += " -UseSSL $UseSSL"
        }
        if ($MaxThreads)
        {
            $params += " -MaxThreads $MaxThreads"
        }
        if ($TimeOut)
        {
            $params += " -Timeout $TimeOut"
        }
        if ($SleepTimer)
        {
            $params += " -SleepTimer $SleepTimer"
        }

        $scriptBlock = '{0} {1}' -f $doBlock.ToString().Trim(), $params
        $block = [scriptBlock]::Create($scriptBlock)
        
        Invoke-Command -ScriptBlock $block
    }
}