# Basic Treasury Rewarder
> Built by, [DeGatchi](https://github.com/DeGatchi). <br />
> SPDX-License-Identifier: AGPL-3.0-only <br />
> Speedrun: Started 20/09/22 5:54pm; Ended 20/09/22 7:15pm (inc. 20 min call).

---

## Overview

`Clip` is a new DeFi protocol and its main logic is to reward people who deposit ETH into their `Vault` contract. The team calls a function `releaseRewards()`manually from their `Vault` contract which releases 1000 `$USDC` from their treasury address and transfers it to the `Vault` contract every week. This reward is divided between all the users who deposit ETH depending on their weightage and can be claimed by the user by calling `claimRewards()`. 

For example: 

`Alice` and `Bob` deposit 5 ETH and 20 ETH respectively into `Clip` and are waiting to withdraw the rewards at the end of the week. After one week, the `Clip` team calls the `releaseRewards()`

which transfers 1000 `$USDC` from their treasury and `Alice` calls `claimRewards()`, `Alice` gets 200 `$USDC` and the 5 ETH which she deposited. 

And when `Bob` calls `claimRewards()`, he gets 800 `$USDC` and the 20 ETH which he deposited.

Requirements

- [x] Create the `Clip` contract and assume that the treasury has a good amount of `$USDC`
- [x] Add functions `depositEth()`, `releaseRewards()` and `claimRewards()` to the `Vault` contract and any additional functions which you think are required.
- [x] Make sure only the team calls `releaseRewards()`
- [x] Please make sure to add logic for all the edge cases including what will happen if `Alice` deposits and the reward is released for that week and then `Bob` deposits. (Hint: include a time limit for depositing ETH)
- [x] Please assume that the max number of people depositing ETH into the contract every week will not be more than 20 and also the max ETH a person can deposit is 20 ETH.

---

## Tests
> To run the tests, enter the following in the console: `forge clean && forge test -vvv` <br />
```
Running 4 tests for ContractTest.json:ContractTest
[PASS] testClaimRewards() (gas: 237568)
[PASS] testDepositEth() (gas: 91439)
[PASS] testFailDepositEthAfterClaim() (gas: 133332)
[PASS] testReleaseRewards() (gas: 124770)
```

---

## License
This project is open-sourced software licensed under the GNU Affero GPL v3.0 license. See the [License file](LICENSE.md) for more information.
