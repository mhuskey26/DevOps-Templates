<#
Websites and App Pools - 
OTS-DR-SCCDA.dmz.local	Website OTS   AppPool OTS
OTS-DR-SCCDB.dmz.local	Website OTS   AppPool OTS
OTS-DR-SCCPA.dmz.local	Website OTS   AppPool OTS
OTS-DR-SCXCA.open-techs          Website xConnect   2 AppPools     xConnect ReferenceData
#>

Get-WebsiteState
Get-AppPoolState

steptemplate



#Or we can make a loop but seems overkill

$Servers = 'Server01'
Invoke-Command -ComputerName $Servers {
    Import-Module -Name WebAdministration
    $Websites  = Get-Website | Where-Object serverAutoStart -eq $true
    foreach ($Website in $Websites) {
        switch ($Website) {
            {(Get-WebAppPoolState -Name $_.applicationPool).Value -eq 'Stopped'} {Start-WebAppPool -Name $_.applicationPool}
            {$_.State -eq 'Stopped'} {Start-Website -Name $Website.Name}
        }
    }
}

