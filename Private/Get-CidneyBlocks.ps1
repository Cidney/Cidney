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
    $statements = @()

    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        $commands = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst] }, $false) 
        foreach($command in $commands)
        { 
            $commonParams = ''

            $value = $command.CommandElements[0].Value
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

                if ($statements)
                {
                    $blocks += $statements
                    $statements = @()
                }
                $blocks += [ScriptBlock]::Create("$command$commonParams")
            }
            else
            {
                $statements += "$($command.Extent.Text)`r"
            }
        }
    }
    if ($statements)
    {       
        $blocks +=  $statements
    }

    return $blocks
}