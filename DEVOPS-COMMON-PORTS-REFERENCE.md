# DevOps Engineer Common Ports Reference

A comprehensive guide to essential ports used in DevOps environments.

---

## Table of Contents
1. [Web Services](#web-services)
2. [Databases](#databases)
3. [Container & Orchestration](#container--orchestration)
4. [Monitoring & Observability](#monitoring--observability)
5. [Infrastructure & Cloud](#infrastructure--cloud)
6. [CI/CD & Version Control](#cicd--version-control)
7. [Message Queues & Streaming](#message-queues--streaming)
8. [DNS & Network Services](#dns--network-services)
9. [Remote Access & SSH](#remote-access--ssh)
10. [Development Tools](#development-tools)
11. [Security & VPN](#security--vpn)

---

## Web Services

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 80 | HTTP | TCP | Standard web traffic |
| 443 | HTTPS | TCP | Secure web traffic (SSL/TLS) |
| 8080 | HTTP Alternate | TCP | Alternative HTTP (often used for development/proxies) |
| 8443 | HTTPS Alternate | TCP | Alternative HTTPS |
| 3000 | Node.js / React Dev | TCP | Development servers (Node, Rails, etc.) |
| 5000 | Flask / Python Dev | TCP | Python development server |
| 5173 | Vite Dev | TCP | Vite development server |
| 9000 | SonarQube | TCP | Code quality analysis |
| 8081 | Artifactory / Nexus | TCP | Maven/artifact repository alternate |

---

## Databases

### Relational Databases

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 3306 | MySQL | TCP | MySQL database |
| 3307 | MySQL Alternate | TCP | MySQL secondary instance |
| 5432 | PostgreSQL | TCP | PostgreSQL database |
| 5433 | PostgreSQL Alternate | TCP | PostgreSQL secondary instance |
| 1433 | MS SQL Server | TCP | Microsoft SQL Server |
| 1434 | MS SQL Server | UDP | SQL Server Browser |
| 5984 | CouchDB | TCP | CouchDB NoSQL database |
| 27017 | MongoDB | TCP | MongoDB database |
| 27018 | MongoDB | TCP | MongoDB secondary/sharded |
| 27019 | MongoDB | TCP | MongoDB config server |
| 27020 | MongoDB | TCP | MongoDB mongos |
| 9200 | Elasticsearch | TCP | Elasticsearch REST API |
| 9300 | Elasticsearch | TCP | Elasticsearch node communication |

### Cache & In-Memory

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 6379 | Redis | TCP | In-memory data store |
| 6380 | Redis | TCP | Redis secondary/alternate |
| 11211 | Memcached | TCP | Distributed memory caching |
| 11212 | Memcached | UDP | Memcached (UDP) |

---

## Container & Orchestration

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 2375 | Docker | TCP | Docker API (insecure - legacy) |
| 2376 | Docker | TCP | Docker API (secure) |
| 2377 | Docker Swarm | TCP | Docker Swarm manager |
| 7946 | Docker Swarm | TCP/UDP | Docker Swarm gossip |
| 4789 | Docker Swarm | UDP | VXLAN overlay network |
| 6443 | Kubernetes | TCP | Kubernetes API Server |
| 8472 | Kubernetes | UDP | Flannel VXLAN |
| 8285 | Kubernetes | TCP | Flannel UDP |
| 8086 | Kubernetes | TCP | Minikube default |
| 10250 | Kubernetes | TCP | Kubelet API |
| 10251 | Kubernetes | TCP | kube-scheduler |
| 10252 | Kubernetes | TCP | kube-controller-manager |
| 10256 | Kubernetes | TCP | kube-proxy metrics |
| 30000-32767 | Kubernetes | TCP | NodePort service range |

### Kubernetes Components

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 179 | Calico | TCP | BGP (Bird) |
| 5473 | Calico | TCP | Calico BIRD Route Reflector |
| 4789 | Weave | UDP | Weave overlay |
| 6783 | Weave | TCP | Weave control |
| 6784 | Weave | UDP | Weave data |

---

## Monitoring & Observability

### Prometheus Ecosystem

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 9090 | Prometheus | TCP | Prometheus Web UI & API |
| 9091 | Prometheus | TCP | Prometheus Pushgateway |
| 9093 | Alertmanager | TCP | Alertmanager Web UI |
| 9094 | Alertmanager | TCP | Alertmanager cluster |
| 9095 | Alertmanager | TCP | Alertmanager mesh |
| 3000 | Grafana | TCP | Grafana Web UI |
| 9100 | Node Exporter | TCP | Node metrics |
| 9113 | Nginx Exporter | TCP | Nginx metrics |
| 9104 | MySQL Exporter | TCP | MySQL metrics |
| 9187 | PostgreSQL Exporter | TCP | PostgreSQL metrics |
| 9121 | Redis Exporter | TCP | Redis metrics |
| 9150 | HAProxy Exporter | TCP | HAProxy metrics |
| 9179 | Docker Exporter | TCP | Docker metrics |

### ELK Stack (Elasticsearch, Logstash, Kibana)

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 5601 | Kibana | TCP | Kibana Web UI |
| 9200 | Elasticsearch | TCP | Elasticsearch HTTP |
| 9300 | Elasticsearch | TCP | Elasticsearch node-to-node |
| 5000 | Logstash | TCP | Logstash input |
| 9600 | Logstash | TCP | Logstash monitoring API |

### Other Monitoring

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 8086 | InfluxDB | TCP | InfluxDB HTTP |
| 8888 | InfluxDB | TCP | InfluxDB RPC |
| 19530 | Milvus | TCP | Vector DB |
| 7199 | Cassandra | TCP | Cassandra JMX monitoring |
| 9042 | Cassandra | TCP | Cassandra native protocol |
| 8500 | Consul | TCP | Consul Web UI & API |
| 8600 | Consul | UDP | Consul DNS |

---

## Infrastructure & Cloud

### Hypervisors & Virtualization

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 6080 | VNC | TCP | VNC noVNC web console |
| 5900 | VNC | TCP | VNC remote desktop |
| 5901 | VNC | TCP | VNC secondary |
| 16509 | libvirt | TCP | libvirt daemon |
| 49152 | QEMU | TCP | QEMU migration |

### API Gateways & Load Balancers

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 8080 | Kong | TCP | Kong API Gateway |
| 8443 | Kong | TCP | Kong HTTPS |
| 8001 | Kong | TCP | Kong Admin API |
| 8444 | Kong | TCP | Kong Admin HTTPS |
| 6379 | Redis (Kong) | TCP | Kong data store |
| 8000 | Nginx | TCP | Nginx proxy |
| 80 | HAProxy | TCP | HAProxy frontend |
| 8888 | Envoy | TCP | Envoy admin |

---

## CI/CD & Version Control

### Git Services

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 22 | SSH/Git | TCP | Git SSH access |
| 80 | HTTP Git | TCP | Git HTTP access |
| 443 | HTTPS Git | TCP | Git HTTPS access |
| 9418 | Git | TCP | Git protocol (read-only) |

### CI/CD Platforms

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 8080 | Jenkins | TCP | Jenkins Web UI |
| 50000 | Jenkins | TCP | Jenkins agent communication |
| 8081 | Artifactory | TCP | JFrog Artifactory |
| 8082 | Artifactory | TCP | Artifactory metadata |
| 8000 | GitLab | TCP | GitLab Web UI |
| 8443 | GitLab | TCP | GitLab HTTPS |
| 9022 | GitLab | TCP | GitLab SSH |
| 9080 | GitLab Runner | TCP | GitLab Runner |
| 3000 | Gitea | TCP | Gitea Web UI |
| 222 | Gitea | TCP | Gitea SSH |
| 6000 | GitHub Actions | TCP | GitHub Actions (API) |
| 8080 | Drone CI | TCP | Drone CI Web UI |
| 3050 | Drone CI | TCP | Drone CI RPC |

### Nexus Repository

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 8081 | Nexus | TCP | Nexus Repository Manager |
| 8082 | Nexus | TCP | Nexus Docker Registry |

---

## Message Queues & Streaming

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 5672 | RabbitMQ | TCP | AMQP protocol |
| 5671 | RabbitMQ | TCP | AMQP SSL/TLS |
| 15672 | RabbitMQ | TCP | RabbitMQ Management UI |
| 15671 | RabbitMQ | TCP | RabbitMQ Management SSL |
| 4369 | RabbitMQ | TCP | Erlang Port Mapper Daemon |
| 25672 | RabbitMQ | TCP | RabbitMQ clustering |
| 9092 | Kafka | TCP | Kafka broker |
| 9093 | Kafka | TCP | Kafka SSL/TLS |
| 9101 | Kafka | TCP | Kafka JMX monitoring |
| 2181 | ZooKeeper | TCP | ZooKeeper client |
| 2888 | ZooKeeper | TCP | ZooKeeper server |
| 3888 | ZooKeeper | TCP | ZooKeeper leader election |
| 6379 | Redis | TCP | Redis (also used for queuing) |
| 5432 | PostgreSQL | TCP | PostgreSQL (logical replication) |
| 3306 | MySQL | TCP | MySQL (replication) |
| 27017 | MongoDB | TCP | MongoDB (replication) |
| 3671 | MQTT | TCP | MQTT Broker |
| 8883 | MQTT | TCP | MQTT SSL/TLS |
| 1883 | MQTT | TCP | MQTT (standard) |

---

## DNS & Network Services

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 53 | DNS | TCP/UDP | Domain Name System |
| 67 | DHCP | UDP | DHCP server |
| 68 | DHCP | UDP | DHCP client |
| 69 | TFTP | UDP | Trivial File Transfer Protocol |
| 123 | NTP | UDP | Network Time Protocol |
| 514 | Syslog | TCP/UDP | System logging |
| 554 | RTSP | TCP | Real Time Streaming Protocol |
| 5355 | mDNS | UDP | Multicast DNS |
| 5353 | Avahi mDNS | UDP | Avahi mDNS |
| 389 | LDAP | TCP | Lightweight Directory Access |
| 636 | LDAPS | TCP | LDAP SSL/TLS |
| 88 | Kerberos | TCP/UDP | Kerberos authentication |
| 464 | Kerberos | TCP/UDP | Kerberos password change |
| 749 | Kerberos | TCP | Kerberos admin |

---

## Remote Access & SSH

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 22 | SSH | TCP | Secure Shell |
| 2222 | SSH Alternate | TCP | SSH alternate port |
| 3389 | RDP | TCP | Remote Desktop Protocol (Windows) |
| 5985 | WinRM | TCP | Windows Remote Management |
| 5986 | WinRM | TCP | WinRM SSL/TLS |
| 23 | Telnet | TCP | Unencrypted remote access (deprecated) |
| 3306 | MySQL Shell | TCP | MySQL command line |
| 5432 | psql | TCP | PostgreSQL command line |

---

## Development Tools

### Package Managers & Registries

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 4873 | npm Registry | TCP | NPM private registry |
| 8080 | Nexus | TCP | Maven central repository |
| 9150 | Artifactory | TCP | Artifact caching |
| 443 | pip / PyPI | TCP | Python Package Index |
| 8080 | Docker Registry | TCP | Private Docker Registry v2 |
| 5000 | Docker Registry | TCP | Docker Registry (dev) |

### IDE & Debugging

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 5037 | ADB | TCP | Android Debug Bridge |
| 35729 | LiveReload | TCP | Live reload development |
| 3000 | Webpack Dev | TCP | Webpack development server |
| 5173 | Vite Dev | TCP | Vite dev server |
| 4200 | Angular Dev | TCP | Angular development server |
| 8000 | Django Dev | TCP | Django development server |
| 9000 | PHP Dev | TCP | PHP development server |

---

## Security & VPN

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 1194 | OpenVPN | TCP/UDP | OpenVPN |
| 500 | IPSec | UDP | Internet Key Exchange |
| 4500 | IPSec | UDP | IPSec NAT Traversal |
| 1723 | PPTP | TCP | Point-to-Point Tunneling |
| 1701 | L2TP | UDP | Layer 2 Tunneling Protocol |
| 51820 | WireGuard | UDP | WireGuard VPN |
| 8834 | Nessus | TCP | Nessus vulnerability scanner |
| 9392 | Nessus | TCP | Nessus essentials |
| 22 | SSH Tunnel | TCP | SSH tunneling |
| 443 | HTTPs VPN | TCP | HTTPS VPN tunneling |

---

## Cloud Platforms

### AWS

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 443 | AWS API | TCP | AWS API endpoints |
| 80 | AWS ELB | TCP | Elastic Load Balancer |
| 443 | AWS NLB | TCP | Network Load Balancer |
| 3389 | AWS EC2 | TCP | RDP for Windows EC2 |
| 5432 | RDS PostgreSQL | TCP | RDS database access |
| 3306 | RDS MySQL | TCP | RDS MySQL access |
| 1433 | RDS SQL Server | TCP | RDS SQL Server |
| 6379 | ElastiCache | TCP | Redis cache |
| 11211 | ElastiCache | TCP | Memcached |
| 5672 | AWS MQ | TCP | Message Broker |

### Azure

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 443 | Azure API | TCP | Azure REST API |
| 3389 | Azure VM | TCP | RDP for Azure VMs |
| 22 | Azure VM | TCP | SSH for Linux VMs |
| 5432 | Azure DB | TCP | PostgreSQL |
| 3306 | Azure DB | TCP | MySQL |
| 1433 | Azure SQL | TCP | SQL Database |
| 6379 | Azure Cache | TCP | Redis cache |
| 5671 | Service Bus | TCP | Azure Service Bus |

### GCP

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 443 | GCP API | TCP | Google Cloud API |
| 3389 | GCP VM | TCP | RDP for Windows |
| 22 | GCP VM | TCP | SSH for Linux |
| 5432 | Cloud SQL | TCP | PostgreSQL |
| 3306 | Cloud SQL | TCP | MySQL |
| 5984 | Firestore | TCP | NoSQL database |

---

## Windows Services

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 135 | RPC EndPoint Mapper | TCP/UDP | Remote Procedure Call |
| 139 | NetBIOS | TCP | NetBIOS Session |
| 445 | SMB | TCP | Server Message Block (File Sharing) |
| 464 | Kerberos | TCP/UDP | Password change |
| 389 | LDAP | TCP | Active Directory |
| 636 | LDAPS | TCP | LDAP SSL |
| 3268 | LDAP GC | TCP | LDAP Global Catalog |
| 3269 | LDAPS GC | TCP | LDAP GC SSL |
| 3389 | RDP | TCP | Remote Desktop |
| 5985 | WinRM | TCP | Windows Remote Management |
| 5986 | WinRM | TCP | WinRM SSL |
| 49152-49255 | RPC Dynamic | TCP/UDP | Dynamic port range |

---

## Quick Troubleshooting Guide

### Common Port Conflicts

```bash
# Linux - Check if port is in use
lsof -i :8080                                  # Check specific port
netstat -tlnp | grep 8080                      # Alternative method
ss -tlnp | grep 8080                           # Modern method

# Linux - Kill process using port
fuser -k 8080/tcp                              # Kill by port

# Windows - Check port usage
netstat -ano | findstr :8080                   # Find port
taskkill /PID <PID> /F                         # Kill process

# macOS - Check port
lsof -i :8080                                  # Check port
kill -9 <PID>                                  # Kill process
```

### Test Connectivity to Port

```bash
# Test if port is open
nc -zv hostname 8080                           # netcat test
telnet hostname 8080                           # Telnet test
curl http://hostname:8080                      # HTTP test
wget http://hostname:8080                      # Wget test

# SSH port forwarding to test
ssh -L 9000:localhost:8080 user@host           # Local forward
```

---

## Port Configuration Tips

### Best Practices

1. **Never use ports 1-1023** (privileged ports) for development
2. **Use 8000-8999** for development tools
3. **Use 9000-9999** for monitoring/observability
4. **Always document custom port mappings**
5. **Use environment variables** for port configuration
6. **Document firewall rules** alongside services

### Common Port Ranges

| Range | Purpose | Example |
|-------|---------|---------|
| 1-1023 | Privileged/system ports | SSH (22), DNS (53) |
| 1024-5999 | User/ephemeral | Unprivileged services |
| 6000-9999 | Development/Tools | Web dev, monitoring |
| 10000-20000 | Dynamic/Kubernetes | NodePorts, services |
| 30000-32767 | Kubernetes NodePort | Standard K8s range |
| 49152-65535 | Dynamic/private | Ephemeral ports |

---

## Docker Compose Port Mapping Example

```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"        # HTTP
      - "443:443"      # HTTPS

  db:
    image: postgres:latest
    ports:
      - "5432:5432"    # PostgreSQL

  redis:
    image: redis:latest
    ports:
      - "6379:6379"    # Redis

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"    # Prometheus

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"    # Grafana
```

---

## Kubernetes Service Port Example

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  type: LoadBalancer
  ports:
    - name: http
      port: 80
      targetPort: 8080
      protocol: TCP
    - name: https
      port: 443
      targetPort: 8443
      protocol: TCP
  selector:
    app: web
```

---

## Environment Variable Configuration

```bash
# Example environment file (.env)
HTTP_PORT=8080
HTTPS_PORT=8443
DB_PORT=5432
REDIS_PORT=6379
PROMETHEUS_PORT=9090
GRAFANA_PORT=3000

# Docker example
docker run -e "HTTP_PORT=8080" -p 8080:8080 myapp

# Kubernetes example
env:
  - name: HTTP_PORT
    value: "8080"
```

---

## Firewall Configuration Examples

### UFW (Ubuntu)

```bash
# Allow specific ports
ufw allow 22/tcp          # SSH
ufw allow 80/tcp          # HTTP
ufw allow 443/tcp         # HTTPS
ufw allow 3306/tcp        # MySQL
ufw allow 5432/tcp        # PostgreSQL

# Allow port range
ufw allow 30000:32767/tcp # Kubernetes NodePorts

# Deny specific port
ufw deny 23/tcp           # Telnet
```

### firewalld (Red Hat/CentOS)

```bash
# Allow specific ports
firewall-cmd --permanent --add-port=80/tcp
firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --permanent --add-port=3306/tcp

# Allow port range
firewall-cmd --permanent --add-port=30000-32767/tcp

# Reload firewall
firewall-cmd --reload
```

### iptables (Manual Rules)

```bash
# Allow port
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Allow port range
iptables -A INPUT -p tcp --dport 30000:32767 -j ACCEPT

# Deny port
iptables -A INPUT -p tcp --dport 23 -j DROP

# Save rules
iptables-save > /etc/iptables/rules.v4
```

---

## Last Updated
March 26, 2026

## Notes
- Ports can vary based on configuration
- Always check service documentation for accurate port numbers
- Firewall rules should be implemented based on security requirements
- Use network segmentation to restrict port access between zones
