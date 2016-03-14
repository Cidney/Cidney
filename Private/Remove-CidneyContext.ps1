function Remove-CidneyContext
{
    param
    (
        [hashtable]
        $Context
    )

    if ($Global:CidneyContext[0].Pipeline -eq $Context)
    {
        $Global:CidneyContext.RemoveAt(0)
    }
}

