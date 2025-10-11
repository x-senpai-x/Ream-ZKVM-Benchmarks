#!/bin/bash

OPERATION=$1

LOG_FILE="logs/execution_$OPERATION.log"
OUTPUT_FILE="summaries/summary_$OPERATION.md"

# Determine the path to timinganalysis.py relative to this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMING_ANALYSIS_SCRIPT="$SCRIPT_DIR/../../guest/zisk/timinganalysis.py"

# Table Header
echo '| Operation | Test Case | Read Pre-State SSZ | Read Pre-State SSZ Time | Deserialize Pre-State SSZ | Deserialize Pre-State SSZ Time | Read Operation Input | Read Operation Input Time | Process | Process Time | Merkleize | Merkleize Time | Commit | Commit Time | Total Cycles | Execution Time | Execution Time Host Call |' > $OUTPUT_FILE
echo '|-----------|-----------|--------------------|-------------------------|---------------------------|--------------------------------|----------------------|---------------------------|---------|--------------|-----------|----------------|--------|-------------|--------------|----------------|--------------------------|' >> $OUTPUT_FILE

# For ZisK, run timing analysis once and save to temp file
TIMING_TEMP_FILE=""
if [[ "$OPERATION" == zisk* ]]; then
    TIMING_TEMP_FILE=$(mktemp)
    python3 "$TIMING_ANALYSIS_SCRIPT" --shell-vars "$LOG_FILE" 2>/dev/null > "$TIMING_TEMP_FILE"
fi

 awk -v timing_file="$TIMING_TEMP_FILE" '
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
    is_zisk = 0;
}

/\[.*\] Test case:/ {
    op = $4;
    gsub(/[\[\]]/, "", op)
    test_case = $NF;
}

# ZISK format detection - look for eprintln format
/read-inputs:start/ {
    is_zisk = 1;
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

# Pico format - Execution time and Execution cycles
/Execution time:/ {
    execution_time_host_call = $NF;
}

/Execution cycles:/ {
    total_cycles = $NF;
}

# ZISK format - process_rom() steps and duration
/process_rom\(\) steps=/ {
    for (i = 1; i <= NF; i++) {
        if ($i ~ /^steps=/) {
            gsub(/steps=/, "", $i);
            total_cycles = $i;
        }
        if ($i ~ /^duration=/) {
            gsub(/duration=/, "", $i);
            execution_time_host_call = $i;
        }
    }
}

# ZISK format - timing from eprintln
/read-inputs:/ && /start/ {
    zisk_read_inputs_start = 1;
}

/deserialize-pre-state-ssz:/ && /start/ {
    zisk_deserialize_pre_state_start = 1;
}

/deserialize-operation-input:/ && /start/ {
    zisk_read_operation_start = 1;
}

/process-operation:/ && /start/ {
    zisk_process_start = 1;
}

/merkleize-operation:/ && /start/ {
    zisk_merkleize_start = 1;
}

/output-state-root:/ && /start/ {
    zisk_output_start = 1;
}

/----- Cycle Tracker End -----/ {
    # Parse execution_time_host_call to get seconds as a float
    exec_time_seconds = 0;
    if (match(execution_time_host_call, /[0-9.]+/)) {
        exec_time_seconds = substr(execution_time_host_call, RSTART, RLENGTH);
    }

    # Determine which format was used and calculate accordingly
    # Check for Pico format: has total_cycles and execution_time_host_call but no detailed cycle breakdowns
    if (total_cycles > 0 && read_pre_state_ssz_cycles == 0 && read_pre_state_ssz_start == 0 && !is_zisk) {
        # Pico format - only has total cycles and execution time, no per-operation breakdown
        printf "%s | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %s |\n", \
            op, test_case, \
            0, "0s", \
            0, "0s", \
            0, "0s", \
            0, "0s", \
            0, "0s", \
            0, "0s", \
            total_cycles, execution_time, execution_time_host_call >> "'$OUTPUT_FILE'"
    } else if (is_zisk) {
        # ZISK format - use timing analysis to extract per-operation costs
        # Read the timing data from the temp file

        # Initialize variables
        read_inputs_cycles = 0
        read_inputs_time = 0
        deserialize_pre_state_cycles = 0
        deserialize_pre_state_time = 0
        read_operation_input_cycles = 0
        read_operation_input_time = 0
        process_operation_cycles = 0
        process_operation_time = 0
        merkleize_operation_cycles = 0
        merkleize_operation_time = 0
        output_state_root_cycles = 0
        output_state_root_time = 0

        # Read the timing analysis data from temp file
        if (timing_file != "") {
            while ((getline line < timing_file) > 0) {
                split(line, parts, "=")
                key = parts[1]
                value = parts[2]

                if (key == "READ_INPUTS_CYCLES") {
                    read_inputs_cycles = value
                } else if (key == "READ_INPUTS_TIME") {
                    read_inputs_time = value
                } else if (key == "DESERIALIZE_PRE_STATE_CYCLES") {
                    deserialize_pre_state_cycles = value
                } else if (key == "DESERIALIZE_PRE_STATE_TIME") {
                    deserialize_pre_state_time = value
                } else if (key == "READ_OPERATION_INPUT_CYCLES") {
                    read_operation_input_cycles = value
                } else if (key == "READ_OPERATION_INPUT_TIME") {
                    read_operation_input_time = value
                } else if (key == "PROCESS_OPERATION_CYCLES") {
                    process_operation_cycles = value
                } else if (key == "PROCESS_OPERATION_TIME") {
                    process_operation_time = value
                } else if (key == "MERKLEIZE_OPERATION_CYCLES") {
                    merkleize_operation_cycles = value
                } else if (key == "MERKLEIZE_OPERATION_TIME") {
                    merkleize_operation_time = value
                } else if (key == "OUTPUT_STATE_ROOT_CYCLES") {
                    output_state_root_cycles = value
                } else if (key == "OUTPUT_STATE_ROOT_TIME") {
                    output_state_root_time = value
                }
            }
            close(timing_file)
        }

        # Format time values
        read_inputs_time_str = sprintf("%.6fs", read_inputs_time)
        deserialize_pre_state_time_str = sprintf("%.6fs", deserialize_pre_state_time)
        read_operation_input_time_str = sprintf("%.6fs", read_operation_input_time)
        process_operation_time_str = sprintf("%.6fs", process_operation_time)
        merkleize_operation_time_str = sprintf("%.6fs", merkleize_operation_time)
        output_state_root_time_str = sprintf("%.6fs", output_state_root_time)

        # Note: ZISK maps read-inputs to Read Pre-State SSZ column
        # and uses deserialize-pre-state-ssz for Deserialize Pre-State SSZ column
        printf "%s | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %d | %s | %s |\n", \
            op, test_case, \
            read_inputs_cycles, read_inputs_time_str, \
            deserialize_pre_state_cycles, deserialize_pre_state_time_str, \
            read_operation_input_cycles, read_operation_input_time_str, \
            process_operation_cycles, process_operation_time_str, \
            merkleize_operation_cycles, merkleize_operation_time_str, \
            output_state_root_cycles, output_state_root_time_str, \
            total_cycles, execution_time, execution_time_host_call >> "'$OUTPUT_FILE'"
    } else if (read_pre_state_ssz_cycles > 0) {
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
    is_zisk = 0;
}
' $LOG_FILE

# Cleanup temp file
if [[ -n "$TIMING_TEMP_FILE" && -f "$TIMING_TEMP_FILE" ]]; then
    rm -f "$TIMING_TEMP_FILE"
fi
