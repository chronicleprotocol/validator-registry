// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IValidatorRegistry {
    /// @notice Thrown if validator `validator` not lifted.
    error ValidatorNotLifted(address validator);

    /// @notice Thrown if validator id `validatorId` not lifted.
    error ValidatorIdNotLifted(uint8 validatorId);

    /// @notice Emitted when new validator lifted.
    /// @param caller The caller's address.
    /// @param validator The validator address lifted.
    event ValidatorLifted(address indexed caller, address indexed validator);

    /// @notice Emitted when validator dropped.
    /// @param caller The caller's address.
    /// @param validator The validator address dropped.
    event ValidatorDropped(address indexed caller, address indexed validator);

    // -- Public Read Functions --

    /// @notice Returns all of Chronicle Protocol's validators.
    /// @return Chronicle Protocol's validators.
    function validators() external view returns (address[] memory);

    /// @notice Returns whether address `validator` is a validator.
    /// @param validator Validator address.
    /// @return True if address `validator` is validator, false otherwise.
    function validators(address validator) external view returns (bool);

    /// @notice Returns list of validators `validators_` in bloom encoding.
    ///
    /// @dev Reverts if:
    ///      - Any validator in `validators` not a validator
    ///
    /// @param validators_ The list of validators to encode via bloom mechanism.
    /// @return Validators encoded via bloom mechanism.
    function encode(address[] calldata validators_)
        external
        view
        returns (uint);

    /// @notice Returns list of validators encoded in `bloom`.
    ///
    /// @dev Reverts if:
    ///      - Any validator encoded in `bloom` not a validator
    ///
    /// @param bloom The list validators encoded via bloom mechanism.
    /// @return List of validator encoded in `bloom`.
    function decode(uint bloom) external view returns (address[] memory);

    // -- Auth'ed Functionality --

    /// @notice Lifts validator `validator`.
    /// @dev Only callable by auth'ed address.
    /// @param validator The validator to lift.
    function lift(address validator) external;

    /// @notice Lifts validators `validators`.
    /// @dev Only callable by auth'ed address.
    /// @param validators The validators to lift.
    function lift(address[] memory validators) external;

    /// @notice Drops validator with validator id `validatorId`.
    /// @dev Only callable by auth'ed address.
    /// @param validatorId The validator id to drop.
    function drop(uint8 validatorId) external;

    /// @notice Drops validators with validator ids `validatorIds`.
    /// @dev Only callable by auth'ed address.
    /// @param validatorIds The validator ids to drop.
    function drop(uint8[] memory validatorIds) external;
}
