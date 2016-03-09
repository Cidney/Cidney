#requires -Modules PSDesiredStateConfiguration
#requires -Version 3
function Dsc:
{
    <#
        .SYNOPSIS
        Invokes a DSC Resource.
        .DESCRIPTION
            The Dsc: functiont executes the Set method of a specified Desired 
            State Configuration (DSC) resource. Before you run this cmdlet set the 
            refresh mode of the Local Configuration Manager (LCM) to Disabled.
    
            This function invokes a DSC resource directly, without creating a 
            configuration document. Using this function, configuration management 
            products can manage windows by using DSC resources. This function also 
            enables debugging of resources when the DSC engine or LCM is running with 
            debugging enabled.  
            
            NOTE: Will not work with File Resource because it doesnt have a module name 
            and although Invoke-DscResource shows that ModuleNAme is not mandatory it seems 
            to be.
            Possibly a bug in Invoke-DscResource
            
            NOTE: Before you run this cmdlet set the refresh mode of the Local Configuration 
            Manager (LCM) to Disabled.      
        .EXAMPLE
        .\IISServer.ps1

        Pipeline: IISServer {
            Stage: Test {
                Dsc: WindowsFeature IIS {
                    Ensure = 'Present'
                    Name = 'Web-server'
                }
       
            }
        } -Verbose 
    
        Output:

        VERBOSE: [03/06/16 9:35:54.343 AM] [Start] Pipeline IISServer
        VERBOSE: [03/06/16 9:35:54.347 AM] [Start] Stage Test
        VERBOSE: [03/06/16 9:35:57.000 AM] [Start] DSCResource WindowsFeature
        VERBOSE: Performing the operation "Invoke-CimMethod: ResourceSet" on target "MSFT_DSCLocalConfigurationManager".
        VERBOSE: Perform operation 'Invoke CimMethod' with following parameters, ''methodName' = ResourceSet,'className' = MSFT_DSCLocalConfigurationManager,'namespaceName' = root/Microsoft/Windows/DesiredStateConfiguration'.
        VERBOSE: An LCM method call arrived from computer ROBERTSP4 with user sid S-1-5-21-682003330-1644491937-484763869-5611.
        VERBOSE: [ROBERTSP4]: LCM:  [ Start  Set      ]  [[WindowsFeature]DirectResourceAccess]  
        VERBOSE: [ROBERTSP4]: LCM:  [ End    Set      ]  [[WindowsFeature]DirectResourceAccess]  in 0.1690 seconds.
        VERBOSE: Operation 'Invoke CimMethod' complete.
        VERBOSE: [03/06/16 9:35:57.717 AM] [Done] DSCResource WindowsFeature
        VERBOSE: [03/06/16 9:35:57.833 AM] [Done] Stage Test
        VERBOSE: [03/06/16 9:35:57.833 AM] [Done] Pipeline IISServer
        
        .EXAMPLE
        .\ServiceTest.ps1

        Example of a Pipeline that makes sure the BITS service is running. This is calling the Test Method of Invoke-DSCResource

        Pipeline: ServiceTest {
            Stage: Test {
                Dsc: Service BITS {
                    Ensure = 'Present'
                    Name = 'BITS'
                    State = 'Running'
                } -Test
       
            }
        } -Verbose  

        VERBOSE: [03/06/16 10:55:43.140 AM] [Start] Pipeline HelloWorld
        VERBOSE: [03/06/16 10:55:43.140 AM] [Start] Stage Test
        VERBOSE: [03/06/16 10:55:45.800 AM] [Start] DSCResource Service
        VERBOSE: Performing the operation "Invoke-CimMethod: ResourceTest" on target "MS
        FT_DSCLocalConfigurationManager".
        VERBOSE: Perform operation 'Invoke CimMethod' with following parameters, ''metho
        dName' = ResourceTest,'className' = MSFT_DSCLocalConfigurationManager,'namespace
        Name' = root/Microsoft/Windows/DesiredStateConfiguration'.
        VERBOSE: An LCM method call arrived from computer ROBERTSP4 with user sid S-1-5-
        21-484763869-1644491937-682003330-5611.
        VERBOSE: [ROBERTSP4]: LCM:  [ Start  Test     ]  [[Service]DirectResourceAccess]
  
        VERBOSE: [ROBERTSP4]: LCM:  [ End    Test     ]  [[Service]DirectResourceAccess]
         True in 0.0000 seconds.
        VERBOSE: [ROBERTSP4]: LCM:  [ End    Set      ]    in  0.1160 seconds.
        VERBOSE: Operation 'Invoke CimMethod' complete.
        VERBOSE: [03/06/16 10:55:46.379 AM] [Done] DSCResource Service
        VERBOSE: [03/06/16 10:55:46.502 AM] [Done] Stage Test
        VERBOSE: [03/06/16 10:55:46.502 AM] [Done] Pipeline HelloWorld

        .Link
        Invoke-DSCResource
    #>

    [cmdletbinding(DefaultParameterSetName='ScriptBlock')]
    param
    (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $DscResource,
        [Parameter(Mandatory, Position = 1, ParameterSetName='Name')]
        [string]
        $DscResourceName,
        [Parameter(Mandatory, Position = 2, ParameterSetName='Name')]
        [Parameter(Mandatory, Position = 1, ParameterSetName='ScriptBlock')]
        [scriptBlock]
        $ScriptBlock,
        [string[]]
        $ComputerName,
        [ValidateSet('Get', 'Set', 'Test')]
        [string]
        $Method = 'Set'
    )
  
    # Preload DSCResources if not loaded yet
    if (-not $Script:DSCResources)
    {
        $Global:progressPreference = 'silentlyContinue'
        $Script:DSCResources = Get-DscResource 
        $Global:progressPreference = 'Continue'      
    }
    
    $resource = $Script:DSCResources | Where-Object Name -eq $DscResource
    $properties = Get-DSCProperty($ScriptBlock)

    Write-Log "[Start] DSCResource $($resource.Name)"

    $commonParams = Get-CommonParameters -BoundParameters $PSBoundParameters
    $params = @{}

    $params.Add('Name', $resource.Name)
    $params.Add('Property', $properties) 
    $params.Add('Method', $Method)
    if ($resource.ModuleName)
    {
        $params.Add('ModuleName', $resource.ModuleName)
    }
    if ($params.ContainsKey('ErrorAction'))
    {
        $params.Remove('ErrorAction')
    }
    $params.Add('ErrorAction','SilentlyContinue')

    if ($commonParams -match 'verbose')
    {
        #$params.Add('Verbose', $null)
    }
    if ($commonParams -match 'debug')
    {
        $params.Add('Debug', $null)
    }

    $result = Invoke-DscResource @params -verbose
    Write-Output $result

    Write-Log "[Done] DSCResource $($resource.Name)"
}

function Get-DSCProperty([scriptblock]$scriptBlock)
{
    $dscProperties = @{}
    $block = $ScriptBlock.ToString().Trim()
    if ($block)
    {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput([scriptblock]::Create($block), [ref] $null, [ref] $null);
        $properties = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]}, $true) 
        foreach($property in $properties)
        { 
            if ($property.CommandElements[1].Value -eq '=') 
            {
                $expression = [string]($property.CommandElements | Select-Object -skip 2 | % {$_.Extent.Text})
                $name = $property.CommandElements[0].Value
                $value = Invoke-Command -ScriptBlock ([scriptBlock]::Create($expression))

                $dscProperties.Add($name, $Value)
            }
        }
    }

    return $dscProperties
}

