# **Cidney**

A Continuous Integration and Deployment DSL in Powershell

----------

Tags: CI, Continuous Integration, Continuous Deployment, DevOps, Powershell, DSL 

**Install**

Add this module to C:\Program Files\WindowsPowershell\Modules\Cidney

**Use**

Import-Module Cidney

I welcome any and all who wish to help out and contribute to this project.

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
 Do: [<Name>] <ScriptBlock> 

         .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                Do: { Dir C:\Windows\System32 | Where Name -match '.dll' | measure }
                Do: GetService { Get-Service B* }
            }
        }

        This example will do a Dir list and count the number of dll files, and run Get-Service as separate jobs and the Stage: will complete once all jobs are finished.
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


**On:**

On: command for Cidney Pipelines. Used between Stage: and Do: 
The On: command lets you specify a computer(s) that you will run its script block against
On: <computer[]> [-Credential <pscredential>] [-ImportModules] <scriptblock>
        
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

        $credential = Get-Credential administrator
        Pipeline: HelloWorld {
            Stage: One {
                On: Server1,Server2 -Credential $credential {
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
