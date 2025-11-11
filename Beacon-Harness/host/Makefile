TARGET = mainnet.tar.gz
EXTRACT_DIR = mainnet
LOGS_DIR = logs
SUMMARIES_DIR = summaries

DOWNLOAD_SCRIPT = ./subscripts/download_ef_data.sh
PARSE_SCRIPT = ./subscripts/parse_log_to_table.sh
SORT_SCRIPT = ./subscripts/sort_table.sh

BLOCK_OPERATIONS = attestation attester_slashing block_header bls_to_execution_change deposit execution_payload proposer_slashing sync_aggregate voluntary_exit withdrawals
EPOCH_OPERATIONS = justification_and_finalization inactivity_updates rewards_and_penalties registry_updates slashings eth1_data_reset pending_deposits pending_consolidations effective_balance_updates slashings_reset randao_mixes_reset historical_summaries_update participation_flag_updates

# zkVM backend: sp1, risc-zero, zisk, pico, or jolt (default: risc-zero)
ZKVM ?= risc-zero

# Execution mode: execute (fast, no proof) or prove (slow, generates proof)
MODE ?= execute

# Proof type (varies by ZKVM):
# - SP1: core, compressed, groth16, plonk
# - RiscZero: succinct, composite, groth16
# - Zisk: default
PROOF_TYPE ?= default

# Set RISC0_DEV_MODE based on MODE (1 for execute, 0 for prove)
ifeq ($(MODE),execute)
    RISC0_DEV_MODE = 1
else
    RISC0_DEV_MODE = 0
endif

RUST_BACKTRACE = full

.PHONY: all help build test download run clean sp1 r0 risc-zero risc-zero-block-all risc-zero-epoch-all zisk zisk-block-all zisk-epoch-all pico pico-block-all pico-epoch-all jolt jolt-block-all jolt-epoch-all $(addprefix run-block-, $(BLOCK_OPERATIONS)) $(addprefix run-epoch-, $(EPOCH_OPERATIONS)) block-all epoch-all sp1-block-all sp1-epoch-all r0-block-all r0-epoch-all

# Default target shows help
help:
	@echo "Beacon Harness Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [ZKVM=sp1|risc-zero|zisk|pico|jolt] [MODE=execute|prove] [PROOF_TYPE=<type>]"
	@echo ""
	@echo "Variables:"
	@echo "  ZKVM        zkVM backend (default: risc-zero)"
	@echo "  MODE        execute (fast, no proof) or prove (slow, generates proof) (default: execute)"
	@echo "  PROOF_TYPE  Proof type - SP1: core/compressed/groth16/plonk, RiscZero: succinct/composite/groth16 (default: default)"
	@echo ""
	@echo "Targets:"
	@echo "  help              Show this help message"
	@echo "  build             Build the project"
	@echo "  test              Run tests"
	@echo "  download          Download Ethereum Foundation test data"
	@echo "  clean             Clean up generated files"
	@echo ""
	@echo "Run all benchmarks:"
	@echo "  all               Run all benchmarks (excludes execution_payload, withdrawals)"
	@echo "  block-all         Run all block processing benchmarks"
	@echo "  epoch-all         Run all epoch processing benchmarks"
	@echo ""
	@echo "zkVM-specific targets:"
	@echo "  sp1               Run all SP1 benchmarks"
	@echo "  sp1-block-all     Run all block benchmarks with SP1"
	@echo "  sp1-epoch-all     Run all epoch benchmarks with SP1"
	@echo "  r0                Run all RISC Zero benchmarks"
	@echo "  r0-block-all      Run all block benchmarks with RISC Zero"
	@echo "  r0-epoch-all      Run all epoch benchmarks with RISC Zero"
	@echo "  zisk              Run all ZISK benchmarks"
	@echo "  zisk-block-all    Run all block benchmarks with ZISK"
	@echo "  zisk-epoch-all    Run all epoch benchmarks with ZISK"
	@echo "  pico              Run all Pico benchmarks"
	@echo "  pico-block-all    Run all block benchmarks with Pico"
	@echo "  pico-epoch-all    Run all epoch benchmarks with Pico"
	@echo "  jolt              Run all Jolt benchmarks"
	@echo "  jolt-block-all    Run all block benchmarks with Jolt"
	@echo "  jolt-epoch-all    Run all epoch benchmarks with Jolt"
	@echo ""
	@echo "Individual operations:"
	@echo "  Block operations: $(BLOCK_OPERATIONS)"
	@echo "  Epoch operations: $(EPOCH_OPERATIONS)"
	@echo ""
	@echo "Examples:"
	@echo "  make run-block-attestation                           # Run attestation with default zkVM (execute mode)"
	@echo "  make run-block-attestation ZKVM=sp1                  # Run attestation with SP1 (execute mode)"
	@echo "  make run-block-attestation ZKVM=sp1 MODE=prove       # Run attestation with SP1 (prove mode)"
	@echo "  make run-block-attestation ZKVM=sp1 MODE=prove PROOF_TYPE=groth16  # SP1 with Groth16 proof"
	@echo "  make run-block-attestation ZKVM=risc-zero MODE=prove # RISC Zero with proving"
	@echo "  make sp1-block-all MODE=prove                        # Run all block benchmarks with SP1 proving"
	@echo "  make r0-epoch-all MODE=execute                       # Run all epoch benchmarks with RISC Zero execution"
	@echo "  make zisk-block-all MODE=prove                       # Run all block benchmarks with ZISK proving"
	@echo ""

