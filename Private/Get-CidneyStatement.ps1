function Get-CidneyStatement
{
    param
    (
        [scriptblock]
        $ScriptBlock = $null,
        [Object]
        $BoundParameters = $null
    )
    
    $statementblocks = @()
    $blocks = @()
    $OFS = "`n`r"
    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $statements = $ScriptBlock.AST.EndBlock.Statements
        foreach($statement in $statements)
        { 
            $commonParams = ''
            $value = $statement.Extent.Text
            if ($value -match '^Stage:|^Do:|^On:|^When:|^At:')  
            {
                $params = Get-CommonParameter -BoundParameters $BoundParameters
                foreach($param in $params.Trim().Split(' '))
                { 
                    if ($statement.ToString().Trim() -notmatch "^$param")
                    {
                        $commonParams += ' {0}' -f $param
                    }
                }

                if ($statementblocks)
                {
                    $blocks += [ScriptBlock]::Create($statementblocks)
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
        $blocks += [scriptblock]::Create($statementblocks)
    }

    Remove-Variable OFS
    return $blocks
}