function New-CidneyContext
{
    param
    (
        [bool]$ShowProgress
    )

    $currentPipeline = 'Pipeline:'+[guid]::NewGuid()
    $Global:CidneyContext.Insert(0, ([PSCustomObject]@{'Name'=$currentPipeline; 'Pipeline'=@{}}))
    $Global:CidneyContext[0].Pipeline.Add('Modules', (Get-Module))
    $Global:CidneyContext[0].Pipeline.Add('CredentialStore', @{})
    $Global:CidneyContext[0].Pipeline.Add('ShowProgress', $ShowProgress)

    return $Global:CidneyContext[0].Pipeline
}

