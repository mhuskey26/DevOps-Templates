"--Common Linux directories----------------------------------------------------"
root/
/bin
/boot
/dev
/etc
/home
/lib
/media
/mnt
/opt
/proc
/root
/srv
/sys
/tmp
/usr
/var

"--Common Linux sub-directories-------------------------------------------------"
/usr/bin
/usr/include
/usr/lib
/usr/local
/usr/sbin
/usr/src
/var/cache
/var/lib
/var/log
/var/log
/var/mail
/var/spool
/var/tmp

"--Inode--------------------------------------------------------------------------------"
"Each file on the disk has a data structure called index node or inode associated with it"

#To get the Inode number when quering
ls -i /dir/ "The first colume is the Inode number"

"-----Reading LS file formate Output--------------------------------------------------------------------------"

#Colume 1 = the file type
- = normal
b = block Device
c = Char Device
d = Directory
l = Link (shortcut)
s = Socket
p = Named Pip
#Columes 2-9 = file permissions for the owner and group owner
r = read
w = write
x = excute
- = none
#Colume 10 = Number of hard links
#Colume 11 = The Owner
#Colume 12 = The Group
#Colume 13 = Size (in KB)
#Colume 14-16 = Time/Date last modified
#Colume 17 = File Name

"--Changing directory------------------------------------------------------------------------------------"

# this is used to change the directory
cd /dir/

#Reset back to root directory
cd

# Print or fined out what directory you are currently working in
pws

"--Listing/Finding file paths-----------------------------------------------------------------------------"

#Show just he current files in the current directory in a A-Z order
ls

#List all Linux directories (ROOT NOT Included)
ls /

#List all directories in single target A-Z order
ls /dir/

#List all directories in multipl targets in with current A-Z order
ls /dir/ /dir/
#With current included
ls /dir/ /dir/ .
#In list formate
ls -l /dir/ /dir/

#List only the file directory in list formate
ls -l

#List all diretories in a target in list formate
ls -l /dir/

#List all recently update/changed files and directories
ls --all
ls -a

#List all diretories including hidden in list formate
ls -la

#List all directories and short them by size
ls -lS
#Formate size to KB
ls -lh /
#See the full size a target directory
du -sh /dir/
#See all file sizes in a target directory
ls -sh /dir/

#list all files including hidden in a users directory
ls -a ~

#List primary files in target directory
ls -l /dir/path

#List all files in target directory
ls -l -all -h /dir/pathls

#Pull the appsolut path for a directory
ls ..
ls ../..

#Sorting by mtime
ls -lt
#Sort by atime
ls -ltu
#Sort by name but shows atime
ls -lu

"---Searching for files--------------------------------------------------"

#Finded is useful for fined the full path of target file
find . -name filename

#Finded a file in a target dir
find /dir/ -name filename

#Finded a file and delete it
find . -name filename -delete
or
find /dir/ -name filename -delete

#To list all files the finder finds that match the search
find . -name filename -ls

#Look for file in target directory
find /dir/ -name filename -ls

#Using the find cmd to look for a file using the Inode
find . -inum 0 "Look under the Inode section to fined out how to get the inode for a file"

#Look for directory 
-type d 
"Example: find /dir/ -type d = find all in target that are a directory type"

#Specify how deep it should look
find /dir/ -type d -maxdepth *
"Note: if you with to do a deep seach into the target dir add -maxdeth and then specify how deep 1=on-dir deep=search on sub-dir deep"

#Look for dir with specified permission type
-perm 0
"Example: find /dir/ -type d -maxdepth 3 -perm 755 = find all direrctories that have perssion level 755"

#Find by size
find /dir -type f -size 0k -ls
"Tips for searching by size"
"using a + or - then the size with a k, M, G, T attached you can narrow you search down + means greater and - means less then"

#Find files by atime in the last 24 hours
find /dir/ -type f -atime -ls
"If you wish to find files that have been access furthur back then adding + then specifed number of days to look back on"
"Example: find /dir/ -type f -atime +1 -ls= look for files that atime for the past 48 hours"

#Find files by mtime
find /dir/ -type f -mtime 0

#look for files last modified or accessed within the last hour
find /dir/ -type f -mmin -60 -ls "Whis means it will look for files last modified/accessed within the last 60 minutes"

