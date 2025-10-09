// These two lines are necessary for the program to properly compile.
//
// Under the hood, we wrap your main function with some extra code so that it behaves properly
// inside the zkVM.
#![no_main]
sp1_zkvm::entrypoint!(main);
use tree_hash::TreeHash;

use ream_consensus::electra::beacon_state::BeaconState;

use ream_lib::{input::OperationInput, ssz::from_ssz_bytes};

#[sp1_derive::cycle_tracker]
fn deserialize<T: ssz::Decode>(ssz_bytes: &[u8]) -> T {
    println!("cycle-tracker-report-start: deserialize-{}", std::any::type_name::<T>());
    let deserialized = from_ssz_bytes(&ssz_bytes).unwrap();
    println!("cycle-tracker-report-end: deserialize-{}", std::any::type_name::<T>());
    deserialized
}
pub fn main() {
    // Read an input to the program.
    //
    // Behind the scenes, this compiles down to a custom system call which handles reading inputs
    // from the prover.
    // NOTE: BeaconState/OperationInput should implement Serialize & Deserialize trait.

    println!("cycle-tracker-report-start: read-pre-state-ssz");
    let pre_state_ssz_bytes = sp1_zkvm::io::read_vec();
    println!("cycle-tracker-report-end: read-pre-state-ssz");
    
    let mut state: BeaconState = deserialize(&pre_state_ssz_bytes);

    println!("cycle-tracker-report-start: read-operation-input");
    let input = sp1_zkvm::io::read::<OperationInput>();
    println!("cycle-tracker-report-end: read-operation-input");

    // Main logic of the program.
    // State transition of the beacon state.
    println!("cycle-tracker-report-start: process-operation");
    input.process(&mut state);
    println!("cycle-tracker-report-end: process-operation");

    println!("cycle-tracker-report-start: merkleize-operation");
    let state_root = state.tree_hash_root();
    println!("cycle-tracker-report-end: merkleize-operation");

    println!("cycle-tracker-report-start: commit");
    sp1_zkvm::io::commit(&state_root);
    println!("cycle-tracker-report-end: commit");
}
