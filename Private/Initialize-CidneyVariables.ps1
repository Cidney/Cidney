function Initialize-CidneyVariables
{
    param
    (
        [scriptblock]
        $ScriptBlock,
        [hashtable]
        $Context
    )

    if (-not $context.Contains('LocalVariables'))
    {
        $context.Add('LocalVariables', @())
    }
    
    if ($ScriptBlock.ToString().Trim())
    {
        $newVariables = @()
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($ScriptBlock.ToString(), [ref] $null, [ref] $null);

        $assignments = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.AssignmentStatementAst]}, $false) 
        foreach($assignment in $assignments)
        {
            $item = $assignment
            $name = $item.Left.VariablePath.UserPath
            if ($item.Right.Expression)
            {
                $value = Invoke-Expression -Command $item.Right.Expression
            }
            else
            {
                $value = Invoke-Command -Command ([scriptblock]::Create($Item.Right.Extent.Text))
            }

            if (-not (Get-Variable -Name $name -Scope Local -ErrorAction SilentlyContinue))
            {
                New-Variable -Name $name -Value $value -Scope Local -Force -ErrorAction SilentlyContinue
                $newVariables += Get-Variable -Name $name -Scope Local              
            }
            else
            {
                Set-Variable -Name $name -Value $value -Scope Local -Force -ErrorAction SilentlyContinue
            }                 
        } 

        if ($newVariables.Count -gt 0)
        {
            $context.LocalVariables += $newVariables              
        }
    }
}