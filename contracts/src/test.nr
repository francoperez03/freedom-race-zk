use dep::aztec::{prelude::AztecAddress, test::helpers::test_environment::TestEnvironment};

use crate::FreedomRace;

pub unconstrained fn setup() -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();

    let alice = env.create_account();
    let bob = env.create_account();
    let carlo = env.create_account();

    let initializer_call_interface = FreedomRace::interface().constructor([alice, bob, carlo]);

    let game_contract =
        env.deploy_self("FreedomRace").with_public_void_initializer(initializer_call_interface);

    let game_contract_address = game_contract.to_address();
    env.advance_block_by(1);
    (&mut env, game_contract_address, alice, bob, carlo)
}
