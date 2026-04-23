# LINUX SYSTEM MANAGEMENT QUICK CLI SHEET
# Focus: system info, updates, logs, processes, services, and jobs

# Index:
# 1) System Information
# 2) Updates and Patch Management
# 3) Logs and Diagnostics
# 4) Process Monitoring
# 5) Process Control
# 6) Service Management
# 7) Foreground and Background Jobs


# ---------------------------------------------------------------------------
# 1) SYSTEM INFORMATION
# ---------------------------------------------------------------------------

uname -a
hostnamectl
lscpu
free -h
uptime


# ---------------------------------------------------------------------------
# 2) UPDATES AND PATCH MANAGEMENT
# ---------------------------------------------------------------------------

# Debian/Ubuntu
sudo apt update
sudo apt full-upgrade -y

# RHEL/CentOS/Fedora
sudo dnf update -y
sudo yum update -y


# ---------------------------------------------------------------------------
# 3) LOGS AND DIAGNOSTICS
# ---------------------------------------------------------------------------

# Kernel and boot logs
dmesg
journalctl -k
journalctl -b

# Search errors
dmesg | grep -i error
journalctl -p err -b

# Context around matches
dmesg | grep -i -A 5 -B 5 error

# Count log lines
dmesg | wc -l


# ---------------------------------------------------------------------------
# 4) PROCESS MONITORING
# ---------------------------------------------------------------------------

ps
ps -ef
ps aux | less
pstree
pstree -p

# Count running processes
ps -ef | wc -l

# Sort by CPU or memory
ps aux --sort=-%cpu | head
ps aux --sort=-%mem | head

# Find process by name/user
pgrep -l sshd
pgrep -u root sshd
pidof sshd

# Interactive monitor
top
htop


# ---------------------------------------------------------------------------
# 5) PROCESS CONTROL
# ---------------------------------------------------------------------------

# List signal numbers and names
kill -l

# Graceful terminate (SIGTERM=15)
kill -15 PID

# Force kill (SIGKILL=9)
kill -9 PID

# Kill by process name
killall -15 PROCESS_NAME
pkill -f "process_pattern"


# ---------------------------------------------------------------------------
# 6) SERVICE MANAGEMENT
# ---------------------------------------------------------------------------

# Service status/start/stop/restart
sudo systemctl status SERVICE_NAME
sudo systemctl start SERVICE_NAME
sudo systemctl stop SERVICE_NAME
sudo systemctl restart SERVICE_NAME

# Enable/disable at boot
sudo systemctl enable SERVICE_NAME
sudo systemctl disable SERVICE_NAME

# Service logs
journalctl -u SERVICE_NAME
journalctl -u SERVICE_NAME -f


# ---------------------------------------------------------------------------
# 7) FOREGROUND AND BACKGROUND JOBS
# ---------------------------------------------------------------------------

# Start foreground job
sleep 30

# Start background job
sleep 30 &

# List jobs
jobs
jobs -l

# Bring jobs to foreground/background
fg %1
bg %1

# Pause running foreground job
# Ctrl+z

# Keep process running after logout
nohup COMMAND > output.log 2>&1 &

disown -h %1
