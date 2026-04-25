#Before you can mount a S3 Bucket you need to do the following
#Create an IAM Policy for the EC2 instace or Access Key that will be used to grant permissions

# Mounting S3 to a Ubuntu linux https://github.com/s3fs-fuse/s3fs-fuse

# Intial Setup EC2 for SFPT
sudo apt update -y
sudo apt-get install awscli -y
sudo apt-get install s3fs -y
sudo apt-get install automake autotools-dev -y

# Creat new dir for s3 mnt
sudo mkdir /s3
sudo chown nobody:nogroup /s3
sudo chown ubuntu:ubuntu /s3
sudo chown  ubuntu /s3
sudo chmod -R a+rwx /s3

# Configure store of IAM Access login for s3
sudo aws configure
# IAM Access config
# Access key
# secret access key
# Region
# default output format


# Sync s3bucket
sudo aws s3 sync /s3 s3://bucket-name

# Storing IAM Access for auto remunt 
echo ACCESS_KEY_ID:SECRET_ACCESS_KEY > /etc/passwd-s3fs
chmod 600 /etc/passwd-s3fs

# Auto mount S3
