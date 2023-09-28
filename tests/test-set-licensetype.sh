#!/bin/bash

# Test the set-licensetype.sh script. To be run from the parent directory.
#

# Include helper functions.
source ./includes.sh

# Mock AzCLI.
az() { return 0; }

# Test failing with various missing (required) parameters.
test_missing_parameters() {
    # Run the script.
    output=$(source ./set-licensetype.sh)

    # Check the result.
    assertEquals "The script should have failed because of missing parameters." 1 $?
    assertContains "The script should have printed failure information." "$output" "ERROR: Parameter --license-type is required"
    assertContains "The script should have printed usage information." "$output" "$(usage)"
    # Run the script missing license-type.
    output=$(source ./set-licensetype.sh --resource-group invalid --ids vms.txt)

    # Check the result.
    assertEquals "The script should have failed because of missing parameters." 1 $?
    assertContains "The script should have printed failure information." "$output" "ERROR: Parameter --license-type is required"
    assertContains "The script should have printed usage information." "$output" "$(usage)"

    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group invalid --ids vms.txt)

    # Run the script missing resource-group.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --ids vms.txt)

    # Check the result.
    assertEquals "The script should have failed because of missing parameters." 1 $?
    assertContains "The script should have printed failure information." "$output" "ERROR: Parameter --resource-group is required"
    assertContains "The script should have printed usage information." "$output" "$(usage)"

    # Run the script missing ids.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group invalid)

    # Check the result.
    assertEquals "The script should have failed because of missing parameters." 1 $?
    assertContains "The script should have printed failure information." "$output" "ERROR: Parameter --ids is required"
    assertContains "The script should have printed usage information." "$output" "$(usage)"

}

# Test failing with missing azCLI.
test_missing_azcli() {
    # Unset any previous mock.
    unset -f az
    # Unset the path to azCLI.
    REALPATH=${PATH}
    # Get the path to azCLI.
    AzPath=$(dirname $(which az))
    # Remove the path to azCLI from the PATH variable.
    PATH=$(sed 's/'${AzPath}'//g' <<< ${PATH})

    # Run the script.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt)
    errorcode=$?
    
    # Re-set the path
    PATH=${REALPATH}
    # Re-set the default mock
    az() { return 0; }
    # Check the result.
    assertEquals "The script should have failed with missing azCLI." 1 $errorcode
    assertContains "The script should have printed failure information." "$output" "ERROR: azCLI could not be found. Please install it or add it to your PATH."
    assertContains "The script should have printed usage information." "$output" "$(usage)"
}

# Test failing with invalid license type.
test_invalid_license_type() {
    # Run the script.
    output=$(source ./set-licensetype.sh --license-type invalid --resource-group myResourceGroup --ids vms.txt)

    # Check the result.
    assertEquals "The script should have failed with invalid license type." 1 $?
    assertContains "The script should have printed failure information." "$output" "Parameter --license-type invalid is not allowed. License type must be one of the following values: ${ALLOWED_LICENSE_TYPES[@]}"
    assertContains "The script should have printed usage information." "$output" "$(usage)"
}

# Test failing with invalid VM IDs file.
test_invalid_ids_file() {
    # Run the script.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids invalid)

    # Check the result.
    assertEquals "The script should have failed with invalid VM IDs file." 1 $?
    assertContains "The script should have printed failure information." "$output" "ERROR: File invalid does not exist."
    assertContains "The script should have printed usage information." "$output" "$(usage)"
}

# Test failing with invalid offer ID.
test_invalid_offer_id() {
    # Create a file with VM IDs.
    echo "vm1" > vms.txt
    # Run the script.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt --offer-id invalid)
    errorcode=$?
    # Clean up the file.
    rm vms.txt
    # Check the result.
    assertEquals "The script should have failed with invalid offer ID." 1 $errorcode
    assertContains "The script should have printed failure information." "$output" "Parameter --offer-id invalid is not a valid GUID."
    assertContains "The script should have printed usage information." "$output" "$(usage)"
}

# Test successful execution.
test_success() {
    # Mock AzCLI
    az() { echo "az $@"; return 0; }
    # Create a file with VM IDs.
    echo "vm1" > vms.txt
    echo "vm2" >> vms.txt
    # Run the script.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt)
    errorcode=$?
    # Clean up the file.
    rm vms.txt
    # Check the result.
    assertEquals "The script should have succeeded." 0 $errorcode
    # Check the execution log (should execute on both VMs).
    assertContains "The script should have executed az vm update." "$output" "az vm update --resource-group myResourceGroup --set tags.licensePrivateOfferId= --license-type RHEL_BYOS --ids vm1 vm2"
    assertContains "The script should have executed az vm extension set." "$output" "az vm extension set --publisher Microsoft.Azure.AzureHybridBenefit --name AHBForRHEL --resource-group myResourceGroup --ids vm1 vm2"
}

# Run the tests.
. shunit2