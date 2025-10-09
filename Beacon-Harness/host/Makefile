TARGET = mainnet.tar.gz
EXTRACT_DIR = mainnet
LOGS_DIR = logs
SUMMARIES_DIR = summaries

DOWNLOAD_SCRIPT = ./subscripts/download_ef_data.sh
PARSE_SCRIPT = ./subscripts/parse_log_to_table.sh
SORT_SCRIPT = ./subscripts/sort_table.sh

BLOCK_OPERATIONS = attestation attester_slashing block_header bls_to_execution_change deposit execution_payload proposer_slashing sync_aggregate voluntary_exit withdrawals
EPOCH_OPERATIONS = justification_and_finalization inactivity_updates rewards_and_penalties registry_updates slashings eth1_data_reset pending_deposits pending_consolidations effective_balance_updates slashings_reset randao_mixes_reset historical_summaries_update participation_flag_updates

# zkVM backend: sp1 or risc-zero (default: risc-zero)
ZKVM ?= risc-zero
RISC0_DEV_MODE = 1
RUST_BACKTRACE = full

.PHONY: all help build test download run clean sp1 r0 risc-zero risc-zero-block-all risc-zero-epoch-all $(addprefix run-block-, $(BLOCK_OPERATIONS)) $(addprefix run-epoch-, $(EPOCH_OPERATIONS)) block-all epoch-all sp1-block-all sp1-epoch-all r0-block-all r0-epoch-all

# Default target shows help
help:
	@echo "Beacon Harness Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make <target> [ZKVM=sp1|risc-zero]"
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
	@echo ""
	@echo "Individual operations:"
	@echo "  Block operations: $(BLOCK_OPERATIONS)"
	@echo "  Epoch operations: $(EPOCH_OPERATIONS)"
	@echo ""
	@echo "Examples:"
	@echo "  make run-block-attestation              # Run attestation with default zkVM"
	@echo "  make run-block-attestation ZKVM=sp1     # Run attestation with SP1"
	@echo "  make sp1-block-all                      # Run all block benchmarks with SP1"
	@echo "  make r0-epoch-all                       # Run all epoch benchmarks with RISC Zero"
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
	@NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
		$(if $(filter risc-zero,$(ZKVM)),RISC0_DEV_MODE=$(RISC0_DEV_MODE),) \
		cargo run --release -- \
			--zkvm $(ZKVM) \
			--excluded-cases multi_proposer_index_iterations \
			--excluded-cases random_with_exits_with_duplicates \
			block $* \
			2>&1 | tee $(LOGS_DIR)/execution_$(ZKVM)_block_$*.log
	@echo "Execution complete for block $* using $(ZKVM)."
	@$(PARSE_SCRIPT) $(ZKVM)_block_$*
	@$(SORT_SCRIPT) $(SUMMARIES_DIR)/summary_$(ZKVM)_block_$*.md

$(addprefix run-epoch-, $(EPOCH_OPERATIONS)): run-epoch-%: $(EXTRACT_DIR)
	@mkdir -p $(LOGS_DIR)
	@mkdir -p $(SUMMARIES_DIR)
	@echo "##################################################"
	@echo "Running epoch processing benchmarks for $* using $(ZKVM)..."
	@echo "##################################################"
	@NO_COLOR=1 RUST_BACKTRACE=$(RUST_BACKTRACE) \
		$(if $(filter risc-zero,$(ZKVM)),RISC0_DEV_MODE=$(RISC0_DEV_MODE),) \
		cargo run --release -- \
			--zkvm $(ZKVM) \
			epoch $* \
			2>&1 | tee $(LOGS_DIR)/execution_$(ZKVM)_epoch_$*.log
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
