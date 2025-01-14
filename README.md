# ValidatorRegistry • [![CI](https://github.com/chronicleprotocol/validator-registry/actions/workflows/ci.yml/badge.svg)](https://github.com/chronicleprotocol/validator-registry/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This contract provides an onchain registry for _Chronicle Protocol_ validators via 1-byte validators ids.

A validators id is computed as the highest-order byte of the validators address, ie `uint8 validatorId = uint8(uint(uint160(validator)) >> 152);`

Due to validator ids being 1 byte, the maximum number of feeds supported is 256.

Note that a set of lifted validators can be encoded in a single uint. The code refers to it as `uint bloom`.

> [!IMPORTANT]
> Due to a vulnerability in Scribe this registry also implements a proof of possession to defend against rogue key attacks.
> The proof of possession is an ECDSA signature signing a message derived from the validator's public key, the Chronicle Validator Registration Message V2.

## Installation

Install module via Foundry:

```bash
$ forge install chronicleprotocol/validator-registry@v1
```

## Contributing

The project uses the Foundry toolchain. You can find installation instructions [here](https://getfoundry.sh/).

Setup:

```bash
$ git clone https://github.com/chronicleprotocol/validator-registry
$ cd validator-registry/
$ forge install
```

Run tests:

```bash
$ forge test
$ forge test -vvvv # Run with full stack traces
$ FOUNDRY_PROFILE=intense forge test # Run in intense mode
```

Lint:

```bash
$ forge fmt [--check]
```

## Dependencies

- [chronicleprotocol/chronicle-std@v2](https://github.com/chronicleprotocol/chronicle-std/tree/v2)
- [chronicleprotocol/scribe@v2](https://github.com/chronicleprotocol/scribe/tree/v2)
