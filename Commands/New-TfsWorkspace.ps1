Add-PSSnapin Microsoft.TeamFoundation.PowerShell
function New-TfsWorkspace
{
    <#
        .SYNOPSIS
        Creates a TFS workspace. Requires Microsoft Visual Studio Team Foundation Server Power Tools
        
        .DESCRIPTION
        Creates a TFS workspace.
        This function will create a Local WorkSpace and a mapping to a local folder
        
        Requires Microsoft Visual Studio Team Foundation Server Power Tools
        See: https://visualstudiogallery.msdn.microsoft.com/898a828a-af00-42c6-bbb2-530dc7b8f2e1
       
        .EXAMPLE
        New-TfsWorkspace -Server http://tfs.example.com:8080/tfs/Collection -Credential (Get-Credential) -WorkspaceName 'MyWorkSpace' -LocalPath C:\Projects -Path $\Projects

        Creates a workspace mapping from $\Projects to c:\projects

        .PARAMETER Server
        Server object to TFS server

        .PARAMETER Name
        Web address of the TFS Server
        Example: http://tfs.example.com:8080/tfs/DefaultCollection

        .PARAMETER Credential
        Credential object for logging into the Tfs Server

        .PARAMETER WorkspaceName
        Name of the Workspace mapping between server path and local path
        
        .PARAMETER Path
        The the location if TFS Source control of the files

        .PARAMETER LocalPath
        The local path where the source files will be downloaded

        .LINK
        https://msdn.microsoft.com/en-us/library/microsoft.teamfoundation.versioncontrol.client(v=vs.120).aspx
        
    #>

    [CmdletBinding(DefaultParameterSetName='Server')]
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
        $WorkspaceName,
        [parameter(Mandatory)]
        [string]
        $Path,
        [parameter(Mandatory)]
        [string]
        $LocalPath
    )
   
    if (-not (Test-Path $LocalPath))
    {
        $null = New-Item -Path $LocalPath -ItemType Directory
    }
    
    Write-Verbose "Login to TFS $Server"
    if (-not $Server)
    {
        $Server = Get-TfsServer $Name -Credential $Credential
    }
    $vcs = $Server.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer]);
    $user = $Server.AuthorizedIdentity.UniqueName

    $workspace = $vcs.TryGetWorkspace($LocalPath)
    if (-not $workspace)
    {
        Write-Verbose "Creating workspace $WorkspaceName at $LocalPath"
        $workspace = $vcs.CreateWorkspace($WorkspaceName, $user, 'temp workspace')
        $workspace.Map($Path, $LocalPath)
    }
    
    Write-Verbose "Done creating workspace $WorkspaceName"
    return $WorkspaceName
}