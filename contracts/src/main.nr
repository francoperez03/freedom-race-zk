use dep::aztec::macros::aztec;
mod test;
#[aztec]
contract FreedomRace {
    use dep::value_note::{utils::{increment, decrement}, value_note::ValueNote};
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
    fn advance() {
        let sender = context.msg_sender();
        increment(storage.player_states.at(sender), 1, sender, sender);
    }

    #[private]
    fn sabotage(target: AztecAddress) {
        let sender = context.msg_sender();
        assert(sender != target, "Cannot sabotage yourself");
        decrement(storage.player_states.at(target), 1, target, sender);
    }


}


use dep::value_note::value_note::ValueNote;
use dep::aztec::note::note_getter::{MAX_NOTES_PER_PAGE, view_notes};
use dep::aztec::note::note_viewer_options::NoteViewerOptions;
use dep::aztec::protocol_types::storage::map::derive_storage_slot_in_map;
#[test]
unconstrained fn deploy_test() {
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