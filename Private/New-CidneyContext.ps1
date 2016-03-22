function New-CidneyContext
{
    $CidneyContext = [hashtable]::Synchronized(@{})
    $CidneyContext.Add('Pipeline','Pipeline:'+[guid]::NewGuid())
    $CidneyContext.Add('Modules', (Get-Module))
    $CidneyContext.Add('CredentialStore', @{})

    return $CidneyContext
}

