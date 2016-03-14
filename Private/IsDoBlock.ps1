function IsDoBlock
{
     param
     (
         [scriptblock]
         $ScriptBlock
     )

    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($block, [ref] $null, [ref] $null);
        $commands = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $false) 
        
        return ($commands[0].CommandElements[0].Value -eq 'Do:')
    }
}    
