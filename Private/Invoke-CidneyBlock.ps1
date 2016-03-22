function Invoke-CidneyBlock
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [scriptblock]
        $ScriptBlock,
        [Parameter(Mandatory)]
        [hashtable]
        $Context
    )
    
    $localVariables = @{}
    $variables = @{}

    $localVariables = (Get-Variable -Scope Local | Where { $_.GetType().Name -eq 'PSVariable'}) 
    
    Invoke-Command -Command $ScriptBlock -ArgumentList $Context -NoNewScope
    
    $variables = (Get-Variable -Scope Local | Where {$_.GetType().Name -eq 'PSVariable' }) 
    if ($localVariables.Count -ne $variables.Count)
    {
        $localVariables = Compare-Object -ReferenceObject $variables -DifferenceObject $localVariables -PassThru -Property Name
        $Context.LocalVariables = $localVariables
    }
}

