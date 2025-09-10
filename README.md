# Ream-Beacon-State-Transition-Functions-ZKVM-Benchmarks
**State Transition Function (STF)** is the core logic that updates Ethereum's consensus state:

![alt text](https://github.com/user-attachments/assets/6c746924-f462-4d4a-8a70-f6167f851144)
```
STF: (BeaconState, SignedBeaconBlock) → BeaconState'
```

**Key Components:**
- **Input:** Current `BeaconState` + New `SignedBeaconBlock`
- **Processing:** Validation, attestations, slashings, committee updates
- **Output:** Updated `BeaconState`
---
![alt text](https://github.com/user-attachments/assets/b864cb44-ee6e-47e8-9546-2cb302e12b1e)

```rust
state_transition(state: &mut BeaconState, block: &SignedBeaconBlock) - A wrapper of process_slots(), verify_block_signature() and process_block()

process_slots(state: &mut BeaconState, slot: block.slot) - A wrapper of process_slot() and process_epoch()

process_slot(state: &mut BeaconState, slot: Slot) - Updates the state for a specific slot, including validator updates and committee assignments

fn process_epoch(state: &mut BeaconState) -> anyhow::Result<()> {
    process_justification_and_finalization(state)?;
    process_inactivity_updates(state)?;
    process_rewards_and_penalties(state)?;
    process_registry_updates(state)?;
    process_slashings(state)?;
    process_eth1_data_reset(state)?;
    process_pending_deposits(state)?;
    process_pending_consolidations(state)?;
    process_effective_balance_updates(state)?;
    process_slashings_reset(state)?;
    process_randao_mixes_reset(state)?;
    process_historical_summaries_update(state)?;
    process_participation_flag_updates(state)?;
    process_sync_committee_updatestates()
}

fn process_block(state: &mut BeaconState, block: &SignedBeaconBlock) {
    process_block_header(state, block);
    process_withdrawals(state, block.body.execution_payload);
    process_execution_payload(state, block.body,execution_engine);
    process_randao(state, block.body);
    process_eth1_data(state, block.body);
    process_proposer_slashings(state, block.body.proposer_slashings);
    process_attester_slashings(state, block.body.attester_slashings);
    process_attestations(state, block.body.attestations);
    process_deposits(state, block.body.deposits);
    process_voluntary_exits(state, block.body.voluntary_exits);
    process_bls_to_execution_change(state, block.body.bls_to_execution_change);
    process_deposit_request(state, block.body.execution_requests.deposits);
    process_withdrawal_requests(state, block.body.execution_requests.withdrawals);
    process_consolidation_requests(state, block.body.execution_requests.consolidations);
    process_sync_aggregate(state, block.body.sync_aggregate);
}

```

The benchmarks have been performed on MacBook Air M2 16 GB RAMand are based on the `electra` test suite 

[Consensus-specs](https://github.com/ethereum/consensus-spec-tests/tree/master/tests/mainnet/electra) provides test suites with pre/post state and input.

The zkvms used for benchmarking are 
- [SP1](https://github.com/succinctlabs/sp1)
- [RiscZero](https://github.com/risc0/risc0)
- [Pico](https://github.com/brevis-network/pico/)
- [Jolt](https://github.com/a16z/jolt/)
- OpenVM

Here's the ongoing work 
- [RiscZero](https://github.com/ReamLabs/consenzero-bench/pull/25)
- [Pico](https://github.com/x-senpai-x/consenpico-bench/tree/main/app)
- [Jolt](https://github.com/x-senpai-x/consenJolt/tree/bump-twist/shout)
- [Zisk](https://github.com/x-senpai-x/consenzisk-bench)
- [SP1](https://github.com/ReamLabs/consensp1us/tree/main/lib)
- [OpenVM](https://github.com/DimitriosMitsios/openvm-ream/tree/main/)

