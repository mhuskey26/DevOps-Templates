#set variables
$today = Get-Date -format yyyyMMdd
$ComputerName = hostname
$applicationPath = 'D:\OTS\Websites'

cd $applicationPath

$SCpaths = Get-ChildItem $applicationPath #-Recurse

ForEach ($SCPath in $SCPaths){

    Write-Host $SCPath
    Write-Host $applicationPath

    $ToBeCopieds = Get-ChildItem -Path $applicationPath\$SCPath\Config -include *.json,*.config -Recurse

    ForEach ($ToBeCopied in $ToBeCopieds){
           $FileName = ($ToBeCopied | Select-Object Name)
            Copy-Item $ToBeCopied -Destination "H:\PS\outputs\$ComputerName\$SCPath-$($ToBeCopied.Basename).txt" -Force
    }
}

