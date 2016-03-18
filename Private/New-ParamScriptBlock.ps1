function New-ParamScriptBlock
{
    param
    (
        [string[]]
        $Script
    )
    
    $paramHeader = @'
    param([hashtable]$Context) 
    
    foreach($__var in $Context.LocalVariables) 
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

    $newScriptBlock = "$paramHeader`n$Script"
    return [scriptBlock]::Create($newScriptBlock)
}