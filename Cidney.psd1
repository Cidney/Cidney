@{
    RootModule = 'Cidney.psm1'
    ModuleVersion = '1.0.0.5'
    GUID = '95f1121c-d1c5-4fc1-89c0-5da6e5cc2082'
    Author = 'Cidney Team'
    CompanyName = 'Cidney'
    Copyright = 'Copyright (c) 2016 by Cidney Team, licensed under MIT License.'
    Description = 'This module defines a DSL for doing pipelines and stages for Continuous Integration and Deployment'
    FunctionsToExport = 'Pipeline:','Stage:','Do:','On:','When:','Write-CidneyLog','Invoke-Cidney','Remove-CidneyPipeline', 'Get-CidneyPipeline', 'Wait-CidneyJob', 'Send-Event'
    
    PrivateData = @{
        # PSData is module packaging and gallery metadata embedded in PrivateData
        # It's for rebuilding PowerShellGet (and PoshCode) NuGet-style packages
        # We had to do this because it's the only place we're allowed to extend the manifest
        # https://connect.microsoft.com/PowerShell/feedback/details/421837
        PSData = @{
            # The primary categorization of this module (from the TechNet Gallery tech tree).
            Category = 'Scripting Techniques'

            # Keyword tags to help users find this module via navigations and search.
            # cannot have spaces
            Tags = @('powershell','continuousintegration','ci','devops', 'continuousdeployment', 'continuousdelivery', 'releasemanagement')

            # The web address of an icon which can be used in galleries to represent this module
            IconUri = 'https://avatars3.githubusercontent.com/u/17713732'

            # The web address of this module's project or support homepage.
            ProjectUri = 'https://github.com/Cidney/Cidney'

            # The web address of this module's license. Points to a page that's embeddable and linkable.
            LicenseUri = 'https://github.com/Cidney/Cidney/blob/master/LICENSE'

            # Release notes for this particular version of the module
            # ReleaseNotes = False

            # If true, the LicenseUrl points to an end-user license (not just a source license) which requires the user agreement before use.
            # RequireLicenseAcceptance = ""

            # Indicates this is a pre-release/testing version of the module.
            IsPrerelease = 'False'
        }
    }
}