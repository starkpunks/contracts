// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.4.0b (token/erc721/enumerable/presets/ERC721EnumerableMintableBurnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import (
    Uint256,
    uint256_add,
    uint256_unsigned_div_rem,
    assert_uint256_le,
)
from starkware.cairo.common.math import assert_not_zero, assert_in_range
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.alloc import alloc

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.upgrades.library import Proxy

from utils.token_uri import TokenUri
from utils.whitelist import Whitelist
from utils.royalty import Royalty
from starkpunks.library import Starkpunks

//
// Getters
//

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC721.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC721.symbol();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    return ERC721.balance_of(owner);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    owner: felt
) {
    return ERC721.owner_of(tokenId);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (approved: felt) {
    return ERC721.get_approved(tokenId);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (isApproved: felt) {
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved=isApproved);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    return Ownable.owner();
}

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interfaceId: felt
) -> (success: felt) {
    return ERC165.supports_interface(interfaceId);
}

@view
func totalSupply{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC721Enumerable.total_supply();
    return (totalSupply=totalSupply);
}

@view
func tokenByIndex{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    index: Uint256
) -> (tokenId: Uint256) {
    let (tokenId: Uint256) = ERC721Enumerable.token_by_index(index);
    return (tokenId=tokenId);
}

@view
func tokenOfOwnerByIndex{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    owner: felt, index: Uint256
) -> (tokenId: Uint256) {
    let (tokenId: Uint256) = ERC721Enumerable.token_of_owner_by_index(owner, index);
    return (tokenId=tokenId);
}

@view
func baseTokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    baseTokenURI_len: felt, baseTokenURI: felt*
) {
    let (baseTokenURI_len, baseTokenURI) = TokenUri.base_token_uri();
    return (baseTokenURI_len, baseTokenURI);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (tokenURI_len: felt, tokenURI: felt*) {
    let (tokenURI_len, tokenURI) = TokenUri.token_uri(tokenId);
    return (tokenURI_len, tokenURI);
}

// EIP 2981 - Royalties

@view
func royaltyInfo{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256, salePrice: Uint256
) -> (receiver: felt, royaltyAmount: Uint256) {
    let (receiver: felt, royaltyAmount: Uint256) = Royalty.royalty_info(tokenId, salePrice);
    return (receiver, royaltyAmount);
}

// Custom views

@view
func merkle_root{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    merkle_root: felt
) {
    return Whitelist.merkle_root();
}

@view
func max_supply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    max_supply: felt
) {
    return Starkpunks.max_supply();
}

@view
func mint_phase{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    mint_phase: felt
) {
    return Starkpunks.mint_phase();
}

@view
func minted_count{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (minted_count: felt) {
    return Starkpunks.minted_count(address);
}

@view
func max_per_address{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    max_per_address: felt
) {
    return Starkpunks.max_per_address();
}

//
// Modifiers
//

@external
func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, max_supply: felt
) {
    Proxy.initializer(owner);
    Ownable.initializer(owner);
    ERC721.initializer('Starkpunks', 'SPK');
    ERC721Enumerable.initializer();
    Starkpunks.initializer(max_supply);
    Royalty.initializer();
    return ();
}

@external
func upgrade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_implementation: felt
) {
    Proxy.assert_only_admin();
    Proxy._set_implementation_hash(new_implementation);
    return ();
}

@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    ERC721.approve(to, tokenId);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    ERC721Enumerable.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    ERC721Enumerable.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

@external
func setBaseTokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    baseTokenURI_len: felt, baseTokenURI: felt*
) {
    Ownable.assert_only_owner();
    TokenUri._set_base_token_uri(baseTokenURI_len, baseTokenURI);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    newOwner: felt
) {
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.renounce_ownership();
    return ();
}

@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(tokenId: Uint256) {
    ERC721.assert_only_token_owner(tokenId);
    ERC721Enumerable._burn(tokenId);
    return ();
}

@external
func setMintPhase{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    mint_phase: felt
) {
    Starkpunks.set_mint_phase(mint_phase);
    return ();
}

@external
func setMaxMintsPerAddress{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    max_per_address: felt
) {
    Starkpunks.set_max_per_address(max_per_address);
    return ();
}

// Custom modifiers

@external
func setMerkleRoot{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    merkle_root: felt
) {
    Whitelist.set_merkle_root(merkle_root);
    return ();
}

@external
func mintCount{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, count: felt
) {
    Starkpunks.mint_count(to, count);
    return ();
}

@external
func mintWhitelist{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    proof_len: felt, proof: felt*
) {
    Starkpunks.mint_whitelist(proof_len, proof);
    return ();
}

@external
func mintPublic{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() {
    Starkpunks.mint_public();
    return ();
}
