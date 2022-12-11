%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, uint256_unsigned_div_rem
from starkware.cairo.common.alloc import alloc

//
// Storage
//

@storage_var
func TokenUri_base_token_uri(index: felt) -> (char: felt) {
}

namespace TokenUri {

    //
    // Getters
    //

    func base_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
        base_token_uri_len: felt, base_token_uri: felt*
    ) {
        let (first_char) = TokenUri_base_token_uri.read(0);
        let (array) = alloc();
        let (base_token_uri_len, base_token_uri) = _read_base_token_uri(0, array);
        return (base_token_uri_len, base_token_uri);
    }

    func token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        tokenId: Uint256
    ) -> (token_uri_len: felt, token_uri: felt*) {
        alloc_locals;
        let (local base_token_uri_len, local base_token_uri_) = base_token_uri();
        let (added_len) = _append_number_ascii(tokenId, base_token_uri_ + base_token_uri_len);
        return (base_token_uri_len + added_len, base_token_uri_);
    }

    //
    // Unprotected
    //

    func _set_base_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        uri_len: felt, uri: felt*
    ) {
        if (uri_len == 0) {
            return ();
        }
        tempvar new_len = uri_len - 1;
        TokenUri_base_token_uri.write(new_len, uri[new_len] + 1);
        _set_base_token_uri(new_len, uri);
        return ();
    }

    func _read_base_token_uri{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        array_len: felt, array: felt*
    ) -> (array_len: felt, array: felt*) {
        let (val) = TokenUri_base_token_uri.read(array_len);
        if (val == 0) {
            return (array_len, array);
        }
        assert array[array_len] = val - 1;
        return _read_base_token_uri(array_len + 1, array);
    }

    func _append_number_ascii{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        num: Uint256, array_end: felt*
    ) -> (added_len: felt) {
        alloc_locals;
        local ten: Uint256 = Uint256(10, 0);
        let (q: Uint256, r: Uint256) = uint256_unsigned_div_rem(num, ten);
        let digit = r.low + 48;  // ascii

        if (q.low == 0 and q.high == 0) {
            assert array_end[0] = digit;
            return (1,);
        }

        let (added_len) = _append_number_ascii(q, array_end);
        assert array_end[added_len] = digit;
        return (added_len + 1,);
    }
}