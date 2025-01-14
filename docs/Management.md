# Management

This document describes how to manage deployed `ValidatorRegistry` instances.

## Table of Contents

- [Management](#management)
  - [Table of Contents](#table-of-contents)
  - [Environment Variables](#environment-variables)
  - [Functions](#functions)
    - [`IValidatorRegistry::lift`](#ivalidatorregistrylift)
    - [`IValidatorRegistry::lift multiple`](#ivalidatorregistrylift-multiple)
    - [`IValidatorRegistry::drop`](#ivalidatorregistrydrop)
    - [`IValidatorRegistry::drop multiple`](#ivalidatorregistrydrop-multiple)
    - [`IAuth::rely`](#iauthrely)
    - [`IAuth::deny`](#iauthdeny)

## Environment Variables

The following environment variables must be set for all commands:

- `RPC_URL`: The RPC URL of an EVM node
- `KEYSTORE`: The path to the keystore file containing the encrypted private key
    - Note that password can either be entered on request or set via the `KEYSTORE_PASSWORD` environment variable
- `KEYSTORE_PASSWORD`: The password for the keystore file
- `VALIDATOR_REGISTRY`: The `ValidatorRegistry` instance to manage

Note that an `.env.example` file is provided in the project root. To set all environment variables at once, create a copy of the file and rename the copy to `.env`, adjust the variable's values', and run `source .env`.

To easily check the environment variables, run:

```bash
$ env | grep -e "RPC_URL" -e "KEYSTORE" -e "KEYSTORE_PASSWORD" -e "VALIDATOR_REGISTRY"
```

## Functions

### `IValidatorRegistry::lift`

Set the following environment variables:

- `VALIDATOR_PUBLIC_KEY_X`: The validator's public key's x coordinate
- `VALIDATOR_PUBLIC_KEY_Y`: The validator's public key's y coordinate
- `VALIDATOR_SIG_V`: The validator's registration signature's v value
- `VALIDATOR_SIG_R`: The validator's registration signature's r value
- `VALIDATOR_SIG_S`: The validator's registration signature's s value

Run:

```bash
$ forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "lift(address,uint,uint,uint8,bytes32,bytes32)" "$VALIDATOR_REGISTRY" "$VALIDATOR_PUBLIC_KEY_X" "$VALIDATOR_PUBLIC_KEY_Y" "$VALIDATOR_SIG_V" "$VALIDATOR_SIG_R" "$VALIDATOR_SIG_S")\
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IValidatorRegistry::lift multiple`

Set the following environment variables:

- `VALIDATOR_PUBLIC_KEY_XS`: The validators' public key's x coordinate
    - Note to use the following format: `"[<elem>,<elem>]"`
- `VALIDATOR_PUBLIC_KEY_YS`: The validators' public key's y coordinate
    - Note to use the following format: `"[<elem>,<elem>]"`
- `VALIDATOR_SIG_VS`: The validators' registration signature's v value
    - Note to use the following format: `"[<elem>,<elem>]"`
- `VALIDATOR_SIG_RS`: The validators' registration signature's r value
    - Note to use the following format: `"[<elem>,<elem>]"`
- `VALIDATOR_SIG_SS`: The validators' registration signature's s value
    - Note to use the following format: `"[<elem>,<elem>]"`

Run:

```bash
$ forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "lift(address,uint[],uint[],uint8[],bytes32[],bytes32[])" "$VALIDATOR_REGISTRY" "$VALIDATOR_PUBLIC_KEY_XS" "$VALIDATOR_PUBLIC_KEY_YS" "$VALIDATOR_SIG_VS" "$VALIDATOR_SIG_RS" "$VALIDATOR_SIG_SS")\
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IValidatorRegistry::drop`

Set the following environment variables:

- `VALIDATOR_ID`: The validator's validator id

Run:

```bash
$ forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "drop(address,uint8)" "$VALIDATOR_REGISTRY" "$VALIDATOR_ID")\
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IValidatorRegistry::drop multiple`

Set the following environment variables:

- `VALIDATOR_IDS`: The validators' validator ids
    - Note to use the following format: `"[<elem>,<elem>]"`

Run:

```bash
$ forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "drop(address,uint8[])" "$VALIDATOR_REGISTRY" "$VALIDATOR_IDS")\
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IAuth::rely`

Set the following environment variables:

- `WHO`: The address to grant auth to

Run:

```bash
$ forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "rely(address,address)" "$VALIDATOR_REGISTRY" "$WHO") \
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IAuth::deny`

Set the following environment variables:

- `WHO`: The address to renounce auth from

Run:

```bash
$ forge script \
    --keystore "$KEYSTORE" \
    --password "$KEYSTORE_PASSWORD" \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "deny(address,address)" "$VALIDATOR_REGISTRY" "$$WHO") \
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```
