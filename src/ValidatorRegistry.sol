// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Auth} from "chronicle-std/auth/Auth.sol";

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

import {IValidatorRegistry} from "./IValidatorRegistry.sol";

/**
 * @title ValidatorRegistry
 * @custom:version 2.0.0
 *
 * @notice Single source of truth for all of Chronicle Protocol's validators
 *
 * @dev This contract provides a registry for validators via 1-byte validator
 *      ids.
 *
 *      A validators validator id is computed as the highest-order byte of the
 *      validators address:
 *
 *        uint8 validatorId = uint8(uint(uint160(validator)) >> 152);
 *
 *      Due to validator ids being 1 byte, the maximum number of validators
 *      supported is 256.
 *
 *      Note that a set of lifted validators can be encoded in a single uint.
 *      The code refers to it as `uint bloom`.
 *
 * @dev Due to a vulnerability in Scribe this registry also implements a proof
 *      of possession to defend against rogue key attacks.
 *
 *      The proof of possession is an ECDSA signature signing a message derived
 *      from the validator's public key, the Chronicle Validator Registration
 *      Message V2.
 *
 *      Without a valid ECDSA signature a validator cannot be lifted!
 *
 * @author Chronicle Labs, Inc
 * @custom:security-contact security@chroniclelabs.org
 */
contract ValidatorRegistry is IValidatorRegistry, Auth {
    using LibSecp256k1 for LibSecp256k1.Point;

    /// @dev The prime over which the secp256k1 curve is defined.
    ///
    ///      Defines the upper bound for a secp256k1 field element.
    uint private constant _SECP256K1_P =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

    /// @dev The domain separating context string of the Chronicle Validator
    ///      Registration V2 message.
    string private constant _CONTEXT = "Chronicle Validator Registration V2";

    /// @dev Statically allocated array for validators.
    ///      Indexed via validator's validator id.
    address[256] internal _validators;

    constructor(address initialAuthed) Auth(initialAuthed) {}

    /// @inheritdoc IValidatorRegistry
    function constructValidatorRegistrationMessageV2(
        LibSecp256k1.Point memory pubKey
    ) public view returns (bytes32) {
        // Note the domain separation via `address(this)` and `block.chainid`.
        //
        // Without them the signed payload is fully determined by the public key
        // alone, so a proof-of-possession signature is valid on every chain and
        // for every registry deployment. An observer who captures one signature
        // could then present it to any other ValidatorRegistry to have that
        // validator id registered without ever holding the private key at the
        // time of that registry's own registration process. Binding the message
        // to this registry and chain prevents that replay.
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(
                    abi.encodePacked(
                        address(this),
                        block.chainid,
                        _CONTEXT,
                        pubKey.x,
                        pubKey.y
                    )
                )
            )
        );
    }

    /// @inheritdoc IValidatorRegistry
    function validators() external view returns (address[] memory) {
        address[] memory validators_ = new address[](256);
        uint ctr;
        for (uint i; i < 256; i++) {
            address validator = _validators[i];

            if (validator == address(0)) {
                continue;
            }

            validators_[ctr++] = validator;
        }

        assembly ("memory-safe") {
            mstore(validators_, ctr)
        }

        return validators_;
    }

    /// @inheritdoc IValidatorRegistry
    function validators(address validator) public view returns (bool) {
        if (validator == address(0)) {
            return false;
        }

        uint8 validatorId = uint8(uint(uint160(validator)) >> 152);

        return _validators[validatorId] == validator;
    }

    // -- Auth'ed Functionality --

    /// @inheritdoc IValidatorRegistry
    function lift(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) external auth {
        _lift(pubKey, sig);
    }

    /// @inheritdoc IValidatorRegistry
    function lift(
        LibSecp256k1.Point[] memory pubKeys,
        IScribe.ECDSAData[] memory sigs
    ) external auth {
        require(pubKeys.length == sigs.length);

        for (uint i; i < pubKeys.length; i++) {
            _lift(pubKeys[i], sigs[i]);
        }
    }

    /// @inheritdoc IValidatorRegistry
    function drop(uint8 validatorId) external auth {
        _drop(validatorId);
    }

    /// @inheritdoc IValidatorRegistry
    function drop(uint8[] memory validatorIds) external auth {
        for (uint i; i < validatorIds.length; i++) {
            _drop(validatorIds[i]);
        }
    }

    // -- Internal Helpers --

    function _lift(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory feedRegistrationSigV2
    ) internal {
        address validator = pubKey.toAddress();

        // Verify public key's coordinates are field elements.
        require(pubKey.x < _SECP256K1_P);
        require(pubKey.y < _SECP256K1_P);

        // Verify public key is valid.
        require(pubKey.isOnCurve());

        // Reject signature malleability.
        //
        // `ecrecover` accepts both (r, s) and (r, Q - s) for the same signer, so
        // without these checks a single valid proof of possession has two
        // distinct on-chain encodings. That breaks any off-chain uniqueness
        // assumption (e.g. de-duplicating registrations by signature bytes) and
        // is the standard defence-in-depth guard required for ECDSA verification.
        //
        // Note that `ecrecover` itself reverts on r == 0 or s == 0, and returns
        // address(0) on any other invalid input, which the `signer` check below
        // already rejects because `validator` is never address(0) here.
        require(
            feedRegistrationSigV2.s
                <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
            "ValidatorRegistry: signature s not canonical"
        );

        // Verify feed registration signature v2 is valid.
        address signer = ecrecover(
            constructValidatorRegistrationMessageV2(pubKey),
            feedRegistrationSigV2.v,
            feedRegistrationSigV2.r,
            feedRegistrationSigV2.s
        );
        require(validator == signer);

        uint8 validatorId = uint8(uint(uint160(validator)) >> 152);

        address current = _validators[validatorId];
        if (current != validator) {
            // Reject rather than silently overwriting: an occupied slot means a
            // different validator already holds this id. Overwriting it would
            // silently evict a live validator.
            require(current == address(0), "ValidatorRegistry: id occupied");

            _validators[validatorId] = validator;
            emit ValidatorLifted(msg.sender, validator);
        }
    }

    function _drop(uint8 validatorId) internal {
        address current = _validators[validatorId];
        if (current != address(0)) {
            delete _validators[validatorId];
            emit ValidatorDropped(msg.sender, current);
        }
    }
}

/**
 * @dev Contract overwrite to deploy contract instances with specific naming.
 *
 *      For more info, see docs/Deployment.md.
 */
contract ValidatorRegistry_COUNTER is ValidatorRegistry {
    // @todo               ^^^^^^^ Adjust counter of ValidatorRegistry instance.
    constructor(address initialAuthed) ValidatorRegistry(initialAuthed) {}
}
