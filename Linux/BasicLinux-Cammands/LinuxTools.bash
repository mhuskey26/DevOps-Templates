"Blow is a list of helpful linux tools every Linux user/administrator should have and use"

"---Install SSH--------------------------------------------------"

#Adding SSH ubuntu/Depian
"Need to be run with sudo access"
apt install openssh-server -y

#Check if ssh is running
"Need to be run with sudo access"
systemctl status ssh


"---Net-Tools----------------------------------------------------"
"installs network tools simliare to windows cmd/powershell"

#Install networking tools to linux (Ubuntu/Debian)
apt install net-tools -y

#Install networking tools to linux (Amazon Linux/CentOS/Redhat)
"Need to be run with sudo access"
yum install net-tools

"--Tools to Install for FS Managment---------------------------------------------------------------------"

#One tool to always install is TREE its a helpful tool to pull and view full diretory tree and all there sub-diretories along with other features
"Need to be run with sudo access"
apt install tree #Ubuntu/Debian

"--Using the Tree Tool--------------------------------------------------------------------------------------"

#Pulling the full tree directory
tree /dir/

#Pulling just the folder directory paths
tree -f /dir/
tree -f ~

#Pulling just the directories
tree -d /dir/

#Pull just the directories with full paths
tree -df /dir/

"---Locate--------------------------------------------------"
"add a useful quering tool to search and locate files in linux, it dose have a draw back as it uses its own db to run the search so the db needs to be keep up to date but this is easy to do"

#Installing mlocate tool
apt install mlocate -y

#Updating the locatedb
updatedb

#The db for locate can be found at
ls /var/lib/mlocate/

#To see the size of the DB Index
locate -S

#Using locate to query data
locate yourqueryname
example: locate passwords

#To query the base name for file in a targeted dir
locate -b '\dirname'

#Query a serach with a partiale dir name
locate -b *dir* 
Example: locate -b *pass*

#Query a search and verify the file/dir still exist
locate -e dir/file

#Query a search eqnoring casesitive = look for both CAP and Lower
locate -i file

