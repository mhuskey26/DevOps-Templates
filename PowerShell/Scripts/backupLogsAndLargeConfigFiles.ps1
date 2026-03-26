# This script is used to backup large configuration files, for instance with SiteCore. 
$AppConfigSource = $OctopusParameters['AppConfigSource']
$AppDataLogSource = $OctopusParameters['AppDataLogSource']
$AppWebConfigSource = $OctopusParameters['AppWebConfigSource']
$BackupDestination = $OctopusParameters['BackupDestination']
$AllFiles = '*.*'
$LogDate = Get-Date -Format yyyyMMdd
$LogFiles = "*$LogDate*.txt"

function Copy-Source{
	param($SourceName, $BackupPath, $FileNames)
    $result = $null

	Write-Host "parameters: SourceName -  " $SourceName 
    Write-Host "parameters: BackupPath -  " $BackupPath
    Write-Host "parameters: FileNames - " $FileNames

	if(Test-Path -Path $SourceName) {

    	robocopy $SourceName $BackupPath $FileNames /E /V
	}
	if($LastExitCode -gt 8) {
    	$result = 1
	}
	else {
    	$result = 0
	}
	Write-Verbose "Copy-Source for '$($SourceName)' [value='$($result)']"

    return $result
}

Write-Host "AppConfigSource" $AppConfigSource
Write-Host "AppDataLogSource" $AppDataLogSource
Write-Host "AppWebConfigSource" $AppWebConfigSource
Write-Host "BackupDestination" $BackupDestination

Copy-Source -SourceName $AppConfigSource -BackupPath "$BackupDestination\App_config" -FileNames $AllFiles
Copy-Source -SourceName $AppDataLogSource -BackupPath "$BackupDestination\logs" -FileNames $LogFiles


robocopy $AppWebConfigSource "$BackupDestination\web" 'web.config' /V

if($result -gt 8) {
    	exit 1
	}
	else {
    	exit 0
	}