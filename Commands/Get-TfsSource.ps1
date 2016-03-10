function Get-TfsSource
{
    <#
        .SYNOPSIS
        Gets a local copy of source files from TFS. Requires Microsoft Visual Studio Team Foundation Server Power Tools
        
        .DESCRIPTION
        Gets a local copy of source files from TFS.
        This function will create a Local WorkSpace and a mapping to a local folder and then download all the files
        Will output basic messages to Success output: Getting Source and Downloading source.
        Verbose output shows connecting to TFS Server, Creating workspace and a done message with time in seconds to get files.
        Debug output will display list of files downloaded.

        Requires Microsoft Visual Studio Team Foundation Server Power Tools
        See: https://visualstudiogallery.msdn.microsoft.com/898a828a-af00-42c6-bbb2-530dc7b8f2e1
       
        .EXAMPLE
        Get-TfsSource -Name http://tfs.example.com:8080/tfs/Collection -WorkspaceName 'MyWorkSpace' -LocalPath C:\Projects -Path $\Projects

        Gets files from $\Projects to c:\projects

        .EXAMPLE
        Get-TfsSource -Name http://tfs.example.com:8080/tfs/Collection -WorkspaceName 'MyWorkSpace' -LocalPath C:\Projects -Path $\Projects -VersionSpec 'LRelease 5.0.0.1'

        Gets the version of source labeled Release 5.0.0.1 from Server path $\Projects to local path c:\Projects

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

        .PARAMETER VersionSpec
        Defaults to T which is the tip version or current version in source control.

        Other types of VersionSpec formats:

        Changeset [C]n
        Specifies items based on a changeset number. If an item that is in scope was not modified in the specified changeset, the system takes the latest version of the item that occurred before the specified changeset.
        You can omit the C if you specify only a number.

        Label Llabel
        Specifies items to which label was applied.
        Date and time Dyyyy-mm-ddTxx:xx OR Dmm/dd/yyyy OR Any .NET Framework-supported format OR Any of the date formats supported on the local machine. 
        Specifies a changeset created on a specified date and time.

        Workspace (current) W
        Specifies the version in your workspace.

        Workspace (specified) Wworkspacename; workspaceowner
        Specifies the version in a specified workspace.

        Tip T
        Specifies the most recent version.

        .PARAMETER Force
        Download all and overwrite files even if previously downloaded

        .LINK
        https://msdn.microsoft.com/en-us/library/microsoft.teamfoundation.versioncontrol.client(v=vs.120).aspx
        
    #>

    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [string]
        $Name,
        [parameter(Mandatory)]
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
        $LocalPath,
        [string]
        $VersionSpec = 'T',
        [switch]
        $Force
    )

    if (-not (Test-Path $LocalPath))
    {
        $null = 
        New-Item -Path $LocalPath -ItemType Directory
    }

    $server = Get-TfsServer -Name $Name -Credential $Credential
    $workspace = New-TfsWorkspace -Name $Name -Credential $Credential -WorkspaceName $WorkspaceName -Path $Path -LocalPath $LocalPath 

    Write-Output "Downloading source to $LocalPath"
    $Date = Get-date

    if ($PSBoundParameters.ContainsKey('Debug'))
    {
        Update-TfsWorkspace -Item $LocalPath -Version $VersionSpec -Recurse -All -Force:$Force
    }
    else
    {
        $null = Update-TfsWorkspace -Item $LocalPath -Version $VersionSpec -Recurse -All -Force:$Force
    }

    $time = New-TimeSpan -Start $Date -End (Get-Date)
    Write-Verbose "Done getting source from $Path in $($time.TotalSeconds) seconds"
}
                