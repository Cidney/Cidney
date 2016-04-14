function Get-CidneyPipelineParams
{
    param
    (
        [string]
        $functionName,
        [System.Collections.Generic.List`1[System.Object]]
        $DynamicParams
    )

    # When Invoking a cidney pipeline in a Do: block (new runspace) we need to Find the Function in the Global namespace. 
    # and then add in Functions from the regularly scoped variable
    $CidneyFunctions = $Global:CidneyPipelineFunctions
    if ($CidneyPipelineFunctions -and $CidneyFunctions)
    {
        foreach ($function in $CidneyPipelineFunctions.GetEnumerator())
        {
            if (-not $CidneyFunctions.ContainsKey($function.Key))
            {
                $CidneyFunctions += $CidneyPipelineFunctions
            }
        }
    }
    else
    {
        $CidneyFunctions = $CidneyPipelineFunctions
    }

    $result = $CidneyFunctions.GetEnumerator() | Where-Object Name -eq $functionName
    $params = $null
    if ($result)
    {
        $params = $result.Value

        $parameters = @{}
        if ($params.Params)
        {
            foreach($p in $params.Params.GetEnumerator())
            {
                $parameters[$p.Key] = $p.Value
            }
        }
        
        for ($i = 0; $i -lt $DynamicParams.count; $i+=2)
        {
            $parameters[($DynamicParams[$i]-replace '^-+')] = $DynamicParams[$i+1]
        }
        for ($i = 0; $i -lt $params.DynamicParams.count; $i+=2)
        {
            $parameters[($params.DynamicParams[$i]-replace '^-+')] = $params.DynamicParams[$i+1]
        }
        $params.Params = $parameters
        $null = $params.Remove('Passthru')
        $null = $params.Remove('Invoke')
        $null = $params.Remove('DynamicParams')
    }
    
    return $params
}