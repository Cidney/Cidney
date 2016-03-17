function Get-CidneyBlocks
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
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        $commands = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.pipelineast] }, $false) 
        foreach($command in $commands)
        { 
            $commonParams = ''

            $value = $command.PipelineElements[0].Extent.Text
            if ($value -match 'Pipeline:|Stage:|Do:|On:|When:|At:')  
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

function Get-CidneyStatements
{
    param
    (
        [scriptblock]
        $ScriptBlock,
        [Object]
        $BoundParameters
    )
    
    $statementblocks = @()
    $blocks = @()

    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        #$ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        $statements = $ScriptBlock.AST.EndBlock.Statements
        foreach($statement in $statements)
        { 
            $commonParams = ''
            $value = $statement.Extent.Text
            if ($value -match 'Pipeline:|Stage:|Do:|On:|When:|At:')  
            {
                $params = Get-CommonParameters -BoundParameters $BoundParameters
                foreach($param in $params.Trim().Split(' '))
                { 
                    if ($statement.ToString().Trim() -notmatch $param)
                    {
                        $commonParams += ' {0}' -f $param
                    }
                }

                if ($statementblocks)
                {
                    $blocks += [ScriptBlock]::Create($statementblocks -join ';')
                    $statementblocks = @()
                }
                $blocks += [ScriptBlock]::Create("$value$commonParams")
            }
            else
            {
                $statementblocks += $statement.Extent.Text
            }
        }
    }

    if ($statementblocks)
    {
        $blocks += [ScriptBlock]::Create($statementblocks -join ';')
    }

    return $blocks
}