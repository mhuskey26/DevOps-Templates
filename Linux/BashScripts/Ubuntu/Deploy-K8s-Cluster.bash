#!/bin/bash

# Deploy a new Kubernetes cluster on Ubuntu using kubeadm.
# Run on the control-plane node first, then use the printed join command on worker nodes.
# Update the variables below before running.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
K8S_VERSION="1.30"                        # Minor version stream (e.g. 1.30)
POD_CIDR="192.168.0.0/16"                 # Pod network CIDR (matches Calico default)
CNI="calico"                              # CNI plugin: calico | flannel
CONTROL_PLANE_ENDPOINT=""                 # Optional: load-balancer DNS/IP for HA setups
NODE_ROLE="control-plane"                 # control-plane | worker
JOIN_TOKEN=""                             # Required when NODE_ROLE=worker
JOIN_CA_HASH=""                           # Required when NODE_ROLE=worker (sha256:...)
JOIN_ENDPOINT=""                          # Required when NODE_ROLE=worker (IP:6443)
# ──────────────────────────────────────────────────────────────────────────────

# ── Validation ────────────────────────────────────────────────────────────────
if [ "${EUID}" -ne 0 ]; then
  echo "Run this script as root or with sudo."
  exit 1
fi

if [ "$NODE_ROLE" = "worker" ]; then
  if [ -z "$JOIN_TOKEN" ] || [ -z "$JOIN_CA_HASH" ] || [ -z "$JOIN_ENDPOINT" ]; then
    echo "Set JOIN_TOKEN, JOIN_CA_HASH, and JOIN_ENDPOINT before running as a worker node."
    exit 1
  fi
fi
# ──────────────────────────────────────────────────────────────────────────────

export DEBIAN_FRONTEND=noninteractive

echo "==> Updating packages..."
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gpg

# ── Disable swap (required by kubelet) ────────────────────────────────────────
echo "==> Disabling swap..."
swapoff -a
sed -i '/\bswap\b/d' /etc/fstab

# ── Kernel modules and sysctl ─────────────────────────────────────────────────
echo "==> Configuring kernel modules..."
cat > /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat > /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

# ── Install containerd ────────────────────────────────────────────────────────
echo "==> Installing containerd..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y containerd.io

containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

# ── Install kubeadm / kubelet / kubectl ───────────────────────────────────────
echo "==> Installing kubeadm, kubelet, kubectl (v${K8S_VERSION})..."
curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/Release.key" \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v${K8S_VERSION}/deb/ /" \
  > /etc/apt/sources.list.d/kubernetes.list

apt-get update -y
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

# ── Control-plane init ────────────────────────────────────────────────────────
if [ "$NODE_ROLE" = "control-plane" ]; then
  echo "==> Initialising control-plane node..."

  INIT_ARGS="--pod-network-cidr=${POD_CIDR}"

  if [ -n "$CONTROL_PLANE_ENDPOINT" ]; then
    INIT_ARGS="$INIT_ARGS --control-plane-endpoint=${CONTROL_PLANE_ENDPOINT}"
  fi

  kubeadm init $INIT_ARGS | tee /root/kubeadm-init.log

  # Set up kubeconfig for root
  mkdir -p /root/.kube
  cp /etc/kubernetes/admin.conf /root/.kube/config
  chown root:root /root/.kube/config

  # Set up kubeconfig for the invoking sudo user (if present)
  if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    mkdir -p "$USER_HOME/.kube"
    cp /etc/kubernetes/admin.conf "$USER_HOME/.kube/config"
    chown "$SUDO_USER:$SUDO_USER" "$USER_HOME/.kube/config"
  fi

  # ── Install CNI ─────────────────────────────────────────────────────────────
  echo "==> Installing CNI: ${CNI}..."
  if [ "$CNI" = "calico" ]; then
    kubectl --kubeconfig=/etc/kubernetes/admin.conf \
      apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
  elif [ "$CNI" = "flannel" ]; then
    kubectl --kubeconfig=/etc/kubernetes/admin.conf \
      apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
  else
    echo "Unknown CNI '${CNI}'. Install a CNI manually before worker nodes can become Ready."
  fi

  echo ""
  echo "==> Control-plane is ready."
  echo "    Run the following on each worker node (also printed in /root/kubeadm-init.log):"
  grep -A2 "kubeadm join" /root/kubeadm-init.log | tail -3
fi

# ── Worker node join ──────────────────────────────────────────────────────────
if [ "$NODE_ROLE" = "worker" ]; then
  echo "==> Joining cluster at ${JOIN_ENDPOINT}..."
  kubeadm join "$JOIN_ENDPOINT" \
    --token "$JOIN_TOKEN" \
    --discovery-token-ca-cert-hash "$JOIN_CA_HASH"
  echo "==> Worker node joined successfully."
fi
