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

.PHONY: all download run clean $(addprefix run-block-, $(BLOCK_OPERATIONS)) $(addprefix run-epoch-, $(EPOCH_OPERATIONS)) block-all epoch-all sp1-block-all sp1-epoch-all risc-zero-block-all risc-zero-epoch-all

# run-block-execution_payload (not implemented) and run-block-withdrawals (incompatible with BeaconState workaround) are excluded
all: download $(addprefix run-block-, $(filter-out execution_payload withdrawals, $(BLOCK_OPERATIONS))) $(addprefix run-epoch-, $(EPOCH_OPERATIONS))

# Run all block processing benchmarks
block-all: $(addprefix run-block-, $(BLOCK_OPERATIONS))

# Run all epoch processing benchmarks
epoch-all: $(addprefix run-epoch-, $(EPOCH_OPERATIONS))

# Run all block processing benchmarks with SP1
sp1-block-all:
	@$(MAKE) block-all ZKVM=sp1

# Run all epoch processing benchmarks with SP1
sp1-epoch-all:
	@$(MAKE) epoch-all ZKVM=sp1

# Run all block processing benchmarks with RISC Zero
risc-zero-block-all:
	@$(MAKE) block-all ZKVM=risc-zero

# Run all epoch processing benchmarks with RISC Zero
risc-zero-epoch-all:
	@$(MAKE) epoch-all ZKVM=risc-zero

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
	@NO_COLOR=1 RISC0_DEV_MODE=$(RISC0_DEV_MODE) RUST_BACKTRACE=$(RUST_BACKTRACE) \
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
	@NO_COLOR=1 RISC0_DEV_MODE=$(RISC0_DEV_MODE) RUST_BACKTRACE=$(RUST_BACKTRACE) \
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
	@echo "Clean up complete."
