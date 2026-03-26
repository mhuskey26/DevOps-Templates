----------------------------------------------------------------------Top most common cammands to know-------------------------------------------------------------------------------------#

sudo #Run commands as root
grep #On of the most useful commands is Grep man grep for more or grep --help
ls #List all files/directory in a directory learn more man ls or ls --help
man or --Help #When needing to know more about a command and the ways you can use it


--------------------------------------------------------------------Running As Root---------------------------------------------------------------------------------------------------#

# If you need to run cmds that requre Root access and you are an admin/ have access to root privlages you can us the following
sudo su

# If you need to be in the full root access (Use on limited base)
sudo su -

# After you run a sudo you can run the following and make it where you don't have to enter sudo to run a sudo command for 5 minutes
sudo -v

# To clear the sudo catch and force a password vaildation next time running sudo
sudo -k

# Setting password for user accounts
sudo passwd username

# To login as root in terminal
su

------------------------------------------------------------------Power Managment---------------------------------------------------------------------------------#

#Resooting and powing off
reboot
shutdown

-----------------------------------------------------------------Installing Apps and Patches---------------------------------------------------------------------#

#Fully update all install apps/packages
sudo apt full-upgrade -y

#Installing updates Amazon Linux/CentOS
sudo yum update 

#Installing updates Amazon Debian/Ubuntu
sudo apt update

# Install modules/apps to Debian/Ubuntu
sudo apt install

-----------------------------------------------------------------------Special Commands------------------------------------------------------------------------------------#

#Linux PIPE (PIPING is usefule to combine more then one command) much like CICD Piplien its a list of steps to take to achive a goal
| #Adding this between each cammand you want to run from 1st-last is a greate way to run specifice commands to achive a task
Example we just want to get the header info for dir: ls -lSh /dir/ | head

#Redirection will redirect the output of file or command
> #Adding this to the end of your command tells the system to send the output somewhere lese like file
Example: ifconig > /dir/text.txt #Note if the file dosn't exist it will create the file, if it dose it will overwrite the current file to avoid this you can make a new file or add a 
>>
Example: ifcong >> /dir/text.txt


----------------------------------------------------------------------Miscellaneous-------------------------------------------------------------------------------------#
# Clears the terminal
clear

# Find out what defualt shell of the linux OS
ps

#To auto aprove any install you can add a at the end the command
-y

# Get the state of download
wget +urlpath the download is coming from
example: wget https://example.com/download

#On of the most useful commands is Grep man grep for more or grep --help
grep





