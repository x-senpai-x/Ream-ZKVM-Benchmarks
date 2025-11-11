#![no_main]
ziskos::entrypoint!(main);
use bincode;
use ream_consensus::electra::beacon_state::BeaconState;
use ream_lib::{input::OperationInput, ssz::from_ssz_bytes};
use tree_hash::TreeHash;
use ziskos::read_input;
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
pub struct ZiskInput {
    pre_state_ssz_bytes: Vec<u8>,
    operation_input: Vec<u8>,
}

fn start_timing(operation: &str) {
    eprintln!("TIMING_START:{}", operation);
    eprintln!("OPERATION_DETAILS:{}:started", operation);
}

fn end_timing(operation: &str) {
    eprintln!("OPERATION_DETAILS:{}:completed", operation);
    eprintln!("TIMING_END:{}", operation);
}

fn log_operation_progress(operation: &str, step: &str) {
    eprintln!("OPERATION_PROGRESS:{}:{}", operation, step);
}

fn main() {
    eprintln!("{}:{}", "read-inputs", "start");
    let input_bytes=read_input();
    eprintln!("{}:{}", "read-inputs", "end");

    eprintln!("{}:{}", "deserialize-inputs", "start");
    let zisk_input: ZiskInput = bincode::deserialize(&input_bytes).expect("Failed to deserialize input");
    eprintln!("{}:{}", "deserialize-inputs", "end");

    let pre_state_ssz_bytes = zisk_input.pre_state_ssz_bytes;
    eprintln!("{}:{}", "deserialize-pre-state-ssz", "start");
    start_timing("deserialize-pre-state-ssz");
    log_operation_progress("deserialize-pre-state-ssz", "parsing_ssz_bytes");
    log_operation_progress("deserialize-pre-state-ssz", "creating_beacon_state");
    let mut state: BeaconState = from_ssz_bytes(&pre_state_ssz_bytes).unwrap();
    log_operation_progress("deserialize-pre-state-ssz", "state_created");
    end_timing("deserialize-pre-state-ssz");
    eprintln!("{}:{}", "deserialize-pre-state-ssz", "end");

    eprintln!("{}:{}", "deserialize-operation-input", "start");
    start_timing("deserialize-operation-input");
    log_operation_progress("deserialize-operation-input", "extracting_input_bytes");
    let operation_input_bytes = zisk_input.operation_input;
    log_operation_progress("deserialize-operation-input", "deserializing_operation");
    let operation_input: OperationInput = bincode::deserialize(&operation_input_bytes).unwrap();
    log_operation_progress("deserialize-operation-input", "operation_parsed");
    end_timing("deserialize-operation-input");
    eprintln!("{}:{}", "deserialize-operation-input", "end");

    eprintln!("{}:{}", "process-operation", "start");
    start_timing("process-operation");
    log_operation_progress("process-operation", "initializing_state_transition");
    log_operation_progress("process-operation", "processing_operation");
    operation_input.process(&mut state);
    log_operation_progress("process-operation", "state_transition_complete");
    end_timing("process-operation");
    eprintln!("{}:{}", "process-operation", "end");

    eprintln!("{}:{}", "merkleize-operation", "start");
    start_timing("merkleize-operation");
    log_operation_progress("merkleize-operation", "initializing_tree_hash");
    log_operation_progress("merkleize-operation", "computing_merkle_root");
    let state_root = state.tree_hash_root();
    log_operation_progress("merkleize-operation", "merkle_root_computed");
    end_timing("merkleize-operation");
    eprintln!("{}:{}", "merkleize-operation", "end");

    eprintln!("{}:{}", "output-state-root", "start");
    start_timing("output-state-root");
    log_operation_progress("output-state-root", "preparing_hex_output");
    for byte in state_root.as_ref() as &[u8] {
        print!("{:02x}", byte);
    }
    println!();
    log_operation_progress("output-state-root", "hex_output_complete");
    end_timing("output-state-root");
    eprintln!("{}:{}", "output-state-root", "end");
}