#!/bin/bash

# Test the set-licensetype.sh script.
#

# Include helper functions.
source ./includes.sh

# Test failing with missing parameters.
test_missing_parameters() {
    # Run the script.
    output=$(source ./set-licensetype.sh)

    # Check the result.
    assertEquals "The script should have failed because of missing parameters." 1 $?
    assertContains "The script should have printed failure information." "$output" "ERROR: Parameter --license-type is required"
    assertContains "The script should have printed usage information." "$output" "$(usage)"
}

# Test failing with missing azCLI.
test_missing_azcli() {
    # Unset the path to azCLI.
    REALPATH=${PATH}
    PATH=$(sed 's/\/usr\/bin//g' <<< ${PATH})
    # Run the script.
    output=$(source ./set-licensetype.sh --license-type RHEL_BYOS --resource-group myResourceGroup --ids vms.txt)
    errorcode=$?
    # Re-set the path
    PATH=${REALPATH}
    # Check the result.
    assertEquals "The script should have failed with missing azCLI." 1 $errorcode
    assertContains "The script should have printed failure information." "$output" "ERROR: azCLI could not be found. Please install it or add it to your PATH."
}


# Run the tests.
. shunit2