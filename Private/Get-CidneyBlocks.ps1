﻿function Get-CidneyStatements
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
    $OFS = "`n`r"
    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        #$ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null)
        $statements = $ScriptBlock.AST.EndBlock.Statements
        foreach($statement in $statements)
        { 
            $commonParams = ''
            $value = $statement.Extent.Text
            if ($value -match '^Stage:|^Do:|^On:|^When:|^At:')  
            {
                $params = Get-CommonParameters -BoundParameters $BoundParameters
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