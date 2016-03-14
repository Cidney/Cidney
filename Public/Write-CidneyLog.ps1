function Write-CidneyLog
{
     param
     (
         [parameter(ValueFromPipeline)]
         [string]
         $Message
     )

    $Date = "[$(Get-Date -Format 'MM/dd/yy h:mm:ss.fff tt')]"
    $indent = ('...' * $Global:CidneyPipelineCount)
    Write-Verbose "$Date $indent$Message"
}

