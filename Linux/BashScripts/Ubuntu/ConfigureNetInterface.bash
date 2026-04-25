#!/bin/bash

"---------------Storing network settings to load on restart-------------------------------------"
"Steps to setup and save network configuration on ubunut server"

#Step 1. stop and disable network manager
systemtl stop NetworkManager
systemtl disable NetworkManager

#Step 2. Create new network config yaml file
vim /etc/netplan/01-netconfig.yaml

"Network configuration template"
network:
    version:2
    renderer: networkd
    ethernets:
        enp0s3: #change to the proper network interface id on the device
            dhcp4: false or true #set acordingly 
            addresses:
                -0.0.0.0/0 #input the ip and mask
            gateway4: "0.0.0.0" #inpute the gateway
            nameservers:
                addresses:#Inpute the correct DNS Servers
                    - "0.0.0.0"
                    - "0.0.0.0"
                    - "0.0.0.0"



