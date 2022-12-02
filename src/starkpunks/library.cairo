%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add, assert_uint256_le

from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable

namespace Starkpunks {

    const MAX_SUPPLY = 10000;

    //
    // Unprotected
    //

    func _mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(to: felt) {
        let (total_supply) = ERC721Enumerable.total_supply();
        let (new_token_id, _) = uint256_add(total_supply, Uint256(1, 0));
        with_attr error_message("There cannot be more than 10,000 stark punks") {
            assert_uint256_le(new_token_id, Uint256(MAX_SUPPLY, 0));
        }
        ERC721Enumerable._mint(to, new_token_id);
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