// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {IAuth} from "chronicle-std/auth/IAuth.sol";

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

import {IValidatorRegistry} from "src/IValidatorRegistry.sol";
import {ValidatorRegistry_COUNTER as ValidatorRegistry} from
    "src/ValidatorRegistry.sol";
// @todo                  ^^^^^^^ Adjust counter of ValidatorRegistry instance.

/**
 * @notice ValidatorRegistry Management Script
 */
contract ValidatorRegistryScript is Script {
    using LibSecp256k1 for LibSecp256k1.Point;

    /// @dev Deploys a new ValidatorRegistry instance with `initialAuthed` being the
    ///      address initially auth'ed.
    function deploy(address initialAuthed) public {
        vm.startBroadcast();
        address deployed = address(new ValidatorRegistry(initialAuthed));
        vm.stopBroadcast();

        console.log("Deployed at", deployed);
    }

    // -- IValidatorRegistry Functions --

    /// @dev Lifts validator `validator`.
    function lift(
        address self,
        uint pubKeyCoordinateX,
        uint pubKeyCoordinateY,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS
    ) public {
        LibSecp256k1.Point memory pubKey =
            LibSecp256k1.Point(pubKeyCoordinateX, pubKeyCoordinateY);
        IScribe.ECDSAData memory sig = IScribe.ECDSAData(sigV, sigR, sigS);

        address validator = pubKey.toAddress();
        assert(validator != address(0));

        vm.startBroadcast();
        IValidatorRegistry(self).lift(pubKey, sig);
        vm.stopBroadcast();

        console.log("Lifted", validator);
    }

    /// @dev Lifts validators `validators`.
    function lift(
        address self,
        uint[] memory pubKeyCoordinateXs,
        uint[] memory pubKeyCoordinateYs,
        uint8[] memory sigVs,
        bytes32[] memory sigRs,
        bytes32[] memory sigSs
    ) public {
        uint len = pubKeyCoordinateXs.length;
        require(len == pubKeyCoordinateYs.length, "Length mismatch");
        require(len == sigVs.length, "Length mismatch");
        require(len == sigRs.length, "Length mismatch");
        require(len == sigSs.length, "Length mismatch");

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](len);
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](len);
        for (uint i; i < len; i++) {
            pubKeys[i] =
                LibSecp256k1.Point(pubKeyCoordinateXs[i], pubKeyCoordinateYs[i]);
            sigs[i] = IScribe.ECDSAData(sigVs[i], sigRs[i], sigSs[i]);
        }

        vm.startBroadcast();
        IValidatorRegistry(self).lift(pubKeys, sigs);
        vm.stopBroadcast();

        console.log("Lifted:");
        for (uint i; i < pubKeys.length; i++) {
            address validator = pubKeys[i].toAddress();
            assert(validator != address(0));

            console.log("  ", validator);
        }
    }

    /// @dev Drops validator with validator id `validatorId`.
    function drop(address self, uint8 validatorId) public {
        vm.startBroadcast();
        IValidatorRegistry(self).drop(validatorId);
        vm.stopBroadcast();

        console.log("Dropped", validatorId);
    }

    /// @dev Drops feeds with validator ids `validatorIds`.
    function drop(address self, uint8[] memory validatorIds) public {
        vm.startBroadcast();
        IValidatorRegistry(self).drop(validatorIds);
        vm.stopBroadcast();

        console.log("Dropped:");
        for (uint i; i < validatorIds.length; i++) {
            console.log("  ", validatorIds[i]);
        }
    }

    // -- IAuth Functions --

    /// @dev Grants auth to address `who`.
    function rely(address self, address who) public {
        vm.startBroadcast();
        IAuth(self).rely(who);
        vm.stopBroadcast();

        console.log("Relied", who);
    }

    /// @dev Renounces auth from address `who`.
    function deny(address self, address who) public {
        vm.startBroadcast();
        IAuth(self).deny(who);
        vm.stopBroadcast();

        console.log("Denied", who);
    }
}
