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