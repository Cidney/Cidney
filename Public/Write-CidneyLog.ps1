function Write-CidneyLog
{
    param
    (
        [parameter(ValueFromPipeline)]
        [string]
        $Message = $null
    )

    $indentLevel = $CidneyPipelineCount-1
    if($indentLevel -lt 0)
    {
        $indentLevel = 0
    }
    $Date = "[$(Get-Date -Format 'MM/dd/yy h:mm:ss.fff tt')]"
    $indent = ('...' * $indentLevel)
    Write-Verbose "$Date $indent$Message"
}

