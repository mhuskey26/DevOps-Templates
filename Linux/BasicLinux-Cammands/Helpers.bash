"------------------------------------------------------------MAN PAGE----------------------------------------------------------#

"Man pages are helpful to learn more about a Linux CLI CMD they offer tetailed information on what you can do with it and all the commands associated with it."

#Access the man page for a cmd in linux
man #enter the comman
ex. man ls

#Navigation keys for man pages
Use the arrow keys to move up/down
# Move forward 1 page
Clt+f or space
#Move backwords
Clt+B
# Jump to the end
g
#Search
? then type /enteryourstring to seach for
# Open adidtion help info
h
# To exite
q

#Seach a man file for a specific cmd
man -k "cmd" 
example: man -k "copy files"
Returns all the cmds you can use to copy files

"-------------------------------------------------------------------------HELPER-------------------------------------------------------------------------#

"Not all cli cmds are in the man, like alias, umask extra to fined out if a cmd has a man papge or not simple do the following. But also all man cli commands can also be opened with the helper"

#Check if has a man page
type //then the cmd you want to fined
example: type df
returns: df is hashed (/usr/bin/df)
# Note if you get back (is a shell builtin) you will need to use the help command

#Using the help cmd
help (type command)
exaample: help cd
(returns the helper)
# you can also just add --help to the end of the cmd to open the helper, also not you can do this for man helpers as well
ls --help
cd --help

#cmd+TABx2 = Will show all the cmds for that command in a simple list
example rm then hidd TAB two times



