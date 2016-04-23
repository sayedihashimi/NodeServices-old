[cmdletbinding()]
param()

$logfilepath = $env:PecanWaffleLogFilePath

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'AureliaES2016'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'AngularSpaApplication'
    AfterInstall = {
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
        $projdest = $properties['FinalDestPath']
        $filetoextract = (Join-Path $projdest 'n-modules.7z')

        try{
            Push-Location

            # see if the file has already been extracted
            $extractdest = ([System.IO.DirectoryInfo](Join-Path $env:LOCALAPPDATA 'pecan-waffle\aur2016\nmv1')).FullName

            if(-not (Test-Path $extractdest)){
                New-Item -Path $extractdest -ItemType Directory

                Set-Location $extractdest

                $7zippath = (Get-7zipExe)

                if( -not ([string]::IsNullOrWhiteSpace($filetoextract)) -and (Test-Path $filetoextract) ){
                    $cmdargs = @('-bd','x',$filetoextract,('-w{0}' -f $extractdest))

                    $cmdargsstr = "`r`n{0} {1}" -f $7zippath,($cmdargs -join ' ')

                    if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                        [System.IO.File]::AppendAllText($logfilepath, $cmdargsstr)
                    }

                    Invoke-CommandString -command $7zippath -commandArgs $cmdargs -ignoreErrors $true
                }
                else{
                    throw ('Did not find node modules zip at [{0}]' -f $filetoextract)
                }
            }

            if(-not ([string]::IsNullOrEmpty($projdest)) -and (test-path $projdest) ){
                if(-not (Test-Path $extractdest)){
                    throw ('node modules content folder not found at [{0}]' -f $extractdest)
                }

                $nmdest = ([System.IO.DirectoryInfo](Join-Path $projdest 'node_modules')).FullName
                Copy-ItemRobocopy -sourcePath "$extractdest\node_modules" -destPath $nmdest -recurse

            }
            else{
                'destPath is empty' | Write-Output

                if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                    [System.IO.File]::AppendAllText('c:\temp\pean-waffle\log.txt','destPath is empty')
                }
            }
        }
        finally{
            if(Test-Path $filetoextract){
                Remove-Item $filetoextract
            }
            Pop-Location
        }        
    }
}

$templateInfo | replace (
    ('AureliaES2016vNext1', {"$ProjectName"}, {"$DefaultProjectName"},@('.json';'.cs';'.cshtml')),
    ('4aafd9a8-008c-4adf-8089-90c6ed4b96e3', {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj"))
)


# when the template is run any filename with the given string will be updated
$templateInfo | update-filename (
    ,('AureliaES2016vNext1', {"$ProjectName"},$null,@('*.*proj'))
)

# excludes files from the template
$templateInfo | exclude-file 'pw-*.*','*.user','*.suo','*.userosscache','project.lock.json','*.vs*scc'
# excludes folders from the template
$templateInfo | exclude-folder '.vs','artifacts','packages','bin','obj','node_modules'

# This will register the template with pecan-waffle
Set-TemplateInfo -templateInfo $templateInfo

<#
To get the list of includes for AureliaES2016vNext1 replace item above
Get-ChildItem NodeServices\templates\AureliaES2016vNext1 * -Recurse -File|select-string 'skeleton_navigation_es2016_vs' -SimpleMatch|Select-Object -ExpandProperty path -Unique|% { Get-Item $_ | Select-Object -ExpandProperty extension}|Select-Object -Unique|%{ Write-Host "'$_';" -NoNewline }


To get the list of includes for guid replace above
Get-ChildItem NodeServices\templates\AureliaES2016vNext1 *.*proj -Recurse -File|Select-Object -ExpandProperty fullname -Unique|% { ([xml](Get-Content $_)).Project.PropertyGroup.ProjectGuid|Select-Object -Unique|%{ '('{0}', {{"$ProjectId"}}, {{[System.Guid]::NewGuid()}},@("*.*proj")),' -f $_ }}
('4aafd9a8-008c-4adf-8089-90c6ed4b96e3', {"$ProjectId"}, {[System.Guid]::NewGuid()},@("*.*proj")),
#>