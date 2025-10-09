# Beacon Harness

`Beacon Harness` is a unified benchmark suite for Ethereum consensus state transition functions supporting both [RISC Zero zkVM](https://github.com/risc0/risc0) and [SP1](https://github.com/succinctlabs/sp1). It leverages [ream](https://github.com/ReamLabs/ream) to provide comprehensive performance metrics for consensus operations.

## Requirements

- [Rust](https://rustup.rs/)
- [RISC Zero](https://dev.risczero.com/api/getting-started) (for RISC Zero backend)
- [SP1](https://docs.succinct.xyz/getting-started/install.html) (for SP1 backend)

## Running the Project

### Quick Start

First, download the required Ethereum Foundation test data:

```sh
cd host
make download
```

### Running Benchmarks

You can run benchmarks using either RISC Zero or SP1 as the zkVM backend.

#### Run All Benchmarks

With SP1:
```sh
make sp1
```

With RISC Zero:
```sh
make r0
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
make block-all        # Using default backend
```

Run all epoch processing benchmarks:
```sh
make sp1-epoch-all    # Using SP1
make r0-epoch-all     # Using RISC Zero
make epoch-all        # Using default backend
```

#### Run Individual Operations

Run a specific block operation:
```sh
make run-block-<OPERATION_NAME>              # Using default backend
make run-block-<OPERATION_NAME> ZKVM=sp1     # Using SP1
make run-block-<OPERATION_NAME> ZKVM=risc-zero  # Using RISC Zero
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
make run-epoch-<OPERATION_NAME>              # Using default backend
make run-epoch-<OPERATION_NAME> ZKVM=sp1     # Using SP1
make run-epoch-<OPERATION_NAME> ZKVM=risc-zero  # Using RISC Zero
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

# Run all block benchmarks with RISC Zero
make r0-block-all

# Run justification benchmark with default backend
make run-epoch-justification_and_finalization

# Run all benchmarks with SP1
make sp1
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

## Notes

- The `all` target excludes `execution_payload` (not implemented) and `withdrawals` (incompatible with BeaconState workaround) from block operations
- RISC Zero runs with `RISC0_DEV_MODE=1` enabled for faster development iteration
- SP1 benchmarks do not include RISC Zero-specific environment variables
