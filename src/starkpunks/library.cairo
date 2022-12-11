%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, assert_uint256_le
from starkware.cairo.common.math import assert_in_range, assert_le_felt
from starkware.starknet.common.syscalls import get_caller_address

from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.access.ownable.library import Ownable

from utils.whitelist import Whitelist

//
// Storage
//

@storage_var
func Starkpunks_max_supply() -> (max_supply: felt) {
}

@storage_var
func Starkpunks_max_per_address() -> (max_per_address: felt) {
}

@storage_var
func Starkpunks_mint_phase() -> (mint_phase: felt) {
    // 0 => closed
    // 1 => whitelist
    // 2 => public mint
}

@storage_var
func Starkpunks_minted_count_per_address(address: felt) -> (minted_count: felt) {
}

namespace Starkpunks {
    //
    // Initializer
    //

    func initializer{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        max_supply: felt
    ) {
        Starkpunks_max_supply.write(max_supply);
        Starkpunks_max_per_address.write(1);
        return ();
    }

    //
    // Getters
    //

    func max_supply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        max_supply: felt
    ) {
        return Starkpunks_max_supply.read();
    }

    func mint_phase{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        mint_phase: felt
    ) {
        return Starkpunks_mint_phase.read();
    }

    func minted_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt
    ) -> (minted_count: felt) {
        return Starkpunks_minted_count_per_address.read(address);
    }

    func max_per_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        max_per_address: felt
    ) {
        return Starkpunks_max_per_address.read();
    }

    //
    // Private modifiers
    //

    func set_mint_phase{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        mint_phase: felt
    ) -> () {
        Ownable.assert_only_owner();
        with_attr error_message("Mint phase must be 0 and 2") {
            assert_in_range(mint_phase, 0, 3);
        }
        Starkpunks_mint_phase.write(mint_phase);
        return ();
    }

    func set_max_per_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        max_per_address: felt
    ) -> () {
        Ownable.assert_only_owner();
        Starkpunks_max_per_address.write(max_per_address);
        return ();
    }

    func mint_count{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        to: felt, count: felt
    ) {
        Ownable.assert_only_owner();
        _mint_count(to, count);
        return ();
    }

    //
    // Public modifiers
    //

    func mint_whitelist{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        proof_len: felt, proof: felt*
    ) {
        alloc_locals;
        let (mint_phase_) = mint_phase();
        with_attr error_message("Whitelist mint is closed") {
            assert 1 = mint_phase_;
        }
        let (caller_address) = get_caller_address();
        with_attr error_message("Caller is not whitelisted") {
            Whitelist.assert_is_allowed(caller_address, proof_len, proof);
        }
        _mint(caller_address);
        return ();
    }

    func mint_public{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
        alloc_locals;
        let (mint_phase_) = mint_phase();
        with_attr error_message("Public mint is closed") {
            assert 2 = mint_phase_;
        }
        let (caller_address) = get_caller_address();
        _mint(caller_address);
        return ();
    }

    //
    // Unprotected
    //

    func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(to: felt) {
        alloc_locals;
        let (total_supply) = ERC721Enumerable.total_supply();
        let (max_supply_) = Starkpunks.max_supply();
        let (new_token_id, _) = uint256_add(total_supply, Uint256(1, 0));
        with_attr error_message("Mint: cannot be more than 10,000 stark punks") {
            assert_uint256_le(new_token_id, Uint256(max_supply_, 0));
        }
        let (minted_count_) = minted_count(to);
        let (max_per_address_) = max_per_address();
        let new_minted_count = minted_count_ + 1;
        with_attr error_message("Mint: cannot mint more than 1 punk") {
            assert_le_felt(new_minted_count, max_per_address_);
        }
        ERC721Enumerable._mint(to, new_token_id);
        Starkpunks_minted_count_per_address.write(to, new_minted_count);
        return ();
    }

    func _mint_count{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
        to: felt, count: felt
    ) {
        if (count == 0) {
            return ();
        }
        _mint(to);
        _mint_count(to, count - 1);
        return ();
    }
}
