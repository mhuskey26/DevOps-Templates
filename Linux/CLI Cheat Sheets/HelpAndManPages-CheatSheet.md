# LINUX HELP AND MAN PAGES QUICK CLI SHEET
# Focus: discover commands, read docs, and navigate help effectively

# Index:
# 1) Find Command Documentation
# 2) Use Man Pages
# 3) Man Page Navigation Keys
# 4) Built-in Shell Help
# 5) Command Discovery


# ---------------------------------------------------------------------------
# 1) FIND COMMAND DOCUMENTATION
# ---------------------------------------------------------------------------

man ls
ls --help
info ls

# Search man page database by keyword
man -k "copy files"
apropos "network interface"

# Show short description for a command
whatis tar


# ---------------------------------------------------------------------------
# 2) USE MAN PAGES
# ---------------------------------------------------------------------------

# Open section-specific man page
man 5 passwd
man 8 useradd

# Open all matches for a command
man -a passwd

# Show where man looks for pages
manpath


# ---------------------------------------------------------------------------
# 3) MAN PAGE NAVIGATION KEYS
# ---------------------------------------------------------------------------

# Move down/up one line
# ArrowDown / ArrowUp

# Move one page forward/back
# Space / b

# Jump to start/end
# g / G

# Search forward/backward
# /pattern
# ?pattern

# Next/previous match
# n / N

# Quit man page
# q


# ---------------------------------------------------------------------------
# 4) BUILT-IN SHELL HELP
# ---------------------------------------------------------------------------

# Check command type
# (binary, alias, function, builtin)
type cd
type ls

# Show shell builtin help
help cd
help history

# More detail for commands in PATH
command -V ls
which ls


# ---------------------------------------------------------------------------
# 5) COMMAND DISCOVERY
# ---------------------------------------------------------------------------

# List shell builtins
help

# List available commands containing text
compgen -c | grep "ssh"

# Tab completion tip
# Press Tab twice to list possible completions
