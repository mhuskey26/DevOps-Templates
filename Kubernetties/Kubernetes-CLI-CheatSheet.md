# Kubernetes CLI Cheat Sheet

Practical reference for setting up, configuring, and managing Kubernetes with CLI tools.

## 1) Core Tools and What They Do

- `kubectl`: Main Kubernetes CLI to interact with cluster API.
- `kubeadm`: Bootstrap and manage Kubernetes control plane/node join (self-managed clusters).
- `kubelet`: Node agent that runs on each worker/control-plane node.
- `helm`: Kubernetes package manager for installing apps/charts.
- `k9s`: Terminal UI for browsing and managing cluster resources.
- `kind`: Run local Kubernetes clusters in Docker.
- `minikube`: Run local single/multi-node Kubernetes clusters.

## 2) Install and Verify CLI Tools

```bash
# kubectl (Linux)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
kubectl version --short
kubectl cluster-info
```

```bash
# Helm (Linux)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

## 3) Cluster Access and Context Management

```bash
# Show kubeconfig currently in use
kubectl config view
kubectl config current-context
kubectl config get-contexts

# Switch context
kubectl config use-context CONTEXT_NAME

# Set default namespace for current context
kubectl config set-context --current --namespace=dev

# Merge multiple kubeconfig files
export KUBECONFIG=~/.kube/config:~/other-config
kubectl config view --merge --flatten > ~/.kube/merged-config
mv ~/.kube/merged-config ~/.kube/config
```

Use these when you manage multiple clusters/environments (dev, stage, prod).

## 4) Create Local Clusters (Learning/Testing)

### kind

```bash
kind create cluster --name dev-cluster
kind get clusters
kubectl cluster-info --context kind-dev-cluster
kind delete cluster --name dev-cluster
```

### minikube

```bash
minikube start
minikube status
minikube addons list
minikube stop
minikube delete
```

Use these for local testing and manifest validation before pushing to shared clusters.

## 5) Self-Managed Cluster Bootstrap (kubeadm)

```bash
# Initialize control plane (on control-plane node)
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

# Configure kubectl for your user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Join worker node (run on worker using token printed by init)
sudo kubeadm join CONTROL_PLANE_IP:6443 --token TOKEN --discovery-token-ca-cert-hash sha256:HASH

# Generate a new join command if needed
kubeadm token create --print-join-command
```

Use this flow to build your own cluster on VMs/bare metal.

## 6) Namespace and Resource Basics

```bash
# List common resources
kubectl get nodes
kubectl get ns
kubectl get pods -A
kubectl get svc -A
kubectl get deploy -A

# Create namespace
kubectl create namespace dev

# Apply/delete manifests
kubectl apply -f app.yaml
kubectl apply -f k8s/
kubectl delete -f app.yaml

# Dry-run (server-side validation)
kubectl apply -f app.yaml --dry-run=server

# Diff before apply
kubectl diff -f app.yaml
```

Use these commands for daily deployment workflows.

## 7) Inspect, Debug, and Troubleshoot

```bash
# Describe object with events/state
kubectl describe pod POD_NAME -n dev
kubectl describe node NODE_NAME

# Logs
kubectl logs POD_NAME -n dev
kubectl logs POD_NAME -c CONTAINER_NAME -n dev
kubectl logs -f POD_NAME -n dev
kubectl logs --since=1h POD_NAME -n dev

# Exec into container
kubectl exec -it POD_NAME -n dev -- /bin/sh
kubectl exec -it POD_NAME -c CONTAINER_NAME -n dev -- /bin/bash

# Port-forward local to pod/service
kubectl port-forward pod/POD_NAME 8080:80 -n dev
kubectl port-forward svc/SVC_NAME 8080:80 -n dev

# Get events sorted
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

Use these first when pods are CrashLooping, Pending, or not reachable.

## 8) Workload Management (Deployments, StatefulSets, Jobs)

```bash
# Deployment lifecycle
kubectl create deployment web --image=nginx -n dev
kubectl scale deployment web --replicas=3 -n dev
kubectl rollout status deployment/web -n dev
kubectl rollout history deployment/web -n dev
kubectl rollout undo deployment/web -n dev

# Set/update image
kubectl set image deployment/web nginx=nginx:1.27 -n dev

# Restart deployment pods
kubectl rollout restart deployment/web -n dev

# StatefulSet / DaemonSet / Job
kubectl get statefulset -A
kubectl get daemonset -A
kubectl create job db-backup --image=busybox -n ops -- /bin/sh -c "echo backup"
kubectl get jobs -n ops
```

