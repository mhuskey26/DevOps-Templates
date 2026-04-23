# LINUX ESSENTIAL TOOLS QUICK CLI SHEET
# Focus: install and use practical admin tools

# Index:
# 1) SSH Tools
# 2) Network Tools
# 3) File/Directory Tools
# 4) Locate Database Tools
# 5) Monitoring and Utility Tools


# ---------------------------------------------------------------------------
# 1) SSH TOOLS
# ---------------------------------------------------------------------------

# Debian/Ubuntu
sudo apt update
sudo apt install openssh-server -y

# RHEL/CentOS/Fedora
sudo dnf install openssh-server -y
sudo yum install openssh-server -y

# Check and enable SSH service
sudo systemctl status ssh
sudo systemctl status sshd
sudo systemctl enable --now sshd


# ---------------------------------------------------------------------------
# 2) NETWORK TOOLS
# ---------------------------------------------------------------------------

# Net-tools package (ifconfig, netstat, route)
sudo apt install net-tools -y
sudo dnf install net-tools -y
sudo yum install net-tools -y

# Modern alternatives
ip addr
ss -tulnp


# ---------------------------------------------------------------------------
# 3) FILE/DIRECTORY TOOLS
# ---------------------------------------------------------------------------

# tree tool
sudo apt install tree -y
sudo dnf install tree -y
sudo yum install tree -y

tree /path/to/dir
tree -d /path/to/dir
tree -L 2 /path/to/dir


# ---------------------------------------------------------------------------
# 4) LOCATE DATABASE TOOLS
# ---------------------------------------------------------------------------

# Install locate (plocate/mlocate depending on distro)
sudo apt install plocate -y
sudo apt install mlocate -y
sudo dnf install mlocate -y
sudo yum install mlocate -y

# Build/update locate database
sudo updatedb

# Locate files
locate ssh_config
locate -i password
locate -b "\\passwd"
locate -e /etc/passwd
locate -S


# ---------------------------------------------------------------------------
# 5) MONITORING AND UTILITY TOOLS
# ---------------------------------------------------------------------------

# htop (interactive process viewer)
sudo apt install htop -y
sudo dnf install htop -y
sudo yum install htop -y
htop

# ncdu (disk usage explorer)
sudo apt install ncdu -y
sudo dnf install ncdu -y
sudo yum install ncdu -y
ncdu /path/to/dir

# ripgrep (fast text search)
sudo apt install ripgrep -y
sudo dnf install ripgrep -y
sudo yum install ripgrep -y
rg "search_text" /path/to/dir
