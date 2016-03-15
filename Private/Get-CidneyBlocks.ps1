function Get-CidneyBlocks
{
    param
    (
        [scriptblock]
        $ScriptBlock,
        [Object]
        $BoundParameters
    )
    
    $paramHeader = @'
    param([object[]]$__Variables)
    
    foreach($__var in $__Variables)
    {
        $__name = $__var.Name
        $__value = $__var.Value

        if(-not (Get-Variable $__name -ErrorAction SilentlyContinue))
        {
            New-Variable -Name $__name -Value $__value
        }
    };
'@

    $blocks = @()

    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        
        $commands = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $false) 
        foreach($command in $commands)
        { 
            $commonParams = ''
            if ($command.CommandElements[0].Value -match 'Pipeline:|Stage:|Do:|On:|When:|At:')  
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
            else
            {
                $blocks += [ScriptBlock]::Create("$paramHeader $command")
            }
        }
    }

    return $blocks
}