#Look for files by user or group
"user" find /dir/ -type f -user username -ls
"group" find /dir/ -type f -group groupname -ls
"Note if you add a -not you can look for files not belonging to a user or group"

#Using the grep cammand to search for file by string
grep stringname /dir/subdir/file "Note you can inclose the string as well "stringname" this is usefull if the string you are looking for has space or break in it"
"To eqnore cas add -i example: grep -i"
"To search for exzace string add a -w example: grep -w"
"To eqnore a string in your search you can add a -v example: grep -v"
"To search for a string inside a file a the -a example: grep -a"
"To just print out the number of matches add the -c example: grep -c"


"-----Backup and Archiving--------------------------------------------------------------------------"

#Backup files
find /etc/ -mtime -7 -type f -exec cp {} /dir/backup \; "This = find all files in directory that are seven days old and copy to backup directory"

#Archiving and compressing a single directory in GNU "gzip compression" - most commonly used
tar -czvf /dir/name.tar.gz /dir/ "this will archive and compress the etc directory and name it etc.tar.gz"
"You can archive and compress multipe files into a single archive by simpley adding the directory paths with space in between each target path example:tar -czvf /dir/name.tar.gz /dir1/ /dir2/"
"Note if you wish to exlude a file type you can simply add the --exclude='*.filetyep' to exlude more then one just add a another --exlude='file' with space 
example: tar --exclude='*.mkv' --exclude='*.config'"
"If want to make multiple backups for the same file but sperate them by day simply add this to the name example: tar -czvf /targetdir/name-$(date +%F).tar.gz"


#Archiving and compressing a directory in BZ2 "bzip2" - Less Common
tar -cjvf /dir/name.tar.bz2 /dir/
"You can archive and compress multipe files into a single archive by simpley adding the directory paths with space in between each target path example:tar -cjvf /dir/name.tar.bz2 /dir1/ /dir2/"
"Note if you wish to exlude a file type you can simply add the --exclude='*.filetyep' to exlude more then one just add a another --exlude='file' with space 
example: tar --exclude='*.mkv' --exclude='*.config'"
"If want to make multiple backups for the same file but sperate them by day simply add this to the name example: tar -cjvf /targetdir/name-$(date +%F).tar.bz2"

#Extracting and Archive
tar -xzvf name.tar.gz
"Add a -C /targetdir/ to extract it to a target directory"
or
tar -xjvf name.tar.bz2
"Add a -C /targetdir/ to extract it to a target directory"

#Extracting by compression type spifice extraction cmd, this if the standard above dosn't work and you need to extract a gzip or bzip
to extract gzip is gunzip "Learn more with gunzip --Help"
to extract bzip bunzip2 "Learn more with bunzip --Help"

#Checking a Archive for a target file/dir
tar -tf name.tar.gz | grep targetname
or
tar -tf name.tar.bz2 | grep targetname

"----File Types-------------------------------------------------------------------------------------------"

#Simple way to fined and sort file type in a list
ls -l /dir/

#Get file meta data for target
file /dir/

