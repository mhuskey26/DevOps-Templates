#Setup a SFTP Server Config on ubuntu

#Intial Setup
sudo -s 
apt update -y
apt-get install awscli -y

#Creating access group
groupadd sftpaccess

#Modify and setp VIM Config
sudo vim /etc/ssh/sshd_config

#Add to VIM Config file
Match Group sftpaccess
    ForceCommand internal-sftp
    PasswordAuthentication yes
    ChrootDirectory %h
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding no
    X11Forwarding no

#Restart SSH
sudo service ssh restart
sudo reboot


# Setting up new user for SFTP

# Adding user and user directory
adduser --shell /bin/false sftptest
mkdir -p /mnt/efs/fs1/SFTP/username/files
cd /mnt/efs/fs1/SFTP/username/files
chown usert:user /mnt/efs/fs1/SFTP/username/files
chown root:root /mnt/efs/fs1/SFTP/username/files
chmod 755 /mnt/efs/fs1/SFTP/username/files

# Adding to access group
usermod -aG sftpaccess username
