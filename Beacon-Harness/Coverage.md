process_slot not done (priority)
process_epoch : sync committee not done
process_block :
execution_payload not to be done
process_randao not done
process_eth1_data not done
process_deposit_request not done
process_withdrawal_request not done
process_consolidation_request not done
```rust
state_transition(state: &mut BeaconState, block: &SignedBeaconBlock) - A wrapper of process_slots(), verify_block_signature() and process_block()

process_slots(state: &mut BeaconState, slot: block.slot) - A wrapper of 
process_slot() and process_epoch()

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
    process_deposit(state, block.body.deposits);
    process_voluntary_exits(state, block.body.voluntary_exits);
    process_bls_to_execution_change(state, block.body.bls_to_execution_change);
    process_deposit_request(state, block.body.execution_requests.deposits);
    process_attestations(state, block.body.attestations);
    process_withdrawal_requests(state, block.body.execution_requests.withdrawals);
    process_consolidation_requests(state, block.body.execution_requests.consolidations);
    process_sync_aggregate(state, block.body.sync_aggregate);
}

```
