// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Script} from "forge-std/Script.sol";
import {console2 as console} from "forge-std/console2.sol";

import {IAuth} from "chronicle-std/auth/IAuth.sol";

import {IValidatorRegistry} from "src/IValidatorRegistry.sol";
import {ValidatorRegistry_COUNTER as ValidatorRegistry} from
    "src/ValidatorRegistry.sol";
// @todo                  ^^^^^^^ Adjust counter of ValidatorRegistry instance.

/**
 * @notice ValidatorRegistry Management Script
 */
contract ValidatorRegistryScript is Script {
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
    function lift(address self, address validator) public {
        vm.startBroadcast();
        IValidatorRegistry(self).lift(validator);
        vm.stopBroadcast();

        console.log("Lifted", validator);
    }

    /// @dev Lifts validators `validators`.
    function lift(address self, address[] memory validators) public {
        vm.startBroadcast();
        IValidatorRegistry(self).lift(validators);
        vm.stopBroadcast();

        console.log("Lifted:");
        for (uint i; i < validators.length; i++) {
            console.log("  ", validators[i]);
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
