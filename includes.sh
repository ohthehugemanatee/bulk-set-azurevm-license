#!/bin/bash
# Print usage information.
usage() {
    echo "Usage: $0 --license-type [license type] --offer-id [optional offer id] --resource-group [resource group] --ids [TXT file with VM IDs]"
    echo "Example: $0 --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt"
    echo "Parameters:"
    echo "  --license-type / -l :    The license type to set for the VMs. Possible values are: RHEL_BASE, RHEL_EUS, RHEL_SAPAPPS, RHEL_SAPHA, RHEL_BASESAPAPPS, RHEL_BASESAPHA, RHEL_BYOS"
    echo "  --resource-group / -g :  The resource group containing the VMs."
    echo "  --ids / -i :             A TXT file containing the VM IDs, one per line."
    echo "  --offer-id / -o :        [OPTIONAL] If you bought Red Hat subscriptions from Microsoft, the Id of the Marketplace private offer."
    echo ""
    echo "All parameters are required except offer-id."
}