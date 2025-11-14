| Operation | Test Case | Read Pre-State SSZ | Read Pre-State SSZ Time | Deserialize Pre-State SSZ | Deserialize Pre-State SSZ Time | Read Operation Input | Read Operation Input Time | Process | Process Time | Merkleize | Merkleize Time | Commit | Commit Time | Total Cycles | Execution Time | Execution Time Host Call |
|-----------|-----------|--------------------|-------------------------|---------------------------|--------------------------------|----------------------|---------------------------|---------|--------------|-----------|----------------|--------|-------------|--------------|----------------|--------------------------|
voluntary_exit | basic | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308049 | 0 | 65.165230458 |
voluntary_exit | default_exit_epoch_subsequent_exit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175307515 | 0 | 65.035505125 |
voluntary_exit | exit_existing_churn_and_balance_multiple_of_churn_limit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308153 | 0 | 65.112679541 |
voluntary_exit | exit_existing_churn_and_churn_limit_balance | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308105 | 0 | 64.052379083 |
voluntary_exit | exit_with_balance_equal_to_churn_limit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308048 | 0 | 63.499655667 |
voluntary_exit | exit_with_balance_multiple_of_churn_limit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308157 | 0 | 63.852511125 |
voluntary_exit | invalid_incorrect_signature | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153432 | 0 | 63.844679875 |
voluntary_exit | invalid_validator_already_exited | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 951589554 | 0 | 52.243037958 |
voluntary_exit | invalid_validator_exit_in_future | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 951589559 | 0 | 51.494319291 |
voluntary_exit | invalid_validator_has_pending_withdrawal | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 951622690 | 0 | 51.655130375 |
voluntary_exit | invalid_validator_incorrect_validator_index | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 951589330 | 0 | 52.258494334 |
voluntary_exit | invalid_validator_not_active | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 951589546 | 0 | 51.625493083 |
voluntary_exit | invalid_validator_not_active_long_enough | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 951589766 | 0 | 50.7580615 |
voluntary_exit | invalid_voluntary_exit_with_current_fork_version_is_before_fork_epoch | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153466 | 0 | 64.435568458 |
voluntary_exit | invalid_voluntary_exit_with_current_fork_version_not_is_before_fork_epoch | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153440 | 0 | 61.797568333 |
voluntary_exit | invalid_voluntary_exit_with_genesis_fork_version_is_before_fork_epoch | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153444 | 0 | 64.693439542 |
voluntary_exit | invalid_voluntary_exit_with_genesis_fork_version_not_is_before_fork_epoch | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153422 | 0 | 63.697291 |
voluntary_exit | max_balance_exit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308181 | 0 | 65.322118 |
voluntary_exit | min_balance_exit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308049 | 0 | 61.963377333 |
voluntary_exit | min_balance_exits_above_churn | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308103 | 0 | 63.855034709 |
voluntary_exit | min_balance_exits_up_to_churn | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308050 | 0 | 64.87018474999999 |
voluntary_exit | success_exit_queue__min_churn | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175308109 | 0 | 63.986196042 |
voluntary_exit | voluntary_exit_with_pending_deposit | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175449057 | 0 | 71.094490667 |
voluntary_exit | voluntary_exit_with_previous_fork_version_is_before_fork_epoch | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153432 | 0 | 61.241992458 |
voluntary_exit | voluntary_exit_with_previous_fork_version_not_is_before_fork_epoch | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1175153417 | 0 | 64.409580917 |
