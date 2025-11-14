| Operation | Test Case | Read Pre-State SSZ | Read Pre-State SSZ Time | Deserialize Pre-State SSZ | Deserialize Pre-State SSZ Time | Read Operation Input | Read Operation Input Time | Process | Process Time | Merkleize | Merkleize Time | Commit | Commit Time | Total Cycles | Execution Time | Execution Time Host Call |
|-----------|-----------|--------------------|-------------------------|---------------------------|--------------------------------|----------------------|---------------------------|---------|--------------|-----------|----------------|--------|-------------|--------------|----------------|--------------------------|
sync_aggregate | invalid_signature_bad_domain | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4324280850 | 0 | 242.300997792 |
sync_aggregate | invalid_signature_extra_participant | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4324280860 | 0 | 243.726746417 |
sync_aggregate | invalid_signature_infinite_signature_with_all_participants | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4322877153 | 0 | 242.105518167 |
sync_aggregate | invalid_signature_infinite_signature_with_single_participant | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1181777054 | 0 | 64.43097975 |
sync_aggregate | invalid_signature_missing_participant | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4311986943 | 0 | 244.157639167 |
sync_aggregate | invalid_signature_no_participants | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1094219680 | 0 | 59.82636275 |
sync_aggregate | invalid_signature_past_block | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4324358015 | 0 | 241.03623725 |
sync_aggregate | random_all_but_one_participating_with_duplicates | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4365688315 | 0 | 240.982304292 |
sync_aggregate | random_high_participation_with_duplicates | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4150544631 | 0 | 232.694960125 |
sync_aggregate | random_low_participation_with_duplicates | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 2767477297 | 0 | 153.936482333 |
sync_aggregate | random_misc_balances_and_half_participation_with_duplicates | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4150398374 | 0 | 230.25904025 |
sync_aggregate | random_only_one_participant_with_duplicates | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1243029105 | 0 | 67.0271265 |
sync_aggregate | sync_committee_rewards_duplicate_committee_full_participation | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4365688315 | 0 | 293.011332042 |
sync_aggregate | sync_committee_rewards_duplicate_committee_half_participation | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 2792065135 | 0 | 156.061504542 |
sync_aggregate | sync_committee_rewards_duplicate_committee_max_effective_balance_only_participate_first_one | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1224588238 | 0 | 67.043826583 |
sync_aggregate | sync_committee_rewards_duplicate_committee_max_effective_balance_only_participate_second_one | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1224588238 | 0 | 67.194784084 |
sync_aggregate | sync_committee_rewards_duplicate_committee_no_participation | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 993065530 | 0 | 54.90637 |
sync_aggregate | sync_committee_rewards_duplicate_committee_zero_balance_only_participate_first_one | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1224588306 | 0 | 68.142891083 |
sync_aggregate | sync_committee_rewards_duplicate_committee_zero_balance_only_participate_second_one | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 1224588307 | 0 | 68.129389292 |
sync_aggregate | sync_committee_rewards_empty_participants | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 993065530 | 0 | 54.467185292 |
sync_aggregate | sync_committee_rewards_not_full_participants | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 2835094792 | 0 | 151.432276042 |
sync_aggregate | sync_committee_with_nonparticipating_exited_member | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4344269886 | 0 | 249.160018083 |
sync_aggregate | sync_committee_with_nonparticipating_withdrawable_member | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4357647982 | 0 | 241.555883917 |
sync_aggregate | sync_committee_with_participating_exited_member | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4362710769 | 0 | 288.114109208 |
sync_aggregate | sync_committee_with_participating_withdrawable_member | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 0 | 0s | 4376088865 | 0 | 248.484646709 |
