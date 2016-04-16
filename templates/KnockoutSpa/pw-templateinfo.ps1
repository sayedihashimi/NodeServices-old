[cmdletbinding()]
param()

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'KnockoutSpa'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'KnockoutApp'
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
    }
}

$templateInfo | replace (
    ('KnockoutSpa', {"$ProjectName"}, {"$DefaultProjectName"}),
    ('85231b41-6998-49ae-abd2-5124c83dbef2', {"$ProjectId"}, {[System.Guid]::NewGuid()})
)

# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    ,('KnockoutSpa', {"$ProjectName"})
)
# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj','node_modules'

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo
