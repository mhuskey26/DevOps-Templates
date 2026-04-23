# LINUX USER/GROUP/ACCESS MANAGEMENT QUICK CLI SHEET
# Focus: users, groups, permissions, access auditing

# Index:
# 1) Account and Access Files
# 2) Audit and Session Monitoring
# 3) User Management
# 4) Group Management
# 5) Password and Account Policy
# 6) Admin and Privilege Access
# 7) File Permissions and Ownership
# 8) Permission Levels and Settings
# 9) ACL Access Control


# ---------------------------------------------------------------------------
# 1) ACCOUNT AND ACCESS FILES
# ---------------------------------------------------------------------------

# Local account database
cat /etc/passwd

# Password hashes and aging data (root only)
sudo cat /etc/shadow

# Group database
cat /etc/group

# Default password/login policy
cat /etc/login.defs

# Sudo policy
sudo visudo
sudo ls -l /etc/sudoers.d


# ---------------------------------------------------------------------------
# 2) AUDIT AND SESSION MONITORING
# ---------------------------------------------------------------------------

# Current user and identity
whoami
id
id USERNAME

# Logged-in users
who
who -aH
w

# Login history
last
last USERNAME
lastb

# Failed and auth events (common locations)
sudo journalctl -u ssh
sudo tail -n 100 /var/log/auth.log
sudo tail -n 100 /var/log/secure


# ---------------------------------------------------------------------------
# 3) USER MANAGEMENT
# ---------------------------------------------------------------------------

# Create users
sudo useradd USERNAME
sudo useradd -m -s /bin/bash USERNAME
sudo useradd -m -d /home/CUSTOM_HOME -s /bin/bash -c "Full Name" USERNAME
sudo adduser USERNAME

# Set/reset password
sudo passwd USERNAME

# Modify users
sudo usermod -c "Full Name" USERNAME
sudo usermod -s /bin/bash USERNAME
sudo usermod -d /new/home/path -m USERNAME
sudo usermod -e YYYY-MM-DD USERNAME

# Lock/unlock user login
sudo usermod -L USERNAME
sudo usermod -U USERNAME

# Remove users
sudo userdel USERNAME
sudo userdel -r USERNAME
sudo deluser USERNAME

# Verify account exists
getent passwd USERNAME


# ---------------------------------------------------------------------------
# 4) GROUP MANAGEMENT
# ---------------------------------------------------------------------------

# Create groups
sudo groupadd GROUPNAME
sudo addgroup GROUPNAME

# View groups
getent group
groups
groups USERNAME

# Rename and remove groups
sudo groupmod -n NEW_GROUP OLD_GROUP
sudo groupdel GROUPNAME
sudo delgroup GROUPNAME

# Set primary group
sudo usermod -g GROUPNAME USERNAME

# Add/remove supplementary groups
sudo usermod -aG GROUP1,GROUP2 USERNAME
sudo gpasswd -d USERNAME GROUPNAME


# ---------------------------------------------------------------------------
# 5) PASSWORD AND ACCOUNT POLICY
# ---------------------------------------------------------------------------

# Show aging policy for user
sudo chage -l USERNAME

# Set min/max password days and warning period
sudo chage -m 1 -M 90 -W 14 USERNAME

# Force password reset at next login
sudo chage -d 0 USERNAME

# Set/clear account expiration
sudo chage -E YYYY-MM-DD USERNAME
sudo chage -E -1 USERNAME


# ---------------------------------------------------------------------------
# 6) ADMIN AND PRIVILEGE ACCESS
# ---------------------------------------------------------------------------

# Grant sudo (Ubuntu/Debian)
sudo usermod -aG sudo USERNAME

# Grant sudo (RHEL/CentOS/Fedora)
sudo usermod -aG wheel USERNAME

# Verify sudo access
sudo -l -U USERNAME

# Switch user context
su - USERNAME
sudo -u USERNAME -s


# ---------------------------------------------------------------------------
# 7) FILE PERMISSIONS AND OWNERSHIP
# ---------------------------------------------------------------------------

# View permissions and ownership
ls -l /path/to/file
stat /path/to/file

# Symbolic chmod examples
chmod u+rwx /path/to/file
chmod g+rw /path/to/file
chmod o-rwx /path/to/file
chmod ug=rwx,o= /path/to/file

# Numeric chmod examples
chmod 644 /path/to/file
chmod 755 /path/to/script.sh
chmod -R 750 /path/to/directory

# Copy permissions from reference file
chmod --reference=/path/from.file /path/to.file

# Change owner/group
sudo chown USERNAME /path/to/file
sudo chown USERNAME:GROUPNAME /path/to/file
sudo chown -R USERNAME:GROUPNAME /path/to/directory
sudo chgrp GROUPNAME /path/to/file
sudo chgrp -R GROUPNAME /path/to/directory


# ---------------------------------------------------------------------------
# 8) PERMISSION LEVELS AND SETTINGS
# ---------------------------------------------------------------------------

# Basic permission values
# r = 4, w = 2, x = 1, - = 0

# Scope order in chmod numeric mode: user, group, others
# Example: 750 => user(rwx)=7, group(rx)=5, others(---)=0

# Common file permission levels
# 600 = rw------- (owner read/write)
# 640 = rw-r----- (owner read/write, group read)
# 644 = rw-r--r-- (common for regular files)
# 660 = rw-rw---- (shared group write)

# Common directory permission levels
# 700 = rwx------ (private directory)
# 750 = rwxr-x--- (owner full, group read/execute)
# 755 = rwxr-xr-x (common for directories)
# 770 = rwxrwx--- (team-shared directory)

# Special permission bits (leading octal digit)
# 4xxx = SUID, 2xxx = SGID, 1xxx = Sticky

# SUID example (runs with file owner permissions)
chmod 4755 /path/to/binary

# SGID examples
chmod 2755 /path/to/binary
chmod 2775 /path/to/directory

# Sticky bit example (common on shared write dirs like /tmp)
chmod 1777 /path/to/directory

# View permissions in symbolic and numeric form
ls -l /path/to/file_or_dir
stat -c "%A %a %n" /path/to/file_or_dir


# ---------------------------------------------------------------------------
# 9) ACL ACCESS CONTROL (EXTENDED PERMISSIONS)
# ---------------------------------------------------------------------------

# View ACL
getfacl /path/to/file_or_dir

# Grant ACL to a specific user/group
sudo setfacl -m u:USERNAME:rwx /path/to/file_or_dir
sudo setfacl -m g:GROUPNAME:rx /path/to/file_or_dir

# Set default ACL on a directory (new files inherit)
sudo setfacl -d -m g:GROUPNAME:rwx /path/to/directory

# Remove ACL entries
sudo setfacl -x u:USERNAME /path/to/file_or_dir
sudo setfacl -b /path/to/file_or_dir







