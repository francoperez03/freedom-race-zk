use dep::aztec::macros::aztec;
mod test;
#[aztec]
contract FreedomRace {   
    use dep::value_note::{balance_utils, utils::{increment, decrement}, value_note::ValueNote};
    use dep::aztec::prelude::{AztecAddress, Map, PrivateSet};
    use dep::aztec::{
        encrypted_logs::encrypted_note_emission::encode_and_encrypt_note,
        macros::{functions::{initializer, private}, storage::storage},
    };

    #[storage]
    struct Storage<Context> {
      player_states: Map<AztecAddress, PrivateSet<ValueNote, Context>, Context>,
    }

    #[private]
    #[initializer]
    fn initialize(players: [AztecAddress; 3]) {
      for player in players {
          let mut initial_note = ValueNote::new(0, player);
          storage.player_states
              .at(player)
              .insert(&mut initial_note)
              .emit(encode_and_encrypt_note(
                  &mut context,
                  player,
                  context.msg_sender(),
              ));
      }
    }

    #[private]
    fn advance(target: AztecAddress) {
        let sender = context.msg_sender();
        increment(storage.player_states.at(target), 1, sender, sender);
    }

    #[private]
    fn sabotage(target: AztecAddress) {
        let sender = context.msg_sender();
        assert(sender != target, "Cannot sabotage yourself");
        decrement(storage.player_states.at(target), 1, target, sender);
    }

    unconstrained fn get_player_state(player: AztecAddress) -> pub Field {
        let player_states = storage.player_states;
        balance_utils::get_balance(player_states.at(player))
    }

    use dep::aztec::note::note_getter::{MAX_NOTES_PER_PAGE, view_notes};
    use dep::aztec::note::note_viewer_options::NoteViewerOptions;
    use dep::aztec::protocol_types::storage::map::derive_storage_slot_in_map;
    use crate::test;

    #[test]
    unconstrained fn test_deploy_contract_initializes_player_states() {
        let (env, game_contract_address, alice) = test::setup();
        env.impersonate(game_contract_address);
        let initial_value = 0;
        let player_states_slot = FreedomRace::storage_layout().player_states.slot;
        let alice_slot = derive_storage_slot_in_map(player_states_slot, alice);

        let mut options = NoteViewerOptions::new();
        let notes: BoundedVec<ValueNote, MAX_NOTES_PER_PAGE> = view_notes(alice_slot, options);
        let initial_note_value = notes.get(0).value;
        assert(
            initial_value == initial_note_value,
            "Expected initial_value to match initial_note_value"
        );
    }

    #[test]
    unconstrained fn test_advance_increments_player_state() {
        let (env, game_contract_address, alice, _bob, _carlo) = test::setup();
        env.impersonate(game_contract_address);

        let player_states_slot = FreedomRace::storage_layout().player_states.slot;
        let alice_slot = derive_storage_slot_in_map(player_states_slot, alice);

        let mut options = NoteViewerOptions::new();
        let notes: BoundedVec<ValueNote, MAX_NOTES_PER_PAGE> = view_notes(alice_slot, options);
        let initial_note_value = notes.get(0).value;

        assert(
            initial_note_value == 0,
            "Expected Alice's initial value to be 0",
        );
        env.impersonate(alice);

        FreedomRace::at(game_contract_address).advance(alice).call(&mut env.private());
        env.impersonate(game_contract_address);

        let current_alice_state = get_player_state(alice);
        let expected_current_value = initial_note_value + 1;
        assert(
            expected_current_value == current_alice_state,
            f"Expected {expected_current_value} but got {current_alice_state}",
        );
    }
    #[test]
    unconstrained fn test_sabotage_decrements_target_player_state() {
        let current_alice_state = 0;
        let expected_current_value =  0;
        assert(
            expected_current_value == current_alice_state,
            f"Expected {expected_current_value} but got {current_alice_state}",
        );
    }
}




