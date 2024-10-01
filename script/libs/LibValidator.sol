// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Vm} from "forge-std/Vm.sol";

import {IScribe} from "scribe/IScribe.sol";
import {LibSecp256k1} from "scribe/libs/LibSecp256k1.sol";

/// @notice Type validator represents a Chronicle Protocol validator.
struct Validator {
    uint _privKey;
}

/**
 * @title LibValidator
 *
 * @notice Library providing validator functionality.
 */
library LibValidator {
    using LibValidator for Validator;
    using LibValidator for address;

    //--------------------------------------------------------------------------
    // Private Constants

    Vm private constant vm =
        Vm(address(uint160(uint(keccak256("hevm cheat code")))));

    uint private constant SECP256K1_Q =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

    //--------------------------------------------------------------------------
    // Construction

    /// @dev Constructs a new validator from string seed `seed`.
    function newValidator(string memory seed)
        internal
        returns (Validator memory)
    {
        Vm.Wallet memory wallet = vm.createWallet(seed);

        return Validator(wallet.privateKey);
    }

    /// @dev Constructs a new validator from private key `privKey`.
    ///
    /// @dev Reverts if:
    ///      - private key invalid
    function newValidator(uint privKey)
        internal
        pure
        returns (Validator memory)
    {
        require(
            privKey != 0 && privKey < SECP256K1_Q,
            "LibValidator::newValidator: private key invalid"
        );

        return Validator(privKey);
    }

    //--------------------------------------------------------------------------
    // Identity

    /// @dev Returns the validator `self`'s address.
    function toAddress(Validator memory self) internal returns (address) {
        return vm.createWallet(self._privKey).addr;
    }

    /// @dev Returns the validator `self`'s public key.
    function toPublicKey(Validator memory self)
        internal
        returns (LibSecp256k1.Point memory)
    {
        Vm.Wallet memory w = vm.createWallet(self._privKey);

        return LibSecp256k1.Point(w.publicKeyX, w.publicKeyY);
    }

    /// @dev Returns the validator `self`'s id.
    function toId(Validator memory self) internal returns (uint8) {
        return uint8(uint(uint160(self.toAddress())) >> 152);
    }

    //--------------------------------------------------------------------------
    // ECDSA Signatures

    /// @dev Returns ECDSA signature from validator `self` signing message
    ///      `message`.
    function signECDSA(Validator memory self, bytes32 message)
        internal
        pure
        returns (IScribe.ECDSAData memory)
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = vm.sign(self._privKey, message);

        return IScribe.ECDSAData(v, r, s);
    }
}
