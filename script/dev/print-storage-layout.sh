#!/bin/bash

# Script to print the storage layout of ValidatorRegistry.
#
# Run via:
# ```bash
# $ script/dev/print-storage-layout.sh
# ```

echo "ValidatorRegistry Storage Layout"
forge inspect src/ValidatorRegistry.sol:ValidatorRegistry storage --pretty
