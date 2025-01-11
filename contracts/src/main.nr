use dep::aztec::macros::aztec;
mod test;
#[aztec]
contract FreedomRace {
    use dep::value_note::{utils::increment, value_note::ValueNote};
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
    fn constructor(players: [AztecAddress; 3]) {
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
}
