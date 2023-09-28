# bulk-set-azurevm-license
A simple script to install [Azure Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-hybrid-benefit-linux) and set the license value (and optional subscription private offer Id) on many Azure RHEL VMs at once. Just load the VM ids into a text file and feed them into this bash script.

## Usage

`./set-licensetype.sh --license-type [license type] --offer-id [offer id] --resource-group [resource group] --ids [TXT file with VM IDs]`

Acceptable values for license-type are listed in the [AHB Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-hybrid-benefit-linux). They are hard-coded into the script based on the time of this writing: `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, and `RHEL_BYOS`.

Resource group is for the Azure Resource Group, and Ids refers to a text file which lists the VM names, one per line.

If you purchased Red Hat subscriptions from the Azure Marketplace, you may enter your private offer Id at the same time with the `-o`/`--offer-id` parameter.

All parameters are required except `offer-id`.

## Tests

Software testing isn't just a fetish - it's a lifestyle. You can test this script if you install shunit2, with `./test-set-licensetype.sh`.

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
    --set tags.licensePrivateOfferId=$offer_id \
    --license-type $license_type \
    --ids $(cat vm-ids.txt)
```

## Warning

This script will modify your VMs billing, and could create extra charges on your Azure bill! **If you set the license to any option other than `RHEL_BYOS`, you will enable Pay-As-You-Go billing for your RHEL license**. Your RHEL license charge will appear on your Azure bill.
