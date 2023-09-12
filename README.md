# bulk-set-azurevm-license
A simple script to install [Azure Hybrid Benefit](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-hybrid-benefit-linux) and set the license value on many Azure VMs at once. Just load the VM ids into a text file and feed them into this bash script.

## Usage

`./set-licensetype.sh --license-type RHEL_BYOS --resource-group mygroup --ids vm-ids.txt`

Acceptable values for license-type are listed in the [AHB Documentation](https://learn.microsoft.com/en-us/azure/virtual-machines/linux/azure-hybrid-benefit-linux). At time of this writing, they are:

- For RHEL: `RHEL_BASE`, `RHEL_EUS`, `RHEL_SAPAPPS`, `RHEL_SAPHA`, `RHEL_BASESAPAPPS`, `RHEL_BASESAPHA`, `RHEL_BYOS`
- For SLES: `SLES`, `SLES_SAP`, `SLES_HPC`, `SLES_BYOS`

## Warning

This script will modify your VMs billing, and could create extra charges on your Azure bill! **If you set the license to any option other than `RHEL_BYOS` or `SLES_BYOS`, you will enable Pay-As-You-Go billing for your RHEL or SLES license**. Your SLES or RHEL license charge will appear on your Azure bill.

