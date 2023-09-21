#!/bin/bash

# Test the set-licensetype.sh script.
#

# Include helper functions.
source ./includes.sh

# Test failing with various missing (required) parameters.
test_missing_parameters() {
    # Mock AzCLI.
    az() { return 0; }
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