#Pull a list of file type into a list
file /run/*

#Pull a list of file type into a list from a targeted directory
file /dir/*

"---Pull/Set Timestamps----------------------------------------------------------------------------------"

#Last Accessed or atime
ls -lu

#Last modified or mtime
ls -l
ls -lt

#Last changed or ctime
ls -lc

#Pulling all this info for a file or directory
stat /dir/

#Update all timestamps to the sametime
touch /dir/
#Change just the atime
touch -a /dir/
#Change just the mtime
touch -m /dir/
#Set atime or mtime to specified time/date, Data and time should be in the formate of ymdhm.s example 202212301530.45 = 2022/12/30 15:30:45
touch -a ymdhm.s /dir/
touch -m ymdhm.s /dir/
#Changing both mtime and atime together
touch -d "y-m-d h:m:s" /dir/
#Mirror timestamp setting from one file to another
touch /dir/ -r /newdir/

#Check and Pull a list of file type inside the current directory (NOTE THIS ONLY LOOKS IN THE CURRENT DIRECTORY AND NOT ANY SUB-DIR)
echo *.type

"---Gathering Detials-------------------------------------------------------------------------------------"

#Pull a detailed info on the filesystem
df
df -hi
df -hi -all

# See mount points
df -h

"--Reading Configs/Text--------------------------------------------------------------------------------------"

#Quick read a file
cat /dir/

#Quikc read with line number
cat -n /dir/

#Print the content of file to another target file
cat /dir/ /file.type > outputfile.txt

#Reading a file and looking for a spacific log type and outputing a count of how manytime it accored
cat -n /dir/file.type | grep -a "query" | wc -l

#To fully open the file without editor tools you can do the following
less /dir/filepath.type

#To exit the file
q

#Pulling just the last lines of file
tail /dir/

#Reading targeted number of lines
tail -n 1 /dir/ #change the 1 to how many lines you want to pull

#To actively watch a log
tail -f /dir/

#Pulling just the reader of a file or first 10 lines
head /dir/

#To actively watch a directory change, not to kill it you need to ctl+c
watch ls

#Actively watch and highligh changes
watch -n 3 -d ls -l

#Actively Watch how network traffic/packets are sent
watch -n 1 -d ifconfig


"--Creating New files and Directories-------------------------------------------------------------------------"

#Creating a new file
touch /filepath/filename.type
add a ~/ in front will create the file in the current directory
to had a space between the name in linux you need to but the two word in "" example "learning linux.type" note thought best practice in linux file creating is to add a _ inbetween words

#Making a new directory
mkdir directoryname #to display the newly created has completed a -v example mkdir -v directoryname

#Creating a new directory into multiple directory targets
mkdir directoryname directory1/directoryname directory2/directoryname

#Creating a new directory tree
mkdir -p /dir/new2/new3

"--Copying Files and Directories------------------------------------------------------------------------------"

#Copying a file
cp /dir/file ./file.type

#Copy another file to another directory
cp /dir/ ./file.type

#Copying files to another directory but pull a log of what will be copied to the directory
cp -v /dir/ ./file.type

#Copying files to another directory but pull a log of what will be copied to the directory and get prompted before copying the files
cp -i /dir/ ./file.type

#Copying file and keep orginal permissions
sudo cp -p copyfile.type newfile.type

"--Moving Files and New Naming--------------------------------------------------------------------------------"

#Move a file to new directory
mv dir/file.type newdir/

#Move multiple files
mv dir/file.type dir/file.type dir/file.type newdir/

#Move all files in directory to a new directory
mv dir/* newdir/

#Target move all files for a type to a new directory
mv dire/*.type new/

#Moving a directory
mv dir/ newdir/file.type

#Adding check if directory already exist before overwriting
mv -i directory/ newdir/file.type

#To pervent any overwriting
mv -n dir/ newdir/file.type

#If douplic found check is file being moved is newest version
mv -u dir/ newdir/file.type

#Renaming a file when moving
mv dir/file.type newdir/newname.type

"--Removing Files-------------------------------------------------------------------------------------------------"

#Removing files (Note files removed in terminal cannot be removered)
rm dir/file.type

#Remove file with confermation
rm -i dir/file.type

#Show more info when removing a file
rm -v dir/file.type

#Remove directory
rm -r dir/

#Force removeal of protect directory
sudo rm -rf dir/

#Removing multiple directorys
rm -r dir/file.type dir/file.type dir/file.type

#Shreding a file data before removing it
shred -vu -n 100 dir/file.type

"--Comparing Files--------------------------------------------------------------------------------"

#Camparing two files
cmp file1 file2
"Note if nothing is displayed then the files are the same"

#Getting the differance between two files
diff file1 file2
"This can be helful in many ways such as cross checking networking logs or access logs and much more"
"Adding a -B will eqnore blank lines example: diff -B"
"Adding -w will eqnore white spaces example: diff -w"
"Adding -i will eqnore cas differncaces example: diff -i"
"Adding -c for a more ditialed caparession example: diff -c"
"Adding -y will let you compaire the full files with marked diffs side by side, note to show only the what is diff add the pipe | less at the end"

"--Linking files--------------------------------------------------------------------------------"

#Creating a hardlink between files
ln /dir/file1 ./dir/file2
"Also note if you delete one of the files linked only the target file will be deleted and not both, the link will be broken though"

#Creating SIM link between files
ln -s /dir/file1 ./dir/file2

#Finding how how many links a file has
ls -li /dir/file