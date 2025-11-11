#!/usr/bin/env bash
# Cleanup script: delete the resource group used for the lab
RG='rg-az700-lab'
set -euo pipefail

echo "Deleting resource group ${RG} (this will remove all resources created by the lab)..."
az group delete --name "$RG" --yes --no-wait
echo "Delete initiated for ${RG}. Use 'az group show -n $RG' to check status or the portal to monitor." 
