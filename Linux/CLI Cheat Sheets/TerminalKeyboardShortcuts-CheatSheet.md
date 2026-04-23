# LINUX TERMINAL KEYBOARD SHORTCUTS QUICK CHEAT SHEET
# Focus: editing commands, navigation, process control, and search

# Index:
# 1) Auto-Complete and Suggestions
# 2) Cursor Movement
# 3) Edit Command Line
# 4) Process Control
# 5) History Navigation and Search
# 6) Terminal Control


# ---------------------------------------------------------------------------
# 1) AUTO-COMPLETE AND SUGGESTIONS
# ---------------------------------------------------------------------------

# Tab completion
# Tab         -> complete command/path if unique
# Tab Tab     -> list all possible completions


# ---------------------------------------------------------------------------
# 2) CURSOR MOVEMENT
# ---------------------------------------------------------------------------

# Ctrl+a      -> move to start of line
# Ctrl+e      -> move to end of line
# Alt+b       -> move back one word
# Alt+f       -> move forward one word


# ---------------------------------------------------------------------------
# 3) EDIT COMMAND LINE
# ---------------------------------------------------------------------------

# Ctrl+u      -> cut from cursor to line start
# Ctrl+k      -> cut from cursor to line end
# Ctrl+w      -> cut previous word
# Ctrl+y      -> paste last cut text
# Ctrl+l      -> clear terminal screen


# ---------------------------------------------------------------------------
# 4) PROCESS CONTROL
# ---------------------------------------------------------------------------

# Ctrl+c      -> stop current foreground command
# Ctrl+z      -> suspend current foreground command
# jobs        -> list suspended/background jobs
# fg %1       -> resume job in foreground
# bg %1       -> resume job in background


# ---------------------------------------------------------------------------
# 5) HISTORY NAVIGATION AND SEARCH
# ---------------------------------------------------------------------------

# Up/Down     -> navigate command history
# Ctrl+r      -> reverse history search
# Ctrl+g      -> cancel history search
# !!          -> repeat last command


# ---------------------------------------------------------------------------
# 6) TERMINAL CONTROL
# ---------------------------------------------------------------------------

# Ctrl+d      -> logout/close shell (if line is empty)
# Ctrl+s      -> freeze terminal output
# Ctrl+q      -> unfreeze terminal output
# reset       -> recover broken terminal state