# LINUX FILE AND STORAGE MANAGEMENT QUICK CLI SHEET
# Focus: file operations, storage usage, search, backup, and recovery

# Index:
# 1) Common Directories
# 2) Navigation and Path Basics
# 3) Listing and Inspecting Files
# 4) Search and Discovery
# 5) Disk Usage and Filesystem Health
# 6) Read and Watch File Content
# 7) Create, Copy, Move, Rename, Remove
# 8) Archive and Backup
# 9) File Types, Inodes, Links, Timestamps
# 10) Compare and Validate Files


# ---------------------------------------------------------------------------
# 1) COMMON DIRECTORIES
# ---------------------------------------------------------------------------

/
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
/run
/srv
/sys
/tmp
/usr
/var

# Common subdirectories
/usr/bin
/usr/local
/usr/sbin
/var/cache
/var/lib
/var/log
/var/spool
/var/tmp


# ---------------------------------------------------------------------------
# 2) NAVIGATION AND PATH BASICS
# ---------------------------------------------------------------------------

pwd
cd
cd /path/to/dir
cd ..
cd -
realpath ./relative/path


# ---------------------------------------------------------------------------
# 3) LISTING AND INSPECTING FILES
# ---------------------------------------------------------------------------

ls
ls -la
ls -lh
ls -lt
ls -ltu
ls -lS
ls -R /path/to/dir

# Show inode numbers
ls -li /path/to/dir

# Show detailed metadata
stat /path/to/file_or_dir


# ---------------------------------------------------------------------------
# 4) SEARCH AND DISCOVERY
# ---------------------------------------------------------------------------

# Find by name
find . -name "filename"
find /path/to/dir -type f -name "*.log"

# Find directories only
find /path/to/dir -type d -maxdepth 3

# Find by permission, owner, group
find /path/to/dir -type f -perm 640 -ls
find /path/to/dir -type f -user USERNAME -ls
find /path/to/dir -type f -group GROUPNAME -ls

# Find by size and age
find /path/to/dir -type f -size +100M -ls
find /path/to/dir -type f -mtime -1 -ls
find /path/to/dir -type f -mmin -60 -ls

# Find by inode
find /path/to/dir -inum INODE_NUMBER

# Search file content
grep -n "search_text" /path/to/file
grep -Rin "search_text" /path/to/dir
grep -Riw "exact_word" /path/to/dir


# ---------------------------------------------------------------------------
# 5) DISK USAGE AND FILESYSTEM HEALTH
# ---------------------------------------------------------------------------

# Filesystem free space
df -h
df -i

# Directory usage
du -sh /path/to/dir
du -h --max-depth=1 /path/to/dir

# Largest files/directories in a path
du -ah /path/to/dir | sort -rh | head -n 20

# Mount points
mount | column -t
findmnt


# ---------------------------------------------------------------------------
# 6) READ AND WATCH FILE CONTENT
# ---------------------------------------------------------------------------

cat /path/to/file
cat -n /path/to/file
less /path/to/file
head -n 20 /path/to/file
tail -n 50 /path/to/file
tail -f /path/to/logfile

# Watch command output for changes
watch -n 3 -d "ls -lh /path/to/dir"


# ---------------------------------------------------------------------------
# 7) CREATE, COPY, MOVE, RENAME, REMOVE
# ---------------------------------------------------------------------------

# Create files/directories
touch /path/to/newfile.txt
mkdir /path/to/newdir
mkdir -p /path/to/parent/child

# Copy
cp /path/from/file /path/to/file
cp -r /path/from/dir /path/to/dir
cp -av /path/from /path/to
cp -i /path/from/file /path/to/file

# Move/rename
mv /path/from/file /path/to/
mv /path/from/file /path/to/newname.txt
mv -i /path/from/file /path/to/file
mv -n /path/from/file /path/to/file

# Remove (use with care)
rm /path/to/file
rm -i /path/to/file
rm -r /path/to/dir
rm -rf /path/to/dir

# Secure delete example
shred -vu -n 3 /path/to/file


# ---------------------------------------------------------------------------
# 8) ARCHIVE AND BACKUP
# ---------------------------------------------------------------------------

# Create gzip tar archive
tar -czvf /backup/name-$(date +%F).tar.gz /path/to/dir

# Create bzip2 tar archive
tar -cjvf /backup/name-$(date +%F).tar.bz2 /path/to/dir

# Exclude patterns while archiving
tar -czvf /backup/name.tar.gz /path/to/dir --exclude='*.log' --exclude='*.tmp'

# Extract archives
tar -xzvf /backup/name.tar.gz -C /restore/path
tar -xjvf /backup/name.tar.bz2 -C /restore/path

# List archive contents
tar -tf /backup/name.tar.gz

# Copy recent files to backup path
find /etc -type f -mtime -7 -exec cp -a {} /backup/path/ \;


# ---------------------------------------------------------------------------
# 9) FILE TYPES, INODES, LINKS, TIMESTAMPS
# ---------------------------------------------------------------------------

# Detect file type
file /path/to/file
file /path/to/dir/*

# Inode and link count
ls -li /path/to/file

# Hard link and symbolic link
ln /path/to/source /path/to/hardlink
ln -s /path/to/source /path/to/symlink

# Timestamps
ls -l /path/to/file      # mtime
ls -lu /path/to/file     # atime
ls -lc /path/to/file     # ctime
stat /path/to/file

# Update timestamps
touch /path/to/file
touch -a /path/to/file
touch -m /path/to/file
touch -d "YYYY-MM-DD HH:MM:SS" /path/to/file
touch -r /path/reference.file /path/target.file


# ---------------------------------------------------------------------------
# 10) COMPARE AND VALIDATE FILES
# ---------------------------------------------------------------------------

# Binary compare
cmp /path/file1 /path/file2

# Text diff compare
diff /path/file1 /path/file2
diff -u /path/file1 /path/file2
diff -y /path/file1 /path/file2 | less

# Checksums for integrity validation
sha256sum /path/to/file
md5sum /path/to/file
