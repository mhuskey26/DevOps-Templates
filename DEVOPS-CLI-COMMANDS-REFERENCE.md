# DevOps Engineer CLI Commands Reference

A comprehensive guide of essential command-line commands every DevOps engineer should know.

---

## Table of Contents
1. [Docker](#docker)
2. [Kubernetes (kubectl)](#kubernetes)
3. [Git](#git)
4. [AWS CLI](#aws-cli)
5. [Azure CLI](#azure-cli)
6. [Linux/Unix Fundamentals](#linuxunix)
7. [Networking](#networking)
8. [System Administration](#system-administration)
9. [Package Management](#package-management)
10. [Terraform](#terraform)
11. [CI/CD & Build Tools](#cicd--build-tools)
12. [Monitoring & Logging](#monitoring--logging)
13. [Security](#security)

---

## Docker

### Image Management
```bash
docker images                                    # List all images
docker build -t image-name:tag .               # Build image from Dockerfile
docker pull image-name:tag                     # Pull image from registry
docker push image-name:tag                     # Push image to registry
docker rmi image-id                            # Remove image
docker tag source-image:tag target-image:tag   # Tag an image
docker inspect image-id                        # Get detailed image info
docker history image-id                        # View image layers
```

### Container Management
```bash
docker ps                                      # List running containers
docker ps -a                                   # List all containers
docker run -d -p 8080:80 --name myapp image   # Run container in background
docker stop container-id                       # Stop container
docker start container-id                      # Start stopped container
docker restart container-id                    # Restart container
docker rm container-id                         # Remove container
docker rm -f container-id                      # Force remove container
docker exec -it container-id /bin/bash         # Execute command in container
docker logs container-id                       # View container logs
docker logs -f container-id                    # Follow container logs
docker stats container-id                      # View resource usage
docker inspect container-id                    # Get container details
docker cp file container-id:/path              # Copy file to container
```

### Docker Compose
```bash
docker-compose up -d                           # Start services in background
docker-compose down                            # Stop and remove services
docker-compose ps                              # List services
docker-compose logs -f                         # Follow service logs
docker-compose build                           # Build services
docker-compose restart                         # Restart services
docker-compose exec service-name bash          # Execute command in service
docker-compose config                          # Validate compose file
```

### Network & Volume Management
```bash
docker network ls                              # List networks
docker network create network-name             # Create network
docker volume ls                               # List volumes
docker volume create volume-name               # Create volume
docker volume inspect volume-name              # Volume details
```

### Registry Operations
```bash
docker login registry-url                      # Login to registry
docker logout                                  # Logout from registry
docker search image-name                       # Search image in registry
```

---

## Kubernetes

### Cluster Information
```bash
kubectl cluster-info                           # Display cluster info
kubectl version                                # Show client and server versions
kubectl get nodes                              # List cluster nodes
kubectl describe node node-name                # Node details
kubectl top nodes                              # Node resource usage
kubectl get namespaces                         # List namespaces
```

### Deployments & Pods
```bash
kubectl get pods                               # List pods
kubectl get pods -n namespace                  # List pods in namespace
kubectl get pods -o wide                       # Pods with more details
kubectl describe pod pod-name                  # Pod details
kubectl logs pod-name                          # View pod logs
kubectl logs -f pod-name                       # Follow pod logs
kubectl logs pod-name -c container-name        # Logs from specific container
kubectl exec -it pod-name -- /bin/bash         # Execute command in pod
kubectl create deployment name --image=img    # Create deployment
kubectl scale deployment name --replicas=3    # Scale deployment
kubectl rollout status deployment/name         # Deployment rollout status
kubectl rollout history deployment/name        # Rollout history
kubectl rollout undo deployment/name           # Rollback deployment
kubectl set image deployment/name image=new   # Update deployment image
kubectl get deployments                        # List deployments
kubectl describe deployment name               # Deployment details
kubectl delete pod pod-name                    # Delete pod
kubectl delete deployment name                 # Delete deployment
```

### Services & Networking
```bash
kubectl get services                           # List services
kubectl get svc                                # Short form
kubectl expose deployment name --port=80      # Expose deployment as service
kubectl describe service name                 # Service details
kubectl port-forward svc/name 8080:80         # Forward local port to service
kubectl get endpoints                          # List endpoints
```

### ConfigMaps & Secrets
```bash
kubectl get configmaps                         # List ConfigMaps
kubectl create configmap name --from-file=path # Create ConfigMap from file
kubectl describe configmap name                # ConfigMap details
kubectl get secrets                            # List secrets
kubectl create secret generic name --from-literal=key=value # Create secret
kubectl describe secret name                   # Secret details
```

### Resource Management
```bash
kubectl apply -f file.yaml                     # Apply YAML manifest
kubectl delete -f file.yaml                    # Delete resource from YAML
kubectl get all                                # Get all resources
kubectl get all -n namespace                   # All resources in namespace
kubectl top pods                               # Pod resource usage
kubectl describe quota                         # Resource quotas
```

### Troubleshooting
```bash
kubectl get events                             # Cluster events
kubectl get events -n namespace                # Namespace events
kubectl describe pod pod-name                  # Detailed pod info
kubectl logs pod-name --previous               # Previous container logs
kubectl debug pod pod-name -it --image=image  # Debug pod
kubectl exec -it pod-name -- /bin/bash         # Interactive shell
```

### Advanced Operations
```bash
kubectl apply -f - < file.yaml                 # Apply from stdin
kubectl patch pod name -p '{"spec":{"key":"value"}}' # Patch resource
kubectl label pods pod-name key=value          # Add label
kubectl annotate pod pod-name key=value        # Add annotation
kubectl get pod -L label-key                   # Show label column
kubectl create namespace name                  # Create namespace
```

---

## Git

### Basic Operations
```bash
git init                                       # Initialize repository
git clone url                                  # Clone repository
git add file                                   # Stage file
git add .                                      # Stage all changes
git commit -m "message"                        # Commit changes
git push origin branch                         # Push to remote
git pull origin branch                         # Pull from remote
git fetch origin                               # Fetch from remote
```

### Branching
```bash
git branch                                     # List local branches
git branch -a                                  # List all branches
git branch branch-name                         # Create branch
git checkout branch-name                       # Switch branch
git checkout -b branch-name                    # Create and switch branch
git switch -c branch-name                      # Modern create and switch
git merge branch-name                          # Merge branch
git branch -d branch-name                      # Delete branch
git branch -D branch-name                      # Force delete branch
```

### Remote Management
```bash
git remote -v                                  # List remotes
git remote add origin url                      # Add remote
git remote remove origin                       # Remove remote
git remote set-url origin url                  # Change remote URL
git push origin --all                          # Push all branches
git push origin --delete branch                # Delete remote branch
```

### History & Changes
```bash
git log                                        # View commit history
git log --oneline                              # Concise history
git log --graph --oneline --all                # Visual history
git diff                                       # Show unstaged changes
git diff --staged                              # Show staged changes
git diff branch1 branch2                       # Compare branches
git status                                     # Current status
git show commit-hash                           # Show commit details
```

### Stashing & Undoing
```bash
git stash                                      # Stash changes
git stash list                                 # List stashes
git stash pop                                  # Apply and delete stash
git stash apply                                # Apply stash
git reset --soft HEAD~1                        # Undo commit, keep changes
git reset --hard HEAD~1                        # Undo commit, discard changes
git revert commit-hash                         # Create revert commit
git clean -fd                                  # Remove untracked files
```

### Tags
```bash
git tag                                        # List tags
git tag -a v1.0 -m "message"                   # Create annotated tag
git push origin v1.0                           # Push tag
git delete tag v1.0                            # Delete local tag
git push origin --delete v1.0                  # Delete remote tag
```

---

## AWS CLI

### Configuration
```bash
aws configure                                  # Configure AWS credentials
aws configure --profile profile-name           # Configure named profile
aws sts get-caller-identity                    # Verify credentials
aws ec2 describe-regions                       # List regions
```

### EC2 Instances
```bash
aws ec2 describe-instances                     # List all instances
aws ec2 describe-instances --instance-ids id   # Get specific instance
aws ec2 run-instances --image-id ami --count 1 # Launch instance
aws ec2 terminate-instances --instance-ids id  # Terminate instance
aws ec2 start-instances --instance-ids id      # Start instance
aws ec2 stop-instances --instance-ids id       # Stop instance
aws ec2 reboot-instances --instance-ids id     # Reboot instance
aws ec2 describe-instance-status                # Instance status
aws ec2 describe-security-groups                # List security groups
```

### S3 Operations
```bash
aws s3 ls                                      # List buckets
aws s3 mb s3://bucket-name                     # Create bucket
aws s3 rb s3://bucket-name                     # Remove bucket
aws s3 cp file s3://bucket/path                # Upload file
aws s3 cp s3://bucket/file local-file          # Download file
aws s3 sync local-dir s3://bucket/path         # Sync directory
aws s3 rm s3://bucket/file                     # Delete file
aws s3 ls s3://bucket/path                     # List bucket contents
aws s3api head-bucket --bucket name            # Check bucket exists
aws s3api get-bucket-versioning --bucket name  # Get versioning status
```

### RDS & Databases
```bash
aws rds describe-db-instances                  # List DB instances
aws rds describe-db-clusters                   # List DB clusters
aws rds create-db-instance --db-instance-identifier id # Create DB
aws rds delete-db-instance --db-instance-identifier id # Delete DB
aws rds create-db-snapshot --db-snapshot-identifier id # Create snapshot
aws rds restore-db-instance-from-db-snapshot   # Restore from snapshot
```

### CloudFormation
```bash
aws cloudformation create-stack --stack-name name --template-body file://template.yaml
aws cloudformation update-stack --stack-name name --template-body file://template.yaml
aws cloudformation delete-stack --stack-name name
aws cloudformation describe-stacks --stack-name name
aws cloudformation describe-stack-resources --stack-name name
aws cloudformation validate-template --template-body file://template.yaml
```

### IAM
```bash
aws iam list-users                             # List IAM users
aws iam create-user --user-name name           # Create user
aws iam delete-user --user-name name           # Delete user
aws iam create-access-key --user-name name     # Create access key
aws iam list-access-keys --user-name name      # List access keys
aws iam delete-access-key --user-name name --access-key-id key
aws iam attach-user-policy --user-name name --policy-arn arn
aws iam list-roles                             # List roles
```

### CloudWatch & Logs
```bash
aws logs describe-log-groups                   # List log groups
aws logs create-log-group --log-group-name name # Create log group
aws logs describe-log-streams --log-group-name name
aws logs get-log-events --log-group-name group --log-stream-name stream
aws cloudwatch get-metric-statistics --namespace AWS/EC2 --metric-name CPUUtilization
```

---

## Azure CLI

### Authentication
```bash
az login                                       # Login to Azure
az logout                                      # Logout
az account list                                # List subscriptions
az account set --subscription id               # Set subscription
```

### Resource Groups
```bash
az group list                                  # List resource groups
az group create --name name --location location # Create resource group
az group delete --name name                    # Delete resource group
az group show --name name                      # Get RG details
```

### Virtual Machines
```bash
az vm list                                     # List VMs
az vm create --resource-group rg --name name --image UbuntuLTS
az vm delete --resource-group rg --name name   # Delete VM
az vm start --resource-group rg --name name    # Start VM
az vm stop --resource-group rg --name name     # Stop VM
az vm restart --resource-group rg --name name  # Restart VM
az vm open-port --resource-group rg --name name --port 80
```

### Container Instances
```bash
az container create --resource-group rg --name name --image image:tag
az container list --resource-group rg         # List containers
az container delete --resource-group rg --name name
az container logs --resource-group rg --name name
```

### App Service
```bash
az appservice list                             # List app services
az appservice plan create --name name --resource-group rg --sku B1 --is-linux
az webapp create --name name --plan plan --resource-group rg
az webapp deployment source config-zip --resource-group rg --name name --src-path path
```

### Storage
```bash
az storage account list                        # List storage accounts
az storage account create --name name --resource-group rg --location location
az storage account delete --name name --resource-group rg
az storage blob upload --account-name name --container-name container --name blob --file file
az storage blob download --account-name name --container-name container --name blob
```

### AKS (Azure Kubernetes Service)
```bash
az aks create --resource-group rg --name name --node-count 1
az aks delete --resource-group rg --name name
az aks get-credentials --resource-group rg --name name
az aks scale --resource-group rg --name name --node-count 3
```

---

## Linux/Unix

### File Operations
```bash
ls -la                                         # List files (detailed)
cd directory                                   # Change directory
pwd                                            # Print working directory
mkdir directory                                # Create directory
mkdir -p path/to/dir                           # Create nested directories
rm file                                        # Remove file
rm -r directory                                # Remove directory recursively
rm -f file                                     # Force remove
cp source dest                                 # Copy file
cp -r source dest                              # Copy directory
mv source dest                                 # Move/rename file
touch file                                     # Create empty file
find . -name "*.log"                           # Find files
find . -type f -mtime +7                       # Find files older than 7 days
```

### File Content
```bash
cat file                                       # Display file content
less file                                      # View file (paginated)
head -20 file                                  # First 20 lines
tail -20 file                                  # Last 20 lines
tail -f file                                   # Follow file updates
grep pattern file                              # Search in file
grep -r pattern directory                      # Recursive search
sed 's/pattern/replace/' file                  # Replace string
sed -i 's/pattern/replace/g' file              # In-place replacement
wc -l file                                     # Count lines
sort file                                      # Sort lines
uniq file                                      # Remove duplicate lines
```

### Permissions & Ownership
```bash
chmod 755 file                                 # Change permissions
chmod +x file                                  # Make executable
chmod -x file                                  # Remove execute
chown user:group file                          # Change ownership
chown -R user:group directory                  # Recursive change
umask                                          # View default permissions
```

### Process Management
```bash
ps aux                                         # List all processes
ps -ef                                         # Process list (alternative)
ps -ef | grep process-name                     # Find specific process
top                                            # Interactive process monitor
htop                                           # Enhanced process monitor
kill pid                                       # Kill process
kill -9 pid                                    # Force kill
killall process-name                           # Kill by name
bg                                             # Run in background
fg                                             # Bring to foreground
nohup command &                                # Run immune to hangups
```

### System Information
```bash
uname -a                                       # System information
uname -r                                       # Kernel version
lsb_release -a                                 # Distribution info
hostnamectl                                   # Hostname info
uptime                                         # System uptime
df -h                                          # Disk space (human-readable)
du -sh directory                               # Directory size
free -h                                        # Memory usage
lsblk                                          # Block devices
lscpu                                          # CPU information
timedatectl                                    # Date and time
```

### User Management
```bash
whoami                                         # Current user
id                                             # User and group IDs
sudo command                                   # Run as superuser
sudo -u user command                           # Run as specific user
sudo -i                                        # Switch to root shell
su - user                                      # Switch user
useradd username                               # Add user
userdel -r username                            # Delete user
usermod -aG group username                     # Add user to group
passwd username                                # Change password
groups username                                # List user groups
```

### Network Commands
```bash
ifconfig                                       # Network config (deprecated)
ip addr show                                   # IP addresses
ip link show                                   # Network interfaces
ip route show                                  # Routing table
hostname                                       # System hostname
hostname -I                                    # IP addresses
ufw status                                     # Firewall status
ufw enable                                     # Enable firewall
ufw disable                                    # Disable firewall
ufw allow 22                                   # Allow port 22
ufw deny 22                                    # Deny port 22
firewall-cmd --list-all                        # Red Hat firewall
firewall-cmd --add-port=22/tcp --permanent    # Add port (Red Hat)
```

### Text Processing
```bash
cat file1 file2 > merged                       # Concatenate files
echo "text" | tee file                         # Print and save
cut -d: -f1 /etc/passwd                        # Extract fields
awk '{print $1}' file                          # Process columns
tr 'a-z' 'A-Z' < file                          # Translate characters
paste file1 file2                              # Combine files
```

### Archives
```bash
tar -czf archive.tar.gz directory              # Create tar.gz
tar -xzf archive.tar.gz                        # Extract tar.gz
tar -cf archive.tar directory                  # Create tar
tar -xf archive.tar                            # Extract tar
zip -r archive.zip directory                   # Create zip
unzip archive.zip                              # Extract zip
gzip file                                      # Compress file
gunzip file.gz                                 # Decompress
```

---

## Networking

### TCP/IP Commands
```bash
ping hostname                                  # Test connectivity
ping -c 4 hostname                             # Ping with count (Linux)
traceroute hostname                            # Trace route
tracert hostname                               # Trace route (Windows)
netstat -an                                    # Show network statistics
netstat -tlnp                                  # Listening ports (Linux)
ss -tlnp                                       # Socket statistics
nslookup domain                                # DNS lookup
dig domain                                     # Detailed DNS lookup
curl url                                       # Fetch URL
curl -H "header" url                           # Custom headers
wget url                                       # Download file
wget -O filename url                           # Download with name
```

### SSH & Tunneling
```bash
ssh user@host                                  # SSH connection
ssh -i key-file user@host                      # SSH with key file
ssh -p 2222 user@host                          # SSH custom port
ssh-keygen -t rsa -b 4096                      # Generate SSH key
ssh-copy-id user@host                          # Copy SSH key to host
scp file user@host:/path                       # Secure copy to host
scp user@host:/path local-path                 # Secure copy from host
scp -r directory user@host:/path               # Recursive copy
ssh -L 8080:localhost:80 user@host             # Local port forward
ssh -R 8080:localhost:80 user@host             # Remote port forward
ssh -D 9090 user@host                          # Dynamic proxy
```

### Network Configuration
```bash
ip link set eth0 up                            # Bring interface up
ip link set eth0 down                          # Bring interface down
ip addr add 192.168.1.10/24 dev eth0           # Add IP address
ip addr del 192.168.1.10/24 dev eth0           # Remove IP address
ip route add default via 192.168.1.1           # Add default route
ip route del 192.168.1.0/24                    # Delete route
iptables -L                                    # List firewall rules
iptables -A INPUT -p tcp --dport 80 -j ACCEPT # Add rule
nmcli device show                              # Network Manager info
nmcli connection show                          # Connections
```

---

## System Administration

### Package Management (apt - Debian/Ubuntu)
```bash
apt update                                     # Update package list
apt upgrade                                    # Upgrade packages
apt install package-name                       # Install package
apt remove package-name                        # Remove package
apt purge package-name                         # Remove with config
apt autoremove                                 # Remove unused packages
apt search package-name                        # Search for package
apt show package-name                          # Package details
apt list --installed                           # List installed packages
```

### Package Management (yum - Red Hat/CentOS)
```bash
yum update                                     # Update packages
yum install package-name                       # Install package
yum remove package-name                        # Remove package
yum search package-name                        # Search for package
yum info package-name                          # Package details
yum list installed                             # List installed packages
yum clean all                                  # Clean cache
```

### apt (Debian/Ubuntu)
```bash
apt install -y package                         # Install without prompt
apt install package=version                    # Install specific version
apt-cache search keyword                       # Search packages
apt-cache policy package                       # Check versions available
```

### Service Management (systemd)
```bash
systemctl status service                       # Service status
systemctl start service                        # Start service
systemctl stop service                         # Stop service
systemctl restart service                      # Restart service
systemctl reload service                       # Reload service
systemctl enable service                       # Enable on boot
systemctl disable service                      # Disable on boot
systemctl list-units --type=service            # List all services
systemctl list-unit-files                      # List service files
journalctl -u service                          # Service logs
journalctl -u service -f                       # Follow logs
systemctl daemon-reload                        # Reload service files
```

### Service Management (init.d)
```bash
service service-name status                    # Service status
service service-name start                     # Start service
service service-name stop                      # Stop service
service service-name restart                   # Restart service
service service-name reload                    # Reload service
/etc/init.d/service-name status                # Direct init.d call
```

### Cron Jobs
```bash
crontab -e                                     # Edit cron jobs
crontab -l                                     # List cron jobs
crontab -r                                     # Remove all cron jobs
crontab -i -r                                  # Remove with confirmation
cat /var/log/cron                              # View cron log
```

### System Logs
```bash
tail -f /var/log/syslog                        # Follow system log
tail -f /var/log/messages                      # Follow messages (Red Hat)
grep error /var/log/syslog                     # Search logs
dmesg                                          # Boot messages
dmesg | tail -20                               # Recent boot messages
```

---

## Package Management

### NPM (Node.js)
```bash
npm init                                       # Initialize project
npm install                                    # Install dependencies
npm install package-name                       # Install specific package
npm install -g package-name                    # Install globally
npm install --save-dev package-name            # Install as dev dependency
npm uninstall package-name                     # Uninstall package
npm update                                     # Update packages
npm outdated                                   # Check outdated packages
npm list                                       # List installed packages
npm run script-name                            # Run script
npm audit                                      # Security audit
npm audit fix                                  # Fix vulnerabilities
```

### Python (pip)
```bash
pip install package-name                       # Install package
pip install -r requirements.txt                # Install from file
pip install --upgrade package-name             # Upgrade package
pip uninstall package-name                     # Uninstall package
pip list                                       # List installed packages
pip show package-name                          # Package details
pip freeze > requirements.txt                  # Save dependencies
pip search package-name                        # Search packages (deprecated)
python -m venv env                             # Create virtual environment
source env/bin/activate                        # Activate (Linux/Mac)
env\Scripts\activate                           # Activate (Windows)
```

### Ruby (gem)
```bash
gem install gem-name                           # Install gem
gem uninstall gem-name                         # Uninstall gem
gem list                                       # List installed gems
gem update                                     # Update gems
bundle init                                    # Initialize Bundler
bundle install                                 # Install from Gemfile
bundle update                                  # Update Gemfile.lock
```

---

## Terraform

### Initialization & Planning
```bash
terraform init                                 # Initialize terraform
terraform validate                             # Validate configuration
terraform fmt                                  # Format HCL files
terraform plan                                 # Show plan
terraform plan -out=planfile                   # Save plan
terraform plan -destroy                        # Plan destruction
terraform show planfile                        # Show saved plan
```

### Deployment & Destruction
```bash
terraform apply                                # Apply configuration
terraform apply planfile                       # Apply saved plan
terraform apply -auto-approve                  # Apply without confirmation
terraform destroy                              # Destroy infrastructure
terraform destroy -auto-approve                # Destroy without confirmation
terraform destroy -target resource.name        # Destroy specific resource
```

### State Management
```bash
terraform state list                           # List resources in state
terraform state show resource.name             # Show resource state
terraform state mv source dest                 # Move state resource
terraform state rm resource.name               # Remove from state
terraform state pull                           # Output state
terraform state push file.json                 # Push state from file
terraform state backup                         # Create state backup
terraform refresh                              # Refresh state
```

### Workspace Management
```bash
terraform workspace list                       # List workspaces
terraform workspace new workspace-name         # Create workspace
terraform workspace select workspace-name      # Switch workspace
terraform workspace delete workspace-name      # Delete workspace
terraform workspace show                       # Current workspace
```

### Debugging & Inspection
```bash
terraform console                              # Interactive console
terraform output                               # Show outputs
terraform output output-name                   # Specific output
terraform graph                                # Show dependency graph
terraform version                              # Show version
TF_LOG=DEBUG terraform apply                   # Enable debug logging
```

### Import & Lock
```bash
terraform import resource.name resource-id    # Import existing resource
terraform lock                                 # Lock state file
terraform unlock LOCK_ID                       # Unlock state file
```

---

## CI/CD & Build Tools

### Jenkins
```bash
jenkins-cli -s http://jenkins-url init         # Initialize Jenkins CLI
java -jar jenkins-cli.jar -s http://jenkins-url help
java -jar jenkins-cli.jar -s http://jenkins-url build job-name
java -jar jenkins-cli.jar -s http://jenkins-url get-job job-name
java -jar jenkins-cli.jar -s http://jenkins-url create-job job-name < config.xml
```

### GitLab CI/CD
```bash
gitlab-runner register                         # Register GitLab Runner
gitlab-runner start                            # Start runner
gitlab-runner stop                             # Stop runner
gitlab-runner verify                           # Verify runner
gitlab-runner unregister --id 1                # Unregister runner
```

### Build Tools
```bash
make                                           # Run Makefile
make clean                                     # Clean build
make test                                      # Run tests
gradle build                                   # Gradle build
gradle clean                                   # Clean gradle
mvn clean install                              # Maven build
mvn test                                       # Maven test
mvn deploy                                     # Maven deploy
```

---

## Monitoring & Logging

### System Monitoring
```bash
top -u username                                # Monitor user processes
iostat 1 10                                    # IO statistics
vmstat 1 10                                    # Virtual memory stats
sar -u 1 10                                    # CPU usage
sar -n DEV 1 10                                # Network stats
lsof -i :8080                                  # List open files on port
lsof -u username                               # Open files by user
strace -p pid                                  # System call trace
ltrace -p pid                                  # Library call trace
```

### Log Analysis
```bash
grep pattern /var/log/auth.log                 # Search auth log
grep -i error /var/log/syslog                  # Case-insensitive search
grep -c pattern logfile                        # Count matches
zgrep pattern logfile.gz                       # Search gzipped logs
journalctl --since "1 hour ago"                # Recent journal entries
journalctl --until "now" -n 100                # Last 100 entries
```

### Package Specific Logs
```bash
docker logs container-name                     # Docker container logs
journalctl -u service-name                     # Systemd service logs
tail -f /var/log/nginx/error.log               # Nginx error log
tail -f /var/log/apache2/error.log             # Apache error log
tail -f /var/log/mysql/error.log               # MySQL error log
tail -f /var/log/postgresql/postgresql.log     # PostgreSQL log
```

### Metrics & Performance
```bash
iotop                                          # IO per process
nethogs                                        # Network per process
iftop                                          # Network bandwidth
watch -n 1 'command'                           # Run command every 1 second
```

---

## Security

### Certificate Management
```bash
openssl genrsa -out private.key 2048           # Generate private key
openssl req -new -key private.key -out req.csr # Create CSR
openssl x509 -req -in req.csr -signkey private.key -out cert.crt
openssl x509 -in cert.crt -text -noout         # View certificate
openssl verify cert.crt                        # Verify certificate
openssl s_client -connect host:443             # Test SSL/TLS
```

### SSH Security
```bash
ssh-keygen -t rsa -b 4096 -f key-name          # Generate SSH key
ssh-keygen -t ed25519 -f key-name              # ED25519 key
ssh-keyscan hostname >> ~/.ssh/known_hosts     # Add to known hosts
chmod 600 ~/.ssh/id_rsa                        # Secure key permissions
chmod 644 ~/.ssh/id_rsa.pub                    # Public key permissions
chmod 700 ~/.ssh                               # SSH directory permissions
```

### Encryption
```bash
gpg --gen-key                                  # Generate GPG key
gpg --encrypt --recipient user file            # Encrypt file
gpg --decrypt file.gpg                         # Decrypt file
gpg --sign file                                # Sign file
gpg --verify file.sig file                     # Verify signature
openssl enc -aes-256-cbc -in file -out file.enc # Encrypt with OpenSSL
openssl enc -d -aes-256-cbc -in file.enc       # Decrypt
```

### User & Access Control
```bash
sudo visudo                                    # Edit sudoers file safely
sudo -l                                        # List sudo privileges
su - username                                  # Switch user with login shell
sudo usermod -aG sudoers username              # Add user to sudoers
passwd -l username                             # Lock user account
passwd -u username                             # Unlock user account
getfacl file                                   # View file ACL
setfacl -m u:user:rx file                      # Set file ACL
```

### Network Security
```bash
nmap hostname                                  # Scan for open ports
nmap -p 22,80,443 hostname                     # Scan specific ports
nmap -O hostname                               # Detect OS
ufw allow ssh                                  # Allow SSH in firewall
ufw allow 80/tcp                               # Allow HTTP
ufw allow 443/tcp                              # Allow HTTPS
iptables -L -n                                 # View firewall rules
fail2ban-client status                         # Fail2ban status
fail2ban-client set sshd unbanip IP            # Unban IP
```

### Updates & Patches
```bash
apt update && apt upgrade -y                   # Update and upgrade
yum update -y                                  # Red Hat update
unattended-upgrade                             # Automatic updates (Debian)
yum-cron                                       # Automatic updates (Red Hat)
needrestart                                    # Check for needed service restarts
```

---

## Pro Tips & Tricks

### Command Combinations
```bash
# Check if service is running
systemctl is-active service-name

# Backup before edit
cp file file.backup && nano file

# Find and replace in multiple files
find . -name "*.txt" -exec sed -i 's/old/new/g' {} \;

# Monitor disk usage
watch -n 5 'df -h'

# Stream processing: find large files
find . -type f -size +100M -exec ls -lh {} \;

# Check service status and restart if down
systemctl is-active service || systemctl restart service

# List processes and sort by memory usage
ps aux --sort=-%mem | head -10

# Find recently modified files
find . -type f -mtime -1 -ls

# Check open ports and services
netstat -tulpn | grep LISTEN

# Continuous log monitoring with grep
tail -f /var/log/syslog | grep "pattern"

# View real-time network connections
watch -n 1 'netstat -tulpn | grep LISTEN'

# Archive and compress old logs
tar -czf logs-$(date +%Y%m%d).tar.gz /var/log/

# Parallel processing with xargs
find . -name "*.log" | xargs -P 4 gzip

# Test HTTP response time
curl -o /dev/null -s -w '%{time_total}\n' https://example.com
```

---

## Quick Reference Summary

| Category | Purpose | Common Command |
|----------|---------|-----------------|
| **Container** | Container isolation | `docker run`, `docker-compose up` |
| **Orchestration** | Container management | `kubectl apply`, `kubectl scale` |
| **Version Control** | Code management | `git push`, `git commit` |
| **Cloud** | Infrastructure | `aws ec2`, `az vm create` |
| **Config Management** | Infrastructure as Code | `terraform apply` |
| **Monitoring** | System observation | `top`, `docker stats` |
| **Security** | Access control | `ssh`, `chmod`, `sudo` |
| **Networking** | Connectivity | `ping`, `curl`, `netstat` |

---

## Last Updated
March 26, 2026
