function Register-PSSnapin 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Name}
    )

    if (-not $Global:CidneyAddedSnapins.Contains($Name))
    {
        $null = $Global:CidneyAddedSnapins += $Name
    }
}

