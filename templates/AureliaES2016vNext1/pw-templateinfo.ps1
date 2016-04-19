[cmdletbinding()]
param()

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'AureliaES2016'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'AngularSpaApplication'
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
        $dest = $properties['FinalDestPath']

        try{
            Push-Location
            if(-not ([string]::IsNullOrEmpty($dest)) -and (test-path $dest) ){
                Set-Location $dest
                # $7zippath = 'C:\temp\pecan-waffle\7z1514-extra\7za.exe'
                $7zippath = (Get-7zipExe)
                $filetoextract = (Join-Path $dest 'n-modules.7z')
                if( -not ([string]::IsNullOrWhiteSpace($filetoextract)) -and (Test-Path $filetoextract) ){
                    Invoke-CommandString -command $7zippath -commandArgs @('x','n-modules.7z','-bd','-so',"-w$dest")
                    Remove-Item $filetoextract
                }
                <# 
                call npm install - this took about 10 min to complete
                #>
                # 'calling npm install' | Write-Output
                # Invoke-CommandString -command 'npm' -commandArgs 'install'
            }
            else{
                'destPath is empty' | Write-Output
            }
        }
        finally{
            Pop-Location
        }
        
    }
}

$templateInfo | replace (
    ('AureliaES2016vNext1', {"$ProjectName"}, {"$DefaultProjectName"}<#, $null, @('*.xproj'), @('node_modules')#>),
    ('4aafd9a8-008c-4adf-8089-90c6ed4b96e3', {"$ProjectId"}, {[System.Guid]::NewGuid()}<#,$null, @('*.xproj'), @('node_modules')#>)
)

# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    ,('AureliaES2016vNext1', {"$ProjectName"}<#, $null, @('AureliaES2016vNext1'), @('node_modules')#>)
    # ,('EmptyProject', {"$ProjectName"},$null,'EmptyProject.xproj')
)
# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj','node_modules'

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo
