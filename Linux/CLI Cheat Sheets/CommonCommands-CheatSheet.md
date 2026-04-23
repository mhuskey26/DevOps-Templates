# LINUX COMMON COMMANDS QUICK CLI SHEET
# Focus: daily core commands, privilege, updates, and command chaining

# Index:
# 1) Core Daily Commands
# 2) Working with Root/Sudo
# 3) Power Commands
# 4) Package Updates and Installs
# 5) Pipes and Redirection
# 6) Useful Misc Commands


# ---------------------------------------------------------------------------
# 1) CORE DAILY COMMANDS
# ---------------------------------------------------------------------------

ls
pwd
cd /path/to/dir
cat /path/to/file
grep "text" /path/to/file
man ls
ls --help


# ---------------------------------------------------------------------------
# 2) WORKING WITH ROOT/SUDO
# ---------------------------------------------------------------------------

# Run one command as root
sudo COMMAND

# Open root shell (use carefully)
sudo su -

# Refresh sudo timestamp
sudo -v

# Invalidate sudo timestamp
sudo -k

# Set password for a user
sudo passwd USERNAME


# ---------------------------------------------------------------------------
# 3) POWER COMMANDS
# ---------------------------------------------------------------------------

# Reboot now
sudo reboot

# Shutdown now
sudo shutdown now

# Schedule shutdown in 10 minutes
sudo shutdown +10


# ---------------------------------------------------------------------------
# 4) PACKAGE UPDATES AND INSTALLS
# ---------------------------------------------------------------------------

# Debian/Ubuntu
sudo apt update
sudo apt full-upgrade -y
sudo apt install PACKAGE_NAME -y

# RHEL/CentOS/Fedora (dnf/yum depending on distro)
sudo dnf update -y
sudo dnf install PACKAGE_NAME -y
sudo yum update -y
sudo yum install PACKAGE_NAME -y


# ---------------------------------------------------------------------------
# 5) PIPES AND REDIRECTION
# ---------------------------------------------------------------------------

# Pipe output to another command
ls -lh /var/log | head

# Overwrite output file
ip addr show > /tmp/ip.txt

# Append output file
ip addr show >> /tmp/ip.txt

# Redirect stderr
command 2> /tmp/error.log

# Redirect stdout + stderr
command > /tmp/all.log 2>&1


# ---------------------------------------------------------------------------
# 6) USEFUL MISC COMMANDS
# ---------------------------------------------------------------------------

clear
whoami
uname -a
hostnamectl
wget https://example.com/file
curl -I https://example.com
