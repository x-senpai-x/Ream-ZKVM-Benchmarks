#!/bin/bash

OPERATION=$1

LOG_FILE="logs/execution_$OPERATION.log"
OUTPUT_FILE="summaries/summary_$OPERATION.md"

# Table Header
echo '| Operation | Test Case | Read Pre-State SSZ | Read Pre-State SSZ Time | Deserialize Pre-State SSZ | Deserialize Pre-State SSZ Time | Read Operation Input | Read Operation Input Time | Process | Process Time | Merkleize | Merkleize Time | Commit | Commit Time | Total Cycles | Execution Time | Execution Time Host Call |' > $OUTPUT_FILE
echo '|-----------|-----------|--------------------|-------------------------|---------------------------|--------------------------------|----------------------|---------------------------|---------|--------------|-----------|----------------|--------|-------------|--------------|----------------|--------------------------|' >> $OUTPUT_FILE

 awk '
BEGIN {
    op = "";
    test_case = "";
    read_pre_state_ssz_start = 0;
    read_pre_state_ssz_end = 0;
    read_pre_state_ssz_cycles = 0;
    deserialize_pre_state_ssz_start = 0;
    deserialize_pre_state_ssz_end = 0;
    deserialize_pre_state_ssz_cycles = 0;
    read_operation_input_start = 0;
    read_operation_input_end = 0;
    read_operation_input_cycles = 0;
    process_operation_start = 0;
    process_operation_end = 0;
    process_operation_cycles = 0;
    merkleize_operation_start = 0;
    merkleize_operation_end = 0;
    merkleize_operation_cycles = 0;
    commit_start = 0;
    commit_end = 0;
    commit_cycles = 0;
    total_cycles = 0;
    execution_time = 0;
    execution_time_host_call = 0;
}

/\[.*\] Test case:/ {
    op = $4;
    gsub(/[\[\]]/, "", op)
    test_case = $NF;
}

# RISC Zero format (start/end markers)
/read-pre-state-ssz:start:/ {
    read_pre_state_ssz_start = $NF;
}

/read-pre-state-ssz:end:/ {
    read_pre_state_ssz_end = $NF;
}

/deserialize-ream_consensus_beacon::electra::beacon_state::BeaconState:start:/ {
    deserialize_pre_state_ssz_start = $NF;
}

/deserialize-ream_consensus_beacon::electra::beacon_state::BeaconState:end:/ {
    deserialize_pre_state_ssz_end = $NF;
}

/read-operation-input:start:/ {
    read_operation_input_start = $NF;
}

/read-operation-input:end:/ {
    read_operation_input_end = $NF;
}

/process-operation:start:/ {
    process_operation_start = $NF;
}

/process-operation:end:/ {
    process_operation_end = $NF;
}

/merkleize-operation:start:/ {
    merkleize_operation_start = $NF;
}

/merkleize-operation:end:/ {
    merkleize_operation_end = $NF;
}

/commit:start:/ {
    commit_start = $NF;
}

/commit:end:/ {
    commit_end = $NF;
}

# SP1 format (direct cycle counts)
/read-pre-state-ssz: [0-9]/ {
    gsub(/,/, "", $NF);
    read_pre_state_ssz_cycles = $NF;
}

/deserialize-ream_consensus_beacon::electra::beacon_state::BeaconState: [0-9]/ {
    gsub(/,/, "", $NF);
    deserialize_pre_state_ssz_cycles = $NF;
}

/read-operation-input: [0-9]/ {
    gsub(/,/, "", $NF);
    read_operation_input_cycles = $NF;
}

/process-operation: [0-9]/ {
    gsub(/,/, "", $NF);
    process_operation_cycles = $NF;
}

/merkleize-operation: [0-9]/ {
    gsub(/,/, "", $NF);
    merkleize_operation_cycles = $NF;
}

/commit: [0-9]/ && !/commit_start/ && !/commit_end/ {
    gsub(/,/, "", $NF);
    commit_cycles = $NF;
}

/Number of cycles: [0-9]/ {
    gsub(/,/, "", $NF);
    total_cycles = $NF;
}

/execution time:/ {
    execution_time = $NF;
}

/execution time host call:/ || /execution-time-host-call:/ {
    execution_time_host_call = $NF;
}

