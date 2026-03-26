#This script is used to backup configuration files
#
#  CHANGE THE PATH OF THE NEW-ITEM DIRECTORY TO D:\DRYRUN WHEN  YOU MAKE THIS STEP TEMPLATE!
#  also #backup Destination from Octopus should contain the Octopus machine name
#
$SourcePath = "H:\dryRun\deployDir"  #$OctopusParameters['AppConfigSource']
$BackupFolder = 'BackupsNew' #$OctopusParameters['BackupDestination']  
#backup Destination from Octopus should contain the Octopus machine name
$AllJsonFiles1 = '*.json'
$AllJsonFiles2 = '*.*.json'
$AllConfigFiles1 = '*.config'
$AllConfigFiles2 = '*.*.config'
$AllConfFiles1 = '*.conf'
$AllConfFiles2 = '*.*.conf'
##  Add XML files here and in copy commands below
$date = Get-date -Format "yyyyMMdd"

if(Test-Path -Path $SourcePath) {
	$BackupPath = "H:\" + $BackupFolder
	$BackupPath_wDate = $BackupPath + "_" + $date
	if(Test-Path -Path $BackupPath_wDate) {
		Write-Host "Existing backups created today will be deleted"
		Remove-Item -Recurse -Force $BackupPath_wDate
	}

	$BackupFolderwDate = $BackupFolder + "_" + $date
    New-Item -ItemType Directory -Name $BackupFolder_wDate
#	New-Item -itemType Directory -Path H:\dryRun\$BackupFolder_wDate
#	New-Item -itemType Directory -Path H:\dryRun -Name $BackupFolder_wDate
	
    Write-Host "Beginning copy from SourcePath -  " $SourcePath  "to BackupPath" $BackupPath_wDate
	
    #Write-Host "These files will be copied:"
    #Get-ChildItem -Path $SourcePath/$AllConfFiles1
	#Get-ChildItem -Path $SourcePath/$AllConfFiles2
   	#Get-ChildItem -Path $SourcePath/$AllConfigFiles1
	#Get-ChildItem -Path $SourcePath/$AllConfigFiles2
	#Get-ChildItem -Path $SourcePath/$AllJsonFiles1 
	#Get-ChildItem -Path $SourcePath/$AllJsonFiles2

	Copy-Item $SourcePath\$AllConfFiles1 $BackupPath_wDate -Force
	Copy-Item $SourcePath\$AllConfFiles2 $BackupPath_wDate -Force
	Copy-Item $SourcePath\$AllConfigFiles1 $BackupPath_wDate -Force
	Copy-Item $SourcePath\$AllConfigFiles2 $BackupPath_wDate -Force
	Copy-Item $SourcePath\$AllJsonFiles1 $BackupPath_wDate -Force
	Copy-Item $SourcePath\$AllJsonFiles2 $BackupPath_wDate -Force

	Write-Host "Copy completed to " $BackupPath_wDate

} else {
    Write-host "Source directory does not exist."
}