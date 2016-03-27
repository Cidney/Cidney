# **Cidney** [![Join the chat at https://gitter.im/Cidney/Cidney](https://badges.gitter.im/Cidney/Cidney.svg)](https://gitter.im/Cidney/Cidney?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge) [![Build status](https://ci.appveyor.com/api/projects/status/j0jqgja6d352pkhc/branch/master?svg=true)](https://ci.appveyor.com/project/RobertKozak/cidney/branch/master)

Continuous Integration and Deployment Pipelines in Powershell

----------

Tags: CI, Continuous Integration, Continuous Deployment, DevOps, Powershell,  DSL,  DSC 

**Install**

Add this module to C:\Program Files\WindowsPowershell\Modules\Cidney

**Use**

Import-Module Cidney

**Help**

Keywords and cmdlets have powershell help. 

    Get-Help Invoke-Cidney

    Get-Help Stage:

I welcome any and all who wish to help out and contribute to this project.

----------

**Cidney** is a Continuous Integration and Deployment DSL written in Powershell. Using the concept of **Pipelines** and **Stages** tasks can be performed sequentially and in parallel to easily automate your process.

Cidney is a very easy way to handle multiple tasks in parallel runspaces in a structured way. There are only 5 keywords

- Pipeline:
- Stage: 
- On:
- Do:
- When:


Everything starts with a **Pipeline:** 
A Pipeline: is a named process that executes Stages sequentially one after the other. Inside a Stage: are Do: tasks which execute in parallel using runspaces and threads. Let's look at a quick example:

	Pipeline: 'My First Pipeline' {
		Stage: One {
			Do: { Write-Output 'Task 1'; Start-Sleep -Seconds 5 }
			Do: { Write-Output 'Task 2'; Start-Sleep -Seconds 3 }
		}
    
		Stage: Two {
			Do: { Write-Output 'Task 3'}
		}
	}

    Invoke-Cidney 'My First Pipeline'

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
	} 

    Invoke-Cidney 'My First Pipeline' -Verbose
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

**Pipelines by default do not execute directly but now work more like functions. You define a pipeline and run it with Invoke-Cidney. To invoke a pipeline: directly use the -Invoke switch. See the help for Invoke-Cidney for more information.**

This was done to better support Pipelines within Pipelines. 
For Example:

    Pipeline: One {
        Write-output "Hello from Pipeline: One"
        Invoke-Cidney -Name Two
    }

    Pipeline: Two {
        Write-output "Hello from Pipeline: Two"
    }

    Invoke-Cidney One

    Hello from Pipeline: One
    Hello from Pipeline: Two
    

To Invoke directly:

    Pipeline: One {
        Write-output "Hello from Pipeline: One"
    } -Invoke

    Hello from Pipeline: One
----------

**Pipeline:**


  Pipeline: [-PipelineName] &lt;string&gt; [-PipelineBlock] &lt;scriptblock&gt; [-Invoke] [-ShowProgress] [-PassThru] 
 
 Docs coming soon

 **Stage:**


  Stage: [-StageName] &lt;string&gt; [-StageBlock] &lt;scriptblock&gt;

 Docs coming soon

 **Do:**

 A Cidney Pipeline: will run each Stage: one right after the other synchronously.
 Each Do: Block found will create a Job so they can be run asynchronously ( or in Parallel.)
 

  Do: [-DoBlock] &lt;scriptblock&gt; [-TimeOut &lt;int&gt;] [-MaxThreads &lt;int&gt;] [-SleepTimer &lt;int&gt;] [-Passthru] 

  Do: [[-Name] &lt;string&gt;] [-DoBlock] &lt;scriptblock&gt; [-TimeOut &lt;int&gt;] [-MaxThreads &lt;int&gt;] [-SleepTimer &lt;int&gt;] [-Passthru] 
  
         .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                Do: { Dir C:\Windows\System32 | Where Name -match '.dll' | measure }
                Do: GetService { Get-Service B* }
            }
        }

        Invoke-Cidney HelloWorld -Verbose

        This example will do a Dir list and count the number of dll files, and run Get-Service as separate threads and the Stage: will complete once all threads are finished.
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

NOTE: Current issues with Do: 

  - Write-Host will be out of sequence with the Verbose output. Write-Host happens immediately while regular pipeline output is captured and displayed after the stage or pipeline in order
  - You cannot start an Event from a Do: block. Send-Event will not work inside a Do: block. 

**On:**

On: command for Cidney Pipelines. Used between Stage: and Do: 
The On: command lets you specify a computer(s) that you will run its script block against


  On: [-ComputerName] &lt;string[]&gt; [-OnBlock] &lt;scriptblock&gt; [-Credential &lt;pscredential&gt;] [-UseSSL] [-TimeOut &lt;int&gt;] [-MaxThreads &lt;int&gt;] [-SleepTimer &lt;int&gt;]
        
        .\HelloWorld.ps1

        Pipeline: HelloWorld {
            Stage: One {
                On: Server1 {
                    Do: { Ipconfig}
                }
            }
        }
        Invoke-Cidney HelloWorld -Verbose

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
        Invoke-Cidney HelloWorld -Verbose

        Outputs the computer names of Server1 and Server2


**When:**

When: command for Cidney Pipelines. 

The When: command lets you specify an event to listen for that you will run its script block against. This is a simple implementation of Register-EngineEvent in which an Event name is registered with the When: block. It will not execute until the event it is waiting for is raised with Send-Event (which is a wrapper for New-Event.) The When: block and the act of raising the Event can be in different pipelines.

 When: [-Event] &lt;string&gt; [-WhenBlock] &lt;scriptblock&gt; [-EventObject &lt;Object&gt;] [-Wait] [-Timeout &lt;int&gt;] 

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
        Invoke-Cidney HelloWorld -Verbose

        Run ipconfig from Stage One when MyEvent is fired once Stage Two is run.

Note: All though this is a simple implementation Register-EngineEvent you can use more complex events like Cim, WMI and Object events but just calling Send-Event in the action of these events.
       
	pipeline: TimerTest {
	    $Timer =[timers.timer]::new()
	    When: Timer.Done {
	        Write-host "Timer Elapse Event: $(get-date -Format ‘HH:mm:ss’)"
	        if ($Global:TimerCount++ -ge 3)
	        {
	            $Timer.Stop()
	            $Timer.Dispose()
	            Unregister-Event ATimer
	            Get-Job ATimer | Remove-Job -Force
	        }
	
	    }
	
	    Stage: StartTimer {
	        $Global:TimerCount = 1
	        
	        $timer.Interval = 3000
	        $timer.AutoReset = $true
	
	        $job = Register-ObjectEvent -InputObject $global:timer `
	          -EventName elapsed –SourceIdentifier ATimer -Action { 
	            Send-Event Timer.Done 
	        }  
	
	        $timer.start() 
	    }
	} -Invoke

output

	[0.00ms] PS Cidney> Invoke-Cidney TimerTest
	
	[53.41ms] PS Cidney> Timer Elapse Event: 15:26:27
	Timer Elapse Event: 15:26:30
	Timer Elapse Event: 15:26:33
	
	[53.41ms] PS Cidney> 	

----------
