Add-PSSnapin Microsoft.TeamFoundation.PowerShell
function Remove-TfsWorkspace
{
    <#
        .SYNOPSIS
        Deletes a TFS workspace. Requires Microsoft Visual Studio Team Foundation Server Power Tools
        
        .DESCRIPTION
        Deletes a TFS workspace.
        This function will create a Local WorkSpace and a mapping to a local folder
        
        Requires Microsoft Visual Studio Team Foundation Server Power Tools
        See: https://visualstudiogallery.msdn.microsoft.com/898a828a-af00-42c6-bbb2-530dc7b8f2e1
       
        .EXAMPLE
        Delete-TfsWorkspace -Server http://tfs.example.com:8080/tfs/Collection -Credential (Get-Credential) -WorkspaceName 'MyWorkSpace' 

        Removes a workspace mapping 

        .PARAMETER Name
        Web address of the TFS Server
        Example: http://tfs.example.com:8080/tfs/DefaultCollection

        .PARAMETER Credential
        Credential object for logging into the Tfs Server

        .PARAMETER Server
        Server object to TFS server

        .PARAMETER WorkspaceName
        Name of the Workspace mapping between server path and local path

        .LINK
        https://msdn.microsoft.com/en-us/library/microsoft.teamfoundation.versioncontrol.client(v=vs.120).aspx
        
    #>

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory, ParameterSetName='Server')]
        [Microsoft.TeamFoundation.Client.TfsTeamProjectCollection]
        $Server,
        [parameter(Mandatory, ParameterSetName='Name')]
        [string]
        $Name,
        [parameter(Mandatory, ParameterSetName='Name')]
        [pscredential]
        $Credential,
        [parameter(Mandatory)]
        [string]
        $WorkspaceName
    )
  
    Write-Verbose "Login to TFS $Server"

    if (-not $Server)
    {
        $Server = Get-TfsServer $Name -Credential $Credential
    }

    $vcs = $Server.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer]);
    $user = $Server.AuthorizedIdentity.UniqueName

    try
    {
        Write-Verbose "Checking for workspace $WorkspaceName"
        $workspace = $vcs.GetWorkspace($WorkspaceName, $user)
        
        $null = $workspace.Delete()
        Write-Verbose "Done removing workspace $WorkspaceName"
    }
    catch
    {
        # swallow error if no workspace. GetWorkspace returns an error if no workspace and 
        # TryGetWorkspace requires a local path which we don't have here
        Write-Verbose "No workspace named $WorkspaceName"
    }   
}