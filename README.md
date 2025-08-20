# Wanderlust - Your Ultimate Travel Blog 🌍✈️

WanderLust is a simple MERN travel blog website ✈ This project is aimed to help people to contribute in open source, upskill in react and also master git.

![Screenshot] (https://github.com/Sourabh9125/Wanderlust-Mega-Project/blob/production/Assets/Screenshot%202025-08-20%20at%204.48.11%20PM.png)
#

# Wanderlust Mega Project End to End Implementation

### In this demo, we will see how to deploy an end to end three tier MERN stack application on AKS cluster.

## Tech stack used in this project:
- GitHub (Code)
- Docker (Containerization)
- Azure Pipeline (CI)
- ArgoCD (CD)
- Redis (Caching)
- AZURE EKS (Kubernetes)
- Helm (Monitoring using grafana and prometheus)

## A comprehensive DevOps project demonstrating Azure Kubernetes Service (AKS) deployment with Terraform, Azure DevOps CI/CD pipeline, and ArgoCD GitOps implementation.

## 🚀 Project Components Created

This project includes the following custom-built components:

- **Terraform Infrastructure**: Complete Azure AKS cluster setup
- **Azure DevOps Pipeline**: CI/CD with container builds and deployments
- **Kubernetes Manifests**: Production-ready K8s configurations
- **Docker Containers**: Frontend (React) and Backend (Node.js)
- **Automation Scripts**: Deployment automation for image updates
- **ArgoCD GitOps**: Continuous deployment configuration

## 🛠️ Prerequisites

- **Azure CLI** installed
- **kubectl** installed
- **Terraform** installed
- **Docker** installed
- **Helm** installed
- **Azure subscription** with appropriate permissions

## 🚀 VM Setup and Deployment

### 1. Azure Authentication Setup

```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table

# Set your subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify current subscription
az account show
```

### 2. Configure Terraform Variables

Create `terraform/terraform.tfvars` file:

```hcl
# Azure Authentication
subscription_id = "your-subscription-id"
client_id       = "your-service-principal-client-id"
client_secret   = "your-service-principal-secret"
tenant_id       = "your-tenant-id"

# Environment Configuration
env         = "dev"
location    = "East US"
node_count  = 2
vm_size     = "Standard_DS2_v2"

# Optional: SSH Key Path
ssh_public_key = "~/.ssh/id_rsa.pub"
```

### 3. Deploy Infrastructure with Terraform

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply -auto-approve

# Note the outputs (AKS cluster name, resource group)
terraform output
```

### 4. Configure kubectl Access

```bash
# Get AKS credentials
az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME>

# Test connection
kubectl get nodes
```

**If you get authentication errors:**

```bash
# Get admin credentials
az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME> --admin

# Create cluster admin binding
kubectl create clusterrolebinding my-cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(az ad signed-in-user show --query userPrincipalName -o tsv)

# Verify access
kubectl get nodes
```

### 5. Deploy Application to Kubernetes

```bash
# Deploy all Kubernetes manifests
kubectl apply -f kubernetes/

# Check deployment status
kubectl get all -n wanderlust

# Monitor pods
kubectl get pods -n wanderlust -w
```

### 6. Install and Configure ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Check ArgoCD services
kubectl get svc -n argocd

# Patch ArgoCD server to NodePort (for VM access)
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

### 7. Install ArgoCD CLI

```bash
# Download and install ArgoCD CLI
sudo curl --silent --location -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.7/argocd-linux-amd64

# Make executable
sudo chmod +x /usr/local/bin/argocd

# Verify installation
argocd version --client
```

### 8. Install Ingress Controller

```bash
# Create ingress-nginx namespace
kubectl create namespace ingress-nginx

# Add Helm repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install NGINX Ingress Controller
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.type=LoadBalancer

# Check ingress services
kubectl get svc -n ingress-nginx
```

### 9. Configure Load Balancer IP (if needed)

```bash
# Find load balancer public IP
az network public-ip list --resource-group aks-wanderlust-nodes -o table

# If load balancer IP is not automatically assigned, patch the service
kubectl patch svc nginx-ingress-ingress-nginx-controller -n ingress-nginx -p '{"spec": {"loadBalancerIP": "YOUR_PUBLIC_IP"}}'
```

## 🏗️ Infrastructure Components

### Terraform Resources Created

The `terraform/` directory contains:

- **main.tf**: Core Azure resources
- **aks.tf**: AKS cluster configuration
- **variables.tf**: Input variables
- **output.tf**: Output values
- **terraform.tfvars**: Environment-specific values

**Key Resources:**
- Resource Group
- Virtual Network and Subnet
- AKS Cluster
- Public IP
- Network Security Group

## 🔄 Azure DevOps Pipeline

### Pipeline Configuration

The `azure-pipelines.yml` includes:

- **Build Stage**: Docker image builds
- **Security Scanning**: Container vulnerability scans
- **Deployment**: Automated K8s deployment
- **Automation Scripts**: Image tag updates

### Automation Scripts

Located in `Automations/` directory:

#### Frontend Update Script (`updatefrontendnew.sh`)
```bash
#!/bin/bash
echo "Updating frontend image tag..."
sed -i "s|image: sourabhlodhi/wanderlust-frontend:.*|image: sourabhlodhi/wanderlust-frontend:$BUILD_ID|g" kubernetes/frontend.yml
kubectl apply -f kubernetes/frontend.yml
```

#### Backend Update Script (`updatebackendnew.sh`)
```bash
#!/bin/bash
echo "Updating backend image tag..."
sed -i "s|image: sourabhlodhi/wanderlust-backend:.*|image: sourabhlodhi/wanderlust-backend:$BUILD_ID|g" kubernetes/backend.yml
kubectl apply -f kubernetes/backend.yml
```

## 📊 Monitoring and Verification

### Check Deployment Status
```bash
# Check all resources
kubectl get all -n wanderlust

# Check pod logs
kubectl logs -f deployment/frontend-deployment -n wanderlust
kubectl logs -f deployment/backend-deployment -n wanderlust

# Check service endpoints
kubectl get endpoints -n wanderlust

# Check ingress
kubectl get ingress -n wanderlust
```

### Access Applications
```bash
# Get service external IPs
kubectl get svc -n wanderlust

# Get ingress IP
kubectl get ingress -n wanderlust

# Port forward for local access (if needed)
kubectl port-forward svc/frontend-svc 5173:5173 -n wanderlust
kubectl port-forward svc/backend-svc 8080:8080 -n wanderlust
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. kubectl Access Issues
```bash
# Reset kubectl config
az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME> --admin --overwrite-existing

# Create cluster role binding
kubectl create clusterrolebinding my-cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(az ad signed-in-user show --query userPrincipalName -o tsv)
```

#### 2. Load Balancer Not Getting IP
```bash
# Check Azure load balancer resources
az network lb list --resource-group aks-wanderlust-nodes

# Manually assign public IP
az network public-ip create --resource-group aks-wanderlust-nodes --name wanderlust-ip --sku Standard
```

## 🧹 Cleanup

### Destroy Infrastructure
```bash
cd terraform
terraform destroy -auto-approve
```

## 📝 Important Notes

- Replace `<RESOURCE_GROUP_NAME>` and `<AKS_CLUSTER_NAME>` with actual values from Terraform output
- Update `terraform.tfvars` with your Azure credentials
- Ensure your Azure account has sufficient permissions for AKS and networking resources
- Monitor Azure costs as AKS clusters incur charges
- Use `kubectl get events -n wanderlust` to troubleshoot deployment issues

## 🔗 Useful Commands

```bash
# Get Terraform outputs
terraform output -json


```
