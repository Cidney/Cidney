function New-CidneyContext
{
    $CidneyContext = [hashtable]::Synchronized(@{})
    $CidneyContext.Add('Pipeline','Pipeline:'+[guid]::NewGuid())
    $CidneyContext.Add('Modules', (Get-Module))
    $CidneyContext.Add('CredentialStore', @{})
    $CidneyContext.Add('CurrentPath', (Get-Location))
    $CidneyContext.Add('Jobs', @())
    $CidneyContext.Add('RemoteSessions', @{})

    return $CidneyContext
}

