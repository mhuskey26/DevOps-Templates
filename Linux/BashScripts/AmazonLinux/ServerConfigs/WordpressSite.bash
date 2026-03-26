"----------------Setup and Configure Wordpress Server on EC2 with LB and ASG-------------------------------"

"OS Amazon Linux AMI"

#Step 1 Intial setup
sudo su
yum update -y

#Step 2 setup EFS Drive
mkdir -p /var/www/html
mount "efs mount path" /var/www/html
"Verfiy efs drive is mounted" 
df -h

#Step 3 Setup Web Server
sudo yum install -y httpd httpd-tools mod_ssl
sudo systemctl enable httpd 
sudo systemctl start httpd
"Verfy the Apache is running"
sudo systemctl status httpd

#Step 4 Setup PHP
amazon-linux-extras enable php7.4
yum clean metadata
yum install php php-common php-pear -y
yum install php-{cgi,curl,mbstring,gd,mysqlnd,gettext,json,xml,fpm,intl,zip} -y

#Step 5 configure mysql server
rpm -Uvh https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum install mysql-community-server -y
systemctl enable mysqld
systemctl start mysqld


#Step 6 Install wordpress
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/



#Step 7 Setup wordpress config
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
nano /var/www/html/wp-config.php

#Setup temp full access for configuration setup
usermod -a -G apache ec2-user
chmod 2777 /var/www && find /var/www -type d -exec sudo chmod 2777 {} \;
find /var/www -type f -exec sudo chmod 0777 {} \;
chown apache:apache -R /var/www/html

#Step 8 Configure EFS Drive permissions
chown -R ec2-user:apache /var/www
chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
find /var/www -type f -exec sudo chmod 0664 {} \;
chown apache:apache -R /var/www/html


#Step 9 Restart services
sudo systemctl restart httpd
sudo systemctl restart mysqld
