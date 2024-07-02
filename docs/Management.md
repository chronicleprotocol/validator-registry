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
- `PRIVATE_KEY`: The private key to use
- `VALIDATOR_REGISTRY`: The `ValidatorRegistry` instance to manage

Note that an `.env.example` file is provided in the project root. To set all environment variables at once, create a copy of the file and rename the copy to `.env`, adjust the variable's values', and run `source .env`.

To easily check the environment variables, run:

```bash
$ env | grep -e "RPC_URL" -e "PRIVATE_KEY" -e "VALIDATOR_REGISTRY"
```

## Functions

### `IValidatorRegistry::lift`

Set the following environment variables:

- `VALIDATOR`: The validator's address

Run:

```bash
$ forge script \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "lift(address,address)" "$VALIDATOR_REGISTRY" "$VALIDATOR")\
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IValidatorRegistry::lift multiple`

Set the following environment variables:

- `VALIDATORS`: The validators' addresses
    - Note to use the following format: `"[<elem>,<elem>]"`

Run:

```bash
$ forge script \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "lift(address,address[])" "$VALIDATOR_REGISTRY" "$VALIDATOR")\
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```

### `IValidatorRegistry::drop`

Set the following environment variables:

- `VALIDATOR_ID`: The validator's validator id

Run:

```bash
$ forge script \
    --private-key $PRIVATE_KEY \
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
    --private-key $PRIVATE_KEY \
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
    --private-key $PRIVATE_KEY \
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
    --private-key $PRIVATE_KEY \
    --broadcast \
    --rpc-url $RPC_URL \
    --sig $(cast calldata "deny(address,address)" "$VALIDATOR_REGISTRY" "$$WHO") \
    -vvv \
    script/ValidatorRegistry.s.sol:ValidatorRegistryScript
```
