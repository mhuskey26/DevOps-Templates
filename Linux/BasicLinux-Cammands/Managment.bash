#!/bin/bash
"------Managing a Linux Server---------"

#Pulling CPU info
lscpu


"------Applying Updates and Patches---------"

#Fully update all install apps/packages
sudo apt full-upgrade -y

#Installing updates Amazon Linux/CentOS
sudo yum update 

#Installing updates Amazon Debian/Ubuntu
sudo apt update

#Applying patch fix to a config


"------Pulling Logs and Reports---------"

#Pulling a kernal logs in the RAM
dmesg

#Pulling a error log report stored in RAM
dmesg | grep error
"You can also search the log for any other type of string using the grep"
"If you just want to see an out of how many process are stored you can add a | wc -1 example: dmesg | wc"
"Say you want to look at an error and see the process that ran after it adding -A = After, 5=how many process example: dmesg | grep -A 5 error"
"Say you want to look at an error and see the process that ran before it -B=before, 5=how man proccess example: dmesg | grep -B 5 error"
"To pull both the before and after us -C=Pull both before/after, 5=how man proccess example: dmesg | grep -C 5 error"


"------Monitoring Processes-----------------"

#Reading the log

PID = Unique process identifer 
CPU = Pecent of the total processor power used
MEM = Percent of how much memory being used
VSZ = Virtual memory size in KB
RSS = Size of the phasical memory being used
STAT = Process state "S=sleeping, R=running, Z=Zombie, T=Stopped, Ideial" "The secound letter means <=High Proity, N=Low Proity"
TTY = The terminal intailizing the process
TIME = CPU Run time 
CMD = Command name used to start the process

#Finding infomation about running process
pgstree

#Pull list of most commonely ran processes
pgstree top

#Show list of only currently running processes
ps 
"Added -f or -ef will show more details about the processes"

#Output the log into a read only list
ps aux | less

#Finding our how many total processes are running
ps -ef | wc -l

#Sorting processes 
ps aux --sort="sort option"
"Example" ps aux --sort=%mem | less "Pull the list of process items"
"You can add - to sort the sorted list in decending order" ps aux --sort=-%mem | less

#Check if a process is running
pgrep -l processname
"Example" pgrep -l sshd
or
ps -ef | grep "process name"
"Example" ps -ef | grep sshd

#Look for a process owned by a user
pgrep -u username processname
"example" pgrep -u root sshd

#Pull an active montioring of the linux system
top
"Monitor keys"
d = change refreash rate "Defual it every 3 seconds, lowest setting can be 1secound"
space = mannually refreash
y = highlight the running processes
x = highlights the colums of the running processes
b = highlights both the running and the colums
< or > = to highlight a colum row
r = changes sort order between acending and decending
e = changes the sort by byte size either in kb, mb, gb, tb, etc
q = exits the monitor


"------Killing a Process-----------------"

#Pull a list of the kill signs "defual is 15=SIGTERM"
kill -l

#Finding the PID of a process you wish to kill
pidof application name
"example" pidof firefox

#Killing a process by PID
kill -signlenumber processPID "Not you have to have the Process ID or PID"
"Example" kill -2 21930 "example of killing a open text editor"
"Note to kill multiple processes at once just add the pid with space between them"

#Killing a process and autofill there pids
kill -signlenumber $(pidof appname)
"Example" kill -2 $(pidof firefox)

#To simply kiall all the process for processes running
killall -15 nameofcommand/process
"Example" killall -15 firefox


"------Managing a Service-----------------"

"Options are"
status = checks status of service
restart = restarts a service
stop = stops a service
start = starts a service

#Restarting a service using systemctl
"Need to be run with sudo access"
systemctl serviceoption servicename
"Example" systemctl status ssh

#Reseting a service like SSH using kill
kill -1 processPID

"------Forgound vs Backgroup Processes/Jobs-----------------"

Forground = processes started by a user
Backgroup = system processed started by the system

#Creating a new process
processname processtorun
"example" sleep 20

#Creating a new background process
processname processtorun &
"example" sleep 20 &

#Pulling active running jobs
jobs
"Adding the -l will show the PID"

#Bring a job to the fouground
fb %"jobid" 
"Example" fb %1

#Stopping/Pausing a job
jobcmd "then hit clt+z"

#Restrating a pasued/stopped job
"Restart in background"
bg %"jobid"
"Restart in forground"
fg %"jobid"

#Start a job/process and make sure it will run after the cli is closed
nohup "command/jobtorun"