function When:
{
    <#
        .SYNOPSIS
        When: command for Cidney Pipelines. Used between Stage: and Do:
        The When: command lets you specify a an event to listen for that you will run its script block against 
        
        .DESCRIPTION
        When: command for Cidney Pipelines. Used between Stage: and Do:
        The When: command lets you specify a an event to listen for that you will run its script block against 
        
        .EXAMPLE
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                When: 'MyEvent' {
                    Do: { Ipconfig}
                }
            }
        }
        Invoke-Cidney HelloWorld -Verbose

        Run ipconfig when MyEvent is fired.

        .LINK
        Pipeline:
        Stage:
        Do:
        On:
        Invoke-Cidney
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Event,
        [Parameter(Position = 1)]
        [scriptblock]
        $WhenBlock = $(Throw 'No When: block provided. (Did you put the open curly brace on the next line?)'),
        [switch]
        $Wait,
        [Int32]
        $Timeout = 300,
        [Parameter(DontShow)]
        [hashtable]
        $Context
    )

    $script = "`$Global:CidneyEventOutput.Add(`$event, @($($WhenBlock.ToString().Trim())))"

    $script += @'
    
    $Global:CidneyEvents += $event

    if (-not $Global:CidneyEventSubscribers.Contains($EventSubscriber))
    {
        $Global:CidneyEventSubscribers += $EventSubscriber
    }
'@
    $eventAction = [ScriptBlock]::Create($script)
    $null = Register-EngineEvent -SourceIdentifier $Event -Action $eventAction #-MaxTriggerCount 1 

    if ($wait)
    {
        Wait-Event $Event -Timeout $Timeout
    }
}