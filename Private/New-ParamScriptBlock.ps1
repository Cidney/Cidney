function New-ParamScriptBlock
{
    param
    (
        [string[]]
        $Statements
    )
    
    $paramHeader = @'
    param([hashtable]$__Context) 
    
    foreach($__var in $__Context.LocalVariables) 
    { 
        $__name = $__var.Name
        $__value = $__var.Value

        if (Get-Variable -Name $__name -Scope Local -ErrorAction SilentlyContinue)
        { 
       
            Set-Variable -Name $__name -Value $__value -Scope Local
        }
        else
        {
            New-Variable -Name $__name -Value $__value -Scope Local
        }
    }
'@

    $newScriptBlock = "$paramHeader`n$Statements"
    return [scriptBlock]::Create($newScriptBlock)
}