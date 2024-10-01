// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Auth} from "chronicle-std/auth/Auth.sol";

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

import {IValidatorRegistry} from "./IValidatorRegistry.sol";

/**
 * @title ValidatorRegistry
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
    ) public pure returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(_CONTEXT, pubKey.x, pubKey.y))
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
        // assert(validator != address(0));

        // Verify public key's coordinates are field elements.
        require(pubKey.x < _SECP256K1_P);
        require(pubKey.y < _SECP256K1_P);

        // Verify public key is valid.
        require(pubKey.isOnCurve());

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
            require(current == address(0));

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
