| Operation | Test Case | Read Pre-State SSZ | Read Pre-State SSZ Time | Deserialize Pre-State SSZ | Deserialize Pre-State SSZ Time | Read Operation Input | Read Operation Input Time | Process | Process Time | Merkleize | Merkleize Time | Commit | Commit Time | Total Cycles | Execution Time | Execution Time Host Call |
|-----------|-----------|--------------------|-------------------------|---------------------------|--------------------------------|----------------------|---------------------------|---------|--------------|-----------|----------------|--------|-------------|--------------|----------------|--------------------------|
deposit | correct_sig_but_forked_state | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155425 | 0 | 65.064931291 |
deposit | effective_deposit_with_genesis_fork_version | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155425 | 0 | 65.758856667 |
deposit | incorrect_sig_new_deposit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1094115808 | 0 | 67.123759167 |
deposit | incorrect_sig_top_up | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952164370 | 0 | 56.406610208 |
deposit | incorrect_withdrawal_credentials_top_up | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952164370 | 0 | 50.939771708 |
deposit | ineffective_deposit_with_bad_fork_version | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175638437 | 0 | 66.680282791 |
deposit | ineffective_deposit_with_current_fork_version | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175638431 | 0 | 65.077766459 |
deposit | ineffective_deposit_with_previous_fork_version | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175638432 | 0 | 64.1784325 |
deposit | invalid_bad_merkle_proof | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952027286 | 0 | 53.199713417 |
deposit | invalid_wrong_deposit_for_deposit_count | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952027287 | 0 | 52.321478542 |
deposit | key_validate_invalid_decompression | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 991790236 | 0 | 55.247824708 |
deposit | key_validate_invalid_subgroup | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 991789977 | 0 | 53.066498375 |
deposit | new_deposit_eth1_withdrawal_credentials | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155436 | 0 | 66.523428208 |
deposit | new_deposit_max | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155425 | 0 | 63.622167458 |
deposit | new_deposit_non_versioned_withdrawal_credentials | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155429 | 0 | 63.784478958 |
deposit | new_deposit_over_max | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155433 | 0 | 64.821464458 |
deposit | new_deposit_under_max | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1176155452 | 0 | 63.507562667 |
deposit | success_top_up_to_withdrawn_validator | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952231635 | 0 | 50.863735459 |
deposit | top_up__less_effective_balance | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952164370 | 0 | 51.660705709 |
deposit | top_up__max_effective_balance | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952164370 | 0 | 62.275086917 |
deposit | top_up__zero_balance | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 952164370 | 0 | 51.250755417 |