/----- Cycle Tracker End -----/ {
    # Parse execution_time_host_call to get seconds as a float
    exec_time_seconds = 0;
    if (match(execution_time_host_call, /[0-9.]+/)) {
        exec_time_seconds = substr(execution_time_host_call, RSTART, RLENGTH);
    }

    # Determine which format was used and calculate accordingly
    if (read_pre_state_ssz_cycles > 0) {
        # SP1 format
        # Calculate execution time for each operation
        read_pre_state_ssz_time = (total_cycles > 0) ? sprintf("%.6fs", (read_pre_state_ssz_cycles * exec_time_seconds) / total_cycles) : "0s";
        deserialize_pre_state_ssz_time = (total_cycles > 0) ? sprintf("%.6fs", (deserialize_pre_state_ssz_cycles * exec_time_seconds) / total_cycles) : "0s";
        read_operation_input_time = (total_cycles > 0) ? sprintf("%.6fs", (read_operation_input_cycles * exec_time_seconds) / total_cycles) : "0s";
        process_operation_time = (total_cycles > 0) ? sprintf("%.6fs", (process_operation_cycles * exec_time_seconds) / total_cycles) : "0s";
        merkleize_operation_time = (total_cycles > 0) ? sprintf("%.6fs", (merkleize_operation_cycles * exec_time_seconds) / total_cycles) : "0s";
        commit_time = (total_cycles > 0) ? sprintf("%.6fs", (commit_cycles * exec_time_seconds) / total_cycles) : "0s";

        printf "%s | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %s |\n", op, test_case, read_pre_state_ssz_cycles, read_pre_state_ssz_time, deserialize_pre_state_ssz_cycles, deserialize_pre_state_ssz_time, read_operation_input_cycles, read_operation_input_time, process_operation_cycles, process_operation_time, merkleize_operation_cycles, merkleize_operation_time, commit_cycles, commit_time, total_cycles, execution_time, execution_time_host_call >> "'$OUTPUT_FILE'"
    } else {
        # RISC Zero format
        read_pre_state_ssz_cycles = read_pre_state_ssz_end - read_pre_state_ssz_start;
        deserialize_pre_state_ssz_cycles = deserialize_pre_state_ssz_end - deserialize_pre_state_ssz_start;
        read_operation_input_cycles = read_operation_input_end - read_operation_input_start;
        process_operation_cycles = process_operation_end - process_operation_start;
        merkleize_operation_cycles = merkleize_operation_end - merkleize_operation_start;
        commit_cycles = commit_end - commit_start;
        total_cycles = commit_end;

        # Calculate execution time for each operation
        read_pre_state_ssz_time = (total_cycles > 0) ? sprintf("%.6fs", (read_pre_state_ssz_cycles * exec_time_seconds) / total_cycles) : "0s";
        deserialize_pre_state_ssz_time = (total_cycles > 0) ? sprintf("%.6fs", (deserialize_pre_state_ssz_cycles * exec_time_seconds) / total_cycles) : "0s";
        read_operation_input_time = (total_cycles > 0) ? sprintf("%.6fs", (read_operation_input_cycles * exec_time_seconds) / total_cycles) : "0s";
        process_operation_time = (total_cycles > 0) ? sprintf("%.6fs", (process_operation_cycles * exec_time_seconds) / total_cycles) : "0s";
        merkleize_operation_time = (total_cycles > 0) ? sprintf("%.6fs", (merkleize_operation_cycles * exec_time_seconds) / total_cycles) : "0s";
        commit_time = (total_cycles > 0) ? sprintf("%.6fs", (commit_cycles * exec_time_seconds) / total_cycles) : "0s";

        printf "%s | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %s |\n", op, test_case, read_pre_state_ssz_cycles, read_pre_state_ssz_time, deserialize_pre_state_ssz_cycles, deserialize_pre_state_ssz_time, read_operation_input_cycles, read_operation_input_time, process_operation_cycles, process_operation_time, merkleize_operation_cycles, merkleize_operation_time, commit_cycles, commit_time, total_cycles, execution_time, execution_time_host_call >> "'$OUTPUT_FILE'"
    }

    # Re-initialize for next log
    op = "";
    test_case = "";
    read_pre_state_ssz_start = 0;
    read_pre_state_ssz_end = 0;
    read_pre_state_ssz_cycles = 0;
    deserialize_pre_state_ssz_start = 0;
    deserialize_pre_state_ssz_end = 0;
    deserialize_pre_state_ssz_cycles = 0;
    read_operation_input_start = 0;
    read_operation_input_end = 0;
    read_operation_input_cycles = 0;
    process_operation_start = 0;
    process_operation_end = 0;
    process_operation_cycles = 0;
    merkleize_operation_start = 0;
    merkleize_operation_end = 0;
    merkleize_operation_cycles = 0;
    commit_start = 0;
    commit_end = 0;
    commit_cycles = 0;
    total_cycles = 0;
    execution_time = 0;
    execution_time_host_call = 0;
}
' $LOG_FILE
