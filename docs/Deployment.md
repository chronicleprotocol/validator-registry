# Deployment

This document describes how to deploy a new `ValidatorRegistry` instance.

## Environment Variables

The following environment variables must be set:

- `RPC_URL`: The RPC URL of an EVM node
- `KEYSTORE`: The path to the keystore file containing the encrypted private key
    - Note that password can either be entered on request or set via the `KEYSTORE_PASSWORD` environment variable
- `KEYSTORE_PASSWORD`: The password for the keystore file
- `ETHERSCAN_API_URL`: The Etherscan API URL for the Etherscan's chain instance
    - Note that the API endpoint varies per Etherscan chain instance
    - Note to point to actual API endpoint (e.g. `/api`) and not just host
- `ETHERSCAN_API_KEY`: The Etherscan API key for the Etherscan's chain instance
- `INITIAL_AUTHED`: The address being auth'ed on the newly deployed `ValidatorRegistry` instance

Note that an `.env.example` file is provided in the project root. To set all environment variables at once, create a copy of the file and rename the copy to `.env`, adjust the variable's values', and run `source .env`.

To easily check the environment variables, run:

```bash
$ env | grep -e "RPC_URL" -e "PRIVATE_KEY" -e "ETHERSCAN_API_URL" -e "ETHERSCAN_API_KEY" -e "INITIAL_AUTHED"
```

## Code Adjustments

Two code adjustments are necessary to give each deployed contract instance a unique name:

1. Adjust the `ValidatorRegistry_COUNTER`'s name in `src/ValidatorRegistry.sol` and remove the `@todo` comment
2. Adjust the import of the `ValidatorRegistry_COUNTER` in `script/ValidatorRegistry.s.sol` and remove the `@todo` comment

## Execution

The deployment process consists of two steps - the actual deployment and the subsequent Etherscan verification.

Deployment:

```bash
$ SALT_BYTES32=$(cast format-bytes32-string $SALT) && \
  forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url "$RPC_URL" \
    --sig "$(cast calldata "deploy(address)" "$INITIAL_AUTHED")" \
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

The deployment command will log the address of the newly deployed contract address. Store this address in the `$VALIDATOR_REGISTRY` environment variable and continue with the verification.

Verification:

```bash
$ forge verify-contract \
    "$VALIDATOR_REGISTRY" \
    --verifier-url "$ETHERSCAN_API_URL" \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address)" "$INITIAL_AUTHED") \
    src/ValidatorRegistry.sol:"$SALT"
```
