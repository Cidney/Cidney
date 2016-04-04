function Send-Event 
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Name = $null
    )
    
    $null = New-Event $Name -Sender 'Cidney' 
}