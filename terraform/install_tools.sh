#!/bin/bash

# Update system and install core packages
sudo apt update

# Docker installation
sudo apt-get update
sudo apt-get install docker.io -y

# User group permission
sudo usermod -aG docker $USER
sudo systemctl restart docker

#Azure CLI installation
 curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Helm installation
sudo snap install helm --classic

# Kubectl installation
sudo snap install kubectl --classic

# install unzip
sudo apt-get install unzip -y
# Download and install kubelogin
curl -LO https://github.com/Azure/kubelogin/releases/latest/download/kubelogin-linux-amd64.zip
unzip kubelogin-linux-amd64.zip -d kubelogin
sudo mv kubelogin/bin/linux_amd64/kubelogin /usr/local/bin/
chmod +x /usr/local/bin/kubelogin

# kubelogin convert-kubeconfig -l azurecli
# az aks get-credentials --resource-group <RESOURCE_GROUP_NAME> --name <AKS_CLUSTER_NAME> --admin
# 2. Create a ClusterRoleBinding for your Azure AD user
# kubectl create clusterrolebinding my-cluster-admin-binding \
#     --clusterrole=cluster-admin \
#     --user=$(az ad signed-in-user show --query userPrincipalName -o tsv)


