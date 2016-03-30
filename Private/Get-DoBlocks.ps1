function Get-DoBlocks
{
    param
    (
        [scriptblock]
        $ScriptBlock,
        [Object]
        $BoundParameters
    )
    
    $blocks = @()

    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $commands = $ScriptBlock.AST.FindAll({$args[0] -is [System.Management.Automation.Language.pipelineast] }, $false) 
        foreach($command in $commands)
        { 
            $commonParams = ''

            $value = $command.PipelineElements[0].Extent.Text
            if ($value -match '^|Do:')  
            {
                $params = Get-CommonParameters -BoundParameters $BoundParameters
                foreach($param in $params.Trim().Split(' '))
                { 
                    if ($command.ToString().Trim() -notmatch $param)
                    {
                        $commonParams += ' {0}' -f $param
                    }
                }

                $blocks += [ScriptBlock]::Create("$command$commonParams")
            }
        }
    }

    return $blocks
}