"----Get Command Helps you fined commands-----"

#Pull a list of all the availble get commands
Get-Command *
"To norrow down you search to finded commands for a type of command you can inclose the target command type between two *target*"
"example" Get-Command *process*

#Get more information regarding a Get command
Get-Help "Command to get info on"
"Example" Get-Help Stop-Process
"To get a list of examples for using this just add -Examples"

#Getting more info on Get-commands and there propertise
Get-"Command" | Get-Member
"example" Get-Date | Get-Member

#Keeping the help tool updated
update-help

#Types of get commands
Send
Set
Process
Split
Start
Stop
Suspend
Sync
Test
Unblock
Trace
Unpublish
Unregister
Update
Wait
Where
Write

"------------Example----------------------"

#____________________________________________________________
# https://techthoughts.info/learn-and-use-powershell-with-just-three-commands/
#____________________________________________________________
# your first cmdlet - getting timezone information

Get-TimeZone
#____________________________________________________________
# Get-Command

Get-Command *
# An asterisk (*) in many languages acts as a wildcard. This syntax is saying: get me ALL of the commands

Get-Command *process*
# the wild cards around process will find ANY command that contains the word process

# Get-Command can't always find everything, you may have to Google
Get-Command *file*
#____________________________________________________________
# Get-Help

# Windows Users:
Get-Help Stop-Process
#Linux/MacOs Users
Get-Help Stop-Process -Online

Get-Help Stop-Process -Examples
#____________________________________________________________
# Get-Member

Get-Date | Get-Member

Get-Random | Get-Member
#____________________________________________________________
# Expand the available viewable properties of a cmdlet with Format-List

Get-Date | Format-List
#____________________________________________________________
# Find-Module

Find-Module -Tag Telegram
#____________________________________________________________