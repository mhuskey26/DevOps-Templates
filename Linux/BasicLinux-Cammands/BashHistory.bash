#!/bin/bash
------------------------------------------------------------------Linux Bash---------------------------------------------------------------------------------------#

#Defualt on linux where bash files are stored
cat .bash_history

-----------------------------------------------------------------Pulling Bash History-------------------------------------------------------------------------------#

#To see the history of past cmds ran open the bash history file, note you will not see the most recent cmds ran those are stored in the memory
cat .bash_history

#See the history of most recent bash cmds recently ran that are stored in memory, these cmds are moved to the history file after logout or when max is hit
history

------------------------------------------------------------------Checking Bash Storage Settings---------------------------------------------------------------------#

#See how many bash cmds will be stored in history max
echo $HISTFILESIZE

#See how many bash cmds will be stored in Memory Max
echo $HISTSIZE

----------------------------------------------------------------------Using Bash History-----------------------------------------------------------------------------#

# Rerun a past cmd from history
!+the line number in the history
example: !15 will rerun what cmd is in the line 15 history

# To quickly rerun the last cmd
!!

# Run cmd from bash historyfile
!-line number
example: !-15

# You can also rerun the last cmd by command name from history
!+cmdname
example:!ping this will rerun the last ping cmd ran in the history

# Apend a cmd from history to see what was run
!+cmd:p
example:!ping:p
result will show you what the cmd was before you rerun the cmd

------------------------------------------------------------------------Updating Bash History---------------------------------------------------------------------------#

# Remove a cmd from history
history -d +linenubmer
example: history -d 15 this will remove the stored cmd from the history

# To clear the full history
history -c

# You can edit the bash history file to not log cmd events

#To see what the config for the HISTCONTROL
echo $HISTCONTROL

#Set to inqnor arrow ups
HISTCONTROL=ingnoreups

#Set to inqnor space
HISTCONTROL=ingnorepace

#Set it to inqnore two make sure to input the following cmd afterwords
HISTCONTROL=ingnoreboth

#Log Data and Time for bash history
HISTTIMEFORMAT="%d/%m/%y %T"

#Save bash configs
echo "HISTTIMEFORMAT="%d/%m/%y %T"" >> .bashrc
