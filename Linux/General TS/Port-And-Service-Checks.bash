#!/bin/bash

# PORT AND SERVICE TROUBLESHOOTING
# Copy and paste the commands you need into a Linux terminal.

# ---------------------------------------------------------------------------
# 1) SEE WHAT IS LISTENING
# ---------------------------------------------------------------------------

sudo ss -tulnp
sudo netstat -tulnp
sudo lsof -i -P -n


# ---------------------------------------------------------------------------
# 2) TEST CONNECTIVITY TO A REMOTE PORT
# ---------------------------------------------------------------------------

# Replace TARGET_HOST and PORT.
nc -zv TARGET_HOST PORT
telnet TARGET_HOST PORT
curl -I http://TARGET_HOST
curl -I https://TARGET_HOST


# ---------------------------------------------------------------------------
# 3) CHECK A LOCAL SERVICE
# ---------------------------------------------------------------------------

# Replace SERVICE_NAME.
sudo systemctl status SERVICE_NAME --no-pager
sudo journalctl -u SERVICE_NAME -n 100 --no-pager
sudo systemctl restart SERVICE_NAME


# ---------------------------------------------------------------------------
# 4) FIREWALL RULE VALIDATION
# ---------------------------------------------------------------------------

sudo ufw status numbered
sudo firewall-cmd --list-ports
sudo firewall-cmd --list-services
sudo iptables -S


# ---------------------------------------------------------------------------
# 5) VERIFY BIND ADDRESS ISSUES
# ---------------------------------------------------------------------------

# Look for localhost-only binds such as 127.0.0.1:PORT.
sudo ss -tulnp | grep LISTEN
