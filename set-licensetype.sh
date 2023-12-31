#!/bin/bash

set -eu

#
# Installs the Azure Hybrid Benefit extension and sets the license value
# and optional subscription private offer Id for a list of Azure RHEL VMs 
# in a single resource group.
#
# Usage: 
# ./set-licensetype.sh --license-type [license type] --offer-id [offer id] --resource-group [resource group] --ids [TXT file with VM IDs]
# 
# Example: 
# ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt
#
# Parameters:
#  --license-type / -l :    The license type to set for the VMs. 
#                           Possible values are: `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, `RHEL_BYOS`
#  --resource-group / -g :  The resource group containing the VMs.
#  --ids / -i :             A TXT file containing the VM IDs, one per line.
#  --offer-id / -o :        [OPTIONAL] If you bought Red Hat subscriptions from Microsoft, the Id of the Marketplace private offer.
# 
# All parameters are required except offer-id.
#

# Include helper functions.
source ./includes.sh

# Exit with usage information.
exit_abnormal() {
    usage
    exit 1
}

# Initialize parameters specified from command line
license_type=""
resource_group=""
ids=""
offer_id=""

# Parse the command line options
OPTS=$(getopt -o l:g:i:o: -l license-type:,resource-group:,ids:,offer-id: -n "$0" -- "$@") || exit
eval set -- "$OPTS"
while [[ $1 != -- ]]; do
    case $1 in
        -l|--license-type)
            license_type=${2}
            shift 2
            ;;
        -g|--resource-group)
            resource_group=${2}
            shift 2
            ;;
        -i|--ids)
            ids=${2}
            shift 2
            ;;
        -o|--offer-id)
            offer_id=${2}
            shift 2
            ;;
        esac
done

# Check if azCLI is installed
if ! command -v az &> /dev/null
then
    echo "ERROR: azCLI could not be found. Please install it or add it to your PATH."
    echo ""
    exit_abnormal
fi

# Check if the license type is set and one of the allowed values
if [[ -z "$license_type" ]]; then
    echo "ERROR: Parameter --license-type is required"
    echo ""
    exit_abnormal
fi
ALLOWED_LICENSE_TYPES=(RHEL_BASE RHEL_EUS RHEL_SAPAPPS RHEL_SAPHA RHEL_BASESAPAPPS RHEL_BASESAPHA RHEL_BYOS)
if [[ ! " ${ALLOWED_LICENSE_TYPES[@]} " =~ " ${license_type} " ]]; then
    echo "Parameter --license-type ${license_type} is not allowed. License type must be one of the following values: ${ALLOWED_LICENSE_TYPES[@]}"
    exit_abnormal
fi

# Check if the resource group is set
if [[ -z "$resource_group" ]]; then
    echo "ERROR: Parameter --resource-group is required"
    echo ""
    exit_abnormal
fi

# Check if the VM IDs file is set and exists
if [[ -z "$ids" ]]; then
    echo "ERROR: Parameter --ids is required"
    echo ""
    exit_abnormal
fi
if [ ! -f "$ids" ]; then
    echo "ERROR: File $ids does not exist."
    echo ""
    exit_abnormal
fi

# Check if the offer ID is set and a valid GUID.
if [[ ! -z "$offer_id" ]]; then
    # UUID regex validation from https://stackoverflow.com/a/13653180
    uuid_regex=“/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i”

    if ! [[ $offer_id =~ $uuid_regex ]]; then
        echo "ERROR: Parameter --offer-id $offer_id is not a valid GUID."
        echo ""
        exit_abnormal
    fi
fi

# Get the VM IDs from the file
vm_ids=$(cat $ids)

# Install the Azure Hybrid Benefit extension and set the license type for each VM
statusline="Installing Azure Hybrid Benefit extension and setting license type $license_type"
if [[ ! -z "$offer_id" ]]; then
    statusline="$statusline and offer id $offer_id"
fi
statusline="$statusline for listed VMs in resource group $resource_group"
echo "$statusline"
az vm extension set \
    --publisher Microsoft.Azure.AzureHybridBenefit \
    --name AHBForRHEL \
    --resource-group $resource_group \
    --ids $vm_ids
az vm update \
    --resource-group $resource_group \
    --set tags.licensePrivateOfferId=$offer_id \
    --license-type $license_type \
    --ids $vm_ids
echo "Done"
exit 0
