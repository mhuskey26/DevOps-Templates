# Test firewall connections  --- new step template 
#Author:  Kari Tornow
#Data:  2022/05/05
#NOT MAKING A LOOP - we want to know each particualr one that failes ------ Make a loop that will test every hostname needed for that port # # this can do both hostname and then IP addresses and then multiples of each 
# varialbes for one of each type of port  ---- redis.port 7590   solr.port 8983   database.port  1433  https.port 443
# hostname are the fully qualified DNS names  ---  scope by machine
# IPaddress - scoped by each machine
#
# Test all also with IP address Applications

#Run on OTS-DR-SCCDA and OTS-DR-SCCDB  ---- WHERE the Step Runs - the TARGET
$hostname ='OTS-DR-SCREDA.open-techs.local'
$port = 7590
Test-NetConnection $hostname -Port $port 


$hostname ='OTS-DR-SCREDA.open-techs.local'
$port = 7590
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCSLRA.open-techs.local'
$port = 8983
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCSQLA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-CORP-SCXDBA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

Write-Host "Firewall ports have been checked"



#Run on OTS-DR-SCXCA
$hostname ='OTS-DR-SCSLRA.open-techs.local'
$port = 8983
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-CORP-SCXDBA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCCDA.dmz.local'
$port = 433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCCDB.dmz.local'
$port = 433
Test-NetConnection $hostname -Port $port 

Write-Host "Firewall ports have been checked"




#Run on OTS-DR-SCCPA.open-techs.local
$hostname ='OTS-CORP-SCXDBA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCMASA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCRPTA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

Write-Host "Firewall ports have been checked"




#Run on OTS-CORP-SCCMA.open-techs.local
$hostname ='OTS-DR-SCSQLA.open-techs.local'
$port = 8983
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCRPTA.open-techs.local'
$port = 1433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCXCA.open-techs.local'
$port = 433
Test-NetConnection $hostname -Port $port 

Write-Host "Firewall ports have been checked"



#Run on OTS-CORP-SCXCA.open-techs.lcoal
$hostname ='OTS-DR-SCCPA.dmz.local'
$port = 433
Test-NetConnection $hostname -Port $port 

Write-Host "Firewall ports have been checked"




#Run on OTS-CORP-SCXCB.open-techs.local
$hostname ='OTS-DR-SCCDA.dmz.local'
$port = 433
Test-NetConnection $hostname -Port $port 

$hostname ='OTS-DR-SCCDB.dmz.local'
$port = 433
Test-NetConnection $hostname -Port $port 

Write-Host "Firewall ports have been checked"