<#
$SourcePath = "H:\dryRun\deployDir"  #$OctopusParameters['SourcePath']
$BackupFolder = 'BackupsNew' #$OctopusParameters['BackupFolder']  
#backup Destination from Octopus should contain the Octopus machine name
$BackupPath = "H:\" + $BackupFolder #$OctopusParameters['BackupPath']
#>

#This script is used to backup configuration files

$SourcePath = $OctopusParameters['SourcePath']
$BackupPath = $OctopusParameters['BackupPath']
$AllJsonFiles1 = '*.json'
$AllJsonFiles2 = '*.*.json'
$AllConfigFiles1 = '*.config'
$AllConfigFiles2 = '*.*.config'
$AllConfFiles1 = '*.conf'
$AllConfFiles2 = '*.*.conf'
$AllXMLFiles1 = '*.xml'
$AllXMLFiles2 = '*.*.xml'
$date = Get-date -Format "yyyyMMdd"

Write-Host "SourcePath is " $SourcePath
Write-Host "BackupPath is " $BackupPath

if(Test-Path -Path $SourcePath) {

	if(Test-Path -Path $BackupPath) {
  
    Write-Host "Beginning copy from SourcePath -  " $SourcePath  "to BackupPath" $BackupPath
	Write-Host "These files will be copied:"
    Get-ChildItem -Path $SourcePath/$AllConfFiles1
	Get-ChildItem -Path $SourcePath/$AllConfFiles2
   	Get-ChildItem -Path $SourcePath/$AllConfigFiles1
	Get-ChildItem -Path $SourcePath/$AllConfigFiles2
	Get-ChildItem -Path $SourcePath/$AllJsonFiles1 
	Get-ChildItem -Path $SourcePath/$AllJsonFiles2

	Copy-Item $SourcePath\$AllConfFiles1 $BackupPath -Force
	Copy-Item $SourcePath\$AllConfFiles2 $BackupPath -Force
	Copy-Item $SourcePath\$AllConfigFiles1 $BackupPath -Force
	Copy-Item $SourcePath\$AllConfigFiles2 $BackupPath -Force
	Copy-Item $SourcePath\$AllJsonFiles1 $BackupPath -Force
	Copy-Item $SourcePath\$AllJsonFiles2 $BackupPath -Force
	Copy-Item $SourcePath\$AllXMLFiles1 $BackupPath -Force
	Copy-Item $SourcePath\$AllXMLFiles2 $BackupPath -Force
	Write-Host "Copy completed to " $BackupPath

	} else {
    	Write-host "Backup directory does not exist - " $BackupPath
	}

} else {
    Write-host "Source directory does not exist - " $SourcePath
}