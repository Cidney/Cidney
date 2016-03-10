# **Cidney**

A Continuous Integration and Deployment DSL in Powershell

Tags: CI, Continuous Integration, Continuous Deployment, DevOps, Powershell, DSL 

**Install**
Add this module to C:\Program Files\WindowsPowershell\Modules\Cidney

**Use**
Import-Module Cidney

**NOTE**: This project is in **BETA** version 0.9.0.0 
There is more work I would like to do with Remoting and properly passing variables and session state. If you are not doing any remoting and just running a **Pipeline:** on one server Cidney should work well as is.

I welcome any and all who wish to help out and contribute to this project. See Todo: list at bottom

----------

**Cidney** is a Continuous Integration and Deployment DSL written in Powershell. Using the concept of **Pipelines** and **Stages** tasks can be performed sequentially and in parallel to easily automate your process.

Everything starts with a **Pipeline:** 
A Pipeline: is a named process that executes Stages sequentially one after the other. Inside a Stage: are Do: tasks which execute in parallel using powershell jobs. Let's look at a quick example:

	Pipeline: 'My First Pipeline' {
		Stage: One {
			Do: { Write-Output 'Task 1'; Start-Sleep -Seconds 5 }
			Do: { Write-Output 'Task 2'; Start-Sleep -Seconds 3 }
		}
    
		Stage: Two {
			Do: { Write-Output 'Task 3'}
		}
	}

Output:

	Task 2
	Task 1
	Task 3

As you can see Task 1 and Task 2 ran in parallel because Task 2 finished before Task 1 and Task 3 finished after **Stage:** One completed.

To get a clearer view of what is going on let's add a Verbose switch to the **Pipeline:**

	Pipeline: 'My First Pipeline' {
		Stage: One {
			Do: { Write-Output 'Task 1'; Start-Sleep -Seconds 5 }
			Do: { Write-Output 'Task 2'; Start-Sleep -Seconds 3 }
		}
    
		Stage: Two {
			Do: { Write-Output 'Task 3'}
		}
	} -Verbose

Output:

	VERBOSE: [03/08/16 9:36:03.978 AM] [Start] Pipeline My First Pipeline
	VERBOSE: [03/08/16 9:36:04.015 AM] [Start] Stage One
	VERBOSE: [03/08/16 9:36:04.136 AM] [Start] Job275
	VERBOSE: [03/08/16 9:36:04.267 AM] [Start] Job277
	VERBOSE: [03/08/16 9:36:07.713 AM] [Results] Job277
	Task 2
	VERBOSE: [03/08/16 9:36:07.716 AM] [Completed] Job277
	VERBOSE: [03/08/16 9:36:09.597 AM] [Results] Job275
	Task 1
	VERBOSE: [03/08/16 9:36:09.597 AM] [Completed] Job275
	VERBOSE: [03/08/16 9:36:09.703 AM] [Done] Stage One
	VERBOSE: [03/08/16 9:36:09.718 AM] [Start] Stage Two
	VERBOSE: [03/08/16 9:36:09.850 AM] [Start] Job279
	VERBOSE: [03/08/16 9:36:10.304 AM] [Results] Job279
	Task 3
	VERBOSE: [03/08/16 9:36:10.304 AM] [Completed] Job279
	VERBOSE: [03/08/16 9:36:10.407 AM] [Done] Stage Two
	VERBOSE: [03/08/16 9:36:10.407 AM] [Done] Pipeline My First Pipeline

**Do:** tasks can run any powershell code in the scriptblock as a powershell job.
**Pipeline:** and **Stage:** blocks will execute any cmdlet, function and assignment statements only.

There will be more documentation soon especially for other advanced commands like **On:**, **Dsc:**, **When:** and **At:**

----------

