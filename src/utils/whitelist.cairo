%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_le, is_le_felt, is_not_zero, is_nn, RC_BOUND
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.bool import TRUE

from openzeppelin.token.erc721.library import ERC721
from openzeppelin.access.ownable.library import Ownable

//
// Storage
//

@storage_var
func Whitelist_merkle_root() -> (merkle_root: felt) {
}

namespace Whitelist {
    //
    // Getters
    //

    func merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        merkle_root: felt
    ) {
        return Whitelist_merkle_root.read();
    }

    //
    // Private modifiers
    //

    func set_merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        merkle_root: felt
    ) -> () {
        Ownable.assert_only_owner();
        Whitelist_merkle_root.write(merkle_root);
        return ();
    }

    //
    // Unprotected
    //

    func assert_is_allowed{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: felt, proof_len: felt, proof: felt*
    ) {
        alloc_locals;

        let (local root) = Whitelist_merkle_root.read();
        with_attr error_message("Merkle root should not be null") {
            assert_not_zero(root);
        }

        let (leaf) = _hash_sorted{hash_ptr=pedersen_ptr}(address, address);
        let (is_allow_list) = merkle_verify(leaf, root, proof_len, proof);
        with_attr error_message("Address is not whitelisted") {
            assert TRUE = is_allow_list;
        }

        return ();
    }
}

//
// Private
//

// verifies a merkle proof
func merkle_verify{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leaf: felt, root: felt, proof_len: felt, proof: felt*
) -> (res: felt) {
    let (calc_root) = _merkle_verify_body(leaf, proof_len, proof);
    // check if calculated root is equal to expected
    if (calc_root == root) {
        return (1,);
    } else {
        return (0,);
    }
}

func _hash_sorted{hash_ptr: HashBuiltin*, range_check_ptr}(a, b) -> (res: felt) {
    let le = is_le_felt(a, b);

    if (le == 1) {
        let (n) = hash2{hash_ptr=hash_ptr}(a, b);
    } else {
        let (n) = hash2{hash_ptr=hash_ptr}(b, a);
    }
    return (n,);
}

// calculates the merkle root of a given proof
func _merkle_verify_body{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    curr: felt, proof_len: felt, proof: felt*
) -> (res: felt) {
    alloc_locals;

    if (proof_len == 0) {
        return (curr,);
    }

    let (n) = _hash_sorted{hash_ptr=pedersen_ptr}(curr, [proof]);

    let (res) = _merkle_verify_body(n, proof_len - 1, proof + 1);
    return (res,);
}

func merkle_build{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    leafs_len: felt, leafs: felt*
) -> (res: felt) {
    alloc_locals;
    if (leafs_len == 1) {
        return ([leafs],);
    }
    let (local new_leafs) = alloc();
    _merkle_build_body{new_leafs=new_leafs, leafs=leafs, stop=leafs_len}(0);

    let (q, r) = unsigned_div_rem(leafs_len, 2);
    return merkle_build(q + r, new_leafs);
}

func _merkle_build_body{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    new_leafs: felt*,
    leafs: felt*,
    stop: felt,
}(i: felt) {
    let stop_loop = is_le_felt(stop, i);
    if (stop_loop == TRUE) {
        return ();
    }
    if (i == stop - 1) {
        let (n) = _hash_sorted{hash_ptr=pedersen_ptr}([leafs + i], [leafs + i]);
        tempvar range_check_ptr = range_check_ptr;
    } else {
        let (n) = _hash_sorted{hash_ptr=pedersen_ptr}([leafs + i], [leafs + i + 1]);
        tempvar range_check_ptr = range_check_ptr;
    }
    assert [new_leafs + i / 2] = n;
    return _merkle_build_body(i + 2);
}

func addresses_to_leafs{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    allow_list_len: felt, allow_list: felt*
) -> (leafs_len: felt, leafs: felt*) {
    alloc_locals;
    let (local leafs) = alloc();
    _addresses_to_leafs_body{leafs=leafs, allow_list=allow_list, stop=allow_list_len}(0);
    return (allow_list_len, leafs);
}

func _addresses_to_leafs_body{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
    leafs: felt*,
    allow_list: felt*,
    stop: felt,
}(i: felt) {
    if (i == stop) {
        return ();
    }
    let (n) = hash2{hash_ptr=pedersen_ptr}([allow_list + i], [allow_list + i]);
    assert [leafs + i] = n;
    return _addresses_to_leafs_body(i + 1);
}
