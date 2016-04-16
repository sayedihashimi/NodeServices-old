[cmdletbinding()]
param()

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'WebAppBasic'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'WebApplication'
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
    }
}

$templateInfo | replace (
    ('WebApplicationBasic', {"$ProjectName"}, {"$DefaultProjectName"}),
    ('cb4398d6-b7f1-449a-ae02-828769679232', {"$ProjectId"}, {[System.Guid]::NewGuid()})
)

# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    ,('WebApplicationBasic', {"$ProjectName"})
)
# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj','node_modules' 

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo
