# Beacon Harness

`Beacon Harness` is a unified benchmark suite for Ethereum consensus state transition functions supporting [RISC Zero zkVM](https://github.com/risc0/risc0), [SP1](https://github.com/succinctlabs/sp1), [ZISK](https://github.com/0xPolygonHermez/zisk), [Pico](https://github.com/brevis-network/pico), and [Jolt](https://github.com/a16z/jolt). It leverages [ream](https://github.com/ReamLabs/ream) to provide comprehensive performance metrics for consensus operations.

## Requirements

- [Rust](https://rustup.rs/)
- [RISC Zero](https://dev.risczero.com/api/getting-started) (for RISC Zero backend)
- [SP1](https://docs.succinct.xyz/getting-started/install.html) (for SP1 backend)
- [ZISK](https://github.com/0xPolygonHermez/zisk) (for ZISK backend)
- [Pico](https://github.com/brevis-network/pico) (for Pico backend - requires Rust nightly)
- [Jolt](https://github.com/a16z/jolt) (for Jolt backend)

## Running the Project

### Quick Start

First, download the required Ethereum Foundation test data:

```sh
cd host
make download
```

### Running Benchmarks

You can run benchmarks using RISC Zero, SP1, or ZISK as the zkVM backend.

#### Run All Benchmarks

With SP1:
```sh
make sp1
```

With RISC Zero:
```sh
make r0
```

With ZISK:
```sh
make zisk
```

With Pico:
```sh
make pico
```

With Jolt:
```sh
make jolt
```

With default backend (RISC Zero):
```sh
make all
```

#### Run Specific Operation Types

Run all block processing benchmarks:
```sh
make sp1-block-all    # Using SP1
make r0-block-all     # Using RISC Zero
make zisk-block-all   # Using ZISK
make pico-block-all   # Using Pico
make jolt-block-all   # Using Jolt
make block-all        # Using default backend
```

Run all epoch processing benchmarks:
```sh
make sp1-epoch-all    # Using SP1
make r0-epoch-all     # Using RISC Zero
make zisk-epoch-all   # Using ZISK
make pico-epoch-all   # Using Pico
make jolt-epoch-all   # Using Jolt
make epoch-all        # Using default backend
```

#### Run Individual Operations

Run a specific block operation:
```sh
make run-block-<OPERATION_NAME>                 # Using default backend
make run-block-<OPERATION_NAME> ZKVM=sp1        # Using SP1
make run-block-<OPERATION_NAME> ZKVM=risc-zero  # Using RISC Zero
make run-block-<OPERATION_NAME> ZKVM=zisk       # Using ZISK
make run-block-<OPERATION_NAME> ZKVM=pico       # Using Pico
make run-block-<OPERATION_NAME> ZKVM=jolt       # Using Jolt
```

Available block operations:
- `attestation`
- `attester_slashing`
- `block_header`
- `bls_to_execution_change`
- `deposit`
- `execution_payload` (not implemented)
- `proposer_slashing`
- `sync_aggregate`
- `voluntary_exit`
- `withdrawals` (incompatible with BeaconState workaround)

Run a specific epoch processing operation:
```sh
make run-epoch-<OPERATION_NAME>                 # Using default backend
make run-epoch-<OPERATION_NAME> ZKVM=sp1        # Using SP1
make run-epoch-<OPERATION_NAME> ZKVM=risc-zero  # Using RISC Zero
make run-epoch-<OPERATION_NAME> ZKVM=zisk       # Using ZISK
make run-epoch-<OPERATION_NAME> ZKVM=pico       # Using Pico
make run-epoch-<OPERATION_NAME> ZKVM=jolt       # Using Jolt
```

Available epoch operations:
- `justification_and_finalization`
- `inactivity_updates`
- `rewards_and_penalties`
- `registry_updates`
- `slashings`
- `eth1_data_reset`
- `pending_deposits`
- `pending_consolidations`
- `effective_balance_updates`
- `slashings_reset`
- `randao_mixes_reset`
- `historical_summaries_update`
- `participation_flag_updates`

### Examples

```sh
# Run attestation benchmark with SP1
make run-block-attestation ZKVM=sp1
# Run attestation benchmark with Pico
make run-block-attestation ZKVM=pico
# Run attestation benchmark with Jolt
make run-block-attestation ZKVM=jolt

# Run all block benchmarks with RISC Zero
make r0-block-all

# Run all block benchmarks with Pico
make pico-block-all

# Run all block benchmarks with Jolt
make jolt-block-all

# Run justification benchmark with default backend
make run-epoch-justification_and_finalization

# Run all benchmarks with SP1
make sp1

# Run all benchmarks with Pico
make pico

# Run all benchmarks with Jolt
make jolt
```

### Other Commands

Build the project:
```sh
make build
```

Run tests:
```sh
make test
```

Clean up generated files:
```sh
make clean
```

Show all available commands:
```sh
make help
```

### Output

- **Logs**: Execution logs are saved in `./host/logs/`
- **Summaries**: Benchmark summaries (including cycle counts) are generated in `./host/summaries/`

## Pico Setup

Pico requires Rust nightly and has an additional build step for the guest code.

### First-time Setup

1. Install Rust nightly:
```sh
rustup install nightly
```

2. Build the Pico guest:
```sh
cd guest/app
cargo +nightly pico build
```

### Running Pico Benchmarks

After building the guest, use the Makefile as normal - it automatically handles nightly toolchain:

```sh
make run-block-attestation ZKVM=pico
make pico-block-all
make pico
```

## Notes

- The build system uses feature flags - only the targeted ZKVM is compiled (e.g., `ZKVM=sp1` compiles only SP1)
- The `all` target excludes `execution_payload` (not implemented) and `withdrawals` (incompatible with BeaconState workaround) from block operations
- Zisk only has total execution time available for benchmarks, work is ongoing to capture detailed cycle counts
- Pico is an optional feature and requires Rust nightly. Other zkVMs work with stable Rust.
- Jolt provides trace length metrics and execution time for benchmarks