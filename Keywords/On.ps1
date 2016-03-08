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

        Outputs the computer names of Server1 and Server2

        .LINK
        Pipeline:
        Stage:
        Do:
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
        $Credential
    )

    $doBlocks = Get-CidneyBlocks -ScriptBlock $OnBlock 

    $invokeBlocks = @()
                
    foreach($doBlock in $doBlocks)
    {
        if (IsDoBlock $doBlock) 
        {
            # A new Do: Block is encountered so lets invoke all the previous commands 
            # found up to this point
            $invokeBlock = [scriptblock]::Create($invokeBlocks -join ' ; ')
            Invoke-Command -ComputerName $ComputerName -ScriptBlock $invokeBlock
            $invokeBlocks = @()

            if ($ComputerName)
            {
                $computerNames = $ComputerName -Join ','
                $params = "-ComputerName $ComputerNames"
            }
            if ($Credential)
            {
                # $params += ' -Credential'
            }
        
            $scriptBlock = '{0} {1}' -f $doBlock.ToString().Trim(), $params
            $block = [scriptBlock]::Create($scriptBlock)
        
            Invoke-Command -ScriptBlock $block            
        }
        else
        {
            # Store all the Non Do: blocks so they can invoked all together
            $invokeBlocks += $doBlock
        }
    }
}