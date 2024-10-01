// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";
import {Test} from "forge-std/Test.sol";
import {console2 as console} from "forge-std/console2.sol";

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

import {IAuth} from "chronicle-std/auth/IAuth.sol";

import {LibValidator, Validator} from "script/libs/LibValidator.sol";

import {IValidatorRegistry} from "src/IValidatorRegistry.sol";
import {ValidatorRegistry} from "src/ValidatorRegistry.sol";

contract ValidatorRegistryTest is Test {
    using LibSecp256k1 for LibSecp256k1.Point;
    using LibValidator for Validator;

    // Copied from IValidatorRegistry.
    event ValidatorLifted(address indexed caller, address indexed validator);
    event ValidatorDropped(address indexed caller, address indexed validator);

    // Copied from IValidatorRegistry.
    uint private constant _SECP256K1_P =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

    ValidatorRegistry registry;

    /// @dev List of 256 validators indexed via their unique 1-byte id.
    ///
    /// @dev Assumed to be constant.
    Validator[256] VALIDATORS;

    function setUp() public {
        registry = new ValidatorRegistry(address(this));

        // Populate the validator array based on the validator's id.
        //
        // In order to compute the validator list dynamically, do:
        //
        // ```solidity
        // uint privKey = 2;
        // uint bloom;
        // uint ctr;
        // while (ctr != 256) {
        //     Validator memory v = LibValidator.newValidator(privKey);
        //     uint8 id = v.toId();
        //
        //     if (bloom & (1 << id) == 0) {
        //         bloom |= 1 << id;
        //
        //         validators[id] = v;
        //         ctr++;
        //     }
        //
        //     privKey++;
        // }
        // ```
        //
        // In order to verify the list, do:
        //
        // ```solidity
        // for (uint i = 1; i < 256; i++) {
        //     require(validators[i - 1].toId() < validators[i].toId());
        // }
        // ```
        VALIDATORS[0] = LibValidator.newValidator(130);
        VALIDATORS[1] = LibValidator.newValidator(296);
        VALIDATORS[2] = LibValidator.newValidator(536);
        VALIDATORS[3] = LibValidator.newValidator(254);
        VALIDATORS[4] = LibValidator.newValidator(104);
        VALIDATORS[5] = LibValidator.newValidator(111);
        VALIDATORS[6] = LibValidator.newValidator(512);
        VALIDATORS[7] = LibValidator.newValidator(171);
        VALIDATORS[8] = LibValidator.newValidator(372);
        VALIDATORS[9] = LibValidator.newValidator(33);
        VALIDATORS[10] = LibValidator.newValidator(193);
        VALIDATORS[11] = LibValidator.newValidator(80);
        VALIDATORS[12] = LibValidator.newValidator(105);
        VALIDATORS[13] = LibValidator.newValidator(133);
        VALIDATORS[14] = LibValidator.newValidator(113);
        VALIDATORS[15] = LibValidator.newValidator(671);
        VALIDATORS[16] = LibValidator.newValidator(400);
        VALIDATORS[17] = LibValidator.newValidator(227);
        VALIDATORS[18] = LibValidator.newValidator(79);
        VALIDATORS[19] = LibValidator.newValidator(34);
        VALIDATORS[20] = LibValidator.newValidator(263);
        VALIDATORS[21] = LibValidator.newValidator(21);
        VALIDATORS[22] = LibValidator.newValidator(230);
        VALIDATORS[23] = LibValidator.newValidator(118);
        VALIDATORS[24] = LibValidator.newValidator(160);
        VALIDATORS[25] = LibValidator.newValidator(638);
        VALIDATORS[26] = LibValidator.newValidator(76);
        VALIDATORS[27] = LibValidator.newValidator(338);
        VALIDATORS[28] = LibValidator.newValidator(211);
        VALIDATORS[29] = LibValidator.newValidator(27);
        VALIDATORS[30] = LibValidator.newValidator(4);
        VALIDATORS[31] = LibValidator.newValidator(1028);
        VALIDATORS[32] = LibValidator.newValidator(157);
        VALIDATORS[33] = LibValidator.newValidator(143);
        VALIDATORS[34] = LibValidator.newValidator(270);
        VALIDATORS[35] = LibValidator.newValidator(353);
        VALIDATORS[36] = LibValidator.newValidator(99);
        VALIDATORS[37] = LibValidator.newValidator(17);
        VALIDATORS[38] = LibValidator.newValidator(212);
        VALIDATORS[39] = LibValidator.newValidator(150);
        VALIDATORS[40] = LibValidator.newValidator(89);
        VALIDATORS[41] = LibValidator.newValidator(336);
        VALIDATORS[42] = LibValidator.newValidator(117);
        VALIDATORS[43] = LibValidator.newValidator(2);
        VALIDATORS[44] = LibValidator.newValidator(307);
        VALIDATORS[45] = LibValidator.newValidator(348);
        VALIDATORS[46] = LibValidator.newValidator(191);
        VALIDATORS[47] = LibValidator.newValidator(334);
        VALIDATORS[48] = LibValidator.newValidator(844);
        VALIDATORS[49] = LibValidator.newValidator(186);
        VALIDATORS[50] = LibValidator.newValidator(32);
        VALIDATORS[51] = LibValidator.newValidator(452);
        VALIDATORS[52] = LibValidator.newValidator(500);
        VALIDATORS[53] = LibValidator.newValidator(301);
        VALIDATORS[54] = LibValidator.newValidator(59);
        VALIDATORS[55] = LibValidator.newValidator(22);
        VALIDATORS[56] = LibValidator.newValidator(204);
        VALIDATORS[57] = LibValidator.newValidator(967);
        VALIDATORS[58] = LibValidator.newValidator(287);
        VALIDATORS[59] = LibValidator.newValidator(23);
        VALIDATORS[60] = LibValidator.newValidator(190);
        VALIDATORS[61] = LibValidator.newValidator(11);
        VALIDATORS[62] = LibValidator.newValidator(406);
        VALIDATORS[63] = LibValidator.newValidator(216);
        VALIDATORS[64] = LibValidator.newValidator(365);
        VALIDATORS[65] = LibValidator.newValidator(106);
        VALIDATORS[66] = LibValidator.newValidator(175);
        VALIDATORS[67] = LibValidator.newValidator(916);
        VALIDATORS[68] = LibValidator.newValidator(97);
        VALIDATORS[69] = LibValidator.newValidator(205);
        VALIDATORS[70] = LibValidator.newValidator(385);
        VALIDATORS[71] = LibValidator.newValidator(291);
        VALIDATORS[72] = LibValidator.newValidator(538);
        VALIDATORS[73] = LibValidator.newValidator(836);
        VALIDATORS[74] = LibValidator.newValidator(29);
        VALIDATORS[75] = LibValidator.newValidator(19);
        VALIDATORS[76] = LibValidator.newValidator(10);
        VALIDATORS[77] = LibValidator.newValidator(67);
        VALIDATORS[78] = LibValidator.newValidator(288);
        VALIDATORS[79] = LibValidator.newValidator(234);
        VALIDATORS[80] = LibValidator.newValidator(255);
        VALIDATORS[81] = LibValidator.newValidator(173);
        VALIDATORS[82] = LibValidator.newValidator(625);
        VALIDATORS[83] = LibValidator.newValidator(200);
        VALIDATORS[84] = LibValidator.newValidator(491);
        VALIDATORS[85] = LibValidator.newValidator(197);
        VALIDATORS[86] = LibValidator.newValidator(357);
        VALIDATORS[87] = LibValidator.newValidator(292);
        VALIDATORS[88] = LibValidator.newValidator(119);
        VALIDATORS[89] = LibValidator.newValidator(207);
        VALIDATORS[90] = LibValidator.newValidator(14);
        VALIDATORS[91] = LibValidator.newValidator(373);
        VALIDATORS[92] = LibValidator.newValidator(85);
        VALIDATORS[93] = LibValidator.newValidator(343);
        VALIDATORS[94] = LibValidator.newValidator(322);
        VALIDATORS[95] = LibValidator.newValidator(148);
        VALIDATORS[96] = LibValidator.newValidator(225);
        VALIDATORS[97] = LibValidator.newValidator(115);
        VALIDATORS[98] = LibValidator.newValidator(549);
        VALIDATORS[99] = LibValidator.newValidator(28);
        VALIDATORS[100] = LibValidator.newValidator(146);
        VALIDATORS[101] = LibValidator.newValidator(1011);
        VALIDATORS[102] = LibValidator.newValidator(1133);
        VALIDATORS[103] = LibValidator.newValidator(48);
        VALIDATORS[104] = LibValidator.newValidator(3);
        VALIDATORS[105] = LibValidator.newValidator(135);
        VALIDATORS[106] = LibValidator.newValidator(825);
        VALIDATORS[107] = LibValidator.newValidator(31);
        VALIDATORS[108] = LibValidator.newValidator(45);
        VALIDATORS[109] = LibValidator.newValidator(308);
        VALIDATORS[110] = LibValidator.newValidator(326);
        VALIDATORS[111] = LibValidator.newValidator(66);
        VALIDATORS[112] = LibValidator.newValidator(269);
        VALIDATORS[113] = LibValidator.newValidator(273);
        VALIDATORS[114] = LibValidator.newValidator(103);
        VALIDATORS[115] = LibValidator.newValidator(237);
        VALIDATORS[116] = LibValidator.newValidator(241);
        VALIDATORS[117] = LibValidator.newValidator(65);
        VALIDATORS[118] = LibValidator.newValidator(647);
        VALIDATORS[119] = LibValidator.newValidator(670);
        VALIDATORS[120] = LibValidator.newValidator(390);
        VALIDATORS[121] = LibValidator.newValidator(18);
        VALIDATORS[122] = LibValidator.newValidator(71);
        VALIDATORS[123] = LibValidator.newValidator(91);
        VALIDATORS[124] = LibValidator.newValidator(217);
        VALIDATORS[125] = LibValidator.newValidator(35);
        VALIDATORS[126] = LibValidator.newValidator(154);
        VALIDATORS[127] = LibValidator.newValidator(279);
        VALIDATORS[128] = LibValidator.newValidator(90);
        VALIDATORS[129] = LibValidator.newValidator(20);
        VALIDATORS[130] = LibValidator.newValidator(903);
        VALIDATORS[131] = LibValidator.newValidator(139);
        VALIDATORS[132] = LibValidator.newValidator(86);
        VALIDATORS[133] = LibValidator.newValidator(73);
        VALIDATORS[134] = LibValidator.newValidator(243);
        VALIDATORS[135] = LibValidator.newValidator(15);
        VALIDATORS[136] = LibValidator.newValidator(78);
        VALIDATORS[137] = LibValidator.newValidator(702);
        VALIDATORS[138] = LibValidator.newValidator(320);
        VALIDATORS[139] = LibValidator.newValidator(412);
        VALIDATORS[140] = LibValidator.newValidator(432);
        VALIDATORS[141] = LibValidator.newValidator(112);
        VALIDATORS[142] = LibValidator.newValidator(184);
        VALIDATORS[143] = LibValidator.newValidator(487);
        VALIDATORS[144] = LibValidator.newValidator(252);
        VALIDATORS[145] = LibValidator.newValidator(878);
        VALIDATORS[146] = LibValidator.newValidator(108);
        VALIDATORS[147] = LibValidator.newValidator(36);
        VALIDATORS[148] = LibValidator.newValidator(174);
        VALIDATORS[149] = LibValidator.newValidator(540);
        VALIDATORS[150] = LibValidator.newValidator(865);
        VALIDATORS[151] = LibValidator.newValidator(1238);
        VALIDATORS[152] = LibValidator.newValidator(496);
        VALIDATORS[153] = LibValidator.newValidator(95);
        VALIDATORS[154] = LibValidator.newValidator(25);
        VALIDATORS[155] = LibValidator.newValidator(136);
        VALIDATORS[156] = LibValidator.newValidator(819);
        VALIDATORS[157] = LibValidator.newValidator(657);
        VALIDATORS[158] = LibValidator.newValidator(44);
        VALIDATORS[159] = LibValidator.newValidator(790);
        VALIDATORS[160] = LibValidator.newValidator(121);
        VALIDATORS[161] = LibValidator.newValidator(55);
        VALIDATORS[162] = LibValidator.newValidator(137);
        VALIDATORS[163] = LibValidator.newValidator(56);
        VALIDATORS[164] = LibValidator.newValidator(141);
        VALIDATORS[165] = LibValidator.newValidator(30);
        VALIDATORS[166] = LibValidator.newValidator(823);
        VALIDATORS[167] = LibValidator.newValidator(93);
        VALIDATORS[168] = LibValidator.newValidator(249);
        VALIDATORS[169] = LibValidator.newValidator(72);
        VALIDATORS[170] = LibValidator.newValidator(379);
        VALIDATORS[171] = LibValidator.newValidator(570);
        VALIDATORS[172] = LibValidator.newValidator(83);
        VALIDATORS[173] = LibValidator.newValidator(299);
        VALIDATORS[174] = LibValidator.newValidator(42);
        VALIDATORS[175] = LibValidator.newValidator(81);
        VALIDATORS[176] = LibValidator.newValidator(68);
        VALIDATORS[177] = LibValidator.newValidator(74);
        VALIDATORS[178] = LibValidator.newValidator(606);
        VALIDATORS[179] = LibValidator.newValidator(127);
        VALIDATORS[180] = LibValidator.newValidator(572);
        VALIDATORS[181] = LibValidator.newValidator(38);
        VALIDATORS[182] = LibValidator.newValidator(394);
        VALIDATORS[183] = LibValidator.newValidator(309);
        VALIDATORS[184] = LibValidator.newValidator(46);
        VALIDATORS[185] = LibValidator.newValidator(110);
        VALIDATORS[186] = LibValidator.newValidator(235);
        VALIDATORS[187] = LibValidator.newValidator(476);
        VALIDATORS[188] = LibValidator.newValidator(321);
        VALIDATORS[189] = LibValidator.newValidator(313);
        VALIDATORS[190] = LibValidator.newValidator(679);
        VALIDATORS[191] = LibValidator.newValidator(488);
        VALIDATORS[192] = LibValidator.newValidator(242);
        VALIDATORS[193] = LibValidator.newValidator(297);
        VALIDATORS[194] = LibValidator.newValidator(77);
        VALIDATORS[195] = LibValidator.newValidator(26);
        VALIDATORS[196] = LibValidator.newValidator(219);
        VALIDATORS[197] = LibValidator.newValidator(490);
        VALIDATORS[198] = LibValidator.newValidator(128);
        VALIDATORS[199] = LibValidator.newValidator(419);
        VALIDATORS[200] = LibValidator.newValidator(374);
        VALIDATORS[201] = LibValidator.newValidator(691);
        VALIDATORS[202] = LibValidator.newValidator(483);
        VALIDATORS[203] = LibValidator.newValidator(813);
        VALIDATORS[204] = LibValidator.newValidator(608);
        VALIDATORS[205] = LibValidator.newValidator(192);
        VALIDATORS[206] = LibValidator.newValidator(415);
        VALIDATORS[207] = LibValidator.newValidator(94);
        VALIDATORS[208] = LibValidator.newValidator(129);
        VALIDATORS[209] = LibValidator.newValidator(413);
        VALIDATORS[210] = LibValidator.newValidator(161);
        VALIDATORS[211] = LibValidator.newValidator(305);
        VALIDATORS[212] = LibValidator.newValidator(7);
        VALIDATORS[213] = LibValidator.newValidator(203);
        VALIDATORS[214] = LibValidator.newValidator(107);
        VALIDATORS[215] = LibValidator.newValidator(319);
        VALIDATORS[216] = LibValidator.newValidator(37);
        VALIDATORS[217] = LibValidator.newValidator(100);
        VALIDATORS[218] = LibValidator.newValidator(293);
        VALIDATORS[219] = LibValidator.newValidator(12);
        VALIDATORS[220] = LibValidator.newValidator(654);
        VALIDATORS[221] = LibValidator.newValidator(151);
        VALIDATORS[222] = LibValidator.newValidator(134);
        VALIDATORS[223] = LibValidator.newValidator(315);
        VALIDATORS[224] = LibValidator.newValidator(64);
        VALIDATORS[225] = LibValidator.newValidator(5);
        VALIDATORS[226] = LibValidator.newValidator(168);
        VALIDATORS[227] = LibValidator.newValidator(637);
        VALIDATORS[228] = LibValidator.newValidator(947);
        VALIDATORS[229] = LibValidator.newValidator(6);
        VALIDATORS[230] = LibValidator.newValidator(53);
        VALIDATORS[231] = LibValidator.newValidator(448);
        VALIDATORS[232] = LibValidator.newValidator(125);
        VALIDATORS[233] = LibValidator.newValidator(1240);
        VALIDATORS[234] = LibValidator.newValidator(364);
        VALIDATORS[235] = LibValidator.newValidator(43);
        VALIDATORS[236] = LibValidator.newValidator(1216);
        VALIDATORS[237] = LibValidator.newValidator(595);
        VALIDATORS[238] = LibValidator.newValidator(156);
        VALIDATORS[239] = LibValidator.newValidator(437);
        VALIDATORS[240] = LibValidator.newValidator(224);
        VALIDATORS[241] = LibValidator.newValidator(8);
        VALIDATORS[242] = LibValidator.newValidator(41);
        VALIDATORS[243] = LibValidator.newValidator(155);
        VALIDATORS[244] = LibValidator.newValidator(24);
        VALIDATORS[245] = LibValidator.newValidator(131);
        VALIDATORS[246] = LibValidator.newValidator(39);
        VALIDATORS[247] = LibValidator.newValidator(9);
        VALIDATORS[248] = LibValidator.newValidator(386);
        VALIDATORS[249] = LibValidator.newValidator(57);
        VALIDATORS[250] = LibValidator.newValidator(16);
        VALIDATORS[251] = LibValidator.newValidator(114);
        VALIDATORS[252] = LibValidator.newValidator(220);
        VALIDATORS[253] = LibValidator.newValidator(271);
        VALIDATORS[254] = LibValidator.newValidator(84);
        VALIDATORS[255] = LibValidator.newValidator(75);
    }

    /// @dev Returns the list of validators encoded in bloom `bloom`.
    ///
    /// @dev This function can be used to generate pseudo-random validator sets
    ///      by receiving bloom `bloom` as fuzzer argument.
    function _createValidatorsFromBloom(uint bloom)
        internal
        view
        returns (Validator[] memory)
    {
        Validator[] memory validators = new Validator[](256);
        uint ctr;
        for (uint i; i < 256; i++) {
            if (bloom & (1 << i) != 0) {
                validators[ctr++] = VALIDATORS[i];
            }
        }

        assembly ("memory-safe") {
            mstore(validators, ctr)
        }

        return validators;
    }

    function _lift(Validator memory v) internal {
        // Construct validator's registration message.
        bytes32 message =
            registry.constructValidatorRegistrationMessageV2(v.toPublicKey());

        // Let validator sign registration message.
        IScribe.ECDSAData memory sig = v.signECDSA(message);

        // Lift validator.
        registry.lift(v.toPublicKey(), sig);
    }

    // -- Test: Deployment --

    function test_Deployment() public view {
        // Address given in constructor is authed.
        assertTrue(IAuth(address(registry)).authed(address(this)));

        // No validators lifted.
        assertEq(registry.validators().length, 0);
    }

    // -- Test: validators --

    function test_validators_FailsIf_ValidatorIsZeroAddress() public view {
        assertFalse(registry.validators(address(0)));
    }

    // -- Test: lift Single --

    function testFuzz_lift_Single(uint8 validatorId) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();

        // Let validator sign registration message.
        IScribe.ECDSAData memory sig = v.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey)
        );

        vm.expectEmit();
        emit ValidatorLifted(address(this), v.toAddress());

        // Lift validator.
        registry.lift(pubKey, sig);

        assertTrue(registry.validators(v.toAddress()));

        address[] memory all = registry.validators();
        assertEq(all.length, 1);
        assertEq(all[0], v.toAddress());
    }

    function test_lift_Single_RevertsIf_PublicKeyXNotAFieldElement(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) public {
        vm.assume(pubKey.x >= _SECP256K1_P);

        vm.expectRevert();
        registry.lift(pubKey, sig);
    }

    function test_lift_Single_RevertsIf_PublicKeyYNotAFieldElement(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) public {
        vm.assume(pubKey.y >= _SECP256K1_P);

        vm.expectRevert();
        registry.lift(pubKey, sig);
    }

    function test_lift_Single_RevertsIf_PublicKeyNotOnCurve(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) public {
        vm.assume(!pubKey.isOnCurve());

        vm.expectRevert();
        registry.lift(pubKey, sig);
    }

    function test_lift_Single_RevertsIf_SignatureInvalid(
        uint8 validatorId,
        IScribe.ECDSAData memory sig
    ) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();

        vm.expectRevert();
        registry.lift(pubKey, sig);
    }

    function test_lift_Single_RevertsIf_ValidatorWithSameIdAlreadyLifted(
        string memory seed
    ) public {
        Validator memory v1 = LibValidator.newValidator(seed);
        LibSecp256k1.Point memory pubKey1 = v1.toPublicKey();

        Validator memory v2 = VALIDATORS[v1.toId()];
        LibSecp256k1.Point memory pubKey2 = v2.toPublicKey();

        vm.assume(v1.toAddress() != v2.toAddress());

        // Lift v1.
        IScribe.ECDSAData memory sig1 = v1.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey1)
        );
        registry.lift(pubKey1, sig1);

        // Fail trying to lift v2.
        IScribe.ECDSAData memory sig2 = v2.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey2)
        );
        vm.expectRevert();
        registry.lift(pubKey2, sig2);
    }

    function test_lift_Single_IsIdempotent(uint8 validatorId) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();

        IScribe.ECDSAData memory sig = v.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey)
        );

        registry.lift(pubKey, sig);
        registry.lift(pubKey, sig);
    }

    // -- Test: lift Multiple --

    function testFuzz_lift_Multiple(uint bloom) public {
        Validator[] memory vs = _createValidatorsFromBloom(bloom);

        LibSecp256k1.Point[] memory pubKeys =
            new LibSecp256k1.Point[](vs.length);
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](vs.length);
        for (uint i; i < vs.length; i++) {
            pubKeys[i] = vs[i].toPublicKey();
            sigs[i] = vs[i].signECDSA(
                registry.constructValidatorRegistrationMessageV2(pubKeys[i])
            );
        }

        for (uint i; i < vs.length; i++) {
            vm.expectEmit();
            emit ValidatorLifted(address(this), vs[i].toAddress());
        }

        registry.lift(pubKeys, sigs);

        for (uint i; i < vs.length; i++) {
            assertTrue(registry.validators(vs[i].toAddress()));
        }

        address[] memory all = registry.validators();
        assertEq(all.length, vs.length);
        for (uint i; i < vs.length; i++) {
            assertEq(all[i], vs[i].toAddress());
        }
    }

    function test_lift_Multiple_RevertsIf_ArgumentsLengthMismatch(
        LibSecp256k1.Point[] memory pubKeys,
        IScribe.ECDSAData[] memory sigs
    ) public {
        vm.assume(pubKeys.length != sigs.length);

        vm.expectRevert();
        registry.lift(pubKeys, sigs);
    }

    function testFuzz_lift_Multiple_RevertsIf_PublicKeyXNotAFieldElement(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) public {
        vm.assume(pubKey.x >= _SECP256K1_P);

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](1);
        pubKeys[0] = pubKey;
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](1);
        sigs[0] = sig;

        vm.expectRevert();
        registry.lift(pubKeys, sigs);
    }

    function testFuzz_lift_Multiple_RevertsIf_PublicKeyYNotAFieldElement(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) public {
        vm.assume(pubKey.y >= _SECP256K1_P);

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](1);
        pubKeys[0] = pubKey;
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](1);
        sigs[0] = sig;

        vm.expectRevert();
        registry.lift(pubKeys, sigs);
    }

    function testFuzz_lift_Multiple_RevertsIf_PublicKeyNotOnCurve(
        LibSecp256k1.Point memory pubKey,
        IScribe.ECDSAData memory sig
    ) public {
        vm.assume(!pubKey.isOnCurve());

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](1);
        pubKeys[0] = pubKey;
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](1);
        sigs[0] = sig;

        vm.expectRevert();
        registry.lift(pubKeys, sigs);
    }

    function test_lift_Multiple_RevertsIf_SignatureInvalid(
        uint8 validatorId,
        IScribe.ECDSAData memory sig
    ) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](1);
        pubKeys[0] = pubKey;
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](1);
        sigs[0] = sig;

        vm.expectRevert();
        registry.lift(pubKeys, sigs);
    }

    function test_lift_Multiple_RevertsIf_ValidatorWithSameIdAlreadyLifted(
        string memory seed
    ) public {
        Validator memory v1 = LibValidator.newValidator(seed);
        LibSecp256k1.Point memory pubKey1 = v1.toPublicKey();

        Validator memory v2 = VALIDATORS[v1.toId()];
        LibSecp256k1.Point memory pubKey2 = v2.toPublicKey();

        vm.assume(v1.toAddress() != v2.toAddress());

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](2);
        pubKeys[0] = pubKey1;
        pubKeys[1] = pubKey2;
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](2);
        sigs[0] = v1.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey1)
        );
        sigs[1] = v2.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey2)
        );

        vm.expectRevert();
        registry.lift(pubKeys, sigs);
    }

    function test_lift_Multiple_IsIdempotent(uint8 validatorId) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();
        IScribe.ECDSAData memory sig = v.signECDSA(
            registry.constructValidatorRegistrationMessageV2(pubKey)
        );

        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](2);
        pubKeys[0] = pubKey;
        pubKeys[1] = pubKey;
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](2);
        sigs[0] = sig;
        sigs[1] = sig;

        registry.lift(pubKeys, sigs);
    }

    // -- Test: drop Single --

    function testFuzz_drop_Single(uint8 validatorId) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();

        registry.lift(
            pubKey,
            v.signECDSA(
                registry.constructValidatorRegistrationMessageV2(pubKey)
            )
        );

        vm.expectEmit();
        emit ValidatorDropped(address(this), v.toAddress());

        registry.drop(validatorId);

        assertEq(registry.validators().length, 0);
    }

    function testFuzz_drop_Single_IsIdempotent(uint8 validatorId) public {
        Validator memory v = VALIDATORS[validatorId];
        LibSecp256k1.Point memory pubKey = v.toPublicKey();

        registry.lift(
            pubKey,
            v.signECDSA(
                registry.constructValidatorRegistrationMessageV2(pubKey)
            )
        );

        vm.expectEmit();
        emit ValidatorDropped(address(this), v.toAddress());

        registry.drop(validatorId);

        assertEq(registry.validators().length, 0);

        registry.drop(validatorId);
    }

    // -- Test: drop Multiple --

    function testFuzz_drop_Multiple(uint bloom) public {
        Validator[] memory vs = _createValidatorsFromBloom(bloom);

        LibSecp256k1.Point[] memory pubKeys =
            new LibSecp256k1.Point[](vs.length);
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](vs.length);
        for (uint i; i < vs.length; i++) {
            pubKeys[i] = vs[i].toPublicKey();
            sigs[i] = vs[i].signECDSA(
                registry.constructValidatorRegistrationMessageV2(pubKeys[i])
            );
        }

        registry.lift(pubKeys, sigs);

        uint8[] memory ids = new uint8[](vs.length);
        for (uint i; i < vs.length; i++) {
            ids[i] = vs[i].toId();
        }

        for (uint i; i < vs.length; i++) {
            vm.expectEmit();
            emit ValidatorDropped(address(this), vs[i].toAddress());
        }

        registry.drop(ids);

        assertEq(registry.validators().length, 0);
    }

    function testFuzz_drop_Multiple_IsIdempotent(uint bloom) public {
        Validator[] memory vs = _createValidatorsFromBloom(bloom);

        LibSecp256k1.Point[] memory pubKeys =
            new LibSecp256k1.Point[](vs.length);
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](vs.length);
        for (uint i; i < vs.length; i++) {
            pubKeys[i] = vs[i].toPublicKey();
            sigs[i] = vs[i].signECDSA(
                registry.constructValidatorRegistrationMessageV2(pubKeys[i])
            );
        }

        registry.lift(pubKeys, sigs);

        uint8[] memory ids = new uint8[](vs.length);
        for (uint i; i < vs.length; i++) {
            ids[i] = vs[i].toId();
        }

        for (uint i; i < vs.length; i++) {
            vm.expectEmit();
            emit ValidatorDropped(address(this), vs[i].toAddress());
        }

        registry.drop(ids);

        assertEq(registry.validators().length, 0);

        registry.drop(ids);
    }

    // -- Test: Auth Protection --

    function test_lift_Single_IsAuthProtected() public {
        LibSecp256k1.Point memory pubKey;
        IScribe.ECDSAData memory sig;

        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        registry.lift(pubKey, sig);
    }

    function test_lift_Multiple_IsAuthProtected() public {
        LibSecp256k1.Point[] memory pubKeys = new LibSecp256k1.Point[](0);
        IScribe.ECDSAData[] memory sigs = new IScribe.ECDSAData[](0);

        vm.prank(address(0xbeef));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAuth.NotAuthorized.selector, address(0xbeef)
            )
        );
        registry.lift(pubKeys, sigs);
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
}
