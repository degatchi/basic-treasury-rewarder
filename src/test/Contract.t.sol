// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Hevm} from "./utils/Hevm.sol";

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import {MockERC20} from "./mocks/ERC20.sol";
import {MockERC721} from "./mocks/ERC721.sol";
import {MockERC1155} from "./mocks/ERC1155.sol";

import {Rewarder} from "../Contract.sol";

/// run test:
/// forge test --fork-url https://api.avax.network/ext/bc/C/rpc --fork-block-number 17065205 -vvv
contract ContractTest is DSTest {
    Hevm internal immutable hevm =
        Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D); // HEVM-ADDRESS

    Utilities internal utils;
    address payable[] internal users;
    address internal deployer;

    MockERC20 internal usdc;
    Rewarder internal rewarder; // Distributes USDC.
    address internal treasury; // Owns USDC.
    address internal user0;
    address internal user1;

    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(2);
        user0 = users[0];
        user1 = users[1];

        usdc = new MockERC20("USDC", "USDC", 18);

        hevm.prank(treasury);
        rewarder = new Rewarder(address(usdc));
    }

    function mintUsdc() public {
        usdc.mint(treasury, 100_000 ether);
    }

    function testDepositEth() public {
        hevm.warp(10);

        hevm.prank(user0);
        rewarder.depositEth{value: 20 ether}();
        assertEq(rewarder.user(user0), 20 ether);

        hevm.prank(user1);
        rewarder.depositEth{value: 5 ether}();
        assertEq(rewarder.user(user1), 5 ether);
    }

    function testReleaseRewards() public {
        mintUsdc();

        hevm.startPrank(treasury);
        usdc.approve(address(rewarder), 100_000 ether);
        rewarder.releaseRewards(treasury);
        assertEq(usdc.balanceOf(address(rewarder)), 1_000e18);
    }

    function testClaimRewards() public {
        testDepositEth();
        testReleaseRewards();

        hevm.prank(user0);
        rewarder.claimRewards();
        assertEq(usdc.balanceOf(address(rewarder)), 200e18);
        assertEq(user0.balance, 100 ether);
        assertEq(usdc.balanceOf(address(user0)), 800e18);

        hevm.prank(user1);
        rewarder.claimRewards();
        assertEq(usdc.balanceOf(address(rewarder)), 0);
        assertEq(user1.balance, 100 ether);
        assertEq(usdc.balanceOf(address(user1)), 200e18);
    }

    function testFailDepositEthAfterClaim() public {
        testReleaseRewards();
        hevm.warp(5);
        hevm.prank(user0);
        rewarder.depositEth{value: 20 ether}();
    }
}
