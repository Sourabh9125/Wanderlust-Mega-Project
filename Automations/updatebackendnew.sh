#!/bin/bash
set -e

# ===== Azure Config =====
RESOURCE_GROUP="dev-wanderlust-resources"
PUBLIC_IP_NAME="aks-wanderlust-public-ip"  # This is the Azure Public IP resource name

# Path to the .env file
file_to_find="../backend/.env.docker"

# ===== Fetch Public IP from Azure =====
ipv4_address=$(az network public-ip show \
    --resource-group $RESOURCE_GROUP \
    --name $PUBLIC_IP_NAME \
    --query 'ipAddress' \
    --output tsv)

if [[ -z "$ipv4_address" ]]; then
    echo " ERROR: Could not fetch public IP from Azure."
    exit 1
fi

# ===== Check and Update FRONTEND_URL =====
current_url=$(sed -n "4p" "$file_to_find")

if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:5173\"" ]]; then
    if [ -f "$file_to_find" ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:5173\"|g" "$file_to_find"
        echo "Updated FRONTEND_URL in $file_to_find to http://${ipv4_address}:5173"
    else
        echo " ERROR: File not found at $file_to_find"
        exit 1
    fi
else
    echo " FRONTEND_URL already up-to-date."
fi
