function ConvertTo-CidneyScriptBlock
{
    param
    (
        [scriptblock]
        $ScriptBlock = $null,
        [Object]
        $BoundParameters = $null,
        [hashtable]
        $Context = $null
    )
    
    $OFS = "`r`n"
    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $statements = $ScriptBlock.AST.EndBlock.Statements
    }    

    $header = {
        param([hashtable]$__Context__)

        if ($__Context__ -and $__Context__.LocalVariables)
        {
            foreach($__var__ in $__Context__.LocalVariables)
            {
                if ($__var__.Name -ne 'Context')
                {
                    if (-not (Get-Variable $__var__.Name -ErrorAction SilentlyContinue))
                    {
                        New-Variable -Name $__var__.Name -Value $__var__.Value
                    }
                    else
                    {
                        Set-Variable -Name $__var__.Name -Value $__var__.Value -ErrorAction SilentlyContinue
                    }
                }
            }
        }
    }.ToString()
    $begin = { Write-Progress -Activity "Stage $StageName" -Status 'Processing' -Id ($CidneyPipelineCount + 1) }.ToString()
    $process = @()
    $end= { Write-Progress -Activity "Stage $StageName" -Status 'Completed' -Id ($CidneyPipelineCount + 1) -Completed }.ToString()

    $count = 0
    foreach($statement in $statements)
    {
        $value = $statement.Extent.Text
        $commonParams = ''
        if ($value -match '^Stage:|^Do:|^On:|^When:')  
        {
            $commonParams = ''
            $params = Get-CommonParameter -BoundParameters $BoundParameters
            foreach($param in $params.Trim().Split(' '))
            { 
                if ($statement.ToString().Trim() -notmatch "^$param")
                {
                    $commonParams += ' {0} ' -f $param
                }
            }
            $commonParams += ' -Context $__Context__'
        }
        
        $process += "$value$commonParams"
        
        if ($context.ShowProgress)
        {
            $percentComplete = (++$count / $statements.Count) * 100
            $progress = "Write-Progress -Activity `"Stage `$StageName`" -Status 'Processing' -Id (`$CidneyPipelineCount + 1) -PercentComplete ($percentComplete)"

            $process += "`r`n$progress"
        }
    }

    if ($Context.showProgress)
    {
        $block = "$header`r`n$begin`r`n$process`r`n$end"
    }
    else
    {
        $block = "$header`r`n$process"
    }

    Remove-Variable OFS
    return [scriptblock]::Create($block)
}