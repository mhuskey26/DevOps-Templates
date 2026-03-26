#Cleanup Intersoft Octopus Build Files
$otspath1 = "C:\Octopus\Applications\DEV1\IntersoftWebAutomation"
$otspath2 = "C:\Octopus\Applications\PROD A\IntersoftWebAutomation.Prod"
$deletedate = (Get-Date).AddDays(-14)

#Zip and Cleanup OTS logs in DEV1
cd $otspath1
$otsdirs = Get-ChildItem -Directory
Write-Host "Directory List " $otsdirs
Foreach ($otsdir in $otsdirs)
    {
        #cleanup related file extensions
        Get-ChildItem -Recurse | Where-Object { $_.LastWriteTime -lt $deletedate } | Remove-Item
        rmdir $otsdir
    }

    #Zip and Cleanup OTS logs in PROD A
cd $otspath2
$otsdirs = Get-ChildItem -Directory
Write-Host "Directory List " $otsdirs
Foreach ($otsdir in $otsdirs)
    {
        #cleanup related file extensions
        Get-ChildItem -Recurse | Where-Object { $_.LastWriteTime -lt $deletedate } | Remove-Item
        rmdir $otsdir
    }