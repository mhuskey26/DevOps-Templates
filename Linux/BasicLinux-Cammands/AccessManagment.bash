#!/bin/bash

"---------Key files to beware of-----------------------------"

"etc/Passwd and etc/shadow"

#etc/passrd contains the contins basic infomation a user on the system
cat /etc/passwd
#How to read the etc/passwd file
Colum1 = username
Colum2 = password "should see an x if a password has been set, but if its blank then the user is setup login without a password"
Colum3 = userid
Colum4 = groupid
Colum5 = Comment
Colum6 = User home directory path "Defualt is /home/username/"
Colum7 = Defualt shell directory "Defualt is /bin/bash" "If this shows nologin or false then its user nolonger allowed to login"

#etc/shadow this stores the system user passwords in an ecypted format
cat /etc/shadow
#Reading the shadow file
Colum1 = Username
Colum2 = Password "Showing in an ecypted format"
Colum3-6 = show last changed/ and minume password settings
learn more with man shadow or shadow --help

"---------Monitoring Accounts and Access-----------------------------"

#To see what privalages and groups a user is in
id usernamer

#Resetting a account password
"Need to be run with sudo access"
passwd username

#Pull a list of all active users
who
"Adding -H add colume names to the details"
"Adding -aH adds more aditnial details about the logged in users"

#Pulls only the user you are logged in with
whoami

#Assume another user role
su username "You will need to know the password for the account you are assuming"

#Pulling log for current active users
cat /var/run/utmp

#Pull systme login history
cat /var/log/wtmp
or
ls -l /var/log/wtmp

#Pulling a listing of last logged in users
last
"You can also add a username to target the last login log for a targt user example last username"

"----------Managing Groups--------------------------"

# Creating a new Access Group
"Need to be run with sudo access"
groupadd groupname
or
addgroup groupname

#Get a list of all groups
less /etc/group

#See the list of groups for currently logged in user 
groups

#Get a list of groups a targeted user belongs to
groups username

#Removing a group
"Need to be run with sudo access"
groupdel groupname
or
delgroup groupname

#Modifying a group name
"Need to be run with sudo access"
groupmod -n currentname newname


"---------Managing Users-----------------------------"

#Reviewing the current login policy
less /etc/login.defs
or
cat /etc/login.defs "Preffered"

#Get a list of all users
cat /etc/passwd

#Edite the current login policy
vi /etc/login.defs

#Adding a new account
"Need to be run with sudo access"
useradd username
or
adduser username

#Configing new user account profile
"Need to be run with sudo access"
useradd -m #This creates the directory to the defualt
useradd -m -d /dir/path #This lets you create a custom home directory path
"Adding a -c "comment" after the path allows you to add a comment"
"Adding a -s /bin/bash sets the user to us the defualt bash config"
"-g groupname is for if you wish to cange there primary group from the defualt -- not a common practic"
"-G groupname,groupname,groupname - this allows you to add them to other groups like if you with to give them sudo or admin access"
"Before completeing at the veary end you will enter the username"
"Example" useradd -m /home/jsmith -s /bin/bash -G sudo,adm jsmith

#Setting a experation date to an account to auto disable
"Need to be run with sudo access"
useradd -e y-m-d username

#Change the exirationg date for users password
"Need to be run with sudo access"
chage username
"Add a -l to it to see the expartion date date and age example: chage -l userneame"

#Update or changing existing user account
"Need to be run with sudo access"
usermod
"Adding a -c "comment" after the path allows you to add a comment"
"Adding a -s /bin/bash sets the user to us the defualt bash config"
"-g groupname is for if you wish to cange there primary group from the defualt -- not a common practic"
"-aG groupname,groupname,groupname - this allows you to add them to other groups like if you with to give them sudo or admin access"
"Before completeing at the veary end you will enter the username" 
"Example" usermod -aG sudo,adm jsmith

#Setting up new admin accounts
"Need to be run with sudo access"
usermod -aG sudo username "For Ubuntu/Debian, note older versions of Ubuntu 16 and older the group is admin"
usermod -aG wheel username "For centOS/RedHat"


"----------Removing Users--------------------------"

#Removing user from the system
"Need to be run with sudo access"
userdel username
or
deluser username #Note this well delete any groups the user is in if they are the only user in that group, always check the groups and see if any will be removed by mistake
"Adding a -r will remove the users home directory example userdel -r username"

#Verify a user was removed
grep username /etc/passwd | grep ls /home/username


"----------Configuring File Permission--------------------------"

#There are three file type permissions in linux
r = read access
w = write access
x = execute access
"Note: root has complete access regardless of what the permissons say"

#Permissions number values
"When a number that represents the permission in base-8 can be a either a 3 or a 4-digit number with digits from 0-7. If 0 is the leading number it can be omitted."
- = 0
r = 4
w = 2
x = 1
"To determain the full octonation number for the permissions is to add the user, group, others. Example rw-rw-r--= 4+2+0, 4+2+0, 4+0+0 = 664"
#Break down, this is how you can determian the full number that reprasints the permissions set in octonation formate or base-8
rw- = 4+2+0=6 = User
rw- 4+2+0=6 = Group
r-- = 4+0+0=4 = others
Added together = "664"

#Pull files into list with there permissions
ls -l

#Look a target file and its permission in both octonation and symbolic
stat /dir/path

#Changing access permissons
"Need to be run with sudo access"
chmod 
"Add u for user then add a + or - to add or remove then add file path. Example lets add read, write, excute for a user" chmod u+rwx /file/path
"Add g for group then add a + or - to add or remove then add file path Example lets add read, write, excute for a group" chmod g+rwx /file/path
"Add o for other then add a + or - to add or remove then add file path Example lets remove read, write, excute for others" chmod o-rwx /file/path
"You can also change all the permissons at once example lets up date the permissons for all" chmod u+rwx,g+rwx,o+rwx /file/path
"A more simple way to update all or multiple you can use the following" chmod ug=rwx,o= /file/path "Here we just updated the user+group to have full and other to none"

#Changing permissons using octonation
chmod 000 /file/path
"Example chmod 644 /file/path will give the target rw=user,read=group and other"

#Apply permisson change to a target directory and all its files
"Need to be run with sudo access"
chmod -R 000 dir/ "This will apply the permisson to match the parent"

#Copy permissions from one file to another
"Need to be run with sudo access"
chmod --reference=/copyfromfile/path.type /copytofile/path.type

#Changing file ownership
"Need to be run with sudo access"
chown username file/path.type "You can add multple files paths and change multple files at the same time"

#Changing both the owner and group of file
"Need to be run with sudo access"
chown username:groupname file/paht.type

#Change the group owner for directory
"Need to be run with sudo access"
chgrp groupname /dir
"add -R to apply to all files in the directory" chgrp -R groupname ~/dir