# run-block-execution_payload (not implemented) and run-block-withdrawals (incompatible with BeaconState workaround) are excluded
all: download $(addprefix run-block-, $(filter-out execution_payload withdrawals, $(BLOCK_OPERATIONS))) $(addprefix run-epoch-, $(EPOCH_OPERATIONS))

# Build the project
build:
	@echo "Building project..."
	@cargo build --release
	@echo "Build complete."

# Run tests
test:
	@echo "Running tests..."
	@cargo test
	@echo "Tests complete."

# Run all block processing benchmarks
block-all: $(addprefix run-block-, $(BLOCK_OPERATIONS))

# Run all epoch processing benchmarks
epoch-all: $(addprefix run-epoch-, $(EPOCH_OPERATIONS))

# Run all benchmarks with SP1
sp1:
	@$(MAKE) all ZKVM=sp1

# Run all block processing benchmarks with SP1
sp1-block-all:
	@$(MAKE) block-all ZKVM=sp1

# Run all epoch processing benchmarks with SP1
sp1-epoch-all:
	@$(MAKE) epoch-all ZKVM=sp1

# Run all benchmarks with RISC Zero
r0:
	@$(MAKE) all ZKVM=risc-zero

# Alias for r0
risc-zero: r0

# Run all block processing benchmarks with RISC Zero
r0-block-all:
	@$(MAKE) block-all ZKVM=risc-zero

# Alias for r0-block-all
risc-zero-block-all: r0-block-all

# Run all epoch processing benchmarks with RISC Zero
r0-epoch-all:
	@$(MAKE) epoch-all ZKVM=risc-zero

# Alias for r0-epoch-all
risc-zero-epoch-all: r0-epoch-all

# Run all benchmarks with ZISK
zisk:
	@$(MAKE) all ZKVM=zisk

# Run all block processing benchmarks with ZISK
zisk-block-all:
	@$(MAKE) block-all ZKVM=zisk

# Run all epoch processing benchmarks with ZISK
zisk-epoch-all:
	@$(MAKE) epoch-all ZKVM=zisk

# Run all benchmarks with Pico
pico:
	@$(MAKE) all ZKVM=pico

# Run all block processing benchmarks with Pico
pico-block-all:
	@$(MAKE) block-all ZKVM=pico

# Run all epoch processing benchmarks with Pico
pico-epoch-all:
	@$(MAKE) epoch-all ZKVM=pico

# Run all benchmarks with Jolt
jolt:
	@$(MAKE) all ZKVM=jolt

# Run all block processing benchmarks with Jolt
jolt-block-all:
	@$(MAKE) block-all ZKVM=jolt

# Run all epoch processing benchmarks with Jolt
jolt-epoch-all:
	@$(MAKE) epoch-all ZKVM=jolt

download:
	@echo "Running download script..."
	@chmod +x $(DOWNLOAD_SCRIPT)
	@$(DOWNLOAD_SCRIPT)

run:
	@echo "Specify a block operation: $(BLOCK_OPERATIONS)"
	@echo "Specify an epoch operation: $(EPOCH_OPERATIONS)"
	@echo "Use: make run-block-<operation> or make run-epoch-<operation>"
	@exit 1

$(addprefix run-block-, $(BLOCK_OPERATIONS)): run-block-%: $(EXTRACT_DIR)
	@mkdir -p $(LOGS_DIR)
	@mkdir -p $(SUMMARIES_DIR)
	@echo "##################################################"
	@echo "Running block benchmarks for $* using $(ZKVM)..."
	@echo "##################################################"
	@if [ "$(ZKVM)" = "pico" ]; then \
		echo "Using Rust nightly toolchain for Pico..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo +nightly run --release --features pico -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				--excluded-cases multi_proposer_index_iterations \
				--excluded-cases random_with_exits_with_duplicates \
				block $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_block_$*.log; \
	elif [ "$(ZKVM)" = "sp1" ]; then \
		echo "Building with SP1 feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo run --release --features sp1 -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				--excluded-cases multi_proposer_index_iterations \
				--excluded-cases random_with_exits_with_duplicates \
				block $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_block_$*.log; \
	elif [ "$(ZKVM)" = "risc-zero" ]; then \
		echo "Building with RISC0 feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) RISC0_DEV_MODE=$(RISC0_DEV_MODE) \
			cargo run --release --features risc0 -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				--excluded-cases multi_proposer_index_iterations \
				--excluded-cases random_with_exits_with_duplicates \
				block $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_block_$*.log; \
	elif [ "$(ZKVM)" = "zisk" ]; then \
		echo "Building with ZISK feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo run --release --features zisk -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				--excluded-cases multi_proposer_index_iterations \
				--excluded-cases random_with_exits_with_duplicates \
				block $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_block_$*.log; \
	elif [ "$(ZKVM)" = "jolt" ]; then \
		echo "Building with Jolt feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo run --release --features jolt -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				--excluded-cases multi_proposer_index_iterations \
				--excluded-cases random_with_exits_with_duplicates \
				block $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_block_$*.log; \
	else \
		echo "Unknown ZKVM: $(ZKVM)"; \
		exit 1; \
	fi
	@echo "Execution complete for block $* using $(ZKVM)."
	@$(PARSE_SCRIPT) $(ZKVM)_block_$*
	@$(SORT_SCRIPT) $(SUMMARIES_DIR)/summary_$(ZKVM)_block_$*.md

$(addprefix run-epoch-, $(EPOCH_OPERATIONS)): run-epoch-%: $(EXTRACT_DIR)
	@mkdir -p $(LOGS_DIR)
	@mkdir -p $(SUMMARIES_DIR)
	@echo "##################################################"
	@echo "Running epoch processing benchmarks for $* using $(ZKVM)..."
	@echo "##################################################"
	@if [ "$(ZKVM)" = "pico" ]; then \
		echo "Using Rust nightly toolchain for Pico..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo +nightly run --release --features pico -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				epoch $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_epoch_$*.log; \
	elif [ "$(ZKVM)" = "sp1" ]; then \
		echo "Building with SP1 feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo run --release --features sp1 -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				epoch $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_epoch_$*.log; \
	elif [ "$(ZKVM)" = "risc-zero" ]; then \
		echo "Building with RISC0 feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) RISC0_DEV_MODE=$(RISC0_DEV_MODE) \
			cargo run --release --features risc0 -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				epoch $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_epoch_$*.log; \
	elif [ "$(ZKVM)" = "zisk" ]; then \
		echo "Building with ZISK feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo run --release --features zisk -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				epoch $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_epoch_$*.log; \
	elif [ "$(ZKVM)" = "jolt" ]; then \
		echo "Building with Jolt feature only..."; \
		NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
			cargo run --release --features jolt -- \
				--zkvm $(ZKVM) \
				--mode $(MODE) \
				--proof-type $(PROOF_TYPE) \
				epoch $* \
				2>&1 | tee $(LOGS_DIR)/$(MODE)_$(ZKVM)_epoch_$*.log; \
	else \
		echo "Unknown ZKVM: $(ZKVM)"; \
		exit 1; \
	fi
	@echo "Execution complete for epoch $* using $(ZKVM)."
	@$(PARSE_SCRIPT) $(ZKVM)_epoch_$*
	@$(SORT_SCRIPT) $(SUMMARIES_DIR)/summary_$(ZKVM)_epoch_$*.md

clean:
	@echo "Cleaning up downloaded/execution files..."
	@rm -f $(TARGET)
	@rm -rf $(EXTRACT_DIR)
	@rm -rf $(LOGS_DIR)
	@rm -rf $(SUMMARIES_DIR)
	@cargo clean
	@echo "Clean up complete."
