use ream_consensus::electra::beacon_state::BeaconState;
use tree_hash::TreeHash;
use ream_lib::{input::OperationInput, ssz::from_ssz_bytes};
use jolt::{start_cycle_tracking, end_cycle_tracking};

#[jolt::provable(
    stack_size = 100000,
    memory_size = 50000000,
    max_input_size = 10000000,
    max_output_size = 10000000
)]
pub fn state_transition(pre_state_ssz_bytes: Vec<u8>, input: OperationInput) -> tree_hash::Hash256 {
    // Deserialize the pre-state
    start_cycle_tracking("deserialize_pre_state");
    let mut state: BeaconState = from_ssz_bytes(&pre_state_ssz_bytes).unwrap();
    end_cycle_tracking("deserialize_pre_state");
    // Process the operation input
    start_cycle_tracking("process_operation");
    input.process(&mut state);
    end_cycle_tracking("process_operation");
    // Compute and return the state root
    let state_root = state.tree_hash_root();
    state_root
}

