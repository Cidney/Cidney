function Get-ThrottleLimit
{
    $property = 'numberOfCores', 'NumberOfLogicalProcessors'
    $cpuInfo = Get-CimInstance -class win32_processor -Property $property | Select-Object -Property $property
    $suggestedThreads = ($cpuInfo.numberOfLogicalProcessors * $cpuInfo.NumberOfCores)
    $throttle = [int32]$suggestedThreads * 2

    return $throttle
}
