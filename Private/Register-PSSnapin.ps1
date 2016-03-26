function Register-PSSnapin 
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
        [string[]]
        ${Name}
    )
    Write-Host "Using Register-PSSnapin: $Name"

    if (-not $Global:CidneyAddedSnapins.Contains($Name))
    {
        $null = $Global:CidneyAddedSnapins += $Name
    }
}

