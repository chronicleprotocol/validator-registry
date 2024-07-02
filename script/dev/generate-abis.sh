#!/bin/bash

# Script to generate ValidatorRegistry's ABI.
# Saves the ABI in fresh abis/ directory.
#
# Run via:
# ```bash
# $ script/dev/generate-abis.sh
# ```

rm -rf abis/
mkdir abis

echo "Generating ValidatorRegistry's ABI"
forge inspect src/ValidatorRegistry.sol:ValidatorRegistry abi > abis/ValidatorRegistry.json
