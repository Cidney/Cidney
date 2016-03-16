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
        $ComputerName = $Env:COMPUTERNAME,       
        [Parameter(Mandatory, Position = 1)]
        [scriptblock]
        $OnBlock,
        [PSCredential]
        $Credential,
        [switch]
        $ImportModules,
        [Parameter(DontShow)]
        [hashtable]
        $Context
    )

    $doBlocks = Get-CidneyBlocks -ScriptBlock $OnBlock 

    $invokeBlocks = @()
                
    foreach($doBlock in $doBlocks)
    {
        if ($ComputerName)
        {
            $computerNames = $ComputerName -Join ','
            $params = "-ComputerName $ComputerNames"
        }
        if ($Credential)
        {
            $userName = $Credential.UserName -replace '\\', '_' 
            $credPath = Join-Path $Env:CidneyStore "$($userName)Credentials.xml"
            $Credential | Export-Clixml $credPath

            $params += " -UserName $userName"
            $Context.CredentialStore.Add($userName, $credPath)
        }
        if ($ImportModules -or $Script:CidneyImportModulesPreference)
        {
            $params += ' -ImportModules'
        }
        
        $scriptBlock = '{0} {1}' -f $doBlock.ToString().Trim(), $params
        $block = [scriptBlock]::Create($scriptBlock)
        
        Invoke-Command -ScriptBlock $block            
    }
}