# DevOps Assessment Cram Sheet
### Azure | Terraform/OpenTofu | GitHub Actions | ACR | AKS | Helm

---

## Table of Contents
1. [Sample Web App](#1-sample-web-app)
2. [Dockerfile](#2-dockerfile)
3. [Terraform — ACR + AKS Infrastructure](#3-terraform--acr--aks-infrastructure)
4. [Helm Chart](#4-helm-chart)
5. [GitHub Actions — Build, Push, Deploy](#5-github-actions--build-push-deploy)
6. [Verify with kubectl](#6-verify-with-kubectl)
7. [Key Concepts Cheat Sheet](#7-key-concepts-cheat-sheet)

---

## 1. Sample Web App

A minimal Nginx static site — no runtime dependencies, smallest possible image.

**`app/index.html`**
```html
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8"><title>Hello from AKS</title></head>
<body>
  <h1>Hello from AKS</h1>
  <p>Deployed via Helm | Image from ACR | Infrastructure via Terraform</p>
</body>
</html>
```

---

## 2. Dockerfile

```dockerfile
FROM nginx:alpine
COPY app/index.html /usr/share/nginx/html/index.html
EXPOSE 80
```

**Build and test locally:**
```bash
docker build -t hello-aks:local .
docker run -p 8080:80 hello-aks:local
# open http://localhost:8080
```

---

## 3. Terraform — ACR + AKS Infrastructure

### File Layout

```
infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── backend.tf
└── terraform.tfvars
```

### `infra/variables.tf`

```hcl
variable "location"     { default = "eastus" }
variable "rg_name"      { default = "rg-aks-demo" }
variable "acr_name"     { default = "mydemoacr" }
variable "cluster_name" { default = "aks-demo" }
variable "node_count"   { default = 2 }
```

### `infra/main.tf`

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" { features {} }

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

# ACR
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
}

# AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name       = "system"
    node_count = var.node_count
    vm_size    = "Standard_D2s_v3"
  }

  identity { type = "SystemAssigned" }
}

# Grant AKS permission to pull from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
```

### `infra/outputs.tf`

```hcl
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
```

### `infra/backend.tf` (remote state — optional but recommended)

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "satfstatedemo"
    container_name       = "tfstate"
    key                  = "demo/terraform.tfstate"
  }
}
```

### Deploy

```bash
cd infra
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Connect kubectl to new cluster
az aks get-credentials \
  --resource-group rg-aks-demo \
  --name aks-demo

kubectl get nodes
```

---

## 4. Helm Chart

### Chart Layout

```
charts/hello-aks/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── deployment.yaml
    └── service.yaml
```

### `charts/hello-aks/Chart.yaml`

```yaml
apiVersion: v2
name: hello-aks
description: Demo Nginx app on AKS
version: 0.1.0
appVersion: "1.0.0"
```

### `charts/hello-aks/values.yaml`

```yaml
replicaCount: 2

image:
  repository: mydemoacr.azurecr.io/hello-aks
  tag: latest
  pullPolicy: Always

service:
  type: LoadBalancer
  port: 80
  targetPort: 80

resources:
  requests:
    cpu: 50m
    memory: 64Mi
  limits:
    cpu: 200m
    memory: 128Mi
```

### `charts/hello-aks/templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    app: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app: {{ .Release.Name }}
    spec:
      containers:
        - name: hello-aks
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - containerPort: {{ .Values.service.targetPort }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

### `charts/hello-aks/templates/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Release.Name }}
  ports:
    - port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
      protocol: TCP
```

### Install / upgrade manually

```bash
helm upgrade --install hello-aks ./charts/hello-aks \
  --set image.tag=<git-sha> \
  --namespace demo --create-namespace
```

---

## 5. GitHub Actions — Build, Push, Deploy

### Required Secrets (set in repo Settings → Secrets)

| Secret | Value |
|---|---|
| `AZURE_CLIENT_ID` | App registration client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID |

> Uses **OIDC federated credentials** — no stored passwords or long-lived tokens.

### `.github/workflows/deploy.yml`

```yaml
name: Build and Deploy to AKS

on:
  push:
    branches: [main]

env:
  ACR_NAME: mydemoacr
  IMAGE_NAME: hello-aks
  RESOURCE_GROUP: rg-aks-demo
  AKS_CLUSTER: aks-demo

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    outputs:
      image_tag: ${{ github.sha }}

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Build and push image to ACR
        run: |
          az acr build \
            --registry $ACR_NAME \
            --image $IMAGE_NAME:${{ github.sha }} \
            --image $IMAGE_NAME:latest \
            .

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read

    steps:
      - uses: actions/checkout@v4

      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

      - name: Get AKS credentials
        run: |
          az aks get-credentials \
            --resource-group $RESOURCE_GROUP \
            --name $AKS_CLUSTER \
            --overwrite-existing

      - name: Install Helm
        uses: azure/setup-helm@v3

      - name: Deploy with Helm
        run: |
          helm upgrade --install hello-aks ./charts/hello-aks \
            --set image.repository=$ACR_NAME.azurecr.io/$IMAGE_NAME \
            --set image.tag=${{ github.sha }} \
            --namespace demo --create-namespace \
            --wait --timeout 3m
```

### OIDC Setup (one-time)

```bash
# 1. Create app registration
az ad app create --display-name "github-aks-demo"
APP_ID=$(az ad app list --display-name "github-aks-demo" --query "[0].appId" -o tsv)
az ad sp create --id $APP_ID

# 2. Federated credential for main branch
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'

# 3. Grant Contributor on the resource group
az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope $(az group show -n rg-aks-demo --query id -o tsv)
```

---

## 6. Verify with kubectl

```bash
# Watch pods come up
kubectl get pods -n demo -w

# Check deployment
kubectl get deployment hello-aks -n demo

# Get the external LoadBalancer IP (may take ~60s to provision)
kubectl get svc hello-aks -n demo

# Once EXTERNAL-IP is assigned, curl it
EXTERNAL_IP=$(kubectl get svc hello-aks -n demo \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
curl http://$EXTERNAL_IP

# Describe for event details
kubectl describe deployment hello-aks -n demo

# Logs from a running pod
kubectl logs -l app=hello-aks -n demo

# Full end-to-end rollout status
kubectl rollout status deployment/hello-aks -n demo
```

**Expected output from `curl`:**
```html
<h1>Hello from AKS</h1>
```

---

## 7. Key Concepts Cheat Sheet

### Terraform

| Command | Purpose |
|---|---|
| `terraform init` | Download providers, configure backend |
| `terraform plan -out=tfplan` | Preview changes, save artifact |
| `terraform apply tfplan` | Apply saved plan (no prompt) |
| `terraform state list` | See all tracked resources |
| `terraform import` | Adopt existing resource into state |
| `terraform state rm` | Remove from state without destroying |
| `terraform output -json` | Dump all outputs as JSON |

### ACR

| Concept | Detail |
|---|---|
| Login server | `<name>.azurecr.io` |
| AcrPull | Minimum role for AKS to pull images |
| AcrPush | Role for CI to push images |
| `az acr build` | Cloud build — no local Docker needed |
| Admin access | Disabled by default; use managed identity |

### AKS

| Concept | Detail |
|---|---|
| Control plane | Azure-managed; free on Standard tier |
| System node pool | Runs `kube-system` workloads |
| `kubelet_identity` | The MI used by nodes to pull from ACR |
| `az aks get-credentials` | Writes kubeconfig for `kubectl` |
| `--attach-acr` | Shortcut to grant AcrPull during create |

### Helm

| Command | Purpose |
|---|---|
| `helm upgrade --install` | Install or upgrade idempotently |
| `--set image.tag=abc` | Override a single value on CLI |
| `helm rollback <release> <rev>` | Revert to a previous revision |
| `helm template` | Render manifests locally (dry-run) |
| `helm list -A` | All releases, all namespaces |

### Kubernetes Service Types

| Type | External Access | When to Use |
|---|---|---|
| ClusterIP | No (cluster-internal) | Service-to-service |
| NodePort | Via node IP + port | Local dev/testing |
| LoadBalancer | Yes (Azure Public IP) | Production external traffic |

### Common Pod Failure States

| Status | Cause | Fix |
|---|---|---|
| `ImagePullBackOff` | ACR auth failed or tag missing | Check AcrPull role assignment, tag |
| `CrashLoopBackOff` | App exits at startup | `kubectl logs --previous` |
| `Pending` | No schedulable node | Scale node pool or reduce resource requests |
| `OOMKilled` | Memory limit exceeded | Raise `resources.limits.memory` |

---

*Last updated: 2026-06-17*
