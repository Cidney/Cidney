@{
    RootModule = 'Cidney.psm1'
    ModuleVersion = '0.0.0.9'
    GUID = '95f1121c-d1c5-4fc1-89c0-5da6e5cc2082'
    Author = 'Robert Kozak'
    Copyright = '(c) 2016 Robert Kozak. All rights reserved.'
    Description = 'This module defines a DSL for doing pipelines and stages for Continuous Integration and Deployment'
    FunctionsToExport = 'Pipeline:','Stage:','Do:','On:','Dsc:','When:', 'Register-JobCommand', 'Get-RegisteredJobCommand', 'Get-RegisteredJobModule', 'Get-TfsSource'
    FileList = '.\Keywords\Pipeline.ps1', '.\Keywords\Stage.ps1', '.\Keywords\On.ps1', '.\Keywords\Do.ps1', '.\Keywords\On.ps1', '.\Keywords\Dsc.ps1', '.\Keywords\When.ps1'
    AliasesToExport = '*'
    PrivateData = ''
}

