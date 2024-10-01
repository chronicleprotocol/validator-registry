// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";
import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

import {IAuth} from "chronicle-std/auth/IAuth.sol";

import {IValidatorRegistry} from "src/IValidatorRegistry.sol";

abstract contract IValidatorRegistryTest is Test {
    IValidatorRegistry registry;

    /*
    // Copied from IValidatorRegistry.
    event ValidatorLifted(address indexed caller, address indexed feed);
    event ValidatorDropped(address indexed caller, address indexed feed);

    function setUp(IValidatorRegistry registry_) internal {
        registry = registry_;
    }

    /// @dev Returns validator address and corresponding feed id for every
    ///      possible validator id (256).
    function _createValidators()
        internal
        pure
        returns (address[] memory, uint8[] memory)
    {
        address[] memory validators = new address[](256);
        uint8[] memory validatorIds = new uint8[](256);

        uint privKey = 1;
        uint bloom;
        uint ctr;
        while (bloom != type(uint).max) {
            address validator = vm.addr(privKey++);
            uint8 validatorId = uint8(uint(uint160(validator)) >> 152);

            if (bloom & (1 << validatorId) == 0) {
                bloom |= (1 << validatorId);
                validators[ctr] = validator;
                validatorIds[ctr] = validatorId;
                ctr++;
            }
        }

        return (validators, validatorIds);
    }

    // -- Test: Deployment --

    function test_Deployment() public view {
        // Address given in constructor is authed.
        assertTrue(IAuth(address(registry)).authed(address(this)));

        // No validators lifted.
        assertEq(registry.validators().length, 0);
    }

    // -- Test: validators --

    function test_validators_FailsIf_ValidatorIsZeroAddress() public {
        assertFalse(registry.validators(address(0)));
    }

    // -- Test: decode/encode --

    function testFuzz_encode_RevertsIf_ValidatorNotLifted(address validator)
        public
    {
        address[] memory validators = new address[](1);
        validators[0] = validator;

        vm.expectRevert(
            abi.encodeWithSelector(
                IValidatorRegistry.ValidatorNotLifted.selector, validator
            )
        );
        registry.encode(validators);
    }

    function testFuzz_decode_RevertsIf_ValidatorIdNotLifted(uint8 validatorId)
        public
    {
        uint bloom = (1 << validatorId);

        vm.expectRevert(
            abi.encodeWithSelector(
                IValidatorRegistry.ValidatorIdNotLifted.selector, validatorId
            )
        );
        registry.decode(bloom);
    }

    function test_decodeEncode() public {
        address[] memory validators;
        uint8[] memory validatorIds;
        (validators, validatorIds) = _createValidators();

        registry.lift(validators);

        address[] memory gotValidators =
            registry.decode(registry.encode(validators));
        assertEq(validators.length, gotValidators.length);
    }

    // -- Test: lift --

    function test_lift_Single() public {
        address[] memory validators;
        uint8[] memory validatorIds;
        (validators, validatorIds) = _createValidators();

        for (uint i; i < 256; i++) {
            vm.expectEmit();
            emit ValidatorLifted(address(this), validators[i]);

            registry.lift(validators[i]);

            assertTrue(registry.validators(validators[i]));

            address[] memory validators_ = registry.decode(1 << validatorIds[i]);
            assertEq(validators_.length, 1);
            assertEq(validators_[0], validators[i]);
        }

        assertEq(registry.validators().length, 256);
        assertEq(registry.decode(type(uint).max).length, 256);
    }

    function test_lift_Single_RevertsIf_ValidatorIsZeroAddress() public {
        vm.expectRevert();
        registry.lift(address(0));
    }

    function test_lift_Single_RevertsIf_ValidatorWithSameIdAlreadyLifted()
        public
    {
        registry.lift(address(0x00FfFFfFFFfFFFFFfFfFfffFFFfffFfFffFfFFFf));

        vm.expectRevert();
        registry.lift(address(0x00AAAaaAAAaaaAaAAaAaAaAaaaAAAAaAAAAAaaAA));
    }

    function test_lift_Single_IsIdempotent() public {
        registry.lift(address(0xcafe));
        registry.lift(address(0xcafe));
    }

    function test_lift_Multiple() public {
        address[] memory validators;
        uint8[] memory validatorIds;
        (validators, validatorIds) = _createValidators();

        for (uint i; i < 256; i++) {
            vm.expectEmit();
            emit ValidatorLifted(address(this), validators[i]);
        }
        registry.lift(validators);

        assertEq(registry.validators().length, 256);
        assertEq(registry.decode(type(uint).max).length, 256);
    }

    function test_lift_Multiple_RevertsIf_ValidatorIsZeroAddress() public {
        address[] memory validators = new address[](1);
        validators[0] = address(0);

        vm.expectRevert();
        registry.lift(validators);
    }

    function test_lift_Multiple_RevertsIf_ValidatorWithSameIdAlreadyLifted()
        public
    {
        address[] memory validators = new address[](2);
        validators[0] = address(0x00FfFFfFFFfFFFFFfFfFfffFFFfffFfFffFfFFFf);
        validators[1] = address(0x00AAAaaAAAaaaAaAAaAaAaAaaaAAAAaAAAAAaaAA);

        vm.expectRevert();
        registry.lift(validators);
    }

    function test_lift_Multiple_IsIdempotent() public {
        address[] memory validators = new address[](2);
        validators[0] = address(0xcafe);
        validators[1] = address(0xcafe);

        registry.lift(validators);
    }

    // -- Test: drop --

    function test_drop_Single() public {
        address[] memory validators;
        uint8[] memory validatorIds;
        (validators, validatorIds) = _createValidators();

        registry.lift(validators);

        for (uint i; i < validators.length; i++) {
            vm.expectEmit();
            emit ValidatorDropped(address(this), validators[i]);

            registry.drop(validatorIds[i]);
        }

        assertEq(registry.validators().length, 0);
    }

    function test_drop_Single_IsIdempotent() public {
        registry.drop(0);
    }

    function test_drop_Multiple() public {
        address[] memory validators;
        uint8[] memory validatorIds;
        (validators, validatorIds) = _createValidators();

        registry.lift(validators);

        for (uint i; i < validators.length; i++) {
            vm.expectEmit();
            emit ValidatorDropped(address(this), validators[i]);
        }
        registry.drop(validatorIds);

        assertEq(registry.validators().length, 0);
    }

    function test_drop_Multiple_IsIdempotent() public {
        uint8[] memory validatorIds = new uint8[](1);
        validatorIds[0] = 0;

        registry.drop(validatorIds);
    }

    // -- Auth Protection --

    function test_lift_Single_IsAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        registry.lift(address(0xcafe));
    }

    function test_lift_Multiple_IsAuthProtected() public {
        address[] memory validators = new address[](1);
        validators[0] = address(0xcafe);

        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        registry.lift(validators);
    }

    function test_drop_Single_IsAuthProtected() public {
        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        registry.drop(uint8(0));
    }

    function test_drop_Multiple_IsAuthProtected() public {
        uint8[] memory validatorIds = new uint8[](1);
        validatorIds[0] = uint8(0);

        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        registry.drop(validatorIds);
    }

    // -- Helpers --

    function _signFeedRegistrationMessageV2(uint privKey)
        internal
        view
        returns (IScribe.ECDSAData memory)
    {
        Vm.Wallet memory w = vm.createWallet(privKey);
        LibSecp256k1.Point memory pubKey =
            LibSecp256k1.Point(w.publicKeyX, w.publicKeyY);

        bytes32 message = registry.constructFeedRegistrationMessageV2(pubKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privKey, message);

        return IScribe.ECDSAData(v, r, s);
    }
    */
}
