# hello-aks-demo — Setup Instructions

End-to-end guide: provision ACR + AKS with Terraform, push a container image via GitHub Actions, and deploy it to Kubernetes with Helm.

---

## Prerequisites

| Tool | Install |
|---|---|
| Azure CLI | https://learn.microsoft.com/en-us/cli/azure/install-azure-cli |
| Terraform / OpenTofu | https://developer.hashicorp.com/terraform/install |
| kubectl | `az aks install-cli` |
| Helm | https://helm.sh/docs/intro/install |
| Docker (local testing only) | https://docs.docker.com/get-docker |

```bash
# Verify all tools are present
az version
terraform version
kubectl version --client
helm version
```

---

## Step 1 — Azure Login

```bash
az login
az account set --subscription <your-subscription-id>
az account show   # confirm correct subscription
```

---

## Step 2 — Update Variables

Open [infra/terraform.tfvars](infra/terraform.tfvars) and change the following:

```hcl
acr_name = "mydemoacr"   # ← MUST be globally unique, alphanumeric, 5–50 chars
```

Everything else can stay as-is for a demo. To deploy to a different region, change `location`.

---

## Step 3 — Provision Infrastructure with Terraform

```bash
cd infra

terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

This creates:
- Resource group `rg-aks-demo`
- Azure Container Registry
- AKS cluster (2 nodes, Standard_D2s_v3)
- Role assignment granting AKS the `AcrPull` permission on ACR

**After apply**, note the outputs:
```bash
terraform output acr_login_server   # e.g. mydemoacr.azurecr.io
```

**Optional — enable remote state** (recommended for teams): uncomment the `backend "azurerm"` block in [infra/backend.tf](infra/backend.tf), create the storage account manually, then re-run `terraform init`.

---

## Step 4 — Connect kubectl to AKS

```bash
az aks get-credentials \
  --resource-group rg-aks-demo \
  --name aks-demo

kubectl get nodes   # should show 2 Ready nodes
```

---

## Step 5 — Test the App Locally (optional)

```bash
# From repo root
docker build -t hello-aks:local .
docker run -p 8080:80 hello-aks:local
# open http://localhost:8080
```

---

## Step 6 — Set Up GitHub Actions (OIDC)

No passwords or long-lived secrets — GitHub authenticates to Azure via a federated credential.

### 6a. Create the app registration

```bash
az ad app create --display-name "github-aks-demo"

APP_ID=$(az ad app list \
  --display-name "github-aks-demo" \
  --query "[0].appId" -o tsv)

az ad sp create --id $APP_ID

echo "Client ID: $APP_ID"
```

### 6b. Add the federated credential

Replace `YOUR_ORG` and `YOUR_REPO` with your GitHub org/username and repo name.

```bash
az ad app federated-credential create --id $APP_ID --parameters '{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:YOUR_ORG/YOUR_REPO:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

### 6c. Grant the SP Contributor on the resource group

```bash
RG_ID=$(az group show --name rg-aks-demo --query id -o tsv)

az role assignment create \
  --assignee $APP_ID \
  --role Contributor \
  --scope $RG_ID
```

### 6d. Add secrets to GitHub

Go to your repo → **Settings → Secrets and variables → Actions** and add:

| Secret name | Value |
|---|---|
| `AZURE_CLIENT_ID` | The `$APP_ID` from above |
| `AZURE_TENANT_ID` | `az account show --query tenantId -o tsv` |
| `AZURE_SUBSCRIPTION_ID` | `az account show --query id -o tsv` |

### 6e. Update the workflow env vars

Open [.github/workflows/deploy.yml](.github/workflows/deploy.yml) and confirm these match your Terraform values:

```yaml
env:
  ACR_NAME: mydemoacr       # must match acr_name in terraform.tfvars
  IMAGE_NAME: hello-aks
  RESOURCE_GROUP: rg-aks-demo
  AKS_CLUSTER: aks-demo
```

---

## Step 7 — Deploy via GitHub Actions

Push to `main` to trigger the workflow:

```bash
git add .
git commit -m "initial hello-aks-demo"
git push origin main
```

The workflow will:
1. Log in to Azure via OIDC
2. Build the Docker image in ACR (`az acr build` — no local Docker needed on the runner)
3. Get AKS credentials
4. Run `helm upgrade --install` to deploy the app

Monitor it in **GitHub → Actions**.

---

## Step 8 — Verify the Deployment

```bash
# Watch pods come up
kubectl get pods -n demo -w

# Check the deployment
kubectl get deployment hello-aks -n demo

# Get the public IP (may take ~60 seconds to provision)
kubectl get svc hello-aks -n demo

# Curl the live site
EXTERNAL_IP=$(kubectl get svc hello-aks -n demo \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl http://$EXTERNAL_IP
# Expected: <h1>Hello from AKS</h1>
```

---

## Teardown

```bash
# Remove Kubernetes resources
helm uninstall hello-aks -n demo

# Destroy all Azure infrastructure
cd infra
terraform destroy
```

---

## Troubleshooting

| Problem | Check |
|---|---|
| `ImagePullBackOff` | AcrPull role assigned? Run `terraform apply` again to confirm. |
| `Pending` pods | `kubectl describe pod <name> -n demo` → check Events section |
| `CrashLoopBackOff` | `kubectl logs <pod> -n demo --previous` |
| LoadBalancer IP stuck as `<pending>` | Wait 60–90s; AKS provisions Azure LB asynchronously |
| OIDC auth fails in Actions | Verify the `subject` in the federated credential matches your exact branch/repo path |
| ACR name already taken | Change `acr_name` in `terraform.tfvars` — it must be globally unique |
