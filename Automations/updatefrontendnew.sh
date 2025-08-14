#!/bin/bash
set -e

# ===== Azure Config =====
RESOURCE_GROUP="dev-wanderlust-resources"  # Name of the Azure Resource Group
PUBLIC_IP_NAME="aks-wanderlust-public-ip"  # Name of the Azure Public IP resource

# Path to the .env file
file_to_find="../frontend/.env.docker"

ipv4_address=$(az network public-ip show \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IP_NAME \
    --query 'ipAddress' \
    --output tsv)

if [[ -z "$ipv4_address" ]]; then
    echo "ERROR: Could not fetch public IP from Azure."
    exit 1
fi

# ===== Check and Update VITE_API_PATH =====
current_url=$(cat "$file_to_find")

if [[ "$current_url" != "VITE_API_PATH=\"http://${ipv4_address}:31100\"" ]]; then
    if [ -f "$file_to_find" ]; then
        sed -i -e "s|VITE_API_PATH.*|VITE_API_PATH=\"http://${ipv4_address}:31100\"|g" "$file_to_find"
        echo "Updated VITE_API_PATH in $file_to_find to http://${ipv4_address}:31100"
    else
        echo " ERROR: File not found at $file_to_find"
        exit 1
    fi
else
    echo "VITE_API_PATH already up-to-date."
fi
