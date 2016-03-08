# **Cidney**

A Continuous Integration and Deployment DSL in Powershell

**Install**
Add this module to C:\Program Files\WindowsPowershell\Modules\Cidney

**Use**
Import-Module Cidney

**NOTE**: This project is in **BETA** version 0.9.0.0 
There is more work I would like to do with Remoting and properly passing variables and session state. If you are not doing any remoting and just running a **Pipeline:** on one server Cidney should work well as is.

I welcome any and all who wish to help out and contribute to this project

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
