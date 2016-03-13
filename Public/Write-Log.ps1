function Write-Log([parameter(ValueFromPipeline)][string]$Message)
{
    $Date = "[$(Get-Date -Format 'MM/dd/yy h:mm:ss.fff tt')] "
    
    Write-Verbose "$Date$Message" 
}

