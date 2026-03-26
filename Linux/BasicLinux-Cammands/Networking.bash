"---Testing Network Connections--------------------------------------------"

#Run a endless ping
ping 0.0.0.0

#Send a ping cmd but limit it to a set amount of pings
ping -c 1 0.0.0.0
example: ping -c 1 0.0.0.0
returns: a single ping back if you want to ping more then 1 change the 1 after the -c
example: ping -c 4 0.0.0.0
returns: now you will ping four times

"---Pulling Host Data------------------------------------------------------"

#Network interface prefix
en = eithernet
wl = wireless
lo = loopback

#Quick read of hosts local Data
cat /etc/hosts

"Using the ifconfig cmd"
#Pull list of all active network intefaces and configs
ifconfig
"To show all active and inactive a -a"

#Pulling the config for a targeted interface only
ifconfig "interfaceid"
"example" ifconfig enp0s03

#Output the config to a file
ifconfig > /dir/file.txt

"Using the ip cmd"
#Pull list of all active network intefaces and configs
ip address show

#List only IPv4
ip -4 address

#List only IPv6
ip -6 address

#Pulling the route table for network traffic
route
"Adding a -n converts all into binary"
or
ip route show

#Gathing DNS Info
systemd-resolve --status

"---Configuring Network interfaces and Ports--------------------------------"

"All need to be run with sudo access"

#Disableing an net ineterface
ifconfig "interfaceid" down
or
ip link set "interfaceid" down

#Enabling an net interface
ifconfig "interfaceid" up
or
ip link set "interfaceid" up

#Configure an IP address to interface
ifconfig "interfaceid"  "ip/mask"

#Setting a default gateway
rout add default gw "ipaddress"

#Removing currently set Gateway
rout del default gw "ipaddress"

#Changing the MAC Address of an interface
"The target interface must be disabled/down"
ifconfig "interfaceid" hw ether "new mac address"


"---Configuring Network Ports------------------------------------------------"

#Pulling list of open ports
netstat -tupan

#Chekcing if a port is active
netstat -tupan | grep portnumber "Example: netstat -tupan | grep 22"

#Adding/Opening a port


#Removing/Blocking a port