[cmdletbinding()]
param()

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'ReactSpa'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'ReactApp'
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
    }
}

$templateInfo | replace (
    ('ReactSpa', {"$ProjectName"}, {"$DefaultProjectName"}),
    ('dbfc6db0-a6d1-4694-a108-1c604b988da3', {"$ProjectId"}, {[System.Guid]::NewGuid()})
)

# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    ,('ReactSpa', {"$ProjectName"})
)
# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj','node_modules'

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo
