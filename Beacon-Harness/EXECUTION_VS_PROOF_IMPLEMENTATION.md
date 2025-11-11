# Execution vs Proof Generation Implementation

This document describes the implementation of execution and proof generation modes for SP1, RiscZero, and Zisk ZKVMs.

## Overview

The codebase now supports two modes of operation:
- **Execute Mode**: Fast execution without proof generation (default)
- **Prove Mode**: Slower execution with cryptographic proof generation

## Usage

### Makefile Variables

```bash
# Run with execution mode (default, fast)
make run-block-attestation ZKVM=sp1

# Run with proof generation mode (slow)
make run-block-attestation ZKVM=sp1 MODE=prove

# Run with specific proof type
make run-block-attestation ZKVM=sp1 MODE=prove PROOF_TYPE=groth16
```

### Available Variables

- `ZKVM`: zkVM backend (sp1, risc-zero, zisk, pico)
- `MODE`: execute (default) or prove
- `PROOF_TYPE`: Varies by ZKVM (see below)

### Proof Types by ZKVM

#### SP1
- `core` (default): STARK proof, size proportional to execution
- `compressed`: STARK proof, constant size
- `groth16`: SNARK proof, ~260 bytes, onchain verifiable
- `plonk`: SNARK proof, ~868 bytes, no trusted setup

#### RiscZero
- `succinct` (default): Succinct proof
- `composite`: Composite proof
- `groth16`: Groth16 SNARK proof

#### Zisk
- `default`: Standard Zisk proof

#### Pico
- `core` or `default`: Fast proof (RISC-V phase only, for testing - NOT production)
- `compressed`, `groth16`, `plonk`, etc.: Full proof (RISC-V + Recursion phase, production-ready)

## Implementation Details

### 1. Makefile Changes ([Beacon-Harness/host/Makefile](Beacon-Harness/host/Makefile))

**Added Variables (lines 16-30):**
```makefile
MODE ?= execute
PROOF_TYPE ?= default

ifeq ($(MODE),execute)
    RISC0_DEV_MODE = 1
else
    RISC0_DEV_MODE = 0
endif
```

**Updated Commands:**
All cargo run commands now pass `--mode $(MODE) --proof-type $(PROOF_TYPE)` arguments.
Log files are now named with the pattern: `$(MODE)_$(ZKVM)_block_$*.log`

### 2. Host Code Changes ([Beacon-Harness/host/src/bin/main.rs](Beacon-Harness/host/src/bin/main.rs))

**New Enums (lines 64-90):**
- `ExecutionMode`: Execute or Prove
- `ProofType`: Core, Compressed, Groth16, Plonk, Succinct, Composite, Default

**Updated CLI Arguments (lines 107-113):**
```rust
/// Execution mode: execute (fast, no proof) or prove (slow, generates proof)
#[clap(long, value_enum, default_value = "execute")]
mode: ExecutionMode,

/// Proof type (varies by zkVM)
#[clap(long, value_enum, default_value = "default")]
proof_type: ProofType,
```

### 3. ZKVM Implementation Details

#### SP1 ([main.rs](Beacon-Harness/host/src/bin/main.rs):215-337)

**Execute Mode:**
- Uses `client.execute(OPERATIONS_ELF, &stdin).run()`
- Returns execution report with cycle counts
- Fast, no proof generated

**Prove Mode:**
- Uses `client.setup(OPERATIONS_ELF)` to get proving/verifying keys
- Generates proof based on `proof_type`:
  - `core/default`: `client.prove(&pk, &stdin).run()`
  - `compressed`: `client.prove(&pk, &stdin).compressed().run()`
  - `groth16`: `client.prove(&pk, &stdin).groth16().run()`
  - `plonk`: `client.prove(&pk, &stdin).plonk().run()`
- Verifies proof with `client.verify(&proof, &vk)`
- Logs proof size, proving time, verification time

#### RiscZero ([main.rs](Beacon-Harness/host/src/bin/main.rs):339-470)

**Execute Mode (NEW):**
- Uses `default_executor()` and `executor.execute(env, CONSENSUS_STF_ELF)`
- Returns session info with journal
- Fast, no proof generated
- Previously only supported prove mode

**Prove Mode (EXISTING, enhanced):**
- Uses `default_prover()` and `prover.prove_with_opts(env, CONSENSUS_STF_ELF, &opts)`
- Supports multiple proof types via `ProverOpts`:
  - `succinct`: `ProverOpts::succinct()`
  - `composite`: `ProverOpts::composite()`
  - `groth16`: `ProverOpts::groth16()`
- Verifies proof with `receipt.verify(CONSENSUS_STF_ID)`
- Logs seal size, proving time, verification time

#### Zisk ([main.rs](Beacon-Harness/host/src/bin/main.rs):472-673)

**Execute Mode (EXISTING):**
- Uses `ziskemu` emulator with flags: `-e`, `-i`, `-m`, `-x`
- Parses hex output from stdout
- Fast, no proof generated

**Prove Mode (NEW):**
- Three-step workflow:
  1. **ROM Setup**: `cargo-zisk rom-setup` - generates setup files
  2. **Prove**: `cargo-zisk prove -i <input> -o <output>` - generates proof
  3. **Verify**: `cargo-zisk verify -i <proof_output>` - verifies proof
- Logs proving time and verification time
- All operations use subprocess calls to `cargo-zisk`

#### Pico ([main.rs](Beacon-Harness/host/src/bin/main.rs):769-886)

**Execute Mode:**
- Uses `client.emulate(stdin_builder)`
- Returns execution cycles and raw output
- Fast, no proof generated

**Prove Mode (NEW):**
- Generates proof based on `proof_type`:
  - `core/default`: `client.prove_fast()` - RISC-V phase only (fast, for testing)
    - **Warning**: Uses reduced security, NOT for production use
  - Other types: `client.prove()` - Full proof with RISC-V + Recursion phase (production-ready)
- Extracts public values from `proof.pv_stream`
- Parses 8-byte prefix + 32-byte state root from output
- Logs proving time
- **Note**: Local verification skipped; proofs typically verified on-chain via PicoVerifier.sol
- **Requires**: Nightly Rust compiler (`cargo +nightly`) due to unstable features

## Key Differences Between Modes

| Aspect | Execute Mode | Prove Mode |
|--------|--------------|------------|
| Speed | Fast (seconds) | Slow (minutes to hours) |
| Output | State root only | Cryptographic proof + state root |
| Verification | Trust-based | Cryptographically verifiable |
| Use Case | Development, testing | Production, trustless verification |
| RiscZero Env Var | `RISC0_DEV_MODE=1` | `RISC0_DEV_MODE=0` |

## Environment Variables

### RiscZero
The Makefile automatically sets `RISC0_DEV_MODE` based on the `MODE` variable:
- Execute mode: `RISC0_DEV_MODE=1` (enables dev mode, faster)
- Prove mode: `RISC0_DEV_MODE=0` (disables dev mode, enables proving)

## Examples

```bash
# Execute mode (fast)
make run-block-attestation ZKVM=sp1 MODE=execute
make run-block-attestation ZKVM=risc-zero MODE=execute
make run-block-attestation ZKVM=zisk MODE=execute
make run-block-attestation ZKVM=pico MODE=execute

# Prove mode with default proof type
make run-block-attestation ZKVM=sp1 MODE=prove
make run-block-attestation ZKVM=risc-zero MODE=prove
make run-block-attestation ZKVM=zisk MODE=prove
make run-block-attestation ZKVM=pico MODE=prove

# Prove mode with specific proof type
make run-block-attestation ZKVM=sp1 MODE=prove PROOF_TYPE=groth16
make run-block-attestation ZKVM=risc-zero MODE=prove PROOF_TYPE=composite
make run-block-attestation ZKVM=pico MODE=prove PROOF_TYPE=compressed

# Run all block operations with proving
make sp1-block-all MODE=prove PROOF_TYPE=compressed
make r0-block-all MODE=prove PROOF_TYPE=succinct
make zisk-block-all MODE=prove
```

## Testing

All four features compile successfully:
```bash
cargo check --features sp1           # ✓ Compiles
cargo check --features risc0         # ✓ Compiles
cargo check --features zisk          # ✓ Compiles
cargo +nightly check --features pico # ✓ Compiles (requires nightly)
```

## Notes

1. **Pico**:
   - Prove mode now implemented with both fast (testing) and full (production) proving
   - Requires nightly Rust compiler due to pico SDK's unstable features
   - Local verification not implemented; proofs intended for on-chain verification via PicoVerifier.sol
2. **Jolt**: Function signatures updated but only execute mode is supported (prove mode not implemented)
3. **Log Files**: Now named `{mode}_{zkvm}_{operation_type}_{operation}.log` (e.g., `prove_sp1_block_attestation.log`)
4. **Backward Compatibility**: Default mode is `execute`, maintaining existing behavior
5. **Proof Verification**: SP1, RiscZero, and Zisk prove modes include automatic proof verification

## Future Work

- Implement prove mode for Jolt
- Add local proof verification for Pico
- Add proof size metrics to logs for all ZKVMs
- Support GPU acceleration for Zisk prove mode
- Add proof archival/storage options
- Add EVM proof generation support for Pico (`prove_evm`)
