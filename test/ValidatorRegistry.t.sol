// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ValidatorRegistry} from "src/ValidatorRegistry.sol";

import {IValidatorRegistryTest} from "./IValidatorRegistryTest.sol";

contract ValidatorRegistryTest is IValidatorRegistryTest {
    function setUp() public {
        setUp(new ValidatorRegistry(address(this)));
    }
}
