%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@view
func deploy_starkpunks_contract{syscall_ptr: felt*, range_check_ptr, pedersen_ptr: HashBuiltin*}() {
    %{
        from starkware.starknet.public.abi import get_selector_from_name

        context.owner = 123
        context.max_supply = 10

        implem_hash = declare("src/Starkpunks.cairo").class_hash

        context.starkpunks_address = deploy_contract("src/Proxy.cairo", {
            "implementation_hash": implem_hash,
            "selector": get_selector_from_name("initializer"),
            "calldata": [
                context.owner,
                context.max_supply,
            ]
        }).contract_address
    %}

    return ();
}