// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

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

    /// @notice Returns the Chronicle Validator Registration Message V2 for
    ///         public key `pubKey`.
    ///
    /// @dev The Chronicle Validator Registration Message V2 acts as a proof of
    ///      possession scheme proving a validator possesses the private key of
    ///      its publicly claimed public key. The proof of possession defends
    ///      the Scribe oracle system against rogue key attacks.
    ///
    ///      A validator MUST provide a valid Chronicle Validator Registration
    ///      Message V2 in order to be lifted on this registry.
    ///
    ///      Note that the proof of possession scheme integrated into the Scribe
    ///      smart contract, ie the Chronicle Feed Registration Message, is
    ///      vulnerable to an "extended" rogue key attack.
    ///
    ///      For more info, see https://github.com/chronicleprotocol/scribe/blob/main/audits/Cantina%40v2.0.0_2.pdf
    ///
    /// @return The Chronicle Validator Registration Message V2 for given public
    ///         key.
    function constructValidatorRegistrationMessageV2(
        LibSecp256k1.Point memory pubKey
    ) external view returns (bytes32);

    /// @notice Returns all of Chronicle Protocol's validators.
    /// @return Chronicle Protocol's validators.
    function validators() external view returns (address[] memory);

    /// @notice Returns whether address `validator` is a validator.
    /// @param validator Validator address.
    /// @return True if address `validator` is validator, false otherwise.
    function validators(address validator) external view returns (bool);

    // -- Auth'ed Functionality --

    /// @notice Lifts validator with public key `pubKey`.
    /// @dev Only callable by auth'ed address.
    /// @param pubKey The validator's public key.
    /// @param sig The validator's Chronicle Validator Registration Message V2
    ///            signature.
    function lift(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) external;

    /// @notice Lifts validators with public keys `pubKeys`.
    /// @dev Only callable by auth'ed address.
    /// @param pubKeys The validators' public keys.
    /// @param sigs The validator's Chronicle Validator Registration Message V2
    ///             signature.
    function lift(
        LibSecp256k1.Point[] memory pubKeys,
        IScribe.ECDSAData[] memory sigs
    ) external;

    /// @notice Drops validator with validator id `validatorId`.
    /// @dev Only callable by auth'ed address.
    /// @param validatorId The validator id to drop.
    function drop(uint8 validatorId) external;

    /// @notice Drops validators with validator ids `validatorIds`.
    /// @dev Only callable by auth'ed address.
    /// @param validatorIds The validator ids to drop.
    function drop(uint8[] memory validatorIds) external;
}
