#!/bin/bash

# Script to generate ValidatorRegistry's flattened contract.
# Saves the contracts in fresh flattened/ directory.
#
# Run via:
# ```bash
# $ script/dev/generate-flattened.sh
# ```

rm -rf flattened/
mkdir flattened

echo "Generating flattened ValidatorRegistry's contract"
forge flatten src/ValidatorRegistry.sol > flattened/ValidatorRegistry.sol
