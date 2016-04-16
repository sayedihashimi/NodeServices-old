[cmdletbinding()]
param()

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'Angular2Spa'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'AngularSpaApplication'
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
    }
}

$templateInfo | replace (
    ('Angular2Spa', {"$ProjectName"}, {"$DefaultProjectName"}),   
    ('8f5cb8a9-3086-4b49-a1c2-32a9f89bca11', {"$ProjectId"}, {[System.Guid]::NewGuid()})
)

# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    ,('Angular2Spa', {"$ProjectName"})
)
# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj','node_modules'

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo
