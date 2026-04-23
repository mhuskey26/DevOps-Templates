# LINUX BASH HISTORY QUICK CLI SHEET
# Focus: view, search, rerun, and control command history

# Index:
# 1) View History
# 2) Storage and Limits
# 3) Re-run Commands
# 4) Search and Edit History
# 5) Privacy and Cleanup
# 6) Persistent Bash History Settings


# ---------------------------------------------------------------------------
# 1) VIEW HISTORY
# ---------------------------------------------------------------------------

history
cat ~/.bash_history
history 50


# ---------------------------------------------------------------------------
# 2) STORAGE AND LIMITS
# ---------------------------------------------------------------------------

# Number of commands kept in memory
echo $HISTSIZE

# Number of commands saved to file
echo $HISTFILESIZE

# Location of history file
echo $HISTFILE


# ---------------------------------------------------------------------------
# 3) RE-RUN COMMANDS
# ---------------------------------------------------------------------------

# Re-run command by history number
!15

# Re-run previous command
!!

# Re-run command N commands ago
!-3

# Re-run most recent command starting with text
!ping

# Print command without executing
!ping:p


# ---------------------------------------------------------------------------
# 4) SEARCH AND EDIT HISTORY
# ---------------------------------------------------------------------------

# Search history output
history | grep "ssh"

# Interactive reverse search (keyboard)
# Ctrl+r then type search text

# Delete specific history entry
history -d 15

# Clear current shell history list
history -c

# Write current in-memory history to file now
history -w

# Append current in-memory history to file
history -a

# Reload history file into current shell
history -r


# ---------------------------------------------------------------------------
# 5) PRIVACY AND CLEANUP
# ---------------------------------------------------------------------------

# Do not record duplicate or space-prefixed commands
export HISTCONTROL=ignoreboth

# Ignore selected commands
export HISTIGNORE="ls:pwd:history"

# Disable history for current session
set +o history

# Re-enable history
set -o history


# ---------------------------------------------------------------------------
# 6) PERSISTENT BASH HISTORY SETTINGS
# ---------------------------------------------------------------------------

# Add timestamp format for history output
echo 'HISTTIMEFORMAT="%F %T "' >> ~/.bashrc

# Recommended defaults
echo 'HISTSIZE=5000' >> ~/.bashrc
echo 'HISTFILESIZE=10000' >> ~/.bashrc
echo 'HISTCONTROL=ignoreboth' >> ~/.bashrc

echo 'PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"' >> ~/.bashrc

# Apply changes
source ~/.bashrc
