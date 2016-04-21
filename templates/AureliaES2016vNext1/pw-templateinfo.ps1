[cmdletbinding()]
param()

$logfilepath = $env:PecanWaffleLogFilePath

$templateInfo = New-Object -TypeName psobject -Property @{
    Name = 'AureliaES2016'
    Type = 'ProjectTemplate'
    DefaultProjectName = 'AngularSpaApplication'
    AfterInstall = {
        Start-Sleep -Seconds 5
        Update-VisualStuidoProjects -slnRoot ($SolutionRoot)
        $projdest = $properties['FinalDestPath']

        try{
            Push-Location
            if(-not ([string]::IsNullOrEmpty($projdest)) -and (test-path $projdest) ){
                Set-Location $projdest

                # $7zippath = 'C:\temp\pecan-waffle\7z1514-extra\7za.exe'
                $7zippath = (Get-7zipExe)
                $filetoextract = (Join-Path $projdest 'n-modules.7z')

                if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                $logmsg = @'
 pwd=[{0}]
 projdest=[{1}]
 filetoextract=[{2}]
'@

                [System.IO.File]::AppendAllText($logfilepath, ($logmsg -f $pwd,$projdest,$filetoextract))
                }

                if( -not ([string]::IsNullOrWhiteSpace($filetoextract)) -and (Test-Path $filetoextract) ){
                    $cmdargs = @('-bd','x','n-modules.7z',"-wnode_modules")

                    $cmdargsstr = "`r`n{0} {1}" -f $7zippath,($cmdargs -join ' ')

                    if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                        [System.IO.File]::AppendAllText($logfilepath, $cmdargsstr)
                    }

                    Invoke-CommandString -command $7zippath -commandArgs $cmdargs -ignoreErrors $true
                    Remove-Item $filetoextract
                }
                else{
                    throw ('Did not find node modules zip at [{0}]' -f $filetoextract)
                }
                <# 
                call npm install - this took about 10 min to complete
                #>
                # 'calling npm install' | Write-Output
                # Invoke-CommandString -command 'npm' -commandArgs 'install'
            }
            else{
                'destPath is empty' | Write-Output

                if(-not [string]::IsNullOrWhiteSpace($logfilepath)){
                    [System.IO.File]::AppendAllText('c:\temp\pean-waffle\log.txt','destPath is empty')
                }
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
