function Send-Event 
{
    param
    (
        [Parameter(Mandatory)]
        [string]
        $Name
    )
    
    $event = New-Event $Name -Sender 'Cidney' 
}