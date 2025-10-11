use pico_sdk::io::{commit, read_as, read_vec};
use tree_hash::TreeHash;

use ream_consensus::electra::beacon_state::BeaconState;
use ream_lib::{
    input::OperationInput,
    ssz::from_ssz_bytes,
};

fn main() {
    // Read inputs to the program.

    // Read pre-state length and bytes
    let _pre_state_len: usize = read_as();
    let pre_state_ssz_bytes: Vec<u8> = read_vec();

    // Deserialize beacon state
    let mut state: BeaconState = from_ssz_bytes(&pre_state_ssz_bytes).unwrap();

    // Read operation input
    let input: OperationInput = read_as();

    // Process the operation on the beacon state
    // The OperationInput::process() method handles all the matching internally
    input.process(&mut state);

    // Merkleize the processed state
    let state_root = state.tree_hash_root();

    // Commit the state root as output
    commit(&state_root);
}