Use these to manage app updates and controller-driven workloads.

## 9) Services, Networking, and Ingress

```bash
# Expose deployment as service
kubectl expose deployment web --port=80 --target-port=80 --type=ClusterIP -n dev
kubectl get svc -n dev

# Patch service type (example to NodePort)
kubectl patch svc web -n dev -p '{"spec":{"type":"NodePort"}}'

# Ingress
kubectl get ingress -A
kubectl describe ingress ING_NAME -n dev
```

Use services for service discovery/load-balancing and ingress for HTTP routing.

## 10) Config and Secrets

```bash
# ConfigMap
kubectl create configmap app-config --from-literal=ENV=dev -n dev
kubectl create configmap app-file-config --from-file=app.properties -n dev
kubectl get configmap -n dev

# Secret (generic)
kubectl create secret generic db-secret --from-literal=username=app --from-literal=password='StrongPass' -n dev
kubectl get secret -n dev

# Secret (TLS)
kubectl create secret tls web-tls --cert=tls.crt --key=tls.key -n dev
```

Use ConfigMaps for non-sensitive settings and Secrets for sensitive values.

## 11) Node Operations and Scheduling

```bash
# Mark node unschedulable / schedulable
kubectl cordon NODE_NAME
kubectl uncordon NODE_NAME

# Drain node for maintenance
kubectl drain NODE_NAME --ignore-daemonsets --delete-emptydir-data

# Labels and taints
kubectl label nodes NODE_NAME env=prod
kubectl taint nodes NODE_NAME dedicated=gpu:NoSchedule
kubectl taint nodes NODE_NAME dedicated=gpu:NoSchedule-
```

Use these for maintenance windows and workload placement control.

## 12) RBAC and Access Control

```bash
# List RBAC resources
kubectl get roles,rolebindings -A
kubectl get clusterroles,clusterrolebindings

# Check user/service-account permissions
kubectl auth can-i get pods -n dev
kubectl auth can-i create deployments -n dev
kubectl auth can-i '*' '*' --all-namespaces
```

Use this to validate least-privilege access and troubleshoot permission errors.

## 13) Helm App Management

```bash
# Repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm search repo nginx

# Install/upgrade/rollback
helm install web bitnami/nginx -n dev --create-namespace
helm list -A
helm upgrade web bitnami/nginx -n dev
helm rollback web 1 -n dev
helm uninstall web -n dev
```

Use Helm for packaged, versioned application deployments.

## 14) Output Formatting and Querying

```bash
# Wide output
kubectl get pods -A -o wide

# YAML/JSON output
kubectl get deploy web -n dev -o yaml
kubectl get pod POD_NAME -n dev -o json

# Custom columns
kubectl get pods -n dev -o custom-columns=NAME:.metadata.name,PHASE:.status.phase,NODE:.spec.nodeName

# JSONPath
kubectl get pods -n dev -o jsonpath='{.items[*].metadata.name}'
```

Use these to script automation and extract targeted fields.

## 15) Cleanup and Safety Patterns

```bash
# Delete by kind/name
kubectl delete pod POD_NAME -n dev
kubectl delete deploy web -n dev

# Delete all pods in namespace (careful)
kubectl delete pods --all -n dev

# Delete namespace (removes all contained resources)
kubectl delete ns dev

# Force delete stuck pod (last resort)
kubectl delete pod POD_NAME -n dev --grace-period=0 --force
```

Use careful scoping with `-n` and context checks before destructive operations.

## 16) High-Value Shortcuts

```bash
# Aliases
alias k=kubectl
complete -F __start_kubectl k

# Quick checks
kubectl config current-context
kubectl get nodes
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 30
```

## 17) Recommended Workflow (Safe Day-to-Day)

1. Confirm context and namespace.
2. Validate manifest with dry-run and diff.
3. Apply changes.
4. Check rollout status.
5. Verify logs/events if issues appear.
6. Roll back if needed.

```bash
kubectl config current-context
kubectl config set-context --current --namespace=dev
kubectl apply -f app.yaml --dry-run=server
kubectl diff -f app.yaml
kubectl apply -f app.yaml
kubectl rollout status deployment/web -n dev
```
