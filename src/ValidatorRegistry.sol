// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Auth} from "chronicle-std/auth/Auth.sol";

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
 */
contract ValidatorRegistry is IValidatorRegistry, Auth {
    /// @dev Statically allocated array for validators.
    ///      Indexed via validator's validator id.
    address[256] internal _validators;

    constructor(address initialAuthed) Auth(initialAuthed) {}

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

    /// @inheritdoc IValidatorRegistry
    function encode(address[] calldata validators_)
        external
        view
        returns (uint)
    {
        uint bloom;

        for (uint i; i < validators_.length; i++) {
            address validator = validators_[i];

            if (!validators(validator)) {
                revert ValidatorNotLifted(validator);
            }

            uint8 validatorId = uint8(uint(uint160(validator)) >> 152);
            bloom |= (1 << validatorId);
        }

        return bloom;
    }

    /// @inheritdoc IValidatorRegistry
    function decode(uint bloom) external view returns (address[] memory) {
        address[] memory validators_ = new address[](256);
        uint ctr;
        for (uint i; i < 256; i++) {
            if (bloom & (1 << i) == 0) {
                continue;
            }

            address validator = _validators[i];

            if (validator == address(0)) {
                revert ValidatorIdNotLifted(uint8(i));
            }

            validators_[ctr++] = validator;
        }

        assembly ("memory-safe") {
            mstore(validators_, ctr)
        }

        return validators_;
    }

    // -- Auth'ed Functionality --

    /// @inheritdoc IValidatorRegistry
    function lift(address validator) external auth {
        _lift(validator);
    }

    /// @inheritdoc IValidatorRegistry
    function lift(address[] memory validators_) external auth {
        for (uint i; i < validators_.length; i++) {
            _lift(validators_[i]);
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

    function _lift(address validator) internal {
        require(validator != address(0));

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
