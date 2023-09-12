# bulk-set-azurevm-license
A simple script to install [Azure Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-hybrid-benefit-linux) and set the license value on many Azure RHEL VMs at once. Just load the VM ids into a text file and feed them into this bash script.

## Usage

`./set-licensetype.sh --license-type RHEL_BYOS --resource-group mygroup --ids vm-ids.txt`

Acceptable values for license-type are listed in the [AHB Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-hybrid-benefit-linux). They are hard-coded into the script based on the time of this writing: `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, and `RHEL_BYOS`

## Can't I do this with Azure CLI?

Yes, this is just an ease-of-use wrapper around two AzCLI commands:

```
az vm extension set \
    --publisher Microsoft.Azure.AzureHybridBenefit \
    --name AHBForRHEL \
    --resource-group $resource_group \
    --ids $(cat vm-ids.txt)
az vm update \
    --resource-group $resource_group \
    --license-type $license_type \
    --ids $(cat vm-ids.txt)
```

## Warning

This script will modify your VMs billing, and could create extra charges on your Azure bill! **If you set the license to any option other than `RHEL_BYOS`, you will enable Pay-As-You-Go billing for your RHEL license**. Your RHEL license charge will appear on your Azure bill.