**Pipeline:**
 Docs coming soon

 **Stage:**
 Docs coming soon

 **Do:**

 A Cindey Pipeline: will run each Stage: one right after the other synchronously.
 Each Do: Block found will create a Job so they can be run asyncronously or in Parallel.

         .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                Do: { Dir C:\Windows\System32 | Where Name -match '.dll' | measure }
                Do: GetService { Get-Service B* }
            }
        }

        This example will do a Dir list and count the number of dll files, and run Get-Process as separate jobs and the Stage: will complete once all jobs are finished.
        Notice that Get-Service finished first even when it was listed second in the code.

        VERBOSE: [03/06/16 4:53:39.556 PM] [Start] Pipeline HelloWorld
        VERBOSE: [03/06/16 4:53:39.591 PM] [Start] Stage One
        VERBOSE: [03/06/16 4:53:39.769 PM] [Start] Job28
        VERBOSE: [03/06/16 4:53:40.021 PM] [Start] GetService
        VERBOSE: [03/06/16 4:53:40.150 PM] [Results] GetService

        Status   Name               DisplayName                           
        ------   ----               -----------                           
        Running  BDESVC             BitLocker Drive Encryption Service    
        Running  BFE                Base Filtering Engine                 
        Running  BrokerInfrastru... Background Tasks Infrastructure Ser...
        Running  Browser            Computer Browser                      
        Running  BthHFSrv           Bluetooth Handsfree Service           
        Running  bthserv            Bluetooth Support Service             
        VERBOSE: [03/06/16 4:53:40.170 PM] [Completed] GetService
        VERBOSE: [03/06/16 4:53:40.496 PM] [Results] Job28

        Count    : 3001
        Average  : 
        Sum      : 
        Maximum  : 
        Minimum  : 
        Property : 

        VERBOSE: [03/06/16 4:53:40.499 PM] [Completed] Job28
        VERBOSE: [03/06/16 4:53:40.606 PM] [Done] Stage One
        VERBOSE: [03/06/16 4:53:40.607 PM] [Done] Pipeline HelloWorld


**Dsc:**

The Dsc: function executes the Set method of a specified Desired 
State Configuration (DSC) resource. Before you run this cmdlet set the 
refresh mode of the Local Configuration Manager (LCM) to Disabled.
    
This function invokes a DSC resource directly, without creating a 
configuration document. Using this function, configuration management 
products can manage windows by using DSC resources. This function also 
enables debugging of resources when the DSC engine or LCM is running with 
debugging enabled.  
            
NOTE: Will not work with File Resource because it doesnt have a module name 
and although Invoke-DscResource shows that ModuleName is not mandatory it seems 
to be.
Possibly a bug in Invoke-DscResource or the Hrlp file is wrong.
            
NOTE: Before you run this cmdlet set the refresh mode of the Local Configuration 
Manager (LCM) to Disabled.      

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

**On:**

On: command for Cidney Pipelines. Used between Stage: and Do: 
The On: command lets you specify a computer(s) that you will run its script block against 
        
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                On: Server1 {
                    Do: { Ipconfig}
                }
            }
        }

        Run ipconfig against Server1

        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                On: Server1,Server2 {
                    Do: { Write-Output $Env:ComputerName }
                }
            }
        }

        Outputs the computer names of Server1 and Server2


**When:**

When: command for Cidney Pipelines. Used between Stage: and Do:
The When: command lets you specify an event to listen for that you will run its script block against 
        
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                When: 'MyEvent' {
                    Do: { Ipconfig }
                }
            }
			Stage: Two {
				New-Event MyEvent 
			}
        }

        Run ipconfig from Stage One when MyEvent is fired once Stage Two is run.

----------

**Commands**

**Get-TfsSource (Alias GetSource)**

Gets a local copy of source files from TFS.
This function will create a Local WorkSpace and a mapping to a local folder and then download all the files
Will output basic messages to Success output: Getting Source and Downloading source.
Verbose output shows connecting to TFS Server, Creating workspace and a done message with time in seconds to get files.
Debug output will display list of files downloaded.

Requires Microsoft Visual Studio Team Foundation Server Power Tools
See: https://visualstudiogallery.msdn.microsoft.com/898a828a-af00-42c6-bbb2-530dc7b8f2e1
       
    Get-TfsSource -Name http://tfs.example.com:8080/tfs/Collection -WorkspaceName 'MyWorkSpace' -LocalPath C:\Projects -Path $\Projects

    Gets files from $\Projects to c:\projects


    Get-TfsSource -Name http://tfs.example.com:8080/tfs/Collection -WorkspaceName 'MyWorkSpace' -LocalPath C:\Projects -Path $\Projects -VersionSpec 'LRelease 5.0.0.1'

    Gets the version of source labeled Release 5.0.0.1 from Server path $\Projects to local path c:\Projects


**Invoke-NugetRestore (Alias RestorePackages)**

Does a Nuget Package restore using the supplied path
Requires Nuget.exe to be on the computer this is being run and the location set in the $env:NugetPath environment variable
or or supplied in the parameters 

Download Nuget: https://dist.nuget.org/index.html

    Invoke-NugetRestore -Path c:\Projects\MyProject -Source http://nuget.example.com/nuget 

    Restores Nuget packages from private source http://nuget.example.com/nuget 

----------

**TODO:**

There are a ton of things I want to get to and things I would like to investigate

Done:
* Get-TfsSource
* Invoke-NugetRestore

In progress:
* On: Remoting
* Dsc: Invoke-DscResource
* When: Custom Event handler
* At: Scheduled Trigger

Next:
* AppX installer
* Website
* Start-TfsBuild
* New-Container
* New-Environment
* Deployer

