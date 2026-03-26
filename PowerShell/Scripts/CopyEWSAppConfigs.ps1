#set variables
$today = Get-Date -format yyyyMMdd
$ComputerName = hostname
$applicationPath = 'C:\OTS\Applications'

cd $applicationPath

$EWSpaths = Get-ChildItem $applicationPath #-Recurse

ForEach ($EWSPath in $EWSPaths){

    Write-Host $EWSPath
    Write-Host $applicationPath

    $ToBeCopieds = Get-ChildItem -Path $applicationPath\$EWSPath\Config -include *.json,*.config -Recurse

    ForEach ($ToBeCopied in $ToBeCopieds){
           $FileName = ($ToBeCopied | Select-Object Name)
            Copy-Item $ToBeCopied -Destination "H:\PS\outputs\$ComputerName\$EWSPath-$($ToBeCopied.Basename).txt" -Force
    }
}

