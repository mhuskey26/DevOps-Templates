
#Run on this server
$Server=hostname   
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | out-null
$SMOserver = New-Object ('Microsoft.SqlServer.Management.Smo.Server') -argumentlist $Server
$SMOserver.Databases | where {$_.IsSystemObject -eq $false} | select Name, RecoveryModel | Format-Table
#Reset recovery model to Simple
#$SMOserver.Databases | where {$_.IsSystemObject -eq $false} | foreach {$_.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple; $_.Alter()}
#Check recovery models again
#$SMOserver.Databases | where {$_.IsSystemObject -eq $false} | select Name, RecoveryModel | Format-Table

