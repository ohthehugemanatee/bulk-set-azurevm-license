#!/bin/bash

set -eu

#
# Installs the Azure Hybrid Benefit extension and sets the license value for a
# list of Azure RHEL VMs in a single resource group.
#
# Usage: 
# ./set-licensetype.sh --license-type [license type] --resource-group [resource group] --ids [TXT file with VM IDs]
# 
# Example: 
# ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt
#
# Parameters:
#  --license-type: The license type to set for the VMs. 
#                  Possible values are: `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, `RHEL_BYOS`
#  --resource-group: The resource group containing the VMs.
#  --ids: A TXT file containing the VM IDs, one per line.
# 
# All parameters are required.
#

# Initialize parameters specified from command line
while getopts ":l:r:i:" arg; do
    case "${arg}" in
        l)
            license_type=${OPTARG}
            ;;
        r)
            resource_group=${OPTARG}
            ;;
        i)
            ids=${OPTARG}
            ;;
        esac
done
shift $((OPTIND-1))

# Check if the license type is set and one of the allowed values
if [[ -z "$license_type" ]]; then
    echo "Parameter --license-type is required"
    exit 1
fi
ALLOWED_LICENSE_TYPES=(RHEL_BASE RHEL_EUS RHEL_SAPAPPS RHEL_SAPHA RHEL_BASESAPAPPS RHEL_BASESAPHA RHEL_BYOS)
if [[ ! " ${ALLOWED_LICENSE_TYPES[@]} " =~ " ${license_type} " ]]; then
    echo "Parameter --license-type must be one of the following values: ${ALLOWED_LICENSE_TYPES[@]}"
    exit 1
fi

# Check if the resource group is set
if [[ -z "$resource_group" ]]; then
    echo "Parameter --resource-group is required"
    exit 1
fi

# Check if the VM IDs file is set and exists
if [[ -z "$ids" ]]; then
    echo "Parameter --ids is required"
    exit 1
fi
if [ ! -f "$ids" ]; then
    echo "File $ids does not exist"
    exit 1
fi

# Get the VM IDs from the file
vm_ids=$(cat $ids)

# Install the Azure Hybrid Benefit extension and set the license type for each VM
echo "Installing Azure Hybrid Benefit extension and setting license type $license_type for listed VMs in resource group $resource_group"
az vm extension set \
    --publisher Microsoft.Azure.AzureHybridBenefit \
    --name AHBForRHEL \
    --resource-group $resource_group \
    --settings "{\"licenseType\":\"$license_type\"}" \
    --ids $vm_ids

echo "Done"
exit 0
