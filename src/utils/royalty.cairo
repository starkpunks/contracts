%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero, assert_le_felt
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_le,
    uint256_check,
    uint256_mul,
    uint256_unsigned_div_rem,
)

from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.security.safemath.library import SafeUint256
from openzeppelin.access.ownable.library import Ownable

const IERC2981_ID = 0x2a55205a;

// The royalty percentage is expressed in basis points
// i.e. 10000 basis points = 100% and 500 = 5%
const ROYALTY_BASIS_POINTS = 500;
const FEE_DENOMINATOR = 10000;

@contract_interface
namespace IERC2981 {
    func royaltyInfo(tokenId: Uint256, salePrice: Uint256) -> (
        receiver: felt, royaltyAmount: Uint256
    ) {
    }
}

namespace Royalty {
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        ERC165.register_interface(IERC2981_ID);
        return ();
    }

    func royalty_info{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        token_id: Uint256, sale_price: Uint256
    ) -> (receiver: felt, royalty_amount: Uint256) {
        alloc_locals;
        let (receiver) = Ownable.owner();

        // royalty_amount = sale_price * ROYALTY_BASIS_POINTS / FEE_DENOMINATOR
        let (x: Uint256) = SafeUint256.mul(sale_price, Uint256(ROYALTY_BASIS_POINTS, 0));
        let (royalty_amount: Uint256, _) = SafeUint256.div_rem(x, Uint256(FEE_DENOMINATOR, 0));

        return (receiver, royalty_amount);
    }
}
