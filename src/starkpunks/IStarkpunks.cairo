%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IStarkpunks {
    //
    // Views
    //

    func baseTokenURI() -> (baseTokenURI_len: felt, baseTokenURI: felt*) {
    }
    func merkle_root() -> (merkle_root: felt) {
    }
    func minted_count(address: felt) -> (count: felt) {
    }

    //
    // Externals
    //

    func setBaseTokenURI(baseTokenUri_len: felt, baseTokenUri: felt*) {
    }
    func setMerkleRoot(merkle_root: felt) {
    }
    func setMintPhase(mint_phase: felt) {
    }
    func setMaxMintsPerAddress(max_per_address: felt) {
    }
    func mintCount(to: felt, count: felt) -> () {
    }
    func mintWhitelist(proof_len: felt, proof: felt*) {
    }
    func mintPublic() {
    }
